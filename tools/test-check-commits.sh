#!/usr/bin/env bash
set -euo pipefail

# Self-test for tools/check-commits.sh using a throwaway git repo.

script="$(cd "$(dirname "$0")" && pwd)/check-commits.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q -b main
git config user.email test@example.com
git config user.name test
git commit -q --allow-empty -m "chore: base"
base=$(git rev-parse HEAD)

expect() { # expect <pass|fail> <description>
  if bash "$script" "$base" HEAD >/dev/null 2>&1; then got=pass; else got=fail; fi
  if [[ "$got" != "$1" ]]; then echo "FAIL: $2 (expected $1, got $got)"; exit 1; fi
  echo "ok: $2"
}

git commit -q --allow-empty -m "docs(git): add policy" -m "Assisted-by: Claude Code:claude-opus-5-5"
expect pass "conventional subject with Assisted-by"

git commit -q --allow-empty -m "feat(api)!: drop v1" -m "Co-Authored-By: Jane Doe <jane@example.com>"
expect pass "breaking change with a human co-author"

git checkout -q -b side
git commit -q --allow-empty -m "fix: side work"
git checkout -q main
git merge -q --no-ff --no-edit side
expect pass "merge commit is skipped"

base=$(git rev-parse HEAD)
git commit -q --allow-empty -m "Update stuff"
expect fail "non-conventional subject"

base=$(git rev-parse HEAD)
git commit -q --allow-empty -m "fix: thing" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
expect fail "AI tool as co-author"

if bash "$script" no-such-ref HEAD >/dev/null 2>&1; then echo "FAIL: bad ref accepted"; exit 1; fi
echo "ok: unknown ref is rejected"

echo "All check-commits tests passed."
