#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << 'EOF'
Usage: lmstudio-models.sh [--dry-run] [--reset] [-h]

Options:
  --dry-run   Preview changes without modifying config
  --reset     Replace models field with API response (don't merge)
  -h, --help  Show this help message
EOF
}

log() { echo "[$0] $*" >&2; }

# Parse flags
DRY_RUN=false RESET=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --reset) RESET=true ;;
    -h|--help) usage; exit 0 ;;
  esac
done

# Find config file (prefer .jsonc, fall back to .json)
CONFIG_FILE="${CONFIG_FILE:-}"
if [[ -z "$CONFIG_FILE" ]]; then
  for f in opencode.offline.jsonc opencode.offline.json opencode.override.jsonc opencode.override.jsonc opencode.override.json opencode.jsonc opencode.json; do
    if [[ -f "$f" ]]; then CONFIG_FILE="$f"; break; fi
  done
  [[ -z "$CONFIG_FILE" ]] && { log "ERROR: No opencode.override.jsonc, opencode.override.json, opencode.jsonc or opencode.json found"; exit 1; }
fi

# Read JSONC: strips // comments (inline + whole-line) and trailing commas
read_jsonc() {
  local file="$1"; shift
  sed -e 's|\([[:space:]]\)//.*|\1|' \
    -e 's|^[[:space:]]*//.*||' \
    -e ':a' -e 's|,\([[:space:]]*[}\]]\)|\1|;ta' \
    "$file" | jq "$@"
}

# Get API URL from config, fall back to localhost:1234
BASE_URL=$(read_jsonc "$CONFIG_FILE" -r '.provider.lmstudio.options.baseURL // empty' 2>/dev/null || true)
API_URL="${BASE_URL:-http://localhost:1234}"
API_URL="${API_URL%/v1}/api/v1/models"

# Fetch models
log "Fetching models from $API_URL ..."
API_RESPONSE=$(curl -sf "$API_URL") || { log "ERROR: Failed to fetch from LM Studio API"; exit 1; }

MODEL_COUNT=$(echo "$API_RESPONSE" | jq '[.models[] | select(.type == "llm")] | length')
log "Processing $MODEL_COUNT models..."

# Build provider patch (models only — preserves existing npm/name/options)
PROVIDER=$(echo "$API_RESPONSE" | jq '{
  provider: {
    lmstudio: {
      models: (.models
        | map(select(.type == "llm"))
        | map({
            "key": .key,
            value: {
              name: ((.display_name | sub("\\s*\\(.*\\)$"; "")) + "@" + (.format // "uknw") + "-" + (.quantization.name // "uknw")),
              limit: {
                context: .max_context_length,
                output: ([32768, .max_context_length] | min)
              }
            } + (if .capabilities.vision then {modalities: {input: ["image", "text"], output: ["text"]}} else {} end)
          })
        | sort_by(.key)
        | from_entries)
    }
  }
}')

MODELS=$(echo "$PROVIDER" | jq '.provider.lmstudio.models')

if $RESET; then
  log "Reset mode: Replacing models with $MODEL_COUNT models from API"
  if $DRY_RUN; then
    log "[DRY-RUN] Would update $CONFIG_FILE"
    read_jsonc "$CONFIG_FILE" --argjson models "$MODELS" '.provider.lmstudio.models = $models'
  else
    read_jsonc "$CONFIG_FILE" --argjson models "$MODELS" '.provider.lmstudio.models = $models' > "$CONFIG_FILE.new"
    mv "$CONFIG_FILE.new" "$CONFIG_FILE"
    log "✓ Updated $CONFIG_FILE with $MODEL_COUNT models"
  fi
else
  log "Merge mode: Merging $MODEL_COUNT models with existing config"
  if $DRY_RUN; then
    log "[DRY-RUN] Would merge with $CONFIG_FILE"
    node scripts/deep-merge.js "$CONFIG_FILE" <(echo "$PROVIDER")
  else
    node scripts/deep-merge.js "$CONFIG_FILE" <(echo "$PROVIDER") > "$CONFIG_FILE.new"
    mv "$CONFIG_FILE.new" "$CONFIG_FILE"
    log "✓ Merged into $CONFIG_FILE"
  fi
fi
