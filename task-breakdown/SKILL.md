---
name: task-breakdown
description: Break a large task (8+ story points) into sub-tasks of 1–3 points each. Reads the parent task file to inherit constraints. Writes sub-tasks to TASK-NNNN-slug/subtasks/ and updates the parent task with a Sub-tasks section. Use when a task is too large to deliver cleanly, mentions "task-breakdown", or types /task-breakdown.
trigger: /task-breakdown
argument-hint: "[optional: TASK-NNNN]"
---

# Task Breakdown

Decompose a large task into focused sub-tasks that can each be tested and deliver fast feedback. Sub-tasks target 1–3 story points.

---

## Phase 1 — Identify the task

If an argument was passed (e.g., `/task-breakdown TASK-0003`), use that task reference.

If no argument was passed:
- Scan the current conversation for a recently mentioned task (`TASK-NNNN`)
- If exactly one task is unambiguous, use it
- If ambiguous or none found, ask: "Which task should I break down? (e.g. TASK-0001)"

Locate the task file at `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md`. Read it fully — title, summary, acceptance criteria, and notes.

---

## Phase 2 — Inherit constraints

Do **not** re-scan ADRs or CONTEXT.md. Instead:

- Read the parent task's `## Notes` section — this already contains the relevant ADRs, domain language, and architectural constraints
- Read the parent task's `## Acceptance criteria` — sub-tasks must collectively satisfy all of them
- Note the parent task's `goal:` frontmatter to locate the goal directory

---

## Phase 3 — Decompose into sub-tasks

Using the parent task's acceptance criteria as the decomposition target, produce sub-tasks where:

- Each sub-task is a **focused, testable slice** — it delivers one observable outcome that can be reviewed independently
- Each sub-task targets **1–3 story points** (hard guideline — this is the point of breaking down)
- Sub-tasks are ordered by dependency (earlier sub-tasks unblock later ones)
- A task typically produces 3–6 sub-tasks; if more are needed, consider whether the parent task should be split into multiple tasks instead

Assign a **Fibonacci story point estimate** to each sub-task:

| Points | Meaning |
|--------|---------|
| 1 | Trivial — a few lines, no unknowns |
| 2 | Small — clear path, minimal risk |
| 3 | Medium — some decisions to make |

Sub-tasks must not exceed 3 points. If you find yourself wanting to assign 5+, split further.

---

## Phase 4 — Confirm

Present the full breakdown for approval before writing anything:

```
Task: TASK-NNNN — {Title}

Proposed sub-tasks:

| # | Title | Points | Delivers… |
|---|-------|--------|-----------|
| STASK-0001 | {title} | {pts} | {one-line testable outcome} |
| STASK-0002 | {title} | {pts} | {one-line testable outcome} |
…

Total: {N} sub-tasks, {sum} points

Adjust any titles, points, or order before I write the files.
```

Wait for the user to confirm or correct. Apply corrections. Re-present only if changes are significant.

---

## Phase 5 — Write sub-task files

Once confirmed:

### Locate or create the subtasks folder

The parent task file is at `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md`.

Convert the parent task to a directory if it is currently a flat file:
1. Read the file contents
2. Create the directory `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/`
3. Write the task content to `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/TASK.md`
4. Delete the original flat file

Create `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/subtasks/` if it does not exist.

### Sub-task numbering

Scan the `subtasks/` folder for the highest existing `STASK-NNNN` number. Start from that number + 1. If the folder is new, start at `STASK-0001`.

### Sub-task file name

`STASK-{NNNN}-{slug}.md` where slug is the title lowercased, spaces → hyphens, punctuation stripped.

### Sub-task file template

```md
---
status: open
story_points: {N}
task: TASK-{NNNN}
goal: GOAL-{NNNN}
---

# {Sub-task title}

## Summary

{2–3 sentences: what needs to be done and what testable outcome it delivers.}

## Acceptance criteria

- [ ] {Observable, testable outcome}
- [ ] {Observable, testable outcome}

## Notes

{Constraints inherited from parent task that are relevant here. Omit section if nothing applies.}
```

Write one file per sub-task.

---

## Phase 6 — Update the parent task file

Open the parent task file (`.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/TASK.md` or the flat `.md` if not yet converted).

Add or replace the `## Sub-tasks` section:

```markdown
## Sub-tasks

- STASK-0001 — {Title} ({N} pts)
- STASK-0002 — {Title} ({N} pts)
…
```

Place this section after `## Acceptance criteria` and before `## Notes`.

---

## Phase 7 — Close

List every file written or updated. Tell the user:

```
Created {N} sub-tasks under .goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/subtasks/
Updated TASK.md with sub-task references.

Pick up STASK-0001 to start:
.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/subtasks/STASK-0001-slug.md
```
