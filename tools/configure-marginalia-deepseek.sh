#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$ROOT/.marginalia-yusu"
ENV_FILE="$RUNTIME_DIR/.env"

API_KEY="${DEEPSEEK_API_KEY:-}"
MODEL="${DEEPSEEK_MODEL:-deepseek-v4-flash}"
BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com}"

if [[ -z "$API_KEY" ]]; then
  echo "Set DEEPSEEK_API_KEY before running this script." >&2
  exit 1
fi

mkdir -p "$RUNTIME_DIR"
touch "$ENV_FILE"

upsert_env() {
  local key="$1"
  local value="$2"
  local tmp
  tmp="$(mktemp)"
  if grep -qE "^${key}=" "$ENV_FILE"; then
    sed -E "s|^${key}=.*|${key}=${value}|" "$ENV_FILE" > "$tmp"
  else
    cat "$ENV_FILE" > "$tmp"
    printf '%s=%s\n' "$key" "$value" >> "$tmp"
  fi
  mv "$tmp" "$ENV_FILE"
}

upsert_env "LLM_DEFAULT_PROVIDER" "openai-compatible"
upsert_env "LLM_DEFAULT_BASE_URL" "$BASE_URL"
upsert_env "LLM_DEFAULT_API_KEY" "$API_KEY"
upsert_env "LLM_DEFAULT_MODEL" "$MODEL"

echo "Configured Marginalia LLM provider: openai-compatible"
echo "Configured Marginalia LLM base URL: $BASE_URL"
echo "Configured Marginalia LLM model: $MODEL"
echo "Secret written only to ignored local file: $ENV_FILE"
