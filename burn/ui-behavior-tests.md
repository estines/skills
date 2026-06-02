# UI behavior tests

When a task touches UI, cover it with **behavior tests** — not unit TDD on components, not snapshot-only tests.

Behavior tests assert **what the user sees and can do**, not implementation details.

Referenced from [tdd-default.md](tdd-default.md) after unit TDD and coverage for each acceptance criterion (or as the sole test strategy when the task is UI-only).

---

## When required

Run UI behavior tests when the task creates or changes any of:

- Components, pages, layouts, modals, forms
- Client-side routes or navigation flows
- User-visible loading, empty, error, or success states

Skip when the task is **business-logic-only** with no user-facing surface. Concrete heuristic: skip if the task file contains none of the following keywords — `component`, `page`, `route`, `form`, `modal`, `view`, `screen`, `UI`, `render`, `layout`, or a framework UI import (e.g. `React`, `SwiftUI`, `Composable`). If any keyword is present, run behavior tests.

List **UI files** alongside business-logic files in the test plan.

---

## Given–When–Then (user-level AAA)

Every behavior test uses three visible sections:

```text
// Given — render page/component with realistic providers, route, and data (mock API at boundary)
// When  — one user action (click, type, submit, keyboard)
// Then  — observable outcome the user would notice
```

Rules:
- **One When** per test — one user action or flow step
- Query by **role, label, or accessible name** (`getByRole`, `getByLabelText`) — not CSS classes, `data-testid`, or DOM structure unless no accessible alternative exists
- Mock **network and services at the boundary** (MSW, fetch mock, stubbed ports) — do not mock child components or hooks inside the UI under test
- Assert **outcomes**: visible text, enabled/disabled controls, URL, focus, aria attributes, toasts, list contents — not internal state, prop calls, or CSS values
- Name tests as user stories: `when_{situation}_user_{action}_then_{outcome}`

---

## What to cover (per acceptance criterion with UI)

For each criterion, derive behavior cases from the user's perspective:

- **Happy path**: primary interaction succeeds; user sees expected result
- **Guard states**: button disabled, field hidden, message shown when rules fail
- **Feedback**: loading indicator, validation message, error banner, success confirmation
- **Navigation**: lands on correct page or section after action

Do **not** write behavior tests for:

- Pixel layout, fonts, colors, animation timing
- Private state, custom hook internals, context wiring
- Third-party widget internals (trust the library; test your integration surface only)

---

## Red-green-refactor loop (one behavior at a time)

Use `{ui test command}` from [detect-test-runner.md](detect-test-runner.md). Same discipline as unit TDD: never implement UI ahead of a failing behavior test.

For each behavior case:

**RED:** Write one failing behavior test (Given–When–Then).
       Run: {ui test command}
       Confirm it fails. If it passes without UI implementation, report the anomaly and stop.

**GREEN:** Write the minimal UI code to make this behavior pass.
         Run: {ui test command}
         If still failing after 3 attempts, output `STUCK_HALT` (autonomous) or ask the user (interactive).

**REFACTOR:** Clean up UI and test. Re-run {ui test command}. Autonomous: proceed without asking. Interactive: ask before the next behavior.

**TICK:** A criterion with UI is not complete until **both** unit coverage (business logic) **and** all its behavior tests pass. UI-only criteria need behavior tests only.

---

## Test plan entries (Interactive)

When UI files are in scope, add `B-` prefixed cases to the test plan:

```
UI files: {path/to/Component.tsx, …}

From: "{Criterion with UI}"
  B-01: when_{situation}_user_{action}_then_{outcome} — behavior test
  B-02: when_{situation}_user_{action}_then_{outcome} — behavior test
```

Autonomous mode: derive behavior cases automatically — do not pause for confirmation.

---

## Close report

Include behavior test results at task finish:

```
Behavior tests:
  B-01: {name} — GREEN ✓
  B-02: {name} — GREEN ✓
```
