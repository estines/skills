# Workflow — Feature mode (`/squad feature "<desc>" [--path <repo>]`)

Add a **new feature to an existing codebase that impacts the existing flow** — the
most common real case. Neither pure greenfield (would build blind into live flow)
nor pure reverse (recovers but doesn't build). Feature mode bridges them: recover
the impacted slice, **pin its behavior**, then build forward without breaking it.
Same personas; reuses the `role-*.md` files.

Artifacts land under `dossier/feature-<slug>/`.

---

## Phase P — Execution Preview (runs first)

Same gate as greenfield, with emphasis on **blast radius** and **regression**:
- **Intent restatement** + acceptance criteria for the new feature.
- **Plan of record** = the F1 impact map: file tree tagged new / touched /
  unchanged.
- **Test-case scenarios** = acceptance scenarios for the new behavior **plus
  regression scenarios** asserting impacted existing flows stay identical.
- **Open questions** — thresholds, flags, fallback behavior, scope.

Approve → run F0–F8. The approved regression scenarios are exactly what F3
characterization tests and F7 must satisfy.

---

## Phases F0–F8

| # | Phase | Lead | Gate artifact (`dossier/feature-<slug>/`) | Guardrail |
|---|-------|------|--------------------------------------------|-----------|
| F0 | Intake | Product Owner | `feature-brief.md` | what + why |
| F1 | Impact recon | Architect + BA | `impact-map.md` | recover touched flow → blast radius (files, contracts, callers) |
| F2 | **Impact gate** ⛔ | Principal + QA | risk + regression scope | classify extend / modify / strangler; reject if blast radius unbounded |
| F3 | Characterization | QA | golden-master tests | pin *current* behavior of impacted paths **before any edit** |
| F4 | Design | Architect | `adr.md`, slice plan | prefer extend behind existing seams over modifying hot code |
| F5 | Build | Senior(s) ∥ | code + `dev-notes.md` | feature flag if high-blast |
| F6 | **Review** ⛔ | Principal | `review-report.md` | diff must not break the flow recovered in F1 |
| F7 | **QA gate** ⛔ | QA | `test-report.md` | new-feature tests **+ F3 regression** on impacted paths |
| F8 | Deploy | DevOps | `runbook.md` + flag rollout | staged behind flag, reversible |

---

## Why each guardrail exists

- **F1 Impact recon** — never edit a flow you haven't mapped. Output the callers,
  contracts, and files the change touches; that file tree *is* the blast radius.
- **F2 Impact gate** — Principal can **reject an unbounded change** and force a
  smaller slice or a strangler approach. Classify the change:
  - *extend* — add behind an existing seam, touch nothing hot (lowest risk)
  - *modify* — change existing code in place (needs strong characterization)
  - *strangler* — add alongside, migrate callers incrementally (for big changes)
- **F3 Characterization first** — golden-master the impacted paths **before** any
  edit. Without this, "don't break existing behavior" is unverifiable. These tests
  must reproduce current behavior exactly, then stay green through F5.
- **F6 Review** — the diff is checked against the F1 recovered flow, not just for
  local correctness.
- **F7 Regression gate** — QA proves the *old* impacted paths still pass, not only
  that the new feature works. Tests come from the Phase-P approved scenarios.
- **F8 Feature flag** — high-blast changes ship dark and roll out staged, so a
  problem is reversible without a redeploy.
