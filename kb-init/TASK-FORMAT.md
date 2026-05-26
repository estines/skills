# Task Format

Tasks live in `knowledge-base/tasks/` and use sequential numbering: `TASK-0001-slug.md`, `TASK-0002-slug.md`, etc.

Create the `knowledge-base/tasks/` directory lazily — only when the first task is needed.

## Template

```md
---
status: open
---

# {Short title of the task}

## Summary

{2–4 sentences describing what needs to be done and why.}

## Acceptance criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Notes

{Optional: context, constraints, links to related ADRs or tasks.}
```

## Status values

| Value       | Meaning                          |
|-------------|----------------------------------|
| `open`      | Not started                      |
| `in-progress` | Being worked on                |
| `done`      | Completed                        |
| `deferred`  | Intentionally postponed          |
| `cancelled` | Will not be done                 |

## Numbering

Scan `knowledge-base/tasks/` for the highest existing `TASK-NNNN` number and increment by one.

## When to create a task

Create a task when the work:
- Has a clear outcome (something will change or exist that doesn't now)
- Takes more than a few minutes
- Might be interrupted, handed off, or revisited later

Avoid creating tasks for one-liners, ephemeral questions, or things that are already done.

## Referencing tasks

Use `TASK-NNNN` (e.g., `TASK-0003`) as a short reference in ADRs, commit messages, and agent context files.
