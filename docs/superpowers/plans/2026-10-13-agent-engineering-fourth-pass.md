# Agent Engineering Standards (Fourth Pass) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a spec-first gate, slopsquatting defenses, tool shims and nested `AGENTS.md` rules, parallel-agent conventions, and AI governance mapping.

**Architecture:** This is a docs-only change to a Markdown standards repo. Each task inserts verbatim text at named anchors. "Tests" are shell assertions (`grep`), `markdownlint-cli2`, and `tools/check-links.sh`. Each test fails before the edit and passes after it.

**Tech Stack:** Markdown, bash, `markdownlint-cli2` (run with `npx`), `git grep`.

**Spec:** `docs/superpowers/specs/2026-10-13-agent-engineering-fourth-pass-design.md`

## Global Constraints

- Branch: `docs/agent-engineering-fourth-pass`. Do not commit to `main` or to `docs/agent-engineering-standards`. Do not push.
- Every commit uses Conventional Commits. Every commit message ends with the trailer `Assisted-by: Claude Code:claude-opus-5-5`. Never add `Co-Authored-By` or `Signed-off-by`.
- Lint command: `npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers"`. It must report `0 issues` after every task.
- `bash tools/check-links.sh` must pass after Task 1 and after every later task. Before Task 1 it fails on `standards/AI_GOVERNANCE.md`, which is expected.
- `tools/check-links.sh` only scans tracked files. Run `git add` on new files before running it.
- `AGENTS.md` changes by exactly one amended line (Task 2) and gets no new bullets.
- Lint forbids bold-only lines used as headings (MD036) and requires a language on code fences (MD040) and blank lines around lists (MD032).

## Review Focus

1. **Shim templates are real `CLAUDE.md` and `GEMINI.md` files inside this repo.** An agent working in `templates/tool-shims/` may auto-load them. Their content must be harmless when loaded here: a pointer to `AGENTS.md` and nothing else. Task 4 checks that each file has 3 lines or fewer.
2. **EU AI Act dates must match the spec exactly**, with a "last checked 2026-10-13" stamp. Task 1 checks with `grep`.
3. **`AGENTS.md` diff must be one line.** Task 5 asserts `git diff docs/agent-engineering-standards -- AGENTS.md | grep -c '^[-+][^-+]'` equals `2`.
4. **`TOOLS_AND_AGENTS.md` is edited by Tasks 3 and 4** in different sections. Task 4 must not disturb Task 3's Skills bullet. Task 4's check confirms that bullet is still present.
5. **The governance doc must not read as legal advice.** Task 1 checks that the "not legal advice" text is present.

---

### Task 1: `standards/AI_GOVERNANCE.md` and links to it

**Files:**

- Create: `standards/AI_GOVERNANCE.md`
- Modify: `standards/INDEX.md` (the "Security and operations" list)
- Modify: `README.md` (the "Security standards" list)
- Modify: `standards/AI_AGENT_SECURITY.md` (the "AI Bill of Materials" section)

**Interfaces:**

- Produces: `standards/AI_GOVERNANCE.md`. Tasks 2 and 5 link to it.

- [ ] **Step 1: Add the links first**

In `standards/INDEX.md`, add this after the `` `standards/AI_AGENT_SECURITY.md` `` line:

```markdown
- `standards/AI_GOVERNANCE.md` (NIST AI RMF, ISO/IEC 42001, EU AI Act timeline)
```

In `README.md`, add this after the two-line `AI_AGENT_SECURITY.md` bullet in "Security standards":

```markdown
- [`AI_GOVERNANCE.md`](standards/AI_GOVERNANCE.md) — NIST AI RMF and ISO/IEC 42001
  mapping, EU AI Act timeline, AI risk classification
```

In `standards/AI_AGENT_SECURITY.md`, add this paragraph as the last paragraph of "## AI Bill of Materials (must for shipped AI features)". It goes directly before the heading `## Working with coding agents on our repos (must)`, with one blank line on each side:

```markdown
Record each AI feature's EU AI Act risk tier in the AI-BOM. See
`standards/AI_GOVERNANCE.md` for risk classification and regulatory dates.
```

- [ ] **Step 2: Run the link check and verify it FAILS**

Run: `bash tools/check-links.sh`
Expected: `broken internal link -> standards/AI_GOVERNANCE.md`, then `Internal link check FAILED.`

