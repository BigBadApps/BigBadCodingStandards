#!/usr/bin/env bash
set -euo pipefail

# Self-test for tools/bootstrap-product-repo.sh using a throwaway directory.

script="$(cd "$(dirname "$0")" && pwd)/bootstrap-product-repo.sh"
repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT

files=(AGENTS.md .cursor/rules/coding-standards.mdc CLAUDE.md GEMINI.md .github/copilot-instructions.md)

bash "$script" "$repo" >/dev/null
for f in "${files[@]}"; do
  [[ -s "$repo/$f" ]] || { echo "FAIL: $f not created"; exit 1; }
done
[[ -d "$repo/docs/coding-standards" ]] || { echo "FAIL: docs/coding-standards not created"; exit 1; }
grep -q '^@AGENTS.md$' "$repo/CLAUDE.md" || { echo "FAIL: CLAUDE.md is not the shim"; exit 1; }
echo "ok: fresh repo gets all files"

echo "custom" > "$repo/.cursor/rules/coding-standards.mdc"
echo "custom" > "$repo/AGENTS.md"
bash "$script" "$repo" >/dev/null
for f in AGENTS.md .cursor/rules/coding-standards.mdc; do
  [[ "$(cat "$repo/$f")" == "custom" ]] || { echo "FAIL: $f was overwritten"; exit 1; }
done
echo "ok: existing files are never overwritten"

if bash "$script" "$repo/missing" >/dev/null 2>&1; then echo "FAIL: missing path accepted"; exit 1; fi
echo "ok: missing repo path is rejected"

echo "All bootstrap tests passed."
