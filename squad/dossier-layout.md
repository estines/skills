# Dossier layout

The squad writes every artifact into a `dossier/` tree at the project root, plus an
optional `reports/` folder for the interactive HTML views. `dossier/README.md` is
the live phase index the orchestrator updates after each gate.

## Greenfield tree

```
dossier/
  README.md                 # phase index (state)
  00-preview/execution-preview.md
  00-charter/project-charter.md
  01-requirements/{brd.md, user-stories.md}
  02-architecture/{design.md, api-contracts.md, nfr.md, adr/ADR-0001.md, …}
  03-plan/{backlog.md, task-breakdown.md}
  04-build/{dev-notes.md, changelog.md}
  05-review/review-report.md
  06-qa/{test-plan.md, test-cases.md, bug-report.md, signoff.md}
  07-devops/{runbook.md, ci-cd.md, release-notes.md}
reports/                    # optional interactive HTML views
```

## Brownfield tree (`reverse`)

```
dossier/reverse/
  README.md
  00-preview/execution-preview.md
  scope.md
  01-flow.md
  glossary.md
  module-map.md
  crash-report.md
  refactor.md
  backlog.md
```

## Feature tree (`feature`)

```
dossier/feature-<slug>/
  README.md
  00-preview/execution-preview.md
  feature-brief.md
  impact-map.md
  characterization/            # golden-master tests (or links to them)
  adr.md
  dev-notes.md
  review-report.md
  test-report.md
  runbook.md
```

## README.md — phase index

The orchestrator keeps this table current; `/squad status` prints it.

```markdown
# Dossier — {{project}}  ({{mode}})
| Phase | Status | Artifact | Signed off |
|-------|--------|----------|------------|
| P Preview | approved | 00-preview/execution-preview.md | 2026-06-26 |
| 0 Charter | done | 00-charter/project-charter.md | yes |
| 1 Requirements | in progress | — | — |
```

Status values: `pending` · `in progress` · `done` · `blocked` (gate failed —
include the loop-back reason).
