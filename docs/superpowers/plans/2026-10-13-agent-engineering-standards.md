# Agent Engineering Standards (Third Pass) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic enforcement, Agent Skills, evals, MCP security, and `Assisted-by` attribution standards. Also add a CI check that fails on merge-conflict markers.

**Architecture:** This is a docs-only change to a Markdown standards repo. Each task adds one section or file, then the links and checklist lines that point to it. "Tests" here are shell assertions (`grep`), `markdownlint-cli2`, and `tools/check-links.sh`. Each test fails before the edit and passes after it.

**Tech Stack:** Markdown, GitHub Actions, bash, `markdownlint-cli2` (run with `npx`), `git grep`.

**Spec:** `docs/superpowers/specs/2026-10-13-agent-engineering-standards-design.md`

## Global Constraints

- Branch: `docs/agent-engineering-third-pass`. Do not commit to `main`.
- Every commit uses Conventional Commits (`standards/GIT_CONVENTIONS.md`). Every commit message ends with the trailer `Assisted-by: Claude Code:claude-opus-5-5`. Never add `Co-Authored-By` or `Signed-off-by` for the AI.
- `AGENTS.md` gets no new bullets.
- Only one new standards file: `standards/EVALS.md`.
- `npx --yes markdownlint-cli2 "**/*.md" "#node_modules"` must report `0 issues` after every task.
- `bash tools/check-links.sh` must pass after every task.
- Lint config forbids bold-only lines used as headings (MD036). Use `###` headings instead.
- Release type: minor (new standards). Record it in the `CHANGELOG.md` `[Unreleased]` section. Do not tag a release.

## Review Focus

1. **The link checker skips untracked files.** `tools/check-links.sh` uses `git ls-files`. Run `git add` on any new file before running the checker, or its links go unchecked (Task 3 does this).
2. **The conflict-marker check must not false-positive on Markdown.** `=======` is a valid setext heading underline, so the check matches only `<<<<<<<` or `>>>>>>>` at the start of a line. Task 1 tests both a positive case and the clean tree.
3. **`.mdc` files are not linted.** The markdownlint glob is `**/*.md`. Task 5 checks the cursor rule by `grep` and by eye.
4. **The `Assisted-by` example must match real usage.** The example in `GIT_CONVENTIONS.md` must match the trailer this branch's commits use. Task 5 checks this with `git log`.
5. **`AGENTS.md` must not grow.** Task 6 asserts `git diff main -- AGENTS.md` is empty.

---

### Task 1: CI conflict-marker check

**Files:**

- Modify: `.github/workflows/ci.yml` (add a step after `actions/checkout@v4`)

**Interfaces:**

- Consumes: nothing.
- Produces: a CI step named `Check for merge-conflict markers`. This command is the canonical check:
  `if git grep -nE '^(<<<<<<<|>>>>>>>)( |$)'; then exit 1; fi`

- [ ] **Step 1: Write the failing test (a scratch file with a marker)**

```bash
printf 'ok\n<<<<<<< Updated upstream\nx\n' > scratch-conflict.md
git add scratch-conflict.md
```

- [ ] **Step 2: Run the check and verify it FAILS (exit non-zero)**

Run: `(if git grep -nE '^(<<<<<<<|>>>>>>>)( |$)'; then exit 1; fi); echo "exit=$?"`
Expected: it prints `scratch-conflict.md:2:<<<<<<< Updated upstream`, then `exit=1`

- [ ] **Step 3: Remove the scratch file and verify the clean tree PASSES**

```bash
git rm -q --cached scratch-conflict.md && rm scratch-conflict.md
```

Run: `(if git grep -nE '^(<<<<<<<|>>>>>>>)( |$)'; then exit 1; fi); echo "exit=$?"`
Expected: no matches, then `exit=0`

- [ ] **Step 4: Add the step to CI**

In `.github/workflows/ci.yml`, insert this between the `actions/checkout@v4` step and the `Lint Markdown` step:

```yaml
      - name: Check for merge-conflict markers
        run: "if git grep -nE '^(<<<<<<<|>>>>>>>)( |$)'; then exit 1; fi"
```

- [ ] **Step 5: Verify the YAML parses and lint still passes**

