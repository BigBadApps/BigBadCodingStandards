# Software Supply Chain Standards

Third-party code and the systems that build and publish your own code are part of your
attack surface. Treat the supply chain as a first-class security and reliability concern.

This standard reflects **OWASP Top 10:2025 A03 – Software Supply Chain Failures**, which
replaced and broadened the older "Vulnerable and Outdated Components" category. See
`standards/SECURITY.md` for the broader security context and `standards/DEPENDENCIES.md`
for day-to-day dependency selection.

## Threat model (why this matters)

Recent ecosystem attacks (self-propagating npm worms, mass maintainer-account takeovers,
malicious post-install scripts, dependency confusion, compromised CI credentials) share a
pattern:

- A trusted package or build step is silently replaced with a malicious version.
- The malicious code runs with the privileges of the developer machine or the CI pipeline.
- It exfiltrates secrets/tokens or publishes further malicious versions.

Defense is layered: **know what you depend on**, **slow down adoption**, **verify origin**,
and **contain blast radius**.

## Dependency intake (must)

- **Pin and commit lockfiles** for every package manager in the repo.
- Install with the **frozen/CI mode** of the package manager, never the "resolve and
  update" mode:
  - npm: `npm ci`
  - pnpm: `pnpm install --frozen-lockfile`
  - yarn: `yarn install --immutable`
  - pip: install from a hashed lock (`pip install --require-hashes` / uv / Poetry lock)
  - cargo/go: commit `Cargo.lock` / `go.sum`
- **Adoption cooldown**: do not adopt a brand-new version of a dependency the day it is
  published. Prefer versions that are at least a few days old, or use a tool that enforces
  a cooldown window. Most malicious releases are caught and yanked quickly.
- **Prefer packages with published provenance / Trusted Publishing** (e.g. the npm
  provenance badge). Provenance proves the artifact was built by a known CI pipeline from a
  known source commit, not uploaded from a compromised laptop.
- **Disable install scripts by default** in CI where feasible (`npm config set
  ignore-scripts true` or equivalent) and allow-list only the packages that genuinely need
  them.
- Evaluate critical dependencies with **OpenSSF Scorecard** (maintenance, review process,
  branch protection, signed releases, dangerous-workflow checks).

## Build and publish integrity (must)

- **Separate build rights from publish rights.** The identity that runs CI builds must not
  be the identity that can publish releases.
- Use **short-lived, least-scope credentials** for CI. No long-lived org-wide publish
  tokens sitting in CI secrets.
- Builds must be **reproducible / deterministic** where the toolchain allows: pinned base
  images, pinned tool versions, no network access during the build step beyond the
  dependency fetch.
- Pin third-party CI actions/steps to a **full commit SHA**, not a floating tag.
- Restrict who/what can trigger release workflows; require review for changes to CI
  configuration.

## Provenance and SBOM (must for released artifacts)

- Generate a **build provenance attestation** for each released artifact, following the
  **SLSA** framework. The attestation names the source repository, source commit, build
  platform, build parameters, and the artifact digest, and is signed.
- Generate an **SBOM** (Software Bill of Materials) for each release in **SPDX** or
  **CycloneDX** format. Store it alongside the artifact and reference it from the
  provenance.
- Publish releases with **signed artifacts** (Sigstore/cosign or equivalent) where the
  ecosystem supports it.
- Consumers should **verify provenance and signatures** before promoting an artifact to
  production where verification tooling exists.

Target: **SLSA Build Level 2+** for services and published libraries. Level 3 for
high-value or widely consumed artifacts.

## Secrets and token hygiene (must)

- No secrets in the repo, in build logs, or in error messages (see `standards/SECURITY.md`).
- CI tokens: least scope, short TTL, environment-scoped, and never exposed to workflows
  triggered by untrusted contributors (e.g. `pull_request` from forks).
- Rotate any credential that may have been exposed to a compromised dependency or build
  immediately, and treat it as compromised, not "probably fine".

## Monitoring and response (must)

- Subscribe to security advisories for the languages/registries you use.
- Run automated dependency vulnerability scanning in CI; fail the build on
  high/critical severity with a known fix.
- Have a documented process to:
  - identify all repos/services affected by a compromised package + version range,
  - pin or roll back quickly,
  - rotate exposed credentials,
  - verify no malicious version was ever built or deployed.

## Checklist (new or updated dependency / release pipeline)

- [ ] Lockfile committed; CI uses frozen-install mode.
- [ ] New dependency passed the intake checklist in `standards/DEPENDENCIES.md`.
- [ ] Adoption cooldown respected for new versions.
- [ ] Install scripts reviewed / disabled where not needed.
- [ ] CI actions pinned to commit SHA.
- [ ] Build and publish identities are separate; credentials are short-lived and least-scope.
- [ ] Release produces a signed SLSA provenance attestation.
- [ ] Release produces an SPDX or CycloneDX SBOM.
- [ ] Vulnerability scan runs in CI and gates on high/critical.