- [ ] **Step 3: Create `standards/AI_GOVERNANCE.md`**

```markdown
# AI Governance Standards

This standard maps our engineering standards to the main AI governance frameworks and
records the EU AI Act timeline. It applies to teams that ship AI features and to any
organization using coding agents at scale.

It maps controls to frameworks. It is **not legal advice**: confirm obligations with
counsel for your jurisdiction and product.

## NIST AI RMF 1.0

| Function | What it asks | Where we cover it |
| -------- | ------------ | ----------------- |
| Govern | Policies, accountability, culture | `AGENTS.md`, `standards/CODE_REVIEW.md`, human accountability in `standards/AI_AGENT_SECURITY.md` |
| Map | Context, intended use, risks | `standards/PLAYBOOK.md` step 1; AI risk tier in `templates/DESIGN.md` |
| Measure | Test, evaluate, monitor | `standards/EVALS.md`, `standards/OBSERVABILITY.md` |
| Manage | Prioritize and act on risk | `standards/AI_AGENT_SECURITY.md` (human approval, kill switch), `standards/ROLLOUT.md` |

## ISO/IEC 42001 (AI management system)

| Control area | Where we cover it |
| ------------ | ----------------- |
| AI policy | `AGENTS.md` and `standards/` |
| Risk and impact assessment | Lethal trifecta in `standards/AI_AGENT_SECURITY.md`; AI risk tier in `templates/DESIGN.md` |
| AI system lifecycle | `standards/PLAYBOOK.md` |
| Data, suppliers, and third parties | `standards/SUPPLY_CHAIN.md`; AI-BOM in `standards/AI_AGENT_SECURITY.md` |
| Monitoring and improvement | `standards/EVALS.md`, `standards/OBSERVABILITY.md` |

## EU AI Act timeline

As amended by the AI Omnibus (Regulation (EU) 2026/1744, in force 27 July 2026):

| Date | What applies |
| ---- | ------------ |
| 2 Feb 2025 | Prohibited practices; AI literacy duties |
| 2 Aug 2025 | General-purpose AI (GPAI) model obligations |
| 2 Aug 2026 | Art. 50 transparency duties (sources differ on a labelling grace period to 2 Dec 2026; check the regulation text) |
| 2 Dec 2027 | Annex III standalone high-risk systems |
| 2 Aug 2028 | Annex I high-risk AI embedded in regulated products |

Verify against the official text before relying on these dates. Dates last checked
2026-10-13.

## Rules (must for shipped AI features)

- Classify each AI feature's EU AI Act risk tier (prohibited, high-risk, transparency
  duties, or minimal) at design time. Record it in `templates/DESIGN.md` and in the AI-BOM.
- Re-check the timeline and each feature's classification when the regulation or the
  feature changes, and at least once a year.

## Checklist

- [ ] EU AI Act risk tier recorded in the design doc and the AI-BOM.
- [ ] AI-BOM is current for this release.
- [ ] Timeline and classification re-checked within the last year.
```

- [ ] **Step 4: Track the new file and verify the checks pass**

Run:

```bash
git add standards/AI_GOVERNANCE.md
bash tools/check-links.sh
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers" | tail -1
grep -c -E 'not legal advice|Dates last checked|2 Dec 2027|2 Aug 2028' standards/AI_GOVERNANCE.md
```

Expected: `Internal link check passed`; `Summary: 0 issues in 0 files`; `4`

- [ ] **Step 5: Commit**

```bash
git add standards/AI_GOVERNANCE.md standards/INDEX.md README.md standards/AI_AGENT_SECURITY.md
git commit -q -F - <<'EOF'
docs(governance): add AI governance mapping and EU AI Act timeline

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 2: Spec-first workflow

**Files:**

- Modify: `standards/PLAYBOOK.md` (section `## 2) Design the change`)
- Modify: `templates/DESIGN.md`
- Modify: `AGENTS.md` (amend one line under "Default workflow" → `2. **Design**`)

**Interfaces:**

