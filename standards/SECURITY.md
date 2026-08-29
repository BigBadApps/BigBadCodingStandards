# Security Standards

Security is a first-class product requirement.

## Reference model: OWASP Top 10:2025

Use the current **OWASP Top 10:2025** as the baseline risk checklist for web-facing
software. Key changes from the 2021 list that affect our standards:

- **A01 Broken Access Control** — still the top risk. **SSRF** is now folded in here: an
  attacker steering server-side requests is an access-control failure. Enforce allow-listed
  egress and validate all server-initiated URLs.
- **A02 Security Misconfiguration** — rose to #2. Complexity is the adversary. See the
  Configuration hardening section below.
- **A03 Software Supply Chain Failures** — replaced "Vulnerable and Outdated Components"
  and is much broader. See `standards/SUPPLY_CHAIN.md`.
- **A10 Mishandling of Exceptional Conditions** — new. Error paths, empty results,
  timeouts, and partial failures must be handled deliberately and fail safe. See the error
  handling rules in `standards/CODING.md`.

For LLM and agentic features, also apply `standards/AI_AGENT_SECURITY.md` (OWASP Top 10 for
LLM Applications 2025 and for Agentic Applications 2026).

## Data classification (minimum)

- **Public**: safe to disclose
- **Internal**: non-public business info
- **Sensitive**: credentials, tokens, personal data, financial data

Treat unknown data as **Sensitive**.

## Secrets and credentials

- Never commit secrets (API keys, private keys, tokens, passwords).
- Store secrets in a secrets manager (or environment variables for local dev).
- Rotate compromised credentials immediately.
- Use short-lived tokens where possible.

## Input handling

- Validate and sanitize at trust boundaries.
- Prefer allow-lists over block-lists.
- Protect against injection (SQL/NoSQL/command), XSS, deserialization bugs.
- **SSRF**: never fetch a user-influenced URL without an allow-list of hosts/schemes and
  blocked access to internal networks and cloud metadata endpoints.

## Authentication and authorization

- Authentication answers **who**; authorization answers **what they can do**.
- Enforce authorization on every privileged action (OWASP A01).
- Default deny.
- Prefer phishing-resistant methods (passkeys / WebAuthn, hardware keys) for privileged
  and internal access.

## Configuration hardening (OWASP A02)

- Secure defaults: least privilege, deny by default, minimal surface.
- No default credentials, no debug endpoints or verbose stack traces in production.
- Set security headers for web apps: `Content-Security-Policy`, `Strict-Transport-Security`,
  `X-Content-Type-Options`, a sane `Referrer-Policy`, and restrictive `Permissions-Policy`.
- Lock down CORS to known origins; no wildcard with credentials.
- Keep dev/test/prod configuration separate and reviewed; fail fast on missing/invalid
  config in deployed environments.
- Review infrastructure-as-code and cloud resource policies the same way you review code.

## Dependency and supply chain security

- Keep dependencies minimal (see `standards/DEPENDENCIES.md`).
- Update regularly and respond quickly to high-severity CVEs.
- Pin lockfiles; install in frozen/CI mode; respect an adoption cooldown for new versions.
- For build and release integrity, SBOMs, and provenance, follow
  `standards/SUPPLY_CHAIN.md`.

## Logging and privacy

- Do not log secrets, tokens, or full credentials.
- Minimize personal data in logs; redact when needed.
- Prefer event metadata over full payloads.

## Handling exceptional conditions (OWASP A10)

- Every error, timeout, empty result, and partial failure has an intended, safe handling
  path — no silent swallow, no fail-open.
- Do not leak internal detail (stack traces, queries, config) in responses; log it safely
  instead with a correlation ID.
- Fail closed for security-relevant decisions (auth, quota, feature gates).

## Secure delivery

- CI must run tests, linters, and dependency/vulnerability scanning on every PR.
- Use code review for all changes; require review before merge to `main`.
- Produce signed releases with SLSA provenance and an SBOM (`standards/SUPPLY_CHAIN.md`).