Run: `npx --yes js-yaml .github/workflows/ci.yml > /dev/null && echo ok && npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1`
Expected: `ok`, then `Summary: 0 issues in 0 files`

- [ ] **Step 6: Commit**

```bash
git add .github/workflows/ci.yml
git commit -q -F - <<'EOF'
ci: fail on merge-conflict markers

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 2: Deterministic enforcement and Agent Skills in `TOOLS_AND_AGENTS.md`

**Files:**

- Modify: `standards/TOOLS_AND_AGENTS.md`. Insert two sections after `## Context engineering` and before `## Source-of-truth hierarchy`.

**Interfaces:**

- Consumes: nothing.
- Produces: headings `## Deterministic enforcement (must)` and `## Agent Skills (must when skills are used)`. Task 6 references them by those names.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E '^## (Deterministic enforcement \(must\)|Agent Skills \(must when skills are used\))$' standards/TOOLS_AND_AGENTS.md`
Expected: `0`

- [ ] **Step 2: Insert the sections**

Paste this immediately before the line `## Source-of-truth hierarchy`:

```markdown
## Deterministic enforcement (must)

Agents follow written instructions most of the time, not all of the time. Rules that
matter must be enforced by tooling, not only stated in prose.

Enforcement tiers, weakest to strongest:

1. **Prose**: `AGENTS.md` and `standards/`. Guidance only.
2. **Local hooks and pre-commit**: fast feedback, and blocking of dangerous actions before
   they happen.
3. **CI**: the authoritative gate. Nothing merges without it.

- Any "must" rule that can be checked mechanically is enforced in CI. A rule enforced only
  by prose is not enforced.
- Use agent hooks (for example Claude Code hooks) and pre-commit to block dangerous
  actions: writes to secret files (`.env`, key files), destructive shell commands, and
  edits to protected paths.
- Hooks are code: versioned, reviewed, tested, and they **fail closed** (if the hook
  errors, the action is blocked).
- Hooks do not replace the sandbox. Sandboxed execution in
  `standards/AI_AGENT_SECURITY.md` still applies.

## Agent Skills (must when skills are used)

Agent Skills package task-specific instructions in a `SKILL.md` file that an agent loads
on demand. They keep `AGENTS.md` lean.

- Use the `SKILL.md` format with `name` and `description` frontmatter. The description
  says when the skill applies.
- One skill per task domain. Keep `SKILL.md` under about 5k tokens, and move reference
  material into separate files the skill loads only when needed.
- Write direct commands ("Run the migration check"), not passive descriptions.
- Commit shared skills to the repo so they are reviewed and versioned with the code.
- **Trigger tests**: record 5–10 prompts that should activate the skill and 3–5 that
  should not, next to the skill. Re-check them when the description changes.
- Restrict tools with `allowed-tools` where the agent supports it.
- Third-party skills are dependencies: read the full content before adoption, pin a
  version or commit, and re-review on every update (`standards/AI_AGENT_SECURITY.md`).
```

- [ ] **Step 3: Run the test and verify it passes**

Run: `grep -c -E '^## (Deterministic enforcement \(must\)|Agent Skills \(must when skills are used\))$' standards/TOOLS_AND_AGENTS.md && npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1 && bash tools/check-links.sh`
Expected: `2`, then `Summary: 0 issues in 0 files`, then `Internal link check passed`

- [ ] **Step 4: Commit**

```bash
git add standards/TOOLS_AND_AGENTS.md
git commit -q -F - <<'EOF'
docs(agents): add deterministic enforcement and agent skills standards

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 3: `standards/EVALS.md` and links to it

**Files:**

- Create: `standards/EVALS.md`
- Modify: `standards/INDEX.md` (the "Quality and delivery" list)
- Modify: `standards/PLAYBOOK.md:58` (the verify-step line for LLM/agent features)
- Modify: `README.md` (the "Quality and delivery" list under "The standards")

**Interfaces:**

- Consumes: nothing.
- Produces: `standards/EVALS.md` with headings `## Product AI features (must for shipped LLM/agent features)` and `## Agent configuration (should)`.

- [ ] **Step 1: Write the failing test (add the links first)**

In `standards/INDEX.md`, under `## Quality and delivery`, add this after `- \`standards/TESTING.md\``:

