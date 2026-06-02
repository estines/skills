# Single-task mode — TASK or STASK argument

Interactive TDD execution for one task or sub-task.

**Invariants:** AAA unit tests on business logic (≥90% line coverage). Given–When–Then behavior tests on UI. One test at a time. Never batch tests. Never implement ahead of a failing test.

---

## Phase 1 — Identify the task

If an argument was passed (e.g., `/burn TASK-0001` or `/burn STASK-0002`), use that reference directly.

If no argument was passed:
- Scan the current conversation for a recently mentioned `TASK-NNNN` or `STASK-NNNN`
- If exactly one is unambiguous, use it
- If ambiguous or none found, ask: "Which task should I execute? (e.g. TASK-0001)"

### Locate the task file

Tasks may exist in two forms. Check in this order:

1. **Flat file:** `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md`
2. **Directory form** (created by `/task-breakdown`): `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/TASK.md`

Use whichever form exists. If neither exists, report: "Task file not found for TASK-NNNN. Check the goal directory."

Read the task file fully — title, summary, acceptance criteria, notes, goal reference, and `skills:` frontmatter.

### Check blockers

Read the task's `blocked_by:` frontmatter. For each referenced task (e.g., `TASK-0002`):

- Locate that task's file (flat or directory form)
- Read its `status:` frontmatter
- If status is **not** `done`, hard-stop:

```
Cannot start TASK-NNNN — blocked by:
  - TASK-NNNN ({Title}) — status: {status}

Complete the blocking task(s) first.
```

Only proceed when all blockers are `done`.

### Handle sub-tasks

If the task is in directory form, check for a `subtasks/` folder at `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/subtasks/`.

If sub-tasks exist:
- List all `STASK-NNNN-*.md` files in filename order (STASK-0001, STASK-0002, …)
- Find the first sub-task whose `status:` is not `done`
- Each prior STASK is an implicit blocker for the next — do not skip ahead
- If all sub-tasks are `done`, update the parent task `status` to `done` and stop: "All sub-tasks are already done. Task marked complete."

**Burn the identified STASK** as the active work item for Phases 2–5. Report to the user:

```
Resuming TASK-NNNN — {Title}
Starting at: STASK-NNNN — {Sub-task Title}
(STASK-XXXX already done)
```

If there are no sub-tasks (flat file or directory with no `subtasks/`), burn the task itself.

### Read goal context

- **`.goals/GOAL-NNNN-slug/GOAL.md`** — parent goal context
- **`.goals/GOAL-NNNN-slug/CONTEXT.md`** — agent steering context: canonical terms, resolved decisions, and constraints. Apply this language throughout the session.

### Load task skills

If the active task's frontmatter contains a `skills:` list:

- Iterate the slugs in order; find the **first** slug whose file exists at `.goals/skills/{slug}.md` and read it
- The skill body (everything after the closing `---` of the frontmatter) **replaces** Phase 4 (red-green-refactor loop) entirely — do not run the default TDD loop
- If no matching file is found for any slug, proceed with the default TDD phases below
- Skills not found in `.goals/skills/` are silently skipped (a slug may refer to an installed global skill used as a label; that does not change behaviour here)

---

## Phase 2 — Detect the project

Follow [detect-test-runner.md](detect-test-runner.md).

---

## Phase 3 — Derive the test plan

If no custom skill replaced Phase 4, follow the **Interactive → Derive the test plan** section in [tdd-default.md](tdd-default.md).

---

## Phase 4 — Red-green-refactor loop

If no custom skill replaced this phase, follow the **Interactive → Red-green-refactor loop** section in [tdd-default.md](tdd-default.md).

---

## Phase 5 — Close

When all unit and behavior tests are green and every criterion passed its coverage check:

1. Run the full test suite and {ui test command} one final time to confirm no regressions
2. Run the coverage command on business-logic files — all must be ≥90% line coverage
3. Update the active task file's `status` frontmatter to `done`
4. Report:

```
Task complete: TASK-NNNN — {Title}

Unit tests:
  T-01: {test name} — GREEN ✓
  T-02: {test name} — GREEN ✓
  …

Behavior tests:
  B-01: {test name} — GREEN ✓
  … (omit section if no UI)

Coverage (business logic):
  {file}: {NN}% lines ✓

All tests passing. Coverage threshold met. Task marked done.
```

### Sub-task continuation

If the completed task was a STASK, check whether the next STASK exists in filename order:

- If a next STASK exists and is `open`: report "Next up: STASK-NNNN — {Title}. Run `/burn` to continue." and stop.
- If all STASKs are now `done`: update the parent task `status` to `done` and report "All sub-tasks complete. Parent TASK-NNNN marked done."

Tell the user the file path(s) changed so they can commit.
