#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a product repo to reference shared standards locally.
#
# Usage:
#   tools/bootstrap-product-repo.sh /absolute/path/to/product-repo
#
# Copies starter files from this repo's templates/ into the product repo.
# Existing files are never overwritten.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /absolute/path/to/product-repo" >&2
  exit 1
fi

repo="$1"
if [[ ! -d "$repo" ]]; then
  echo "Repo path not found: $repo" >&2
  exit 1
fi

templates="$(cd "$(dirname "$0")/.." && pwd)/templates"

install_file() { # install_file <template path> <destination relative to repo>
  local src="$templates/$1" dest="$repo/$2"
  if [[ -e "$dest" ]]; then
    echo "- skipped $2 (already exists)"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "- created $2"
}

echo "Bootstrapping $repo:"
mkdir -p "$repo/docs/coding-standards"
install_file PROJECT_AGENTS.md AGENTS.md
install_file cursor-rules/coding-standards.mdc .cursor/rules/coding-standards.mdc
install_file tool-shims/CLAUDE.shim.md CLAUDE.md
install_file tool-shims/GEMINI.shim.md GEMINI.md
install_file tool-shims/copilot-instructions.md .github/copilot-instructions.md
echo "- docs/coding-standards/ (populate via submodule or copy)"