```markdown
- `standards/EVALS.md`
```

In `standards/PLAYBOOK.md`, replace the line:

```markdown
- For LLM/agent features: evaluate against `standards/AI_AGENT_SECURITY.md`.
```

with:

```markdown
- For LLM/agent features: run the eval suite (`standards/EVALS.md`) and check against
  `standards/AI_AGENT_SECURITY.md`.
```

In `README.md`, under `### Quality and delivery`, add this after the `TESTING.md · CODE_REVIEW.md · PR_CHECKLIST.md` bullet:

```markdown
- [`EVALS.md`](standards/EVALS.md) — evals for AI features and agent configuration
```

- [ ] **Step 2: Run the link check and verify it FAILS**

Run: `bash tools/check-links.sh`
Expected: `::error ... broken internal link -> standards/EVALS.md`, then `Internal link check FAILED.`

- [ ] **Step 3: Create `standards/EVALS.md`**

```markdown
# Evals Standards

Tests prove deterministic code works. Evals measure how well non-deterministic systems
(LLM features, agents, and the configuration that steers coding agents) behave. Treat
them as a quality gate, not a one-off experiment.

## Product AI features (must for shipped LLM/agent features)

- Keep a **versioned golden set** of inputs and expected outcomes for each AI feature,
  stored next to the prompts it exercises.
- Any change to a prompt, model, tool, or retrieval source runs the eval suite in CI. A
  score below the agreed threshold **blocks merge**.
- Handle non-determinism: run multiple trials per case and report pass rates, not a
  single sample.
- Calibrate LLM-as-judge graders against human-labelled samples before trusting their
  scores. Re-calibrate when the judge model changes.
- Track cost and latency alongside quality. A quality gain that doubles cost is a
  trade-off to decide, not a free win.
- Include adversarial cases: prompt injection and out-of-scope requests
  (`standards/AI_AGENT_SECURITY.md`).
- Update the AI-BOM when the eval set or thresholds change materially.

## Agent configuration (should)

Applies to `AGENTS.md`, Agent Skills, and hooks (`standards/TOOLS_AND_AGENTS.md`).

- Each addition must cite the **observed failure** it prevents. Do not add speculative
  rules.
- Where feasible, measure larger configuration changes on a small, fixed task set before
  and after. Bloated context files can lower task success and raise cost.
- Remove rules that no longer prevent a real failure.

## Checklist

- [ ] Golden set exists, is versioned, and covers adversarial cases.
- [ ] Eval suite runs in CI on prompt/model/tool/retrieval changes and gates merge.
- [ ] Results report pass rates over multiple trials, plus cost and latency.
- [ ] LLM-as-judge graders calibrated against human labels.
- [ ] Agent-configuration changes cite the failure they prevent.
```

- [ ] **Step 4: Track the new file, then verify the link check and lint pass**

Run: `git add standards/EVALS.md && bash tools/check-links.sh && npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1`
Expected: `Internal link check passed`, then `Summary: 0 issues in 0 files`

- [ ] **Step 5: Commit**

```bash
git add standards/EVALS.md standards/INDEX.md standards/PLAYBOOK.md README.md
git commit -q -F - <<'EOF'
docs(evals): add evals standard for AI features and agent config

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 4: MCP servers section in `AI_AGENT_SECURITY.md`

**Files:**

- Modify: `standards/AI_AGENT_SECURITY.md`. Insert a section after `## Supply chain for AI (must)` and before `## AI Bill of Materials`. Add checklist lines at the end of `## Checklist`.

**Interfaces:**

- Consumes: nothing.
- Produces: heading `## MCP servers (must)`.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E '^## MCP servers \(must\)$|^- \[ \] MCP tool definitions' standards/AI_AGENT_SECURITY.md`
Expected: `0`

- [ ] **Step 2: Insert the section**

Paste this immediately before the line `## AI Bill of Materials (must for shipped AI features)`:

