# Tools and Agent Productivity Standards

These standards exist to maximize output quality while minimizing wasted agent time.

## Default agent loop (universal)

- **Restate goal** and define “done” (acceptance criteria + passing tests).
- **Inspect before changing**: read relevant files and current behavior. Locate existing tests for the area you're touching.
- **Write the failing test first** (TDD Red step): express the desired behavior as a test before touching implementation.
- **Implement** with minimal diff and clear structure (TDD Green step).
- **Refactor** without breaking the test (TDD Refactor step).
- **Verify** with the fastest credible tests (then add deeper tests if risk warrants). All tests must pass; lint and typecheck must pass.
- **Summarize** what changed, why, and how to validate.

## Tool usage (general)

- Prefer **repo-native tooling**: existing linters, formatters, test runners, and CI scripts.
- Avoid introducing new dependencies unless:
  - it clearly reduces total complexity
  - it is widely supported and maintained
  - it has a clear owner and upgrade path
- Prefer **MCP** for connecting agents to tools/data over bespoke per-model API wrappers;
  use **A2A** for multi-agent handoffs. Only connect MCP servers / tools from trusted,
  pinned sources (`standards/AI_AGENT_SECURITY.md`).

## Context engineering

Context window space and prompt-cache efficiency are real constraints. Manage them
deliberately.

- **Separate static from dynamic context**:
  - *Static* (coding rules, architecture, API endpoints, conventions) — stable, put it in
    checked-in files (`AGENTS.md`, `standards/`, `docs/`) so it is cache-friendly and
    identical across runs.
  - *Dynamic* (current task, chat state, live file contents, tool output) — changes every
    run; keep it separate and minimal.
- **Just-in-time retrieval over bulk loading**: do not dump the whole repo into context.
  Pull the specific files/sections a step needs, when it needs them.
- **Keep `AGENTS.md` lean**: it is loaded every run. High-signal constraints only; link out
  to `standards/` for detail rather than inlining it.
- Avoid restating the same large context every turn — reference it instead.

## Deterministic enforcement (must)

Agents follow written instructions most of the time, not all of the time. Rules that
matter must be enforced by tooling, not only stated in prose.

Enforcement tiers, weakest to strongest:

1. **Prose**: `AGENTS.md` and `standards/`. Guidance only.
2. **Local hooks and pre-commit**: fast feedback, and blocking of dangerous actions before
   they happen.
3. **CI**: the authoritative gate. Nothing merges without it.

- Any "must" rule that can be checked mechanically is enforced in CI. A rule enforced only
  by prose is not enforced.
- Use agent hooks (for example Claude Code hooks) and pre-commit to block dangerous
  actions: writes to secret files (`.env`, key files), destructive shell commands, and
  edits to protected paths.
- Hooks are code: versioned, reviewed, and tested. Write them to **fail closed**: any
  internal error must block the action. Many tools fail open by default (in Claude Code,
  only exit code 2 or a deny decision blocks; other errors let the action proceed), so
  test the error path. Pre-commit hooks can be skipped with `--no-verify`, so CI remains
  the authoritative gate.
- Hooks do not replace the sandbox. Sandboxed execution in
  `standards/AI_AGENT_SECURITY.md` still applies.

## Agent Skills (must when skills are used)

Agent Skills package task-specific instructions in a `SKILL.md` file that an agent loads
on demand. They keep `AGENTS.md` lean.

- Use the `SKILL.md` format with `name` and `description` frontmatter. The description
  says when the skill applies.
- One skill per task domain. Keep `SKILL.md` under about 5k tokens, and move reference
  material into separate files the skill loads only when needed.
- Write direct commands ("Run the migration check"), not passive descriptions.
- Commit shared skills to the repo so they are reviewed and versioned with the code.
- **Trigger tests**: record 5–10 prompts that should activate the skill and 3–5 that
  should not, next to the skill. Re-check them when the description changes.
- Restrict tools with `allowed-tools` where the agent supports it.
- Third-party skills are dependencies: read the full content before adoption, pin a
  version or commit, and re-review on every update (`standards/AI_AGENT_SECURITY.md`).
- Skill files can carry hallucinated package installs or repository URLs. Review them like
  any other dependency (AI-suggested packages, `standards/SUPPLY_CHAIN.md`).

## Source-of-truth hierarchy

When deciding behavior, use:

1. Product requirements and acceptance criteria
2. Existing tests (they define contracts)
3. Existing public APIs and docs
4. Current runtime behavior (if tests are missing)

## Efficiency patterns

- Batch related work in one pass (read → plan → patch → test).
- Prefer targeted searches over reading many full files.
- When uncertain, add a test or instrumentation to reduce ambiguity.

## Quality gates (recommended defaults)

For every PR:

- Lint/format/typecheck passes
- Unit tests pass
- Risk-based integration/e2e tests (when boundaries change)
- PR template completed with test plan and rollout plan

## Cross-agent consistency

All agents should:

- Use the same definition of “done” (acceptance criteria + tests).
- Write PR summaries in the `templates/PULL_REQUEST_TEMPLATE.md` format.
- Record durable architecture decisions in ADRs (`templates/ADR.md`).
