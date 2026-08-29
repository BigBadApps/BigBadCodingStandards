# Web Performance Standards

Performance is a feature: it improves conversion, retention, and perceived quality.

## Default performance priorities

- Fast first render for core routes.
- Keep interactions responsive (avoid long main-thread tasks).
- Reduce bundle size and runtime work.

## Core Web Vitals targets (must)

Measured on **p75 of real users** (field data), mobile and desktop:

- **LCP** (Largest Contentful Paint): **≤ 2.5 s**
- **INP** (Interaction to Next Paint): **≤ 200 ms**  — INP replaced FID as a Core Web Vital in March 2024
- **CLS** (Cumulative Layout Shift): **≤ 0.1**

Supporting targets:

- **TTFB**: ≤ 800 ms for key routes.
- Treat "needs improvement" as a regression to fix, not an acceptable steady state.

## Budgets (starting point)

Treat these as defaults; adjust per product, but set explicit numbers per repo.

- **JS on core routes**: aim for ≤ ~150–200 KB compressed initial payload; code-split by route.
- **Bundle**: no unused large libraries; audit with a bundle analyzer in CI.
- **Images**: serve appropriately sized, compressed images; prefer AVIF/WebP; set explicit
  `width`/`height` or `aspect-ratio` to protect CLS.
- **JS execution**: avoid long tasks (> 50 ms) on load and on interaction; break up work.

## Practices (must)

- Use caching intentionally (HTTP cache headers, SWR strategies).
- Avoid waterfalls: parallelize independent requests.
- Defer non-critical scripts and UI work.
- Avoid layout thrash: batch DOM reads/writes; prefer CSS for animations.

## Practices (recommended)

- Preload critical resources when it measurably improves UX.
- Use virtualization for large lists.
- Use server rendering / streaming when it improves TTFB and LCP for key routes.

## Measurement

- Collect **field** Core Web Vitals (RUM) for LCP, INP, CLS — this is the source of truth.
- Use **lab** tools (Lighthouse / trace-based) in CI for regression detection on critical
  pages; gate merges on budget breaches once the setup is stable.
- Alert when p75 of any Core Web Vital crosses its target.

