# PR Checklist

Use this on every PR (human or agent-authored).

## Scope and clarity

- [ ] PR is small, cohesive, and reviewable.
- [ ] PR description includes **what/why**, not just what changed.
- [ ] User-facing behavior changes are called out.

## Correctness

- [ ] Input validation exists at boundaries.
- [ ] Errors are actionable and safe (no secrets/PII).
- [ ] Edge cases and failure modes considered; no empty catch / fail-open (OWASP A10).
- [ ] Bug fixes: root cause identified and captured, not just symptom patched.

## Tests

- [ ] Tests added/updated for bug fixes and non-trivial logic.
- [ ] Tests cover happy path and key error paths.
- [ ] No flaky tests introduced.

## Security

- [ ] No secrets committed.
- [ ] AuthN/AuthZ enforced where required; SSRF egress controlled for server-side fetches.
- [ ] Security headers / config unchanged or reviewed (OWASP A02).
- [ ] User-influenced errors don't leak internal detail.

## Supply chain (if dependencies or build/release changed)

- [ ] New/updated deps passed `standards/DEPENDENCIES.md` intake; cooldown respected.
- [ ] Lockfile committed; CI uses frozen install.
- [ ] Install scripts reviewed; CI actions pinned to SHA.
- [ ] Release still produces SLSA provenance + SBOM (`standards/SUPPLY_CHAIN.md`).

## AI / agent features (if applicable)

- [ ] Lethal trifecta assessed; least-privilege tools; human approval for irreversible actions.
- [ ] External content treated as untrusted; model output validated before privileged use.
- [ ] Code/shell/DB execution sandboxed; exact logic offloaded to deterministic code.
- [ ] Resource/cost limits and logging in place; AI-BOM updated if shipping AI features.
- [ ] See `standards/AI_AGENT_SECURITY.md`.

## Performance and reliability

- [ ] No obvious O(n^2) or unbounded memory growth.
- [ ] Timeouts/retries are correct and bounded.
- [ ] Idempotency considered for retried operations.
- [ ] Core Web Vitals budgets not regressed (web UI changes).

## Delivery

- [ ] Rollout plan exists for risky changes.
- [ ] Rollback is feasible and documented if needed.
- [ ] Observability added for new critical paths.

