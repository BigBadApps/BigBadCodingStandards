# Standards Rollout (Submodule-Based)

This document defines the recommended way to **publish, pin, and roll out** updates to shared standards across many projects.

## Canonical repository

- This standards repo is the **source of truth**.
- Canonical GitHub org/repo: `BigBadApps/BigBadCodingStandards`
- Canonical URL: `https://github.com/BigBadApps/BigBadCodingStandards.git`
- Publish it to GitHub and use **tags** (e.g. `v1.0.0`) to create stable versions.

## In each product repo

- Add this standards repo as a git submodule at:
  - `docs/coding-standards/`
- Add a project-local `AGENTS.md` that points agents to:
  - `docs/coding-standards/AGENTS.md`
  - `docs/coding-standards/standards/INDEX.md`
- (Cursor) Commit `.cursor/rules/coding-standards.mdc` so Cursor always applies the rule.

## Publishing an update (standards repo)

1. Make changes on a branch. Record each change under `## [Unreleased]` in `CHANGELOG.md`.
2. Verify docs are consistent.
3. Merge to `main`.
4. Pick the version `vX.Y.Z` by the largest change since the last tag:
   - **patch** for clarifications/small guidance
   - **minor** for new standards/templates
   - **major** for breaking conventions/renames
5. Open a release PR that adds `## [X.Y.Z] - YYYY-MM-DD` directly below `## [Unreleased]`,
   so the unreleased entries now sit under the new version, and merge it.
6. Only then tag the merge commit and push the tag:

   ```bash
   git fetch origin && git tag vX.Y.Z origin/main && git push origin vX.Y.Z
   ```

   Check the tag holds the release before announcing it:
   `git show vX.Y.Z:CHANGELOG.md | grep -n '## \[X.Y.Z\]'`.

Never move or re-push a published tag. If a tag points at the wrong commit, delete it only if
nobody can have fetched it yet; otherwise ship the fix as the next patch version.

## Rolling out an update (product repos)

For each product repo:

1. Update the submodule to the desired tag/commit.
2. Commit the submodule pointer bump.
3. Open a PR with:
   - summary of what standards changed
   - any required follow-ups (e.g. new CI gate to add)

Use this setup command when adding the submodule initially:

`git submodule add https://github.com/BigBadApps/BigBadCodingStandards.git docs/coding-standards`

### Recommended: scripted bump across repos

Use `tools/bump-standards-submodule.sh` with a repo list file (one repo path per line).

## Important notes

- Submodules pin an exact commit. This is **intentional**: rollouts stay auditable and reversible.
- Do not auto-update standards on every build; that creates surprise breakages.
- Prefer periodic rollout cadence (e.g. weekly) or per-need updates.
