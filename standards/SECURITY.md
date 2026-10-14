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
- **SSRF**: never fetch a user-influenced URL without a scheme allow-list and blocked access
  to internal networks and cloud metadata endpoints (a host allow-list is preferred). See
  the SSRF section below.

## SSRF: server-side request forgery (must for server-side fetches)

Any server-side code that fetches a URL derived from external input must go through an
SSRF guard. External input includes request bodies, query strings, headers, stored user
data, and user-editable config.

- **Schemes**: allow only `http:` and `https:`. Block `file:`, `ftp:`, `gopher:`, `data:`,
  `javascript:`, and everything else.
- **Hosts**: prefer an exact-match allow-list of hostnames when the use case permits it.
  Never match by substring, or by suffix without a leading dot (`allowed.com.evil.com`,
  `evilallowed.com`). The address, redirect, and limit rules below apply even to
  allow-listed hosts.
- **Parsing**: parse the URL with the same parser the HTTP client uses, and check only the
  parsed hostname, never the raw string. Reject URLs with userinfo (`user:pass@`). Strip
  IPv6 brackets and zone IDs (`%eth0`), lowercase, and drop a trailing dot. Use the
  platform's IP parser (Node: `node:net` `isIP` / `BlockList`; Python: `ipaddress`), and
  never hand-roll one. A host that fails IP parsing is not safe for that reason; resolve
  it and check the result. Numeric forms such as `2130706433`, `0177.0.0.1`, and `127.1`
  all mean `127.0.0.1` to most URL parsers.
- **Check the address the socket connects to**: resolve the hostname and reject the
  request if *any* resolved address is blocked. The check must run on the address the
  socket actually uses, so a second DNS lookup (DNS rebinding) cannot return a different
  answer. Either validate inside the connect-time lookup hook (Node: a custom `lookup` on
  the `http`/`https` `Agent`, or `connect.lookup` on an undici `Agent` passed to `fetch` as
  `dispatcher`), or resolve once, check, and connect to that IP while keeping the original
  `Host` header and TLS server name. Resolving and checking in a separate step before
  calling the client is not enough. A custom Node `lookup` must handle both the
  `all: false` and `all: true` callback shapes. Fail closed on any parse, resolve, or
  check error.
- **Redirects**: do not follow redirects automatically. Follow each hop yourself, cap the
  number of hops (for example 5), resolve each `Location` against the current URL, and run
  the full guard on it before requesting it. Drop `Authorization`, `Cookie`, and other
  credential headers on cross-origin hops. Checking the final URL after an automatic
  redirect is too late, because the internal request has already been sent.
- **Limits**: set connect and read timeouts, and enforce a maximum response size while
  streaming (not from `Content-Length`). Return the same generic error for blocked,
  refused, and timed-out requests, so error differences cannot be used to scan internal
  ports.
- **Where the guard does not reach**: an in-process guard does not apply behind a forward
  proxy (the proxy resolves and connects), or to headless browsers, HTML/PDF renderers,
  image/SVG/XML processors, and webhook senders that open their own connections. Enforce
  deny-by-default egress at the network layer for those. On AWS, require IMDSv2 with a hop
  limit of 1.

| Range | CIDR | Why |
| ----- | ---- | --- |
| Loopback | `127.0.0.0/8`, `::1` | Local services |
| Unspecified and IPv4-compatible | `0.0.0.0/8`, `::/96` | Can reach local services; `::/96` also covers `::` and `::1` |
| Link-local and cloud metadata | `169.254.0.0/16`, `fe80::/10` | AWS, GCP, and Azure metadata at `169.254.169.254`; `fe80::/10` is IPv6 link-local |
| Private | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | Internal network |
| Unique local (IPv6) | `fc00::/7` | Internal network; includes AWS IMDS over IPv6 at `fd00:ec2::254` |
| Shared address space (CGNAT) | `100.64.0.0/10` | Carrier and cloud internal; includes Alibaba Cloud metadata at `100.100.100.200` |
| IETF protocol assignments | `192.0.0.0/24` | Not publicly routed; listed in public SSRF references as an Oracle Cloud metadata range |
| Azure platform endpoint | `168.63.129.16/32` | Azure WireServer; looks public but is not |
| Benchmarking | `198.18.0.0/15` | Not publicly routed |
| Reserved and broadcast | `240.0.0.0/4` | Not publicly routed |
| Documentation, multicast, deprecated IPv6 | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`, `224.0.0.0/4`, `ff00::/8`, `2001::/32`, `2001:db8::/32`, `fec0::/10` | Never legitimate fetch targets |
| IPv4-mapped IPv6 | `::ffff:0:0/96` | `::ffff:127.0.0.1` bypasses IPv4-only checks |
| NAT64 | `64:ff9b::/96`, `64:ff9b:1::/48` | Embeds an IPv4 address (`64:ff9b::a9fe:a9fe` = `169.254.169.254`); some NAT64 setups translate it even though RFC 6052 forbids non-global IPv4 there |
| 6to4 | `2002::/16` | Embeds an IPv4 address |

On IPv6-only networks that use DNS64/NAT64, public IPv4-only sites resolve into
`64:ff9b::/96`, so blocking it wholesale breaks outbound traffic. There, extract the
embedded IPv4 address (the last 32 bits) and apply the IPv4 rules to it instead. Python's
`ipaddress` reports NAT64 addresses as global, so `is_global` alone is not enough. Node's
`BlockList` applies IPv4 rules to IPv4-mapped addresses but does not unwrap NAT64 or 6to4.

### SSRF tests (must)

Every SSRF guard has unit tests that cover:

- at least one address in each blocked range, plus `localhost` and `localhost.`;
- non-http schemes (`file:///etc/passwd`, `gopher:`, `data:`), including mixed case;
- numeric IPv4 forms: decimal `2130706433`, octal `0177.0.0.1`, hex `0x7f.1`, short `127.1`;
- IPv6 bracket forms (`[::1]`, `[fe80::1]`), IPv4-mapped forms (`::ffff:127.0.0.1` and
  `::ffff:7f00:1`), NAT64 (`64:ff9b::a9fe:a9fe`), and 6to4 (`2002:7f00:1::`);
- metadata addresses: `169.254.169.254`, `fd00:ec2::254`, `100.100.100.200`, `168.63.129.16`;
- userinfo and allow-list bypasses: `http://allowed.com@127.0.0.1/`, `allowed.com.evil.com`;
- a resolver answer that mixes a public and a private address (must be rejected);
- a rebinding resolver (public on the first lookup, private on the second), run against
  the real connect path rather than only the pure check function;
- redirects: to a blocked address, a relative `Location`, a non-http scheme, past the hop
  cap, and credential headers dropped on a cross-origin hop;
- timeout and maximum-response-size enforcement;
- at least two public hosts that must be allowed.

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
