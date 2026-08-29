# BigBadCodingStandards

> A shared, tool-agnostic operating system for AI-assisted software development —
> readable by humans **and** coding agents (Claude, Codex, Cursor, Gemini, Copilot, …).

[![CI](https://github.com/BigBadApps/BigBadCodingStandards/actions/workflows/ci.yml/badge.svg)](https://github.com/BigBadApps/BigBadCodingStandards/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/BigBadApps/BigBadCodingStandards)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/BigBadApps/BigBadCodingStandards?sort=semver)](https://github.com/BigBadApps/BigBadCodingStandards/releases)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

These standards exist to:

- **Raise quality** — reliability, security, maintainability, and performance.
- **Increase throughput** — less rework, fewer regressions, faster reviews.
- **Standardize delivery** — predictable architecture, testing, releases, and operations.
- **Make agent work safe and consistent** — one definition of "done" across every tool.

They are intentionally framework-agnostic and lifecycle-oriented: they describe *how* to
build and operate software, not which stack to use.

## Table of contents

- [Who this is for](#who-this-is-for)
- [Quick start](#quick-start)
- [Repository structure](#repository-structure)
- [The standards](#the-standards)
- [Adopting these standards in a product repo](#adopting-these-standards-in-a-product-repo)
- [Versioning and releases](#versioning-and-releases)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)
- [References](#references)

## Who this is for

| You are… | Start here |
| --- | --- |
| A **coding agent** working in one of our repos | [`AGENTS.md`](AGENTS.md), then [`standards/PLAYBOOK.md`](standards/PLAYBOOK.md) |
| A **developer** reviewing or shipping a change | [`standards/PR_CHECKLIST.md`](standards/PR_CHECKLIST.md) and [`standards/TESTING.md`](standards/TESTING.md) |
| Setting up a **new product repo** | [`DISTRIBUTION.md`](DISTRIBUTION.md) and [`templates/`](templates/) |
| Just **navigating** | [`standards/INDEX.md`](standards/INDEX.md) |

## Quick start

Clone the repo (or add it to a product repo — see
[Adopting these standards](#adopting-these-standards-in-a-product-repo)):

```bash
git clone https://github.com/BigBadApps/BigBadCodingStandards.git
```

Then:

- **Agents**: read [`AGENTS.md`](AGENTS.md) (the Agent Operating Contract). It follows the
  [AGENTS.md open standard](https://agents.md) and is the single authoritative entrypoint —
  tool-specific files (`CLAUDE.md`, `.cursor/rules/`, …) should point to it, not duplicate it.
- **Humans**: skim [`standards/INDEX.md`](standards/INDEX.md), then the checklist in
  [`standards/PR_CHECKLIST.md`](standards/PR_CHECKLIST.md).
- **CI locally** (matches the `build` check on every PR):

  ```bash
  npx --yes markdownlint-cli2 "**/*.md" "#node_modules"
  bash tools/check-links.sh
  shellcheck --severity=warning tools/*.sh
  ```

## Repository structure

```text
.
├── AGENTS.md                  # Agent Operating Contract — primary entrypoint for agents
├── DISTRIBUTION.md            # How to reference these standards from a product repo
├── CHANGELOG.md               # Notable changes, per release
├── standards/                 # The standards themselves (see below)
│   └── INDEX.md               # Navigation entrypoint
├── templates/                 # Reusable docs: PR, issue, ADR, design, runbook, postmortem
│   └── cursor-rules/          # Drop-in Cursor rule pointing at the standards
├── tools/                     # Bootstrap + submodule-bump scripts, internal link checker
├── .github/workflows/ci.yml   # Lint + link-check gate (job: build)
└── .editorconfig              # Cross-language formatting defaults
```

## The standards

Full navigation in [`standards/INDEX.md`](standards/INDEX.md).

### Foundations

- [`PLAYBOOK.md`](standards/PLAYBOOK.md) — end-to-end software lifecycle
- [`ARCHITECTURE.md`](standards/ARCHITECTURE.md) — system design, boundaries, deterministic
  offloading, agent/protocol interoperability (MCP, A2A)
- [`CODING.md`](standards/CODING.md) — correctness, clarity, error handling, root-cause fixes
- [`API_CONTRACTS.md`](standards/API_CONTRACTS.md) — compatibility and error models

### Quality and delivery

- [`TESTING.md`](standards/TESTING.md) · [`CODE_REVIEW.md`](standards/CODE_REVIEW.md) ·
  [`PR_CHECKLIST.md`](standards/PR_CHECKLIST.md)
- [`DELIVERY.md`](standards/DELIVERY.md) — PRs → releases → operations
- [`OBSERVABILITY.md`](standards/OBSERVABILITY.md) ·
  [`DATA_MIGRATIONS.md`](standards/DATA_MIGRATIONS.md)

### Security standards

- [`SECURITY.md`](standards/SECURITY.md) — application security, aligned with OWASP Top 10:2025
- [`SUPPLY_CHAIN.md`](standards/SUPPLY_CHAIN.md) — dependency intake, build integrity,
  provenance, SBOM, SLSA
- [`AI_AGENT_SECURITY.md`](standards/AI_AGENT_SECURITY.md) — LLM/agentic feature security,
  sandboxed execution, and working safely with coding agents
- [`DEPENDENCIES.md`](standards/DEPENDENCIES.md) — choosing and maintaining dependencies

### Web applications (responsive, mixed-stack)

- [`PROJECT_CONVENTIONS_WEB.md`](standards/PROJECT_CONVENTIONS_WEB.md) — repo shapes, scripts, CI gates
- [`FRONTEND_WEB.md`](standards/FRONTEND_WEB.md) — frontend architecture and responsive UI
- [`ACCESSIBILITY_WEB.md`](standards/ACCESSIBILITY_WEB.md) — WCAG 2.2 AA
- [`PERFORMANCE_WEB.md`](standards/PERFORMANCE_WEB.md) — Core Web Vitals budgets

### Agent productivity

- [`TOOLS_AND_AGENTS.md`](standards/TOOLS_AND_AGENTS.md) — agent loop, context engineering, quality gates
- [`ROLLOUT.md`](standards/ROLLOUT.md) — publishing and rolling out standards updates

## Adopting these standards in a product repo

Pick one approach (details and trade-offs in [`DISTRIBUTION.md`](DISTRIBUTION.md)):

| Approach | Pros | Cons |
| --- | --- | --- |
| **Git submodule** at `docs/coding-standards/` (recommended) | Pinned version, easy updates, tool-agnostic | Some teams dislike submodules |
| **Vendor a snapshot** into `docs/coding-standards/` | Simplest; no submodule | Updates are manual |
| **Reference the URL** only | Zero repo changes | Version drift; agents/CI may lack network |

Bootstrap a repo:

```bash
tools/bootstrap-product-repo.sh /absolute/path/to/product-repo
```

This creates `docs/coding-standards/`, a project-local `AGENTS.md` pointing at the
standards, and a Cursor rule. Roll updates out with
[`standards/ROLLOUT.md`](standards/ROLLOUT.md) and `tools/bump-standards-submodule.sh`.

## Versioning and releases

- Releases are tagged **`vMAJOR.MINOR.PATCH`** (semantic versioning):
  - **patch** — clarifications and small guidance
  - **minor** — new standards or templates
  - **major** — breaking conventions or renames
- Every notable change is recorded in [`CHANGELOG.md`](CHANGELOG.md).
- Product repos **pin a tag** (via submodule commit) and update on a deliberate cadence —
  standards never auto-update on build.

## Contributing

Contributions are welcome.

1. Branch from `main` (`main` is protected; direct pushes are blocked).
2. Make a small, cohesive change. Update [`CHANGELOG.md`](CHANGELOG.md) under `[Unreleased]`.
3. Open a PR using [`templates/PULL_REQUEST_TEMPLATE.md`](templates/PULL_REQUEST_TEMPLATE.md).
4. CI (`build`) must pass: Markdown lint, internal link check, and shell lint.
5. A maintainer reviews and merges; releases are tagged per
   [`standards/ROLLOUT.md`](standards/ROLLOUT.md).

Keep entries high-signal, prescriptive, and machine-readable. Review guidance lives in
[`standards/CODE_REVIEW.md`](standards/CODE_REVIEW.md) and
[`standards/TOOLS_AND_AGENTS.md`](standards/TOOLS_AND_AGENTS.md).

## Security

To report a vulnerability in a repo that follows these standards, use that repo's private
disclosure channel (GitHub Security Advisories) — **do not open a public issue**.

For the security expectations these standards set, see
[`standards/SECURITY.md`](standards/SECURITY.md),
[`standards/SUPPLY_CHAIN.md`](standards/SUPPLY_CHAIN.md), and
[`standards/AI_AGENT_SECURITY.md`](standards/AI_AGENT_SECURITY.md).

## License

[MIT](LICENSE) © BigBadApps

## References

These standards track current industry baselines, including:

- [OWASP Top 10:2025](https://owasp.org/Top10/) and the OWASP Top 10 for
  [LLM Applications](https://genai.owasp.org/) / Agentic Applications
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) (Level AA)
- [Core Web Vitals](https://web.dev/articles/vitals)
- [AGENTS.md](https://agents.md), [Model Context Protocol](https://modelcontextprotocol.io),
  and [A2A](https://a2aproject.github.io/A2A/) — stewarded by the Agentic AI Foundation
- [SLSA](https://slsa.dev) and [CycloneDX](https://cyclonedx.org) (SBOM / ML-BOM)
