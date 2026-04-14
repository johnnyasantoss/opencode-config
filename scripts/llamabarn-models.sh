#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
RESET=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --reset)
      RESET=true
      ;;
    -h|--help)
      echo "Usage: ${0##*/} [--dry-run] [--reset] [-h]"
      echo ""
      echo "Options:"
      echo "  --dry-run   Preview changes without modifying opencode.json"
      echo "  --reset     Replace models field with API response (don't merge)"
      echo "  -h, --help  Show this help message"
      exit 0
      ;;
  esac
done

PROVIDER_JSON=$(curl -s http://localhost:2276/v1/models | jq '{
  provider: {
    llamabarn: {
      npm: "@ai-sdk/openai-compatible",
      name: "LlamaBarn (llama.cpp server)",
      options: {
        baseURL: "http://localhost:2480"
      },
      models: (.data | map({
        key: .id,
        value: {
          name: .id
        }
      }) | from_entries)
    }
  }
}')

# Extract just the models object
MODELS_JSON=$(echo "$PROVIDER_JSON" | jq '.provider.llamabarn.models')

if [[ "$DRY_RUN" == "true" ]]; then
  if [[ "$RESET" == "true" ]]; then
    jq --argjson models "$MODELS_JSON" '.provider.llamabarn.models = $models' opencode.json
  else
    node scripts/deep-merge.js opencode.json <(echo "$PROVIDER_JSON")
  fi
else
  if [[ "$RESET" == "true" ]]; then
    jq --argjson models "$MODELS_JSON" '.provider.llamabarn.models = $models' opencode.json > opencode.json.new
    mv opencode.json.new opencode.json
  else
    echo "$PROVIDER_JSON" > llamabarn-provider.json
    node scripts/deep-merge.js opencode.json llamabarn-provider.json > opencode.json.new
    mv opencode.json.new opencode.json
  fi
fi