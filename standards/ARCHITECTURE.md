# Architecture Standards

These standards guide system design so software remains reliable and easy to change.

## Core principles

- **Explicit boundaries**: modules/services own specific responsibilities.
- **Stable interfaces**: APIs are contracts; changes are intentional and versioned when needed.
- **Separation of concerns**: business logic is independent of transport/UI/persistence.
- **Design for failure**: timeouts, retries, idempotency, backpressure.
- **Observability first**: measure and debug real behavior in production.

## Preferred shapes

- **Layered architecture (typical app)**:
  - **Domain**: core business logic and invariants
  - **Application**: use cases / orchestration
  - **Infrastructure**: DB, HTTP clients, queues, caches
  - **Interfaces**: HTTP/GraphQL/gRPC handlers, UI, CLI
- **Hexagonal (“ports & adapters”)** for complex domains or many integrations.
- **Event-driven** only when you have clear async needs and operational maturity.

## Dependencies and coupling

- Dependencies flow **inward**: interface → application → domain (domain depends on nothing).
- Avoid circular dependencies; enforce with tooling where possible.
- Prefer composition over inheritance.

## Data and schemas

- Treat schema changes as deployments:
  - Backwards compatible migrations first (expand)
  - Deploy code that writes both / reads new (migrate)
  - Remove old fields later (contract)
- Avoid “big bang” migrations.
- Establish ownership of each table/collection/topic.

## APIs and contracts

- Define error model (codes, messages, retryability).
- Version when you can’t be compatible.
- Make operations idempotent where clients may retry.
- Use timeouts everywhere; never wait forever.

## Reliability patterns

- Timeouts + retries with jitter (only for safe/idempotent ops).
- Circuit breakers for unstable dependencies.
- Rate limiting at edges.
- Graceful degradation for non-critical features.

## Deterministic offloading (hybrid AI architecture)

When a system uses an LLM or agent in its control flow, keep the probabilistic part small
and the fragile parts deterministic.

- **Do not let a reasoning loop improvise logic that must be exact**: money and tax
  calculations, permission decisions, schema/DB operations, regulatory rules, parsing of
  formal formats.
- Put that logic in **normal, reviewed, tested code** (functions, services, jobs). The
  model's job is to parse intent and *call* it with validated arguments — not to reinvent
  it each run.
- Validate model-produced arguments at the boundary before the deterministic code runs
  (same rules as any untrusted input).
- Prefer this split even when the model "can usually do the math" — usually is not a
  correctness guarantee.

See `standards/AI_AGENT_SECURITY.md` for the security side of agent execution.

## Agent and protocol interoperability

For systems that expose tools to agents or coordinate multiple agents, prefer open
protocols over bespoke glue to avoid vendor lock-in:

- **MCP (Model Context Protocol)** for exposing tools, data, and internal capabilities to
  agents. Prefer an MCP server over hand-rolled per-model API wrappers.
- **A2A (Agent-to-Agent)** for handoffs between independent agents, especially across
  vendors or teams.
- Both are stewarded by the Agentic AI Foundation (Linux Foundation). Treat the specific
  protocol/tooling choices as current best practice and revisit periodically — this area
  is still moving.
- Keep application logic independent of the model provider: the provider is an adapter,
  not a dependency of the domain.

## Observability requirements

- **Structured logging** with correlation IDs.
- **Metrics** for latency, throughput, errors, saturation.
- **Tracing** for distributed requests where applicable.
- Avoid logging secrets and sensitive payloads.

## Decision records (ADRs)

Use `templates/ADR.md` when:

- A decision will persist longer than a PR
- It affects multiple teams/systems
- It trades off operational complexity vs. delivery speed
