# Goal Format

Goals live in `knowledge-base/goals/` and use sequential numbering: `GOAL-0001-slug.md`, `GOAL-0002-slug.md`, etc.

Create the `knowledge-base/goals/` directory lazily — only when the first goal is written.

## Template

```md
---
status: open
---

# {Title}

## Description

{2–3 sentences: what this goal is and what it enables.}

## Why

{1–2 sentences: the motivation or problem this goal solves.}

## Acceptance criteria

- [ ] {Observable, testable outcome}
- [ ] {Observable, testable outcome}

## Tasks

<!-- TASK-NNNN references, populated when tasks are created from this goal. -->

## Notes

<!-- Optional: constraints, open questions, links to related goals or ADRs. -->
```

## Status values

| Value         | Meaning                          |
|---------------|----------------------------------|
| `open`        | Not started                      |
| `in-progress` | Being worked on                  |
| `done`        | All acceptance criteria met      |
| `deferred`    | Intentionally postponed          |
| `cancelled`   | Will not be pursued              |

## Naming

`GOAL-{NNNN}-{slug}.md`

- `NNNN`: zero-padded sequential number (scan existing files for highest, increment by one)
- `slug`: title lowercased, spaces → hyphens, punctuation stripped

Examples: `GOAL-0001-add-user-authentication.md`, `GOAL-0004-support-csv-export.md`

## Referencing goals

Use `GOAL-NNNN` (e.g., `GOAL-0003`) as a short reference in tasks, ADRs, and commit messages.

## Goal vs Task

| | Goal | Task |
|---|---|---|
| Scope | What we want to achieve | A discrete unit of work |
| Driven by | User intent, product need | A goal |
| Done when | Acceptance criteria all met | Single deliverable complete |
| Reference | `GOAL-NNNN` | `TASK-NNNN` |

A goal typically spawns 1–10 tasks. If a goal would spawn more than ~10 tasks, consider splitting it into sub-goals.

## Title style

Use imperative form: "Add X", "Support Y", "Remove Z", "Migrate A to B".
Avoid: "Adding X", "X support", "X feature".
