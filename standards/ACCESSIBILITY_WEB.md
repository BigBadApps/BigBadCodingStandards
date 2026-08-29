# Web Accessibility Standards

Goal: ship UIs that are usable with keyboard, screen readers, and touch.

## Conformance target

- **WCAG 2.2 Level AA** is the required bar for all user-facing web UIs.
- This is now the explicit legal benchmark in major markets (US DOJ web rule, effective
  January 2026; EU Accessibility Act via EN 301 549, aligned to WCAG 2.2). Treat AA as a
  compliance requirement, not an aspiration.
- WCAG 3.0 is still a draft (Candidate Recommendation expected ~2027, Recommendation later).
  Do not design to it yet; track it, keep designing to 2.2 AA.

## WCAG 2.2 new criteria (added since 2.1 — do not miss these)

- **Target Size (Minimum) 2.5.8 (AA)** — pointer targets are at least **24×24 CSS px**, or
  have sufficient spacing. Aim for 44×44 for primary touch controls.
- **Focus Not Obscured (Minimum) 2.4.11 (AA)** — the focused element is never fully hidden
  by sticky headers, footers, cookie banners, or overlays.
- **Dragging Movements 2.5.7 (AA)** — any drag interaction has a single-pointer
  (tap/click) alternative.
- **Accessible Authentication (Minimum) 3.3.8 (AA)** — no cognitive function test (e.g.
  remembering/transcribing) required to log in; allow paste, password managers, passkeys.
- **Consistent Help 3.2.6 (A)** — help mechanisms appear in the same relative order across
  pages.
- **Redundant Entry 3.3.7 (A)** — do not force users to re-enter information already
  provided in the same process.

## Baseline requirements (must)

- **Keyboard support**
  - All interactive elements are reachable and operable via keyboard.
  - Visible focus indicator is present and not suppressed.
- **Semantic HTML**
  - Use native elements (`button`, `a`, `input`, `label`) before divs.
  - Use headings in order (don’t skip levels without reason).
- **Labels and names**
  - Inputs have associated labels.
  - Icon-only controls have accessible names.
- **Color and contrast**
  - Do not rely on color alone to convey meaning.
  - Text contrast at least **4.5:1** (**3:1** for large text ≥24px, or ≥18.66px bold).
  - Non-text UI (control boundaries, focus indicators, icons that carry meaning) at least **3:1**.
- **Dynamic content**
  - Modals trap focus and restore it on close.
  - Announce important async updates when needed (ARIA live regions).
- **Motion**
  - Respect reduced-motion preferences.

## Common pitfalls to avoid

- Click handlers on non-interactive elements without keyboard equivalents.
- Missing `alt` text (or using non-informative placeholders).
- Focus loss after route changes or dialog interactions.
- Custom components that don’t expose the right roles/states.

## Testing expectations

- Run an automated checker (axe-core or equivalent) in CI for core pages; gate on new
  violations. Automated tools catch ~30–40% of issues — necessary, not sufficient.
- Include at least one manual accessibility check per critical flow:
  - keyboard-only navigation (including focus visibility and focus not obscured)
  - screen-reader sanity check for core pages
  - target size and drag-alternative check on touch
- Verify reduced-motion and 200% zoom / 320px reflow on layout-heavy pages.