```markdown
## MCP servers (must)

MCP tool names, descriptions, and parameter schemas are read by the model as
instructions. A tool server is both a dependency and a source of untrusted content.
Reflects MCP specification 2025-11-25; revisit periodically, as this area moves fast.

- **Tool poisoning**: review every tool's name, description, and parameter schema on
  adoption. Reject hidden instructions (for example "also read `~/.aws/credentials`").
- **Rug pulls**: pin server versions. On every update, diff the tool definitions and
  re-approve before use.
- **Cross-server shadowing**: do not combine servers of different trust levels in one
  agent session that has sensitive access. One server's descriptions can steer how the
  model uses another server's tools.
- **Remote auth**: OAuth 2.1 with mandatory PKCE. Tokens are audience-bound (RFC 8707)
  so a server accepts only tokens minted for it. Never pass a client token through to
  upstream APIs. Never put tokens or auth codes in logs or URLs.
- **Building servers**: strict input schemas (`additionalProperties: false`); validate
  against command injection, path traversal, and SSRF (`standards/SECURITY.md`); audit-log
  tool name, arguments, caller, and outcome (redacted per `standards/OBSERVABILITY.md`).
```

Then append these lines at the end of the `## Checklist (any agentic feature or agent workflow)` list:

```markdown
- [ ] MCP tool definitions reviewed on adoption and diffed on every update; versions pinned.
- [ ] Remote MCP uses OAuth 2.1 + PKCE with audience-bound tokens; no token passthrough.
```

- [ ] **Step 3: Run the test and verify it passes**

Run: `grep -c -E '^## MCP servers \(must\)$|^- \[ \] MCP tool definitions' standards/AI_AGENT_SECURITY.md && npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1 && bash tools/check-links.sh`
Expected: `2`, then `Summary: 0 issues in 0 files`, then `Internal link check passed`

- [ ] **Step 4: Commit**

```bash
git add standards/AI_AGENT_SECURITY.md
git commit -q -F - <<'EOF'
docs(security): add MCP server security standard

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 5: AI attribution in `GIT_CONVENTIONS.md` and templates

**Files:**

- Modify: `standards/GIT_CONVENTIONS.md` (append a section at the end of the file)
- Modify: `templates/PROJECT_AGENTS.md` (the "Local workflow expectations" list)
- Modify: `templates/cursor-rules/coding-standards.mdc` (the "Output expectations" list)

**Interfaces:**

- Consumes: nothing.
- Produces: heading `## AI attribution` and the trailer format `Assisted-by: <agent>:<model> [tool ...]`.

- [ ] **Step 1: Write the failing test**

Run: `grep -l 'Assisted-by' standards/GIT_CONVENTIONS.md templates/PROJECT_AGENTS.md templates/cursor-rules/coding-standards.mdc | wc -l`
Expected: `0`

- [ ] **Step 2: Append the section to `standards/GIT_CONVENTIONS.md`**

````markdown

## AI attribution

Disclose substantive AI assistance with a commit trailer:

```text
Assisted-by: <agent>:<model> [tool ...]
```

Example:

```text
fix(cart): prevent double-charge when network retries

Assisted-by: Claude Code:claude-opus-5-5
```

- The human who ran the agent is the commit author and is accountable for the change.
- Do **not** use `Co-Authored-By` for AI tools. It has CLA and contribution-stats side
  effects.
- AI tools never add `Signed-off-by`. Only humans can certify the DCO.
- PR descriptions state how AI was used.
- Configure each agent's attribution setting to emit `Assisted-by` instead of its
  default trailer.
- Trivial assistance (a single autocompleted line) does not need a trailer.
````

- [ ] **Step 3: Update the templates**

In `templates/PROJECT_AGENTS.md`, append to the "Local workflow expectations" list:

```markdown
- Mark AI-assisted commits with an `Assisted-by: <agent>:<model>` trailer; never
  `Co-Authored-By` or `Signed-off-by` for the AI.
```

In `templates/cursor-rules/coding-standards.mdc`, append to the "Output expectations" list:

```markdown
- Mark AI-assisted commits with an `Assisted-by: <agent>:<model>` trailer
  (`docs/coding-standards/standards/GIT_CONVENTIONS.md`).
```

- [ ] **Step 4: Run the test and verify it passes, and that the example matches real commits**

