#!/usr/bin/env bash
set -euo pipefail

# Checks that in-repo references to standards/ and templates/ files actually exist.
#
# Only considers tokens wrapped in backticks or markdown link parens whose value
# is exactly a repo-local doc path (standards/... or templates/...). Product-repo
# paths like `docs/coding-standards/standards/INDEX.md` and external URLs are
# ignored because they do not match the anchored pattern.

cd "$(dirname "$0")/.."

fail=0
scanned=0

anchored='^(standards|templates)/[A-Za-z0-9_./-]+\.(md|mdc)$'

while IFS= read -r f; do
  scanned=$((scanned + 1))

  # Candidates: `code spans` and ](link targets)
  while IFS= read -r tok; do
    [[ -z "$tok" ]] && continue
    [[ "$tok" =~ $anchored ]] || continue
    if [[ ! -e "$tok" ]]; then
      echo "::error file=${f}::broken internal link -> ${tok}"
      fail=1
    fi
  done < <(
    {
      grep -oE '`[^`]+`' "$f" | tr -d '`'
      grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//'
    } 2>/dev/null | sort -u || true
  )
done < <(git ls-files '*.md')

if [[ "$fail" -ne 0 ]]; then
  echo "Internal link check FAILED."
  exit 1
fi

echo "Internal link check passed (${scanned} Markdown files scanned)."
