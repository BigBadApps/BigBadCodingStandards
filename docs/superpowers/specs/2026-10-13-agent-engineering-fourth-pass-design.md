# Agent Engineering Standards (Fourth Pass) — Design

- **Date**: 2026-10-13
- **Status**: Draft, awaiting review
- **Release**: minor version bump (new standards), per `standards/ROLLOUT.md`
- **Branch**: `docs/agent-engineering-fourth-pass`, stacked on PR #3
  (`docs/agent-engineering-standards`)

## Problem

The third-pass review deferred five "should add" items:

1. There is no explicit spec-first gate. Agents can start coding non-trivial changes with
   no approved design.
2. There is no defense against **slopsquatting**: AI tools suggest package names that do
   not exist, and attackers register those names.
3. There are no thin shim templates for tool-specific instruction files, and no rule for
   nested `AGENTS.md` files in monorepos.
4. There are no conventions for running several agents in parallel.
5. There is no governance mapping (NIST AI RMF, ISO/IEC 42001) and no current EU AI Act
   timeline.

## Goals

- Close all five gaps with checklist-backed rules.
- Reuse existing files where possible. Only one new standards file (`AI_GOVERNANCE.md`)
  and three tiny shim templates.
- `AGENTS.md` gets no new bullets. At most one existing line is amended.

## Non-goals

- Fixing `tools/bootstrap-product-repo.sh` to render from `templates/`. This stays parked.
- Legal advice. The governance doc maps controls and states dates; it does not interpret
  obligations.

## Decisions

| Decision | Choice | Reason |
| -------- | ------ | ------ |
| Spec template | Extend `templates/DESIGN.md` | It already exists; a second template would compete with it. |
| Governance location | New `standards/AI_GOVERNANCE.md` | A distinct concern (compliance mapping), and too long for a section. |
| Shim location | `templates/tool-shims/` | Keeps the three one-line files together and out of the main template list. |
| Parallel agents location | Section in `TOOLS_AND_AGENTS.md` | Agent workflow content lives there. |

## Changes by file

### 1. Spec-first workflow

**`standards/PLAYBOOK.md`, step "2) Design the change"**: add a "Spec-first (must for
non-trivial changes)" block:

- A change is **non-trivial** if it adds or changes a public interface, changes data or
  schemas, or changes behavior across more than one module.
- For non-trivial changes, the agent writes `templates/DESIGN.md` with acceptance criteria
  and a task breakdown. A human approves it **before** implementation starts.
- Trivial changes, such as a typo, a one-function fix, or a config tweak, need only a
  short summary in the PR.

**`templates/DESIGN.md`**: add two sections after "Requirements":

- `## Acceptance criteria`: testable statements, each of which becomes at least one test.
- `## Task breakdown`: ordered, independently reviewable tasks.

Under "Security and privacy", add the line
`- AI use and EU AI Act risk tier (if the change ships AI):`.

**`AGENTS.md`**: in "Default workflow → 2. Design", amend the existing first sub-bullet to
add "for non-trivial changes, get the design approved before writing code (see
`standards/PLAYBOOK.md`)". Do not add a new bullet.

### 2. Slopsquatting (AI-hallucinated packages)

**`standards/SUPPLY_CHAIN.md`**:

- Threat model: add a bullet saying that AI coding tools invent package names that do
  not exist and attackers register them. Reported hallucination rates are about 5% for
  commercial models and about 22% for open models, and many invented names recur across
  runs, which makes them predictable targets.
- Dependency intake: add a "**AI-suggested packages (must)**" bullet. Treat any package
  name an AI suggests as untrusted. Before installing, verify that it exists on the
  official registry and check its publisher, first-publish date, and download history.
  Agents must not add new dependencies without human approval. Where tooling allows, a
  hook or CI check blocks installs of packages that are not on an allow-list or in the
  lockfile (`standards/TOOLS_AND_AGENTS.md`).
- Checklist: add a line saying AI-suggested packages were verified to exist and checked
  for publisher, age, and downloads.

**`standards/DEPENDENCIES.md`**, "Introducing a new dependency": add a bullet saying that
a name suggested by an AI tool is verified on the registry before use.

**`standards/TOOLS_AND_AGENTS.md`**, Agent Skills: add a bullet saying that skill files
can carry hallucinated package installs or repository URLs, and that these are reviewed
like any other dependency.

### 3. Tool shims and nested `AGENTS.md`

**New `templates/tool-shims/`** with three files, each pointing to `AGENTS.md` and
nothing else:

- `CLAUDE.md`: `@AGENTS.md` (Claude Code import), plus one line saying `AGENTS.md` is
  authoritative.
- `GEMINI.md`: `@AGENTS.md` (Gemini CLI import), plus the same line.
- `copilot-instructions.md`: goes in `.github/` of product repos. It holds one line:
  follow `AGENTS.md` at the repo root.

**`standards/TOOLS_AND_AGENTS.md`**, Context engineering, adds two bullets:

- Tool-specific instruction files are shims that point to `AGENTS.md`
  (`templates/tool-shims/`). Never duplicate rules into them.
- Monorepos may place `AGENTS.md` in subdirectories. The nearest file to the edited code
  wins. A subdirectory file holds only the differences for that directory.

