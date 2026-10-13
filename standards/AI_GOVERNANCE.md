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
