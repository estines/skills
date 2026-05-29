---
name: breakdown
description: Break a goal into vertical-slice tasks with Fibonacci story point estimates. Checks ADRs, domain language, and user rules before decomposing. Use when the user wants to create tasks from a goal, mentions "breakdown", or types /breakdown.
trigger: /breakdown
argument-hint: "[optional: GOAL-NNNN]"
---

# Goal Breakdown

Decompose a goal into vertical-slice tasks, informed by codebase constraints and architectural decisions. Confirm estimates before writing.

---

## Phase 1 — Identify the goal

If an argument was passed (e.g., `/goal-breakdown GOAL-0003`), use that goal reference.

If no argument was passed:
- Scan the current conversation for a recently mentioned or created goal (`GOAL-NNNN`)
- If exactly one goal is unambiguous, use it
- If ambiguous or none found, ask: "Which goal should I break down? (e.g. GOAL-0001)"

Locate the goal file at `knowledge-base/goals/GOAL-NNNN-slug.md`. Read it fully — title, description, why, acceptance criteria, and notes.

---

## Phase 2 — Gather constraints

Before decomposing, read these sources in order. Stop reading a source early if it is absent.

1. **`knowledge-base/adr/`** — scan all ADR files; note any decisions that constrain how this goal's work must be done
2. **`knowledge-base/agents/CONTEXT.md`** — note canonical terms; tasks must use this language
3. **`CLAUDE.md` and `.claude/rules/`** — note any user-set rules or constraints
4. **Goal `## Notes` section** — explicit constraints the goal author recorded
5. **Relevant source code** — only if the goal references a specific area; read just enough to understand current structure

Collect a short list of relevant findings. These will surface in the confirmation step and be embedded in task notes.

---

## Phase 3 — Decompose into tasks

Using the goal's acceptance criteria as the decomposition target, produce a set of tasks where:

- Each task is a **vertical slice** — it delivers an observable, testable outcome end-to-end (not a layer, not a subtask)
- Each task is independently reviewable and can receive feedback on its own
- A goal typically produces 2–8 tasks; if more than 8 are needed, note that the goal may need splitting

Assign a **Fibonacci story point estimate** to each task:

| Points | Meaning |
|--------|---------|
| 1 | Trivial — a few lines, no unknowns |
| 2 | Small — clear path, minimal risk |
| 3 | Medium — some decisions to make |
| 5 | Large — non-trivial, some uncertainty |
| 8 | Very large — significant uncertainty; consider splitting |
| 13 | Too big — must be split before starting |

### Dependency analysis

After drafting all tasks, infer dependencies by examining what each task **produces** and what each task **needs**. A task B is blocked by task A if B's outcome requires an artifact, state, or behaviour that A delivers.

Assign each task a **sequence number**:
- **Sequence 1** — no dependencies; can start immediately
- **Sequence N** — depends on one or more tasks at sequence N-1 (or lower)
- Tasks with identical blocker sets share the same sequence number and can run in parallel

**Circular dependency rule:** If a circular dependency is detected, restructure the breakdown (split or reorder tasks) until no cycles exist. Never present a circular dependency to the user.

Order tasks for writing by sequence number (sequence 1 first), then within the same sequence by logical order.

---

## Phase 4 — Confirm

Present the full breakdown for approval before writing anything:

```
Goal: GOAL-NNNN — {Title}

Relevant constraints found:
- {ADR or rule reference}: {one-line summary}
- …

Proposed tasks:

| # | Title | Points | Sequence | Blocked by |
|---|-------|--------|----------|------------|
| — Sequence 1 — |
| TASK-0001 | {title} | {pts} | 1 | — |
| — Sequence 2 — |
| TASK-0002 | {title} | {pts} | 2 | TASK-0001 |
| TASK-0003 | {title} | {pts} | 2 | TASK-0001 |
| — Sequence 3 — |
| TASK-0004 | {title} | {pts} | 3 | TASK-0002, TASK-0003 |

Total: {N} tasks, {sum} points

Adjust any titles, points, order, dependencies, or split/merge tasks before I write the files.
```

Wait for the user to confirm or correct. Apply corrections. Re-present only if changes are significant.

---

## Phase 5 — Write task files

Once confirmed:

### Locate or create the tasks folder

Check if `knowledge-base/goals/GOAL-NNNN-slug/` exists as a directory.

- If the goal currently exists as a **file** (`GOAL-NNNN-slug.md`), convert it:
  1. Read the file contents
  2. Create the directory `knowledge-base/goals/GOAL-NNNN-slug/`
  3. Write the goal content to `knowledge-base/goals/GOAL-NNNN-slug/GOAL.md`
  4. Delete the original flat file
- If the directory already exists, the goal file is at `knowledge-base/goals/GOAL-NNNN-slug/GOAL.md`

Create `knowledge-base/goals/GOAL-NNNN-slug/tasks/` if it does not exist.

### Task numbering

Scan `knowledge-base/goals/GOAL-NNNN-slug/tasks/` for the highest existing `TASK-NNNN` number. Start from that number + 1. If the folder is new, start at `TASK-0001`.

### Task file name

`TASK-{NNNN}-{slug}.md` where slug is the title lowercased, spaces → hyphens, punctuation stripped.

### Task file template

```md
---
status: open
story_points: {N}
goal: GOAL-{NNNN}
blocked_by: [TASK-{NNNN}, TASK-{NNNN}]   # omit this line entirely for sequence-1 tasks
---

# {Task title}

## Summary

{2–4 sentences: what needs to be done, why, and what it delivers.}

## Acceptance criteria

- [ ] {Observable, testable outcome}
- [ ] {Observable, testable outcome}

## Notes

{Relevant constraints from ADRs, rules, or domain language that shaped this task. Omit section if nothing applies.}
```

Write one file per task.

---

## Phase 6 — Update the goal file

Open `knowledge-base/goals/GOAL-NNNN-slug/GOAL.md`. Find the `## Tasks` section and replace the placeholder comment with a task list:

```markdown
## Tasks

- TASK-0001 — {Title} ({N} pts)
- TASK-0002 — {Title} ({N} pts)
…
```

Also update the goal's `status` frontmatter from `open` to `in-progress` if it was `open`.

---

## Phase 7 — Close

List every file written or updated. Tell the user:

```
Created {N} tasks under knowledge-base/goals/GOAL-NNNN-slug/tasks/
Updated GOAL.md with task references.

Pick up any Sequence 1 task to start:
- knowledge-base/goals/GOAL-NNNN-slug/tasks/TASK-0001-slug.md
- knowledge-base/goals/GOAL-NNNN-slug/tasks/TASK-0002-slug.md  (if also Sequence 1)
```
