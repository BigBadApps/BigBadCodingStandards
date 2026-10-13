# Agent Engineering Standards (Third Pass) — Design

- **Date**: 2026-10-13
- **Status**: Draft, awaiting review
- **Release**: minor version bump (new standards), per `standards/ROLLOUT.md`

## Problem

The security baseline is current: lethal trifecta, sandboxing, AI-BOM, and the OWASP LLM
and Agentic Top 10s. The agent-engineering *workflow* has gaps when compared with 2026
practice:

1. Rules live only as prose in `AGENTS.md`. Agents follow prose most of the time, not
   all of the time.
2. There is no standard for Agent Skills (`SKILL.md`), which is now a cross-tool convention.
3. Evals get one line in `standards/PLAYBOOK.md`. There is no standard for evaluating AI
   features or for changes to agent configuration.
4. MCP is covered only as "use trusted, pinned sources". Tool poisoning, rug pulls and
   OAuth hardening are not covered.
5. There is no AI attribution policy for commits.

## Goals

- Close the five gaps above with enforceable, checklist-backed rules.
- Keep `AGENTS.md` lean. Detail goes in `standards/`, and the entrypoint only links to it.
- Each new rule maps to a checklist line in `standards/PR_CHECKLIST.md`.

## Non-goals (deferred to a later pass)

- Spec-first workflow and template.
- Slopsquatting guidance in `SUPPLY_CHAIN.md`.
- Tool shim templates (`CLAUDE.md`, `GEMINI.md`, Copilot) and nested `AGENTS.md` for monorepos.
- Parallel-agent / worktree conventions.
- Governance mapping (NIST AI RMF, ISO 42001, EU AI Act dates).

## Decisions

| Decision | Choice | Reason |
| -------- | ------ | ------ |
| AI attribution trailer | `Assisted-by:` | Linux kernel and Red Hat convention. `Co-Authored-By` has CLA and stats side effects. |
| New files | One: `standards/EVALS.md` | Guardrails and Skills fit the existing `TOOLS_AND_AGENTS.md`. Fewer files to navigate. |
| MCP guidance location | New section in `AI_AGENT_SECURITY.md` | It is a security concern and extends the existing "Supply chain for AI" section. |
| Spec location | `docs/superpowers/specs/` | Default for the brainstorming workflow. It ships in the submodule, which is acceptable for design records. |

## Changes by file

### 1. `standards/TOOLS_AND_AGENTS.md`: two new sections

#### Deterministic enforcement (must)

- Three enforcement tiers, weakest to strongest:
  1. prose in `AGENTS.md` and `standards/`
  2. local hooks and pre-commit checks
  3. CI
- Any "must" rule that can be checked mechanically is enforced in CI. Prose alone is not
  enforcement.
- Use agent hooks (for example Claude Code hooks) and pre-commit for fast local feedback
  and to block dangerous actions: writes to secret files, destructive shell commands,
  edits to protected paths.
- Hooks are code. They are versioned, reviewed, tested, and they fail closed.
- Hooks do not replace the sandbox. `AI_AGENT_SECURITY.md` sandboxing still applies.

#### Agent Skills (must when skills are used)

- Write skills in the `SKILL.md` format, with `name` and `description` frontmatter.
- Each skill covers one task domain and stays under about 5k tokens. Put reference
  material in separate files that the skill loads on demand.
- Write instructions as direct commands, not passive descriptions.
- Commit shared skills to the repo so they are reviewed and versioned with the code.
- Trigger tests: 5–10 prompts that should activate the skill and 3–5 that should not.
  Record them next to the skill.
- Restrict tools with `allowed-tools` where the tool supports it.
- Third-party skills are dependencies. Read the full content before adoption, pin a
  version or commit, and re-review on update (cross-reference `AI_AGENT_SECURITY.md`).

### 2. `standards/EVALS.md`: new file

#### Product AI features (must for shipped LLM/agent features)

- Keep a versioned golden set of inputs and expected outcomes per AI feature, stored with
  the prompts.
- Any change to a prompt, model, tool, or retrieval source runs the eval suite in CI.
  A regression below the agreed threshold blocks merge.
