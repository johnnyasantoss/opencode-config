#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << 'EOF'
Usage: lmstudio-models.sh [--dry-run] [--reset] [-h]

Options:
  --dry-run   Preview changes without modifying opencode.json
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

log "Fetching models from LM Studio API..."
API_RESPONSE=$(curl -sf http://localhost:1234/api/v1/models) || { log "ERROR: Failed to fetch from LM Studio API"; exit 1; }

log "Processing $(echo "$API_RESPONSE" | jq '.models | length') models..."

# Build provider JSON
PROVIDER=$(echo "$API_RESPONSE" | jq '{
  provider: {
    lmstudio: {
      npm: "@ai-sdk/openai-compatible",
      name: "LM Studio",
      options: { baseURL: "http://localhost:1234/v1" },
      models: (.models 
        | map(select(.type == "llm")) 
        | map({
            key: .key, 
            value: {
              name: ((.display_name | sub("\\s*\\(.*\\)$"; "")) + "@" + (.format // "uknw") + "-" + (.quantization.name // "uknw")),
              variants: { none: { reasoningEffort: "none" }, low: { reasoningEffort: "low" }, medium: { reasoningEffort: "medium" }, high: { reasoningEffort: "high" }, xhigh: { reasoningEffort: "xhigh" } }
            }
          }) 
        | sort_by(.key)
        | from_entries)
    }
  }
}')

MODELS=$(echo "$PROVIDER" | jq '.provider.lmstudio.models')
MODEL_COUNT=$(echo "$MODELS" | jq 'length')

if $RESET; then
  log "Reset mode: Replacing models with $MODEL_COUNT models from API"
  if $DRY_RUN; then
    log "[DRY-RUN] Would update opencode.json"
    jq --argjson models "$MODELS" '.provider.lmstudio.models = $models' opencode.json
  else
    jq --argjson models "$MODELS" '.provider.lmstudio.models = $models' opencode.json > opencode.json.new
    mv opencode.json.new opencode.json
    log "✓ Updated opencode.json with $MODEL_COUNT models"
  fi
else
  log "Merge mode: Merging $MODEL_COUNT models with existing config"
  echo "$PROVIDER" > lmstudio-provider.json
  if $DRY_RUN; then
    log "[DRY-RUN] Would merge with opencode.json"
    node scripts/deep-merge.js opencode.json <(echo "$PROVIDER")
  else
    node scripts/deep-merge.js opencode.json lmstudio-provider.json > opencode.json.new
    mv opencode.json.new opencode.json
    log "✓ Merged into opencode.json"
  fi
fi