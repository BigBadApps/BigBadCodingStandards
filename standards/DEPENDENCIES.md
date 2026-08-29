# Dependency Standards

Dependencies are part of your attack surface and operational burden.

For build integrity, provenance, SBOMs, install-script handling, and CI credential
hygiene, see `standards/SUPPLY_CHAIN.md` (OWASP Top 10:2025 A03). This document covers
choosing and maintaining dependencies.

## Default rules

- Prefer the standard library and existing dependencies.
- Add a dependency only if it:
  - reduces total complexity,
  - is maintained and widely used,
  - has a clear license story,
  - has a viable upgrade path.

## Introducing a new dependency (checklist)

- Evaluate alternatives (including “do nothing”).
- Check maintenance health (recent releases, issue response, bus factor).
- Check security posture and known CVEs; check the **OpenSSF Scorecard** for critical deps.
- Prefer packages published with **provenance / Trusted Publishing** (e.g. npm provenance badge).
- Confirm license compatibility.
- Minimize scope (import only what you need); watch transitive dependency weight.
- Respect an **adoption cooldown**: avoid versions published in the last few days.

## Versioning and upgrades

- Use lockfiles where supported; commit them; install in frozen/CI mode (`npm ci`,
  `pnpm install --frozen-lockfile`, `--require-hashes`, etc.).
- Upgrade regularly; do not allow years of drift.
- Avoid pinning to unmaintained forks without a clear owner.

## Runtime and toolchain versions

- Run only **supported / maintained** language and runtime versions. No end-of-life
  runtimes in production.
- Node.js: track Active and Maintenance LTS only. (From late 2026 Node moves to one major
  per year with all releases becoming LTS; stay on a supported line either way.)
- Pin the toolchain per repo (`.nvmrc` / `.tool-versions` / `engines` / language version
  files) so local, CI, and production match.

## Supply chain hygiene

See `standards/SUPPLY_CHAIN.md` for the full standard. Minimum here:

- Do not run untrusted install scripts; disable them in CI where feasible.
- Prefer verified publishers and official registries; watch for typosquats and dependency
  confusion.
- Keep build steps deterministic and reproducible.