- Consumes: `standards/AI_GOVERNANCE.md` (Task 1).
- Produces: `templates/DESIGN.md` sections `## Acceptance criteria` and `## Task breakdown`.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E '^### Spec-first \(must for non-trivial changes\)$|^## Acceptance criteria$|^## Task breakdown$|get the design approved before writing code' standards/PLAYBOOK.md templates/DESIGN.md AGENTS.md`
Expected: `standards/PLAYBOOK.md:0`, `templates/DESIGN.md:0`, `AGENTS.md:0`

- [ ] **Step 2: Edit `standards/PLAYBOOK.md`**

In `## 2) Design the change`, insert this block directly before the line ``Deliverable: `templates/DESIGN.md` (or ADR if it’s a durable decision).``:

```markdown
### Spec-first (must for non-trivial changes)

A change is **non-trivial** if it adds or changes a public interface, changes data or
schemas, or changes behavior across more than one module.

- For non-trivial changes, write `templates/DESIGN.md` with acceptance criteria and a
  task breakdown, and get human approval **before** implementation starts. This applies
  to agents and humans alike.
- Trivial changes (a typo, a one-function fix, a config tweak) need only a short summary
  in the PR.

```

- [ ] **Step 3: Edit `templates/DESIGN.md`**

Insert this between the end of the `## Requirements` list and `## Proposed approach`:

```markdown
## Acceptance criteria

- Testable statements of done. Each one becomes at least one test.

## Task breakdown

1. Ordered, independently reviewable tasks.

```

Under `## Security and privacy`, append this line after `- AuthN/AuthZ:`:

```markdown
- AI use and EU AI Act risk tier (if the change ships AI; see `standards/AI_GOVERNANCE.md`):
```

- [ ] **Step 4: Amend one line in `AGENTS.md`**

Replace:

```markdown
   - Propose architecture and boundaries.
```

with:

```markdown
   - Propose architecture and boundaries; for non-trivial changes, get the design approved before writing code (see `standards/PLAYBOOK.md`).
```

- [ ] **Step 5: Run the test and verify it passes**

Run:

```bash
grep -c -E '^### Spec-first \(must for non-trivial changes\)$|^## Acceptance criteria$|^## Task breakdown$|get the design approved before writing code' standards/PLAYBOOK.md templates/DESIGN.md AGENTS.md
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers" | tail -1
bash tools/check-links.sh
```

Expected: `standards/PLAYBOOK.md:1`, `templates/DESIGN.md:2`, `AGENTS.md:1`; `Summary: 0 issues in 0 files`; `Internal link check passed`

- [ ] **Step 6: Commit**

```bash
git add standards/PLAYBOOK.md templates/DESIGN.md AGENTS.md
git commit -q -F - <<'EOF'
docs(playbook): require approved design before non-trivial changes

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 3: Slopsquatting defenses

**Files:**

- Modify: `standards/SUPPLY_CHAIN.md` (threat model list, "Dependency intake" list, "Checklist")
- Modify: `standards/DEPENDENCIES.md` ("Introducing a new dependency (checklist)")
- Modify: `standards/TOOLS_AND_AGENTS.md` ("## Agent Skills (must when skills are used)")

**Interfaces:**

- Produces: the `TOOLS_AND_AGENTS.md` Skills bullet starting `- Skill files can carry hallucinated`. Task 4 checks that it survives.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E 'AI-suggested packages|hallucinat' standards/SUPPLY_CHAIN.md standards/DEPENDENCIES.md standards/TOOLS_AND_AGENTS.md`
Expected: all three files `:0`

- [ ] **Step 2: Edit `standards/SUPPLY_CHAIN.md`**

In `## Threat model (why this matters)`, append this bullet after `- It exfiltrates secrets/tokens or publishes further malicious versions.`:

```markdown
- **Slopsquatting**: AI coding tools suggest package names that do not exist, and
  attackers register those names with malicious code. Reported hallucination rates are
  about 5% for commercial models and about 22% for open models, and many invented names
  recur across runs, which makes them predictable targets.
```

In `## Dependency intake (must)`, append this as the last bullet of the list, after the OpenSSF Scorecard bullet that ends `dangerous-workflow checks).`:

```markdown
- **AI-suggested packages (must)**: treat any package name suggested by an AI tool as
  untrusted. Before installing, verify that it exists on the official registry and check
  its publisher, first-publish date, and download history. Agents must not add new
  dependencies without human approval. Where tooling allows, a hook or CI check blocks
  installs of packages that are not in the lockfile or on an allow-list
  (`standards/TOOLS_AND_AGENTS.md`).
```

