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
git config commit.gpgsign false
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

git commit -q --allow-empty -m "fix: pair work" -m "Co-Authored-By: Sam Lee <sam@anthropic.com>"
expect pass "human co-author with an AI-company email"
git commit -q --allow-empty -m "fix: pair work" -m "Co-Authored-By: Devin Patel <devin@example.com>"
expect pass "human whose first name is an AI tool name"

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

base=$(git rev-parse HEAD)
git commit -q --allow-empty -m "fix: thing" -m "co-authored-by: GitHub Copilot <175728472+Copilot@users.noreply.github.com>"
expect fail "lowercase trailer naming GitHub Copilot"

base=$(git rev-parse HEAD)
git commit -q --allow-empty -m "feat: "
expect fail "subject with no description"

set +e
bash "$script" no-such-ref HEAD >/dev/null 2>&1
rc=$?
set -e
[[ "$rc" -eq 2 ]] || { echo "FAIL: unknown ref (expected exit 2, got $rc)"; exit 1; }
echo "ok: unknown ref is rejected with exit 2"

echo "All check-commits tests passed."
