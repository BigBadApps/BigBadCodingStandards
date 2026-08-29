# AI and Agent Security Standards

This organization builds software **with** coding agents and sometimes ships products that
**contain** LLM or agentic features. Both cases introduce a class of risk that traditional
application security does not fully cover.

This standard reflects the **OWASP Top 10 for LLM Applications (2025)** and the **OWASP Top
10 for Agentic Applications (2026)**, plus the Five Eyes joint guidance on securing AI
systems. It applies to:

- Coding agents operating on our repositories (Claude Code, Codex, Gemini CLI, Cline, Aider, etc.).
- Product features that call an LLM or run an autonomous/multi-step agent.

## Core principle: the lethal trifecta

An agent is exploitable when it combines **all three** of:

1. Access to **private or sensitive data**.
2. Exposure to **untrusted content** (web pages, issues, PR comments, emails, tool output,
   scraped text, documents).
3. The ability to **communicate externally** (network calls, posting comments, sending
   messages, opening PRs, writing to shared stores).

Remove or gate at least one leg of the trifecta for any given task. If all three are
present, a human must be in the loop for the externally-visible action.

## Prompt injection (must)

- Treat **all external content as untrusted instructions**, not just data. This includes
  file contents, dependency READMEs, issue/PR text, web search results, API responses, and
  the output of tools the agent runs.
- Never let untrusted content silently change the agent's objective, permissions, or tool
  use.
- Keep a **trust boundary** between the system/developer instructions and any fetched
  content. Fetched content is quoted input, never elevated to policy.
- For product LLM features:
  - Constrain output with schemas / structured responses where possible.
  - Validate and sanitize model output **before** it is used in a privileged context
    (shell, SQL, DOM, file writes, downstream API calls) — same rules as any other
    untrusted input in `standards/SECURITY.md`.
  - Do not put secrets, credentials, or another user's data in the model context unless the
    task genuinely requires it.

## Excessive agency and least privilege (must)

- Give an agent the **smallest set of tools** and the **narrowest permissions** the task
  requires. No broad filesystem, network, or credential access "just in case".
- Scope credentials used by agents: read-only where possible, short-lived, and revocable.
- **Irreversible or outward-facing actions require explicit human approval**: publishing
  releases, deleting data, sending external messages, merging, rotating infra, spending
  money, changing access control. Approval in one context does not carry to the next.
- Default to **dry-run / propose-a-diff** modes. The agent proposes; a human or a gated
  pipeline applies.
- Bound resource use: cap iterations, tool calls, tokens, and wall-clock time to prevent
  unbounded consumption (cost and denial-of-service).

## Sandboxed execution (must)

Agents that run code, shell commands, database operations, or migrations do so in an
**isolated, disposable environment** — never directly on a developer machine or a
production host.

- Use a container or ephemeral VM with:
  - no standing access to production credentials or data,
  - egress restricted to an allow-list,
  - a filesystem scoped to the workspace,
  - resource and time limits.
- The environment is **disposable**: destroy and recreate it per task; do not carry state
  between untrusted runs.
- Actions that leave the sandbox (push, deploy, publish, send, pay, delete) go through the
  human-approval / gated-pipeline path above, not directly from the agent.
- Destructive operations require a hardcoded human-in-the-loop validation step that cannot
  be bypassed by agent instructions.

## Agent architecture (must)

- Prefer **orchestrator-worker / hierarchical decomposition** over one monolithic agent
  loop: a coordinator delegates narrow sub-tasks to smaller, tightly-scoped agents.
- Each sub-agent gets **only the tools and context its sub-task needs** — decomposition is
  a privilege-containment boundary, not just a performance trick.
- Match model size/cost to the sub-task; do not run every step on the largest model.
- Keep fragile or exact logic out of the reasoning loop entirely — see Deterministic
  offloading in `standards/ARCHITECTURE.md`.

## Memory and context integrity (must)

- Do not persist untrusted content into long-lived agent memory / context stores without
  review — poisoned memory re-injects the attack on every later run.
- Treat retrieved documents (RAG) as untrusted; the retrieval layer must not be able to
  override instructions.
- Isolate context between tasks and between users/tenants.

## Supply chain for AI (must)

- Models, prompts, skills, MCP servers, and agent plugins are dependencies. Apply
  `standards/SUPPLY_CHAIN.md`: known origin, pinned versions, review before adoption,
  least privilege.
- Only connect MCP servers / tools from sources you trust. A malicious tool server sees
  everything the agent sends it.

## AI Bill of Materials (must for shipped AI features)

For any product feature that ships an LLM or agent in the loop, maintain an **AI-BOM**
alongside the normal SBOM (`standards/SUPPLY_CHAIN.md`):

- Track: models and versions, datasets / knowledge sources and their lineage, system
  prompts and prompt templates (versioned), tools / MCP servers, and the guardrail config.
- Use a machine-readable format: **CycloneDX ML-BOM** (CI/CD automation) or **SPDX 3.0 AI
  Profile** (regulatory weight).
- Refresh on initial release and on every material change (model swap, prompt change, new
  data source).
- This is increasingly a **regulatory and procurement requirement** (e.g. EU AI Act Annex
  IV technical documentation for high-risk systems). Treat it as compliance, not optional
  hygiene, where that exposure exists.

## Working with coding agents on our repos (must)

- Agent-authored PRs meet the **same standards as human-authored code** (see
  `standards/CODE_REVIEW.md`). No lowered bar.
- The human who runs the agent is **accountable** for the output.
- Agents must not commit secrets, disable security controls, weaken CI gates, or add
  dependencies outside `standards/DEPENDENCIES.md` without a human decision.
- Review agent tool/permission grants the way you review dependencies: periodically, and
  when scope changes.
- Assume agents may behave unexpectedly. Prioritize **reversibility and containment** over
  speed: branch protection, required review, no direct pushes to `main`, audit logs.

## Observability (must for product AI features)

- Log prompts, tool calls, and decisions with correlation IDs (redact secrets/PII per
  `standards/OBSERVABILITY.md`).
- Monitor for anomalous tool use, permission escalation attempts, and cost spikes.
- Have a kill switch: the ability to disable an agent feature or revoke its credentials
  quickly.

## Checklist (any agentic feature or agent workflow)

- [ ] Lethal trifecta assessed; at least one leg removed or human-gated.
- [ ] Tools and credentials scoped to least privilege.
- [ ] Irreversible / outward actions require human approval.
- [ ] External content treated as untrusted; model output validated before privileged use.
- [ ] Resource/iteration/cost limits enforced.
- [ ] Code/shell/DB execution runs in a disposable sandbox with no standing prod access.
- [ ] Destructive actions gated by an unbypassable human-in-the-loop step.
- [ ] Scoped sub-agents over a monolithic loop; exact logic offloaded to deterministic code.
- [ ] Memory and retrieval cannot override instructions; context isolated per user/task.
- [ ] MCP servers / tools / skills come from trusted, pinned sources.
- [ ] AI-BOM maintained for shipped AI features (models, data, prompts, tools).
- [ ] Prompts and tool calls are logged; a kill switch exists.
