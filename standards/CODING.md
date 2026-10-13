# Coding Standards

These standards optimize for correctness, clarity, testability, and long-term maintainability.

## General

- **Prefer clarity over cleverness**: readable code is faster to maintain and review.
- **Keep functions small**: one responsibility, obvious inputs/outputs, fits on a screen without scrolling.
- **Name things precisely**: avoid vague names (`data`, `manager`, `util`, `handler`) unless the scope makes them obvious.
- **Avoid hidden work**: side effects must be explicit — never surprise the caller.
- **Do not duplicate logic**: three similar lines is the threshold to extract a well-named function.

## Naming conventions

- **Functions/methods**: verb phrases — `calculateTotal`, `fetchUser`, `isValidEmail`.
- **Booleans**: `is`, `has`, `can`, `should` prefix — `isActive`, `hasPermission`.
- **Collections**: plural nouns — `users`, `orderItems`.
- **Constants**: SCREAMING_SNAKE for module-level constants; camelCase for local constants.
- **Avoid abbreviations** unless they are universally understood in context (`id`, `url`, `http`).
- Names should make the call site readable without needing to look at the definition.

## Comments

Write no comments by default. Add one only when the **why** is genuinely non-obvious: a hidden constraint, a subtle invariant, a workaround for a known bug, or behavior that would surprise a careful reader.

**Do not write comments that:**

- Describe what the code does (the code already does that).
- Reference the current task, PR, or caller (“added for the X flow”, “fixes issue #123”).
- Explain obvious mechanics (“increment counter by 1”).

One short line is the max. Multi-line comment blocks are a code smell — if the code needs that much explanation, restructure it.

## Dead code and unused artifacts

- Remove commented-out code before merging. Version control is the history.
- Remove unused variables, imports, functions, and files immediately.
- Do not add `TODO` comments without a linked issue; resolve them in the same PR or file the issue.

## Type safety

- Enable strict mode wherever the language/toolchain supports it.
- Prefer explicit return types on public functions and module boundaries.
- Avoid `any` (TypeScript) or equivalent escape hatches. If you need one, isolate it and document why.
- Make invalid states unrepresentable: prefer union types / discriminated unions over boolean flags.

## Code organization

- Organize by **business capability** first, not by technical type.
- Keep “core” logic independent of frameworks (web, DB, UI).
- Centralize cross-cutting concerns (auth, logging, config).
- One concept per file for non-trivial modules; avoid barrel files that re-export everything.

## Function discipline

A function should do one thing at one level of abstraction. If you find yourself mixing orchestration with low-level detail in the same function, split it.

- Maximum useful heuristic: if you can't describe what a function does in one sentence without “and”, it does too much.
- Avoid boolean parameters that change behavior — prefer two named functions instead.
- Prefer early returns to deeply nested conditionals.

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
