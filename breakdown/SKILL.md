---
name: breakdown
description: Break a goal into vertical-slice tasks with Fibonacci story point estimates. Checks ADRs, domain language, and user rules before decomposing. Assigns execution skills to each task, reusing existing skills where possible and creating new ones in .goals/skills/ when needed. Use when the user wants to create tasks from a goal, mentions "breakdown", or types /breakdown.
trigger: /breakdown
argument-hint: "[optional: GOAL-NNNN]"
---

# Goal Breakdown

Decompose a goal into vertical-slice tasks, informed by codebase constraints and architectural decisions. Confirm estimates before writing.

---

## Phase 1 — Identify the goal

If `.goals/` does not exist at the project root, stop: "`.goals/` not found. Run `/goals-init` first."

If an argument was passed (e.g., `/breakdown GOAL-0003`), use that goal reference.

If no argument was passed:
- Scan the current conversation for a recently mentioned or created goal (`GOAL-NNNN`)
- If exactly one goal is unambiguous, use it
- If ambiguous or none found, ask: "Which goal should I break down? (e.g. GOAL-0001)"

Locate `.goals/GOAL-NNNN-slug/GOAL.md`. Read it fully — title, description, why, acceptance criteria, and notes.

---

## Phase 2 — Gather constraints

Before decomposing, read these sources in order. Stop reading a source early if it is absent.

1. **`.goals/adr/`** — scan all ADR files; note any decisions that constrain how this goal's work must be done
2. **`.goals/GOAL-NNNN-slug/CONTEXT.md`** — read the goal's agent context; note canonical terms, resolved decisions, and avoid-lists; tasks must use this language
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
| 8 | Very large — significant uncertainty; flag for `/task-breakdown` |
| 13 | Too big — must be split before starting |

Tasks estimated at **8 or more points** must be flagged in the confirmation table with a note: `⚠ Consider /task-breakdown TASK-NNNN after creation`

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

The goal file is at `.goals/GOAL-NNNN-slug/GOAL.md`. Create `.goals/GOAL-NNNN-slug/tasks/` if it does not exist.

### Task numbering

Scan `.goals/GOAL-NNNN-slug/tasks/` for the highest existing `TASK-NNNN` number. Start from that number + 1. If the folder is new, start at `TASK-0001`.

### Task file name

`TASK-{NNNN}-{slug}.md` where slug is the title lowercased, spaces → hyphens, punctuation stripped.

### Task file template

```md
---
status: open
story_points: {N}
goal: GOAL-{NNNN}
blocked_by: [TASK-{NNNN}, TASK-{NNNN}]   # omit this line entirely for sequence-1 tasks
skills: [{slug}, {slug}]                  # omit if no skills assigned — populated in Phase 5b
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

## Phase 5b — Assign skills to tasks

After writing all task files, determine which skills each task needs. Do this for every task before moving to Phase 6.

### Step 1 — Analyse the task type

For each task, read its title, summary, and acceptance criteria. Classify it:

- **Implementation task** — builds or modifies code; has testable outputs
- **Documentation task** — writes or updates docs, READMEs, guides
- **Infrastructure / ops task** — deploys, migrates, configures environment
- **Research / design task** — investigates options, produces a decision or spec
- **Other** — anything that doesn't fit the above

### Step 2 — Check existing skills

Check in this order. Stop at the first match.

1. **Installed skills** — check `~/.claude/skills/` and the repo's own skill directories. Common mappings:
   - Implementation task → `burn` (TDD red-green-refactor)
   - Research / design task → `brief` or `grill-with-docs`
   - Documentation task → no standard skill (may need a new one)
   - Infrastructure task → no standard skill (may need a new one)

2. **`.goals/skills/`** — scan for an existing custom skill whose name and description match the task type.

### Step 3 — Assign or create

For each task:

**If an installed skill matches:**
Add the installed skill's name as the slug directly in `skills:` frontmatter (e.g., `skills: [burn]`). No new file needed.

**If a `.goals/skills/` skill matches:**
Add its slug to `skills:`. No new file needed.

**If no existing skill matches:**
Create a new skill file at `.goals/skills/{slug}.md`. Name the file with a descriptive slug that captures the role type, not the task (e.g., `db-migration.md`, `api-scaffolder.md`, `docs-writer.md`). The goal is reuse across future tasks.

The skill body will be used verbatim as the `## Your job` section when burn's orchestrator spawns an agent for this task. Write it as direct instructions to that agent — concrete, step-by-step, specific to the task type. Synthesise the body from the task file, CONTEXT.md canonical terms, and any relevant ADR constraints you loaded in Phase 2. Do not write a placeholder or stub.

Use this file template:

```md
---
name: {slug}
description: {one-line description of the role this skill plays}
---

# {Role title}

## Role

{One sentence: what kind of task this agent executes and what it produces.}

## Steps

{Numbered steps for this task type. Be concrete:
- what to read before starting
- what to build or write
- how to verify the output is correct
- what "done" looks like

Reference canonical terms from CONTEXT.md and any ADR constraints.
Include a red-green-refactor loop only if the task type warrants TDD.}

## Done criteria

- [ ] {Observable outcome that signals this task is complete}
- [ ] {Observable outcome}
```

After creating, add the slug to the task's `skills:` frontmatter.

### Step 4 — Update task files

For each task that received skill assignments, rewrite the `skills:` frontmatter line with the resolved list. Omit the line entirely if no skills were assigned.

---

## Phase 6 — Update the goal file

Open `.goals/GOAL-NNNN-slug/GOAL.md`. Find the `## Tasks` section and replace the placeholder comment with a task list:

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
Created {N} tasks under .goals/GOAL-NNNN-slug/tasks/
Updated GOAL.md with task references.
{If new skills were created}: Created {M} skill(s) in .goals/skills/

Pick up any Sequence 1 task to start:
- .goals/GOAL-NNNN-slug/tasks/TASK-0001-slug.md
- .goals/GOAL-NNNN-slug/tasks/TASK-0002-slug.md  (if also Sequence 1)
```