In `## Checklist (new or updated dependency / release pipeline)`, add this after `- [ ] New dependency passed the intake checklist in \`standards/DEPENDENCIES.md\`.`:

```markdown
- [ ] AI-suggested packages verified to exist; publisher, age, and downloads checked.
```

- [ ] **Step 3: Edit `standards/DEPENDENCIES.md`**

In `## Introducing a new dependency (checklist)`, append this as the last bullet:

```markdown
- If an AI tool suggested the package, verify that it exists on the official registry and
  check its publisher and history before use (AI-suggested packages, `standards/SUPPLY_CHAIN.md`).
```

- [ ] **Step 4: Edit `standards/TOOLS_AND_AGENTS.md`**

In `## Agent Skills (must when skills are used)`, append this as the last bullet, after the two-line bullet starting `- Third-party skills are dependencies:`:

```markdown
- Skill files can carry hallucinated package installs or repository URLs. Review them like
  any other dependency (AI-suggested packages, `standards/SUPPLY_CHAIN.md`).
```

- [ ] **Step 5: Run the test and verify it passes**

Run:

```bash
grep -c -E 'AI-suggested packages|hallucinat' standards/SUPPLY_CHAIN.md standards/DEPENDENCIES.md standards/TOOLS_AND_AGENTS.md
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers" | tail -1
bash tools/check-links.sh
```

Expected: `standards/SUPPLY_CHAIN.md:3`, `standards/DEPENDENCIES.md:1`, `standards/TOOLS_AND_AGENTS.md:2`; `Summary: 0 issues in 0 files`; `Internal link check passed`

- [ ] **Step 6: Commit**

```bash
git add standards/SUPPLY_CHAIN.md standards/DEPENDENCIES.md standards/TOOLS_AND_AGENTS.md
git commit -q -F - <<'EOF'
docs(supply-chain): add slopsquatting defenses for AI-suggested packages

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 4: Tool shims, nested `AGENTS.md`, and parallel agents

**Files:**

- Create: `templates/tool-shims/CLAUDE.shim.md`
- Create: `templates/tool-shims/GEMINI.shim.md`
- Create: `templates/tool-shims/copilot-instructions.md`
- Modify: `standards/TOOLS_AND_AGENTS.md` (the "## Context engineering" list, plus a new section before `## Source-of-truth hierarchy`)
- Modify: `standards/PROJECT_CONVENTIONS_WEB.md` ("### Option B: Monorepo (multiple deployables)")
- Modify: `DISTRIBUTION.md` (a new section before `## Suggested minimal bootstrap for product repos`)
- Modify: `README.md` (the `TOOLS_AND_AGENTS.md` description)

**Interfaces:**

- Consumes: Task 3's Skills bullet in `TOOLS_AND_AGENTS.md`. Leave it untouched.
- Produces: heading `## Parallel agents (should)` and the three shim files.

- [ ] **Step 1: Write the failing test**

Run:

```bash
ls templates/tool-shims 2>&1 | head -1
grep -c -E '^## Parallel agents \(should\)$|templates/tool-shims|nearest `AGENTS.md`' standards/TOOLS_AND_AGENTS.md DISTRIBUTION.md standards/PROJECT_CONVENTIONS_WEB.md
```

Expected: `ls: templates/tool-shims: No such file or directory`, then all three files `:0`

- [ ] **Step 2: Create the shim files**

`templates/tool-shims/CLAUDE.shim.md` (exactly these 3 lines):

```markdown
@AGENTS.md

`AGENTS.md` is the authoritative instruction file for this repo. Do not add rules here.
```

`templates/tool-shims/GEMINI.shim.md` (exactly these 3 lines):

```markdown
@AGENTS.md

`AGENTS.md` is the authoritative instruction file for this repo. Do not add rules here.
```

`templates/tool-shims/copilot-instructions.md` (exactly 1 line):

```markdown
Follow `AGENTS.md` at the repository root. It is the authoritative instruction file; do not add rules here.
```

- [ ] **Step 3: Edit `standards/TOOLS_AND_AGENTS.md`**

In `## Context engineering`, append these two bullets at the end of the list, after the bullet starting `- Avoid restating the same large context every turn`:

