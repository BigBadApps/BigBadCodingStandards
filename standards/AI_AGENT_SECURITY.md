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
- [ ] Memory and retrieval cannot override instructions; context isolated per user/task.
- [ ] MCP servers / tools / skills come from trusted, pinned sources.
- [ ] Prompts and tool calls are logged; a kill switch exists.
