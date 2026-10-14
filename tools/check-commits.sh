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
# An AI co-author is a trailer whose name starts with an AI tool's name (or is exactly an ambiguous one such as Devin or Gemini), or whose email
# is a known AI bot address. Matching only the name start avoids rejecting humans who
# work at AI companies.
ai_name_re='^((claude|github copilot|copilot|cursor agent|codex|chatgpt|aider)([^a-z]|$)|(devin|gemini|cursor)$)'
ai_email_re='^(noreply@anthropic\.com|.*copilot.*@users\.noreply\.github\.com|cursoragent@cursor\.com)$'

fail=0
while IFS= read -r sha; do
  subject=$(git log -1 --format=%s "$sha")
  if [[ ! "$subject" =~ $subject_re && ! "$subject" =~ ^Revert\ \".+\"$ ]]; then
    echo "::error::${sha:0:7} subject is not a Conventional Commit: ${subject}"
    fail=1
  fi
  body=$(git log -1 --format=%B "$sha")
  while IFS= read -r trailer; do
    name=$(sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]*<.*$//' <<<"$trailer" | tr '[:upper:]' '[:lower:]')
    email=$(sed -nE 's/.*<([^>]*)>.*/\1/p' <<<"$trailer" | tr '[:upper:]' '[:lower:]')
    if [[ "$name" =~ $ai_name_re || "$email" =~ $ai_email_re ]]; then
      echo "::error::${sha:0:7} uses Co-Authored-By for an AI tool; use Assisted-by instead"
      fail=1
    fi
  done < <(grep -iE '^co-authored-by:' <<<"$body" || true)
done < <(git rev-list --no-merges "$1..$2")

if [[ "$fail" -ne 0 ]]; then
  echo "Commit message check FAILED."
  exit 1
fi

echo "Commit message check passed."