```markdown
- **Tool-specific files are shims**: `CLAUDE.md`, `GEMINI.md`, and
  `.github/copilot-instructions.md` only point to `AGENTS.md` (copy from
  `templates/tool-shims/`). Never duplicate rules into them.
- **Nested `AGENTS.md` in monorepos**: subdirectories may have their own `AGENTS.md`. The
  nearest `AGENTS.md` to the edited code wins, and a subdirectory file holds only the
  differences for that directory.
```

Insert this new section directly before the line `## Source-of-truth hierarchy`:

```markdown
## Parallel agents (should)

When several agents work at once:

- One branch or git worktree per agent. Agents never share a working tree.
- Assign disjoint files or modules per agent. If two tasks touch the same file, run them
  in sequence.
- No shared mutable state between agents: no shared scratch files, databases, or ports
  without isolation.
- One PR per agent task. A human or a gated pipeline merges, never an agent merging
  another agent's work.
- Each agent runs the full verification (tests, lint, typecheck) on its own branch before
  handing off.

```

- [ ] **Step 4: Edit `standards/PROJECT_CONVENTIONS_WEB.md`**

In `### Option B: Monorepo (multiple deployables)`, append this as the last bullet, after ``- `docs/` ``:

```markdown
- Per-package `AGENTS.md` files for package-specific rules (nearest `AGENTS.md` wins;
  see `standards/TOOLS_AND_AGENTS.md`)
```

- [ ] **Step 5: Edit `DISTRIBUTION.md`**

Insert this directly before the line `## Suggested minimal bootstrap for product repos`:

```markdown
## Tool-specific shims (optional)

If a tool reads its own instruction file, add a one-line shim that points to `AGENTS.md`
instead of copying rules. Templates live in `templates/tool-shims/`:

- `CLAUDE.md` (Claude Code) and `GEMINI.md` (Gemini CLI) at the repo root
- `copilot-instructions.md` in `.github/` (GitHub Copilot)

```

- [ ] **Step 6: Edit `README.md`**

Replace:

```markdown
- [`TOOLS_AND_AGENTS.md`](standards/TOOLS_AND_AGENTS.md) — agent loop, context engineering,
  deterministic enforcement (hooks/CI), Agent Skills, quality gates
```

with:

```markdown
- [`TOOLS_AND_AGENTS.md`](standards/TOOLS_AND_AGENTS.md) — agent loop, context engineering,
  deterministic enforcement (hooks/CI), Agent Skills, parallel agents, quality gates
```

- [ ] **Step 7: Track the new files and verify everything passes**

Run:

```bash
git add templates/tool-shims
wc -l templates/tool-shims/*
grep -c -E '^## Parallel agents \(should\)$|templates/tool-shims|nearest `AGENTS.md`' standards/TOOLS_AND_AGENTS.md DISTRIBUTION.md standards/PROJECT_CONVENTIONS_WEB.md
grep -c '^- Skill files can carry hallucinated' standards/TOOLS_AND_AGENTS.md
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers" | tail -1
bash tools/check-links.sh
```

Expected:

- `wc` shows each shim at 3 lines or fewer
- `standards/TOOLS_AND_AGENTS.md:3`, `DISTRIBUTION.md:1`, `standards/PROJECT_CONVENTIONS_WEB.md:1`
- `1`
- `Summary: 0 issues in 0 files`
- `Internal link check passed`

- [ ] **Step 8: Commit**

```bash
git add templates/tool-shims standards/TOOLS_AND_AGENTS.md standards/PROJECT_CONVENTIONS_WEB.md DISTRIBUTION.md README.md
git commit -q -F - <<'EOF'
docs(agents): add tool shims, nested AGENTS.md, and parallel agent rules

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 5: PR checklist, PR template, CHANGELOG, final verification

**Files:**

- Modify: `standards/PR_CHECKLIST.md`
- Modify: `templates/PULL_REQUEST_TEMPLATE.md` (the "## Checklist" list)
- Modify: `CHANGELOG.md` (the top of `## [Unreleased]`)

**Interfaces:**

- Consumes: all earlier tasks.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E 'approved design|AI-suggested packages verified|disjoint files|risk tier recorded|agent engineering \(fourth pass\)|Design doc linked' standards/PR_CHECKLIST.md templates/PULL_REQUEST_TEMPLATE.md CHANGELOG.md`
Expected: all three files `:0`

- [ ] **Step 2: Edit `standards/PR_CHECKLIST.md`**

In `## Scope and clarity`, append:

