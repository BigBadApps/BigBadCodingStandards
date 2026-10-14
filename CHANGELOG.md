# Changelog

All notable changes to the shared coding standards are recorded here.
Versioning follows `standards/ROLLOUT.md` (patch = clarifications, minor = new standards,
major = breaking conventions/renames).

## [Unreleased]

## [1.2.0] - 2026-10-14

### Added

- `standards/SECURITY.md`: **SSRF** section (must for server-side fetches). It covers scheme and
  host allow-lists, checking every resolved IP (DNS rebinding), following redirects manually with
  a check on each hop, a blocked-range table including IPv4-mapped, NAT64, and 6to4 addresses,
  and required tests. Upstreamed from BigBadMeals, with the redirect rule corrected.
- `standards/PR_CHECKLIST.md`: SSRF line now requires a guard with tests.

## [1.1.0] - 2026-10-14

### Added — follow-ups

- `tools/check-commits.sh`: checks Conventional Commit subjects (git's default `Revert "..."`
  subjects are allowed) and rejects AI tools as `Co-Authored-By`. Runs on pull requests;
  product repos can run it from the submodule.
- `tools/test-bootstrap.sh`, `tools/test-check-commits.sh`: self-tests, run in CI.

### Changed — follow-ups

- `tools/bootstrap-product-repo.sh`: renders `AGENTS.md`, the Cursor rule, and tool shims
  from `templates/`. It never overwrites existing files or symlinks (it used to overwrite
  the Cursor rule).
- `templates/cursor-rules/coding-standards.mdc`: now only points to `AGENTS.md`, with no
  duplicated rules.
- CI: `actions/checkout` pinned to a commit SHA.
- `standards/AI_GOVERNANCE.md`: EUR-Lex link for Regulation (EU) 2026/1744, the
  2 Dec 2026 Art. 5 prohibitions, and NIST AI 600-1.
- `standards/GIT_CONVENTIONS.md`: each section labelled must or should.

### Added — agent engineering (fourth pass)

- `standards/AI_GOVERNANCE.md`: new. NIST AI RMF and ISO/IEC 42001 mapping, EU AI Act
  timeline as amended by Regulation (EU) 2026/1744, and risk-tier recording rules.
- `standards/PLAYBOOK.md`, `templates/DESIGN.md`, `AGENTS.md`: **spec-first** gate. Design-required
  changes need an approved design with acceptance criteria and a task breakdown.
- `standards/SUPPLY_CHAIN.md`, `standards/DEPENDENCIES.md`: **slopsquatting** defenses.
  AI-suggested packages are verified before install, and agents cannot add dependencies
  without approval.
- `templates/tool-shims/`: new `CLAUDE.shim.md`, `GEMINI.shim.md`, and
  `copilot-instructions.md` shims that point to `AGENTS.md` (rename when copying).
- `standards/TOOLS_AND_AGENTS.md`: nested `AGENTS.md` rule for monorepos, a **parallel
  agents** section, and a Skills note on hallucinated installs.
- `standards/PR_CHECKLIST.md`, `templates/PULL_REQUEST_TEMPLATE.md`, `README.md`,
  `standards/INDEX.md`, `DISTRIBUTION.md`, `standards/PROJECT_CONVENTIONS_WEB.md`: propagated the above.
- **Rollout follow-up for product repos**: copy `templates/tool-shims/` files where tools
  need them, and record EU AI Act risk tiers for shipped AI features.

### Added — agent engineering (third pass)

- `standards/TOOLS_AND_AGENTS.md`: **Deterministic enforcement** (prose < hooks < CI;
  mechanically checkable rules enforced in CI; hooks written to fail closed) and **Agent Skills**
  (`SKILL.md` format, one domain per skill, trigger tests, pinned third-party skills).
- `standards/EVALS.md`: new. Golden-set evals gating merge for AI features, multi-trial
  pass rates, calibrated LLM-as-judge, and evidence-based agent-configuration changes.
- `standards/AI_AGENT_SECURITY.md`: **MCP servers** (tool poisoning, rug pulls,
  cross-server shadowing, OAuth 2.1 + PKCE with audience-bound tokens, server hardening).
- `standards/GIT_CONVENTIONS.md`: **AI attribution** with an `Assisted-by` trailer; no
  `Co-Authored-By` or `Signed-off-by` for AI.
- `standards/PR_CHECKLIST.md`: new Agent engineering section and an eval item.
- `standards/INDEX.md`, `standards/PLAYBOOK.md`, `README.md`, `templates/PROJECT_AGENTS.md`,
  `templates/cursor-rules/coding-standards.mdc`: propagated the above.
- `standards/GIT_CONVENTIONS.md`: added `ci` and `build` commit types.
- `templates/PULL_REQUEST_TEMPLATE.md`: AI assistance field.
- CI: fails on merge-conflict markers (and fails closed on git errors).
- **Rollout follow-up for product repos**: template files are copied, not linked. Repos
  that already copied `templates/PROJECT_AGENTS.md`, the Cursor rule, or the PR template
  must add the new `Assisted-by` and AI-assistance lines by hand. Configure agents to
  emit `Assisted-by` instead of `Co-Authored-By`.

### Added — agent engineering (second pass)

- `standards/ARCHITECTURE.md` — **Deterministic offloading** (keep exact/compliance/DB/math
  logic in reviewed code the model calls, not in the reasoning loop) and **Agent and
  protocol interoperability** (prefer MCP for tools/data, A2A for multi-agent handoffs;
  AAIF governance; keep app logic provider-independent).
- `standards/TOOLS_AND_AGENTS.md` — **Context engineering** (separate static from dynamic
  context, just-in-time retrieval over bulk repo loading, keep `AGENTS.md` lean) and an
  MCP/A2A tool-usage rule.
- `standards/AI_AGENT_SECURITY.md` — **Sandboxed execution** (disposable container/VM, no
  standing prod access, unbypassable human gate for destructive ops), **Agent architecture**
  (orchestrator-worker / scoped sub-agents as a privilege boundary; right-size the model),
  and **AI-BOM** (models/data/prompts/tools inventory via CycloneDX ML-BOM or SPDX 3.0 AI
  Profile; EU AI Act Annex IV). Checklist updated.
- `standards/CODING.md` / `standards/TESTING.md` / `standards/PR_CHECKLIST.md` — **root
  cause before bug fix**: capture failing state, no symptom-patching.
- `standards/FRONTEND_WEB.md` — generated UI must conform to the project design system, not
  default model styling.
- `AGENTS.md` — sharpened "When uncertain": ask when acceptance criteria are ambiguous
  **and** a wrong guess is costly; otherwise default + document.
- `standards/SUPPLY_CHAIN.md` — AI-BOM cross-reference.

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

- `AGENTS.md`, `standards/PLAYBOOK.md`: aligned wording. Tests are written **before**
  implementation (dropped "or alongside"), and `TODO`s are allowed only with a linked issue,
  matching `standards/CODING.md`.
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
