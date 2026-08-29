# Tools and Agent Productivity Standards

These standards exist to maximize output quality while minimizing wasted agent time.

## Default agent loop (universal)

- **Restate goal** and define “done”.
- **Inspect before changing**: read relevant files and current behavior.
- **Propose the smallest safe change** that achieves the goal.
- **Implement** with minimal diff and clear structure.
- **Verify** with the fastest credible tests (then add deeper tests if risk warrants).
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