**`standards/PROJECT_CONVENTIONS_WEB.md`**, Option B (monorepo): add a bullet pointing to
the nested `AGENTS.md` rule.

**`DISTRIBUTION.md`**: add a short section, "Tool-specific shims", that points to
`templates/tool-shims/`.

### 4. Parallel agents

**`standards/TOOLS_AND_AGENTS.md`**, new section "## Parallel agents (should)":

- One branch or git worktree per agent. Agents never share a working tree.
- Assign disjoint files or modules per agent. If two tasks touch the same file, run them
  in sequence.
- No shared mutable state between agents: no shared scratch files, databases, or ports
  without isolation.
- One PR per agent task. A human or a gated pipeline merges, never an agent merging
  another agent's work.
- Each agent runs the full verification (tests, lint, typecheck) on its own branch before
  handing off.

### 5. Governance mapping

**New `standards/AI_GOVERNANCE.md`**:

- **Scope**: applies to teams that ship AI features, and to any organization using coding
  agents at scale. It maps controls; it is not legal advice.
- **NIST AI RMF 1.0**: a table mapping each function to our standards.
  - Govern: `AGENTS.md`, `CODE_REVIEW.md`, accountability rules.
  - Map: `PLAYBOOK.md` step 1 and the `DESIGN.md` AI risk tier field.
  - Measure: `EVALS.md` and `OBSERVABILITY.md`.
  - Manage: `AI_AGENT_SECURITY.md` (kill switch, human approval) and `ROLLOUT.md`.
- **ISO/IEC 42001** (AI management system): a table mapping the main control areas to
  our standards.
  - AI policy: `AGENTS.md` and `standards/`.
  - Risk and impact assessment: the lethal trifecta in `AI_AGENT_SECURITY.md` and the
    `DESIGN.md` AI field.
  - Lifecycle: `PLAYBOOK.md`.
  - Data and supplier controls: `SUPPLY_CHAIN.md` and the AI-BOM.
  - Monitoring: `EVALS.md` and `OBSERVABILITY.md`.
- **EU AI Act timeline**, as amended by the AI Omnibus (Regulation (EU) 2026/1744, in
  force 27 July 2026):
  - 2 Feb 2025: prohibited practices and AI literacy.
  - 2 Aug 2025: general-purpose AI (GPAI) model obligations.
  - 2 Aug 2026: Art. 50 transparency. Sources differ on a labelling grace period to
    2 Dec 2026; check the regulation text.
  - 2 Dec 2027: Annex III standalone high-risk systems.
  - 2 Aug 2028: Annex I high-risk AI embedded in regulated products.
  - The section ends with "verify against the official text; dates last checked
    2026-10-13".
- **Rules (must for shipped AI features)**:
  - Classify each AI feature's EU AI Act risk tier at design time and record it in
    `DESIGN.md` and the AI-BOM.
  - Re-check the timeline and classifications when the regulation or the feature changes,
    and at least yearly.
- **Checklist**: the risk tier is recorded, the AI-BOM is current, and the timeline was
  re-checked within the last year.

### 6. Propagation

- `standards/INDEX.md` and `README.md`: list `AI_GOVERNANCE.md`. The README description
  of `TOOLS_AND_AGENTS.md` adds "parallel agents".
- `standards/AI_AGENT_SECURITY.md`, AI-BOM section: one line pointing to
  `standards/AI_GOVERNANCE.md` for risk classification and regulatory dates.
- `standards/PR_CHECKLIST.md`:
  - Scope and clarity: "Non-trivial change has an approved design (`templates/DESIGN.md`)."
  - Supply chain: "AI-suggested packages verified to exist; publisher, age, and
    downloads checked."
  - Agent engineering: "Parallel agent work uses separate branches with disjoint files."
  - AI / agent features: "EU AI Act risk tier recorded (`standards/AI_GOVERNANCE.md`)."
- `templates/PULL_REQUEST_TEMPLATE.md`: under Checklist, add a line saying the design
  doc is linked for non-trivial changes.
- `CHANGELOG.md`: add an "Added — agent engineering (fourth pass)" entry at the top of
  Unreleased, including a rollout follow-up: product repos can adopt the shims, and teams
  shipping AI features record risk tiers.

## Risks

| Risk | Mitigation |
| ---- | ---------- |
| EU AI Act dates go stale | "Last checked" date, a yearly re-check rule, and a checklist line. |
| "Non-trivial" is applied inconsistently | Concrete three-part definition, and trivial examples listed. |
| Shim import syntax differs by tool version | Each shim also says in plain words that `AGENTS.md` is authoritative, so it works even if the import is not supported. |
| Stacked branch conflicts if PR #3 changes | Rebase onto `main` after #3 merges. The fourth-pass PR targets #3's branch until then. |

## Verification

- `markdownlint-cli2` reports 0 issues.
- `tools/check-links.sh` passes, including `standards/AI_GOVERNANCE.md` and the
  `templates/tool-shims/` files.
- The conflict-marker check passes.
- `git diff docs/agent-engineering-standards -- AGENTS.md` shows only the one amended
  line.
- Every "must" in sections 1–5 has a matching `PR_CHECKLIST.md` line (manual
  cross-check).
