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

PROVIDER_JSON=$(curl -s http://localhost:1234/api/v1/models | jq '{
  provider: {
    lmstudio: {
      npm: "@ai-sdk/openai-compatible",
      name: "LM Studio",
      options: {
        baseURL: "http://localhost:1234/v1"
      },
      models: (.models 
        | map(select(.type == "llm")) 
        | map({
            key: .key, 
            value: {
              name: ((.display_name | sub("\\s*\\(.*\\)$"; "")) + "@" + (
                if .format == null
                then "uknw"
                else .format
                end
              ) + "-" + (
                if .quantization == null
                then "uknw"
                else .quantization.name
                end
              )),
              variants: {
                "none": { reasoningEffort: "none" },
                "low": { reasoningEffort: "low" },
                "medium": { reasoningEffort: "medium" },
                "high": { reasoningEffort: "high" },
                "xhigh": { reasoningEffort: "xhigh" }
              }
            }
          }) 
        | from_entries)
    }
  }
}')

# Extract just the models object
MODELS_JSON=$(echo "$PROVIDER_JSON" | jq '.provider.lmstudio.models')

if [[ "$DRY_RUN" == "true" ]]; then
  if [[ "$RESET" == "true" ]]; then
    jq --argjson models "$MODELS_JSON" '.provider.lmstudio.models = $models' opencode.json
  else
    node scripts/deep-merge.js opencode.json <(echo "$PROVIDER_JSON")
  fi
else
  if [[ "$RESET" == "true" ]]; then
    jq --argjson models "$MODELS_JSON" '.provider.lmstudio.models = $models' opencode.json > opencode.json.new
    mv opencode.json.new opencode.json
  else
    echo "$PROVIDER_JSON" > lmstudio-provider.json
    node scripts/deep-merge.js opencode.json lmstudio-provider.json > opencode.json.new
    mv opencode.json.new opencode.json
  fi
fi