# PR Checklist

Use this on every PR (human or agent-authored).

## Scope and clarity

- [ ] PR is small, cohesive, and reviewable.
- [ ] PR description includes **what/why**, not just what changed.
- [ ] User-facing behavior changes are called out.
- [ ] Non-trivial change has an approved design (`templates/DESIGN.md`).

## Correctness

- [ ] Input validation exists at boundaries.
- [ ] Errors are actionable and safe (no secrets/PII).
- [ ] Edge cases and failure modes considered; no empty catch / fail-open (OWASP A10).
- [ ] Bug fixes: root cause identified and captured, not just symptom patched.

## Tests

- [ ] Failing test written before implementation for new behavior/bug fixes (TDD).
- [ ] Tests added/updated for bug fixes and non-trivial logic.
- [ ] Tests cover happy path and key error paths.
- [ ] No flaky tests introduced.
- [ ] Test names describe the expected behavior, not the implementation.

## Security

- [ ] No secrets committed.
- [ ] AuthN/AuthZ enforced where required; SSRF egress controlled for server-side fetches.
- [ ] Security headers / config unchanged or reviewed (OWASP A02).
- [ ] User-influenced errors don't leak internal detail.

## Supply chain (if dependencies or build/release changed)

- [ ] New/updated deps passed `standards/DEPENDENCIES.md` intake; cooldown respected.
- [ ] AI-suggested packages verified to exist; publisher, age, and downloads checked.
- [ ] Lockfile committed; CI uses frozen install.
- [ ] Install scripts reviewed; CI actions pinned to SHA.
- [ ] Release still produces SLSA provenance + SBOM (`standards/SUPPLY_CHAIN.md`).

## AI / agent features (if applicable)

- [ ] Lethal trifecta assessed; least-privilege tools; human approval for irreversible actions.
- [ ] External content treated as untrusted; model output validated before privileged use.
- [ ] Code/shell/DB execution sandboxed; exact logic offloaded to deterministic code.
- [ ] Resource/cost limits and logging in place; AI-BOM updated if shipping AI features.
- [ ] Eval suite passes for prompt/model/tool/retrieval changes (`standards/EVALS.md`).
- [ ] EU AI Act risk tier recorded (`standards/AI_GOVERNANCE.md`).
- [ ] See `standards/AI_AGENT_SECURITY.md`.

## Agent engineering (if applicable)

- [ ] Mechanically checkable "must" rules are enforced in CI or hooks, not prose alone.
- [ ] Hooks are versioned, tested (including the error path), and fail closed.
- [ ] New/changed skills follow `SKILL.md` format, stay focused, and are trigger-tested;
  `allowed-tools` set where supported; third-party skills reviewed and pinned.
- [ ] MCP servers pinned; tool definitions reviewed or diffed (`standards/AI_AGENT_SECURITY.md`).
- [ ] MCP servers we build use strict input schemas and audit-log tool calls.
- [ ] Agent-configuration changes cite the failure they prevent (`standards/EVALS.md`).
- [ ] Substantively AI-assisted commits carry an `Assisted-by` trailer (`standards/GIT_CONVENTIONS.md`).
- [ ] Parallel agent work uses separate branches with disjoint files.

## Performance and reliability

- [ ] No obvious O(n^2) or unbounded memory growth.
- [ ] Timeouts/retries are correct and bounded.
- [ ] Idempotency considered for retried operations.
- [ ] Core Web Vitals budgets not regressed (web UI changes).

## Delivery

- [ ] Rollout plan exists for risky changes.
- [ ] Rollback is feasible and documented if needed.
- [ ] Observability added for new critical paths.
