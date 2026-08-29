# Changelog

All notable changes to the shared coding standards are recorded here.
Versioning follows `standards/ROLLOUT.md` (patch = clarifications, minor = new standards,
major = breaking conventions/renames).

## [Unreleased]

### Added

- `standards/SUPPLY_CHAIN.md` — software supply chain standard: dependency intake and
  cooldown, frozen installs, provenance / Trusted Publishing, build/publish separation,
  SLSA build provenance, SBOM (SPDX/CycloneDX), OpenSSF Scorecard, monitoring and
  response. Reflects OWASP Top 10:2025 A03.
- `standards/AI_AGENT_SECURITY.md` — security for LLM/agentic product features and for
  working with coding agents on our repos: the "lethal trifecta", prompt injection,
  excessive agency / least privilege, human approval for irreversible actions, memory and
  context integrity, AI supply chain, observability and kill switch. Reflects OWASP Top 10
  for LLM Applications (2025) and for Agentic Applications (2026).
- `CHANGELOG.md`.

### Changed

- `standards/SECURITY.md` — aligned to OWASP Top 10:2025: SSRF under Broken Access Control,
  new Configuration hardening section (A02), new Handling exceptional conditions section
  (A10), phishing-resistant auth, security headers, supply chain pointer.
- `standards/ACCESSIBILITY_WEB.md` — explicit conformance target **WCAG 2.2 Level AA**;
  added the WCAG 2.2 new criteria (target size 24px, focus not obscured, dragging
  alternatives, accessible authentication, consistent help, redundant entry); numeric
  contrast ratios; stronger testing expectations; note on WCAG 3.0 status.
- `standards/PERFORMANCE_WEB.md` — explicit Core Web Vitals targets (LCP ≤2.5s, INP ≤200ms,
  CLS ≤0.1) on p75 field data; concrete JS/image budgets; field + lab measurement guidance.
- `standards/DEPENDENCIES.md` — frozen/CI installs, adoption cooldown, provenance
  preference, OpenSSF Scorecard, runtime/toolchain version policy (supported LTS only),
  pointer to `SUPPLY_CHAIN.md`.
- `standards/CODING.md` — added OWASP A10 exceptional-conditions rule; untrusted-input note
  for agent-fetched content; fixed broken LaTeX rendering (`\(O(n^2)\)` → `O(n^2)`).
- `standards/PR_CHECKLIST.md` — added Supply chain and AI/agent sections; SSRF, security
  config, Core Web Vitals items; fixed broken LaTeX rendering.
- `standards/PLAYBOOK.md` — verify step adds dependency/accessibility/CWV checks and agent
  evaluation; deliver step requires provenance + SBOM.
- `standards/DELIVERY.md` — new Secure releases section.
- `standards/INDEX.md`, `README.md` — link the new security standards; corrected
  descriptions (WCAG 2.2 AA, Core Web Vitals, OWASP Top 10:2025).
- `AGENTS.md` — declared alignment with the AGENTS.md open standard; added non-negotiables
  for untrusted external content, least privilege, human approval for irreversible actions,
  and supply chain discipline.
- `templates/PULL_REQUEST_TEMPLATE.md`, `templates/PROJECT_AGENTS.md`,
  `templates/cursor-rules/coding-standards.mdc` — propagated the above.

## [1.0.0]

- Initial standards repository.
