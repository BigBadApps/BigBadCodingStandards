# Testing Standards

Testing protects velocity. The goal is fast feedback and high confidence.

## Test-driven development (TDD) — default workflow

Write the test before the implementation. The cycle is:

1. **Red** — write a failing test that describes the desired behavior.
2. **Green** — write the minimal code to make it pass.
3. **Refactor** — clean up without breaking the test.

This is not optional for new behavior. It produces better-designed, more testable code and makes acceptance criteria machine-verifiable from day one.

**When TDD applies:**

- All new business logic and use cases.
- All bug fixes: reproduce the bug with a test *before* patching it.
- All new API endpoints and data boundaries.

**When TDD is impractical (acceptable exceptions):**

- Exploratory spikes (delete or replace with real tests before merging).
- Pure UI/layout changes with no logic.
- Thin glue code with no conditional paths.

## Testing pyramid (default)

- **Unit tests**: fast, deterministic; cover business rules and edge cases.
- **Integration tests**: verify boundaries (DB, HTTP clients, queues) with realistic wiring.
- **E2E tests**: cover critical user flows; keep count small but high value.

## What must be tested

- Bug fixes: **identify the root cause first**, then reproduce it with a failing test, then
  fix. Capture the failing state (inputs, logs, relevant state/config) before changing
  code — do not patch a symptom you cannot explain.
- Business logic: invariants, edge cases, error paths.
- Boundary behavior: validation, auth/permissions, error mapping, retries/timeouts.
- Data migrations: forward + backward compatibility where relevant.

## Test naming

Names must describe behavior, not implementation. The pattern: **`<unit> <action> <expected outcome>`** or **`should <outcome> when <condition>`**.

```text
// Good
it("calculates total price including tax when region is US")
it("rejects login after 5 failed attempts")
it("returns 404 when user does not exist")

// Bad
it("test price")
it("loginTest")
it("works")
```

## Test quality

- Tests should be:
  - **Deterministic** (no time-dependent flakiness)
  - **Isolated** (no shared state leaking across tests)
  - **Readable** (arrange/act/assert or given/when/then)
  - **Targeted** (assert the behavior, not internal implementation)

## Mocking strategy

Use the real thing unless there is a concrete reason not to. Prefer fakes over mocks when possible.

- **Use real implementations** for: pure functions, domain logic, in-process modules.
- **Use fakes/stubs** for: external HTTP APIs, time, random, email/SMS.
- **Use real databases** (test-scoped) for: database interaction code and migrations. Do not mock the DB — a mock that passes is not a passing integration test.
- **Use mocks sparingly** for: verifying specific interaction contracts (e.g., "did we call the payment gateway once?").

Mock at the boundary, not inside your logic.

## Flakiness rules

- A flaky test is a production outage in slow motion.
- Quarantine only as a short-lived emergency measure with an owner and deadline.
- Fix root cause: timeouts, race conditions, environmental dependencies.

## Coverage guidance

- Use coverage as a **signal**, not a target.
- Prefer high-value coverage of critical logic and failure modes.
- Avoid testing trivial getters/setters or framework internals.

## Test data

- Keep fixtures small and intention-revealing.
- Prefer factories/builders over giant JSON blobs.
- Never use real customer data in tests.
