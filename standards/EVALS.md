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
