# Coding Standards

These standards optimize for correctness, clarity, testability, and long-term maintainability.

## General

- **Prefer clarity over cleverness**: readable code is faster code to maintain.
- **Keep functions small**: one responsibility, obvious inputs/outputs.
- **Name things precisely**: avoid vague names (`data`, `manager`, `util`) unless scoped.
- **Avoid hidden work**: side effects should be explicit.
- **Do not duplicate logic**: refactor repeated logic into well-named functions.

## Code organization

- Organize by **business capability** first, not by technical type.
- Keep “core” logic independent of frameworks (web, DB, UI).
- Centralize cross-cutting concerns (auth, logging, config).

## Error handling

- Errors must be:
  - **Actionable** (includes what failed, where, and why)
  - **Classified** (e.g., validation vs. dependency vs. unexpected)
  - **Safe** (no secrets, no PII in messages)
- Prefer typed error objects / error codes for boundaries (APIs).
- Add retries only when safe; cap attempts; use jitter.
- **Handle exceptional conditions deliberately** (OWASP Top 10:2025 A10): every error path,
  empty result, timeout, and partial failure has an intended outcome. No empty `catch`, no
  ignored error returns, no fail-open on security-relevant paths. Fail closed and safe.

## Input validation and invariants

- Validate at trust boundaries (API handlers, message consumers, CLI).
- Enforce invariants in the domain layer as a second line of defense.
- Make invalid states unrepresentable when feasible (types, constructors).

## Concurrency and async

- Prefer simple, deterministic designs.
- Avoid shared mutable state.
- When parallelizing, preserve:
  - cancellation
  - timeouts
  - bounded concurrency

## Performance

- Measure before optimizing.
- Prefer algorithmic wins over micro-optimizations.
- Avoid accidental O(n^2) loops and unbounded memory growth.
- Cache deliberately (explicit invalidation and staleness rules).

## Security basics

- Use least privilege.
- Never log secrets or full tokens.
- Sanitize/escape output in UI contexts.
- Use parameterized queries; never string-concatenate SQL.
- Treat all external input as untrusted, including content fetched by tools and agents
  (see `standards/AI_AGENT_SECURITY.md`).

## Fixing bugs

- Establish the **root cause** before writing the fix. Capture the failing inputs, logs,
  and relevant state first.
- No symptom-patching: if you cannot explain *why* the bug happens, you are not ready to
  fix it.
- Lock the fix in with a test that fails before and passes after (`standards/TESTING.md`).

## Documentation

- Document **intent and constraints**, not obvious mechanics.
- Add docs at boundaries: APIs, modules, operational runbooks.