Run: `grep -l 'Assisted-by' standards/GIT_CONVENTIONS.md templates/PROJECT_AGENTS.md templates/cursor-rules/coding-standards.mdc | wc -l && git log main.. --format=%B | grep -c '^Assisted-by: Claude Code:claude-opus-5-5$' && npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1 && bash tools/check-links.sh`
Expected: `3`, then a count ≥ `1`, then `Summary: 0 issues in 0 files`, then `Internal link check passed`. Also read the `.mdc` diff by eye, because markdownlint does not cover it.

- [ ] **Step 5: Commit**

```bash
git add standards/GIT_CONVENTIONS.md templates/PROJECT_AGENTS.md templates/cursor-rules/coding-standards.mdc
git commit -q -F - <<'EOF'
docs(git): add Assisted-by AI attribution policy

Assisted-by: Claude Code:claude-opus-5-5
EOF
```

---

### Task 6: PR checklist, CHANGELOG, final verification

**Files:**

- Modify: `standards/PR_CHECKLIST.md`. Add a line to `## AI / agent features (if applicable)`, and add a new section `## Agent engineering (if applicable)` after it.
- Modify: `CHANGELOG.md`. Add a new subsection at the top of `## [Unreleased]`.

**Interfaces:**

- Consumes: the headings from Tasks 2–5 and the file `standards/EVALS.md`.
- Produces: nothing downstream.

- [ ] **Step 1: Write the failing test**

Run: `grep -c -E '^## Agent engineering \(if applicable\)$|^### Added — agent engineering \(third pass\)$' standards/PR_CHECKLIST.md CHANGELOG.md`
Expected: `standards/PR_CHECKLIST.md:0` and `CHANGELOG.md:0`

- [ ] **Step 2: Update `standards/PR_CHECKLIST.md`**

Under `## AI / agent features (if applicable)`, insert this before `- [ ] See \`standards/AI_AGENT_SECURITY.md\`.`:

```markdown
- [ ] Eval suite passes for prompt/model/tool/retrieval changes (`standards/EVALS.md`).
```

Then insert this new section between the end of that section and `## Performance and reliability`:

```markdown
## Agent engineering (if applicable)

- [ ] Mechanically checkable "must" rules are enforced in CI or hooks, not prose alone.
- [ ] New/changed skills are trigger-tested; third-party skills reviewed and pinned.
- [ ] MCP servers pinned; tool definitions reviewed or diffed (`standards/AI_AGENT_SECURITY.md`).
- [ ] Agent-configuration changes cite the failure they prevent (`standards/EVALS.md`).
- [ ] AI-assisted commits carry an `Assisted-by` trailer (`standards/GIT_CONVENTIONS.md`).
```

- [ ] **Step 3: Update `CHANGELOG.md`**

Insert this directly under `## [Unreleased]`, above `### Added — agent engineering (second pass)`:

```markdown
### Added — agent engineering (third pass)

- `standards/TOOLS_AND_AGENTS.md`: **Deterministic enforcement** (prose < hooks < CI;
  mechanically checkable rules enforced in CI; hooks fail closed) and **Agent Skills**
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
- CI: fails on merge-conflict markers.
```

- [ ] **Step 4: Run the full verification**

Run:

```bash
grep -c -E '^## Agent engineering \(if applicable\)$|^### Added — agent engineering \(third pass\)$' standards/PR_CHECKLIST.md CHANGELOG.md
npx --yes markdownlint-cli2 "**/*.md" "#node_modules" | tail -1
bash tools/check-links.sh
(if git grep -nE '^(<<<<<<<|>>>>>>>)( |$)'; then exit 1; fi); echo "markers-exit=$?"
git diff --quiet main -- AGENTS.md && echo "AGENTS.md unchanged"
git log main.. --format='%s%n%b' | grep -c -i 'co-authored-by'
```

Expected: `standards/PR_CHECKLIST.md:1` and `CHANGELOG.md:1`; `Summary: 0 issues in 0 files`; `Internal link check passed`; `markers-exit=0`; `AGENTS.md unchanged`; `0`.

- [ ] **Step 5: Commit**

```bash
git add standards/PR_CHECKLIST.md CHANGELOG.md
git commit -q -F - <<'EOF'
docs: add agent engineering checklist items and changelog entry

Assisted-by: Claude Code:claude-opus-5-5
EOF
```