- Handle non-determinism: run multiple trials and report pass rates, not one sample.
- Calibrate LLM-as-judge graders against human-labelled samples before trusting them.
- Track cost and latency alongside quality.
- Include adversarial cases: prompt injection and out-of-scope requests (cross-reference
  `AI_AGENT_SECURITY.md`).

#### Agent configuration (should)

- Each addition to `AGENTS.md`, a skill, or a hook must cite an observed failure it
  prevents. Do not add speculative rules.
- Measure larger config changes on a small task set where feasible. Bloated context
  files can lower success and raise cost.
- Remove rules that no longer prevent a real failure.

### 3. `standards/AI_AGENT_SECURITY.md`: new section "MCP servers (must)"

- **Tool poisoning**: review tool names, descriptions and parameter schemas on adoption.
  They are model-visible instructions.
- **Rug pulls**: pin server versions, and diff tool definitions on every update before
  re-approving.
- **Cross-server shadowing**: do not mix servers of different trust levels in one agent
  session that has sensitive access.
- **Remote auth**: OAuth 2.1 with mandatory PKCE. Tokens are audience-bound (RFC 8707)
  and never passed through to upstream APIs. Never put tokens in logs or URLs.
- **Server implementation**: strict input schemas (`additionalProperties: false`), and
  validation against command injection, path traversal and SSRF. Audit-log tool name,
  arguments, caller and outcome.
- Add matching lines to the section checklist.

### 4. `standards/GIT_CONVENTIONS.md`: new section "AI attribution"

- Disclose substantive AI assistance with a trailer:
  `Assisted-by: <agent>:<model> [tool ...]`, for example
  `Assisted-by: Claude Code:claude-opus-5-5`.
- Do not use `Co-Authored-By` for AI tools. AI never adds `Signed-off-by`. Only humans
  certify the DCO.
- The human who ran the agent is the commit author and is accountable.
- PR descriptions state how AI was used.
- Configure each tool's attribution setting to emit `Assisted-by` instead of its default.
- Trivial assistance (autocomplete of a single line) does not need a trailer.

### 5. Propagation

- `standards/PR_CHECKLIST.md`:
  - Add an "Agent engineering" section: mechanical rules enforced in CI, skills
    trigger-tested and pinned, MCP definitions reviewed and pinned, `Assisted-by` present
    when applicable.
  - Under "AI / agent features", add: eval suite passes.
- `standards/PLAYBOOK.md`: the verify step links `standards/EVALS.md`.
- `standards/INDEX.md` and `README.md`: list `EVALS.md` and describe the new sections.
- `templates/PROJECT_AGENTS.md`, `templates/cursor-rules/coding-standards.mdc`: add one
  line on `Assisted-by` attribution.
- `CHANGELOG.md`: add an "Added — agent engineering (third pass)" entry under Unreleased.
- `AGENTS.md`: no new bullets. It already links `GIT_CONVENTIONS.md`.

### 6. This repo's CI (dogfooding)

- Add a step to `.github/workflows/ci.yml` that fails when it finds merge-conflict
  markers (`^<<<<<<<`, `^>>>>>>>`) in tracked files. This is the gap that let today's
  conflict markers through.

## Error handling and risks

| Risk | Mitigation |
| ---- | ---------- |
| Rules become shelfware | Every rule has a PR checklist line. CI-enforceable rules say so explicitly. |
| `Assisted-by` clashes with tool defaults (Claude Code emits `Co-Authored-By`) | Section 4 requires configuring the tool's attribution setting. |
| MCP spec moves fast | Cite spec version 2025-11-25 and mark the section for periodic review, as `ARCHITECTURE.md` does for MCP/A2A. |
| Docs grow past "lean" | Only `EVALS.md` is new. `AGENTS.md` does not grow. |

## Verification

- `markdownlint-cli2` reports 0 issues.
- `tools/check-links.sh` passes, including links to the new `EVALS.md`.
- The new conflict-marker CI step fails on a scratch file with a marker and passes on
  the clean tree. Test it locally before committing.
- Every "must" in sections 1–4 has a matching `PR_CHECKLIST.md` line (manual
  cross-check during review).
