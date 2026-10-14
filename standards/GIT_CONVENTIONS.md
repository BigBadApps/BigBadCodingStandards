# Git Conventions

Consistent git hygiene makes changes auditable, reviewable, and automatable — especially important for agent-generated work.

## Commit messages (must; CI-enforced: Conventional Commits)

Format: `<type>(<scope>): <short description>`

- The description is lowercase, imperative mood, no trailing period.
- Keep the subject line under 72 characters.
- Add a body only when the "why" is not obvious from the code.

### Types

| Type | When to use |
| ---- | ----------- |
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `test` | Adding or updating tests only |
| `refactor` | Internal restructuring with no behavior change |
| `chore` | Maintenance: deps, config, tooling |
| `ci` | CI workflow changes |
| `build` | Build system or packaging changes |
| `docs` | Documentation only |
| `perf` | Performance improvement |
| `revert` | Reverting a prior commit |

### Examples

```text
feat(auth): add email verification on signup
fix(cart): prevent double-charge when network retries
test(user): cover edge cases for deactivated accounts
refactor(billing): extract invoice calculation to domain layer
chore: upgrade typescript to 5.4
docs(api): document rate-limiting headers
```

### Breaking changes

Add `!` after the type and a `BREAKING CHANGE:` footer:

```text
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/* routes are removed. Use /api/v2/*.
```

## Branch naming (should)

Format: `<type>/<short-slug>`

```text
feat/user-email-verification
fix/cart-double-charge
chore/upgrade-typescript
test/billing-edge-cases
```

- Use hyphens, not underscores or slashes within the slug.
- Keep slugs short (3–5 words max).
- Always branch from `main` for short-lived feature work.

## Commit hygiene (should)

- **One logical change per commit.** Do not bundle unrelated fixes in one commit.
- **Atomic commits**: the code should build and tests should pass at every commit.
- **No "WIP" commits on main-bound PRs.** Squash or rebase before merging if needed.
- **Do not commit**: secrets, generated build artifacts, `.DS_Store`, IDE-specific files.
- Keep `.gitignore` up to date as new tool configs are introduced.

## Agent-authored commits (must)

Agent-generated commits must follow the same conventions as human-authored commits:

- Use the correct `type` prefix — do not default to `chore` for everything.
- The subject line must describe the *change*, not the task ("fix: validate email on signup" not "implement task 3").
- If an agent makes multiple distinct changes in one session, prefer multiple commits over one large commit.

## AI attribution (must; CI rejects AI tools as Co-Authored-By)

Disclose substantive AI assistance with a commit trailer:

```text
Assisted-by: <agent>:<model> [tool ...]
```

Example:

```text
fix(cart): prevent double-charge when network retries

Assisted-by: Claude Code:claude-opus-5-5
```

- The human who ran the agent is the commit author and is accountable for the change.
- Do **not** use `Co-Authored-By` for AI tools. It has CLA and contribution-stats side
  effects.
- AI tools never add `Signed-off-by`. Only humans can certify the DCO.
- PR descriptions state how AI was used.
- Configure each agent's attribution setting to emit `Assisted-by` instead of its
  default trailer (for example, the `attribution` setting in Claude Code's
  `.claude/settings.json`).
- Trivial assistance (a single autocompleted line) does not need a trailer.