```markdown
- [ ] Non-trivial change has an approved design (`templates/DESIGN.md`).
```

In `## Supply chain (if dependencies or build/release changed)`, add this after the first line (`- [ ] New/updated deps passed ...`):

```markdown
- [ ] AI-suggested packages verified to exist; publisher, age, and downloads checked.
```

In `## AI / agent features (if applicable)`, insert this directly before `` - [ ] See `standards/AI_AGENT_SECURITY.md`. ``:

```markdown
- [ ] EU AI Act risk tier recorded (`standards/AI_GOVERNANCE.md`).
```

In `## Agent engineering (if applicable)`, append as the last line:

```markdown
- [ ] Parallel agent work uses separate branches with disjoint files.
```

- [ ] **Step 3: Edit `templates/PULL_REQUEST_TEMPLATE.md`**

In `## Checklist`, insert this as the first line of the list:

```markdown
- [ ] Design doc linked (non-trivial changes; `templates/DESIGN.md`).
```

- [ ] **Step 4: Edit `CHANGELOG.md`**

Insert this directly under `## [Unreleased]`, above `### Added — agent engineering (third pass)`:

```markdown
### Added — agent engineering (fourth pass)

- `standards/AI_GOVERNANCE.md`: new. NIST AI RMF and ISO/IEC 42001 mapping, EU AI Act
  timeline as amended by Regulation (EU) 2026/1744, and risk-tier recording rules.
- `standards/PLAYBOOK.md`, `templates/DESIGN.md`, `AGENTS.md`: **spec-first** gate. Non-trivial
  changes need an approved design with acceptance criteria and a task breakdown.
- `standards/SUPPLY_CHAIN.md`, `standards/DEPENDENCIES.md`: **slopsquatting** defenses.
  AI-suggested packages are verified before install, and agents cannot add dependencies
  without approval.
- `templates/tool-shims/`: new `CLAUDE.md`, `GEMINI.md`, and `copilot-instructions.md`
  shims that point to `AGENTS.md`.
- `standards/TOOLS_AND_AGENTS.md`: nested `AGENTS.md` rule for monorepos, a **parallel
  agents** section, and a Skills note on hallucinated installs.
- `standards/PR_CHECKLIST.md`, `templates/PULL_REQUEST_TEMPLATE.md`, `README.md`,
  `standards/INDEX.md`, `DISTRIBUTION.md`, `standards/PROJECT_CONVENTIONS_WEB.md`: propagated the above.
- **Rollout follow-up for product repos**: copy `templates/tool-shims/` files where tools
  need them, and record EU AI Act risk tiers for shipped AI features.
```

- [ ] **Step 5: Run the full verification**

Run:

```bash
grep -c -E 'approved design|AI-suggested packages verified|disjoint files|risk tier recorded|agent engineering \(fourth pass\)|Design doc linked' standards/PR_CHECKLIST.md templates/PULL_REQUEST_TEMPLATE.md CHANGELOG.md
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.superpowers" | tail -1
bash tools/check-links.sh
bash -c 'set +e; git grep -nE "^(<<<<<<<|>>>>>>>)( |$)"; rc=$?; if [ "$rc" -eq 0 ]; then exit 1; fi; if [ "$rc" -ne 1 ]; then exit "$rc"; fi'; echo "markers-exit=$?"
git diff docs/agent-engineering-standards -- AGENTS.md | grep -c '^[-+][^-+]'
git log docs/agent-engineering-standards.. --format=%B | grep -ci 'co-authored-by'
```

Expected:

- `standards/PR_CHECKLIST.md:4`, `templates/PULL_REQUEST_TEMPLATE.md:1`, `CHANGELOG.md:2`
- `Summary: 0 issues in 0 files`
- `Internal link check passed`
- `markers-exit=0`
- `2`
- `0`

- [ ] **Step 6: Commit**

```bash
git add standards/PR_CHECKLIST.md templates/PULL_REQUEST_TEMPLATE.md CHANGELOG.md
git commit -q -F - <<'EOF'
docs: add fourth-pass checklist items and changelog entry

Assisted-by: Claude Code:claude-opus-5-5
EOF
```
