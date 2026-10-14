#!/usr/bin/env bash
set -euo pipefail

# Checks commit messages in a range against standards/GIT_CONVENTIONS.md:
# - the subject is a Conventional Commit: <type>(<scope>)!: <description>
# - no Co-Authored-By trailer names an AI tool (use Assisted-by instead)
#
# Usage: tools/check-commits.sh <base> <head>
# Merge commits are skipped.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <base> <head>" >&2
  exit 2
fi

for ref in "$1" "$2"; do
  if ! git rev-parse --verify -q "$ref^{commit}" >/dev/null; then
    echo "Unknown ref: $ref" >&2
    exit 2
  fi
done

types='feat|fix|test|refactor|chore|ci|build|docs|perf|revert'
subject_re="^(${types})(\([a-z0-9._/-]+\))?!?: .+"
ai_coauthor_re='^co-authored-by:.*(claude|anthropic|copilot|codex|openai|gemini|cursor)'

fail=0
while IFS= read -r sha; do
  subject=$(git log -1 --format=%s "$sha")
  if [[ ! "$subject" =~ $subject_re ]]; then
    echo "::error::${sha:0:7} subject is not a Conventional Commit: ${subject}"
    fail=1
  fi
  body=$(git log -1 --format=%B "$sha")
  if grep -qiE "$ai_coauthor_re" <<<"$body"; then
    echo "::error::${sha:0:7} uses Co-Authored-By for an AI tool; use Assisted-by instead"
    fail=1
  fi
done < <(git rev-list --no-merges "$1..$2")

if [[ "$fail" -ne 0 ]]; then
  echo "Commit message check FAILED."
  exit 1
fi

echo "Commit message check passed."
