# Tools

These scripts help you roll out shared standards to many projects.

## `bootstrap-product-repo.sh`

Copies starter files from `templates/` into a product repo. It never overwrites an
existing file:

- `docs/coding-standards/` (empty placeholder; you populate via submodule or copy)
- `AGENTS.md` (from `templates/PROJECT_AGENTS.md`)
- `.cursor/rules/coding-standards.mdc` (a pointer to `AGENTS.md`)
- `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md` (shims from
  `templates/tool-shims/`)

Self-test: `bash tools/test-bootstrap.sh`.

Usage:

```bash
tools/bootstrap-product-repo.sh /abs/path/to/product-repo
```

Then add the standards submodule:

```bash
git submodule add https://github.com/BigBadApps/BigBadCodingStandards.git docs/coding-standards
```

## `update-standards-submodules.sh`

Updates standards submodules across multiple repos.

Usage:

```bash
tools/update-standards-submodules.sh /abs/path/to/REPOS.txt
```

Where `REPOS.txt` contains one absolute repo path per line.

## `check-commits.sh`

Checks every non-merge commit in a range. Each subject must be a Conventional Commit, and
no `Co-Authored-By` trailer may name an AI tool (`standards/GIT_CONVENTIONS.md`). CI runs
it on pull requests.

Usage:

```bash
tools/check-commits.sh origin/main HEAD
```

Self-test: `bash tools/test-check-commits.sh`.
