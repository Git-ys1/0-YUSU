#!/usr/bin/env bash
set -euo pipefail

kb_root="${1:-${YUSU_KB_ROOT:-}}"

if [[ -z "$kb_root" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  kb_root="$(cd "$script_dir/.." && pwd)"
fi

if [[ ! -f "$kb_root/00_START_HERE_FOR_CODEX.md" ]]; then
  echo "Cannot find YUSU KB root: $kb_root" >&2
  exit 1
fi

mkdir -p "$HOME/.agents/skills" "$HOME/.codex/skills"
ln -sfn "$kb_root/.agents/skills/yusu-kb" "$HOME/.agents/skills/yusu-kb"
ln -sfn "$kb_root/.agents/skills/yusu-kb" "$HOME/.codex/skills/yusu-kb"

profile_line="export YUSU_KB_ROOT=\"$kb_root\""
if [[ -f "$HOME/.bashrc" ]]; then
  if ! grep -Fq "YUSU_KB_ROOT=" "$HOME/.bashrc"; then
    printf '\n%s\n' "$profile_line" >> "$HOME/.bashrc"
  fi
fi
export YUSU_KB_ROOT="$kb_root"

mkdir -p "$HOME/.codex"
agents_path="$HOME/.codex/AGENTS.md"
touch "$agents_path"

begin="<!-- BEGIN YUSU_KB_SHARED -->"
end="<!-- END YUSU_KB_SHARED -->"
tmp="$(mktemp)"
awk -v begin="$begin" -v end="$end" '
  $0 == begin { skip=1; next }
  $0 == end { skip=0; next }
  skip != 1 { print }
' "$agents_path" > "$tmp"

cat >> "$tmp" <<EOF

$begin
## Shared YUSU Knowledge Vault

Use the shared Codex knowledge vault at \`YUSU_KB_ROOT\`, currently \`$kb_root\`.

Before non-trivial project work:
1. Read \`$kb_root/00_START_HERE_FOR_CODEX.md\`.
2. Read \`$kb_root/04_Runbooks/system-decisions.md\`.
3. Use the \`yusu-kb\` skill when available.
4. Search project and cross-project memory before editing.

After non-trivial project work:
1. Update reusable project memory in the shared vault.
2. Do not use local \`.codex/memories\` as the manual canonical store.
3. Never write secrets, credentials, private tokens, cookies, private keys, or raw private data.
$end
EOF

mv "$tmp" "$agents_path"

echo "YUSU_KB_ROOT=$kb_root"
echo "Skill .agents: $HOME/.agents/skills/yusu-kb"
echo "Skill .codex:  $HOME/.codex/skills/yusu-kb"
echo "AGENTS:        $agents_path"

