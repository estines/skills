# Workflow — Greenfield phase-gate pipeline

The default mode: build a new project from requirements to deployment. Linear,
gated. Each phase has a **lead** role, optional **support** roles, and a **gate
artifact**. State lives in `dossier/README.md`.

---

## Phase P — Execution Preview (runs first, ALWAYS)

Before any phase below, produce an **Execution Preview** and get explicit approval.
The squad never assumes intent — the preview makes its interpretation visible and
the user corrects it. Lead: Product Owner (+ Architect for technical shape).

The preview contains:

1. **Intent restatement** — "here is what I understood you want" + draft
   acceptance criteria. Catches a misread before any work.
2. **Plan of record** — which phases/roles will run + the **file tree** of
   artifacts to be created (and, for feature/brownfield, existing files touched =
   blast radius).
3. **Test-case scenarios** — Given / When / Then per acceptance criterion, plus
   regression scenarios for any impacted existing flow. *These scenarios are the
   contract.*
4. **Open questions** — anything ambiguous; ask here instead of guessing.

Write it to `dossier/00-preview/execution-preview.md` and render the HTML preview
(see [templates-html.md](templates-html.md)). Then use `AskUserQuestion`:

- **Approve** → the approved scenarios become QA's acceptance + regression suite;
  proceed to Phase 0.
- **Revise** → update the preview from the user's notes, re-present.
- **Reject** → stop. Nothing is written beyond the preview.

`--execute` skips this gate only when the user explicitly opted out.

---

## Phases 0–7

| # | Phase | Lead | Support | Gate artifact (`dossier/`) |
|---|-------|------|---------|----------------------------|
| 0 | Intake / Charter | Product Owner | — | `00-charter/project-charter.md` |
| 1 | Discovery & Requirements | Business Analyst | PO | `01-requirements/brd.md`, `user-stories.md` |
| 2 | Architecture & Design | Software Architect | PO, Seniors | `02-architecture/design.md`, `adr/ADR-NNNN.md`, `api-contracts.md`, `nfr.md` |
| 3 | Planning & Breakdown | Product Owner | Architect | `03-plan/backlog.md`, `task-breakdown.md` |
| 4 | Implementation | Senior Engineer ×platform | Architect | code + `04-build/dev-notes.md`, `changelog.md` |
| 5 | **Code Review (GATE)** | Principal Engineer | — | `05-review/review-report.md` |
| 6 | **QA & Test (GATE)** | QA Engineer | Seniors | `06-qa/test-plan.md`, `test-cases.md`, `bug-report.md`, `signoff.md` |
| 7 | Deployment | DevOps Engineer | Architect | `07-devops/runbook.md`, `ci-cd.md`, `release-notes.md` |

---

## Gate rules

- **Phase 5 (Review)** and **Phase 6 (QA)** are hard gates. A *fail* loops back to
  Phase 4 (Implementation) with the findings; re-review on return. Deploy (7) is
  blocked until both pass.
- **Principal reviews only** — emits pass/fail + findings, never edits production
  code.
- **QA verifies against the Phase-P approved scenarios** — acceptance + regression.
  No new acceptance criteria appear at QA that weren't in the approved preview.

## Parallelism

Phase 4 may run multiple Senior Engineer agents at once — one per platform
(frontend / backend / android / ios) via `TaskCreate` / `TaskGet`. Each writes its
own section of `04-build/dev-notes.md`; the orchestrator merges them before Review.

## State — `dossier/README.md`

Maintain a phase index table the orchestrator updates after every gate:

```
| Phase | Status | Artifact | Signed off |
|-------|--------|----------|------------|
| P Preview | approved | 00-preview/execution-preview.md | 2026-06-26 |
| 0 Charter | done | 00-charter/project-charter.md | yes |
| 1 Requirements | in progress | … | — |
```
