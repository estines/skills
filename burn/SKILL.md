---
name: burn
description: Execute tasks from .goals/ using strict TDD red-green-refactor. When given a GOAL, runs all tasks in parallel batches by sequence — each batch uses isolated git worktrees and merges back after the batch completes. When given a single TASK or STASK, runs interactively with the full red-green-refactor loop. Use when the user wants to implement tasks with TDD, mentions "burn", or types /burn.
trigger: /burn
argument-hint: "[GOAL-NNNN | TASK-NNNN | STASK-NNNN]"
---

# TDD Task

Execute a task or a whole goal with strict red-green-refactor. One test at a time. Never batch tests. Never implement ahead of a failing test.

---

## Entry — Single task or whole goal?

**Guard:** If `.goals/` does not exist at the project root, stop: "`.goals/` not found. Run `/goals-init` first."

Check the argument:

- **`GOAL-NNNN`** → enter **Orchestrator mode** (Phase O below)
- **`TASK-NNNN` or `STASK-NNNN`** → enter **Single-task mode** (Phase 1 below)
- **No argument** → scan the current conversation for a recently mentioned `GOAL-NNNN`, `TASK-NNNN`, or `STASK-NNNN`
  - If exactly one reference is unambiguous, use it
  - If ambiguous or none found, ask: "Which goal or task should I burn? (e.g. GOAL-0001 or TASK-0001)"

---

## Orchestrator mode — GOAL argument

Execute all open tasks for a goal in parallel batches ordered by sequence. Each batch contains all tasks whose blockers are done. Tasks within a batch run in parallel, each in an isolated git worktree.

### Phase O-1 — Load goal tasks

Locate `.goals/GOAL-NNNN-slug/`. If not found, report: "Goal directory not found for GOAL-NNNN."

Scan `.goals/GOAL-NNNN-slug/tasks/` for all task files (both flat `.md` files and `TASK.md` inside directory-form tasks). For each task, read:
- `status:` frontmatter (`open`, `in-progress`, `done`, etc.)
- `blocked_by:` frontmatter (may be absent)
- Task title

Build a task map: `{ id → { title, status, blocked_by[] } }`

If there are no tasks with `status: open`, report: "No open tasks found for GOAL-NNNN." and stop.

### Phase O-2 — Compute execution batches

Using the task map, derive execution batches with the ready-set scheduler:

**Algorithm:**
1. Mark all tasks with `status: done` as already complete
2. A task is **ready** if: its `status` is `open` AND every task in its `blocked_by` list has `status: done`
3. The current batch = all ready tasks
4. After a batch is recorded, treat those tasks as complete for the purpose of computing the next batch
5. Repeat until no open tasks remain

This yields an ordered list of batches: `[Batch 1: [TASK-A, TASK-B], Batch 2: [TASK-C], ...]`

If a task has `status: in-progress`, include it in Batch 1 (treat as ready regardless of blockers).

**Circular dependency check:** If any open task is never placed in a batch (its blockers are never resolved by the batching process), report: "Circular or unresolvable dependency detected — TASK-NNNN cannot be scheduled." and stop.

### Phase O-3 — Present the execution plan

Present the plan before starting:

```
Goal: GOAL-NNNN — {Title}

Execution plan:

  Batch 1 (parallel): TASK-NNNN — {Title}, TASK-NNNN — {Title}
  Batch 2 (parallel): TASK-NNNN — {Title}
  Batch 3 (parallel): TASK-NNNN — {Title}, TASK-NNNN — {Title}

{N} tasks across {M} batches. Each batch runs in isolated git worktrees.

Proceeding — interrupt at any time.
```

Do not wait for confirmation. Print the plan and immediately begin Phase O-4.

### Phase O-4 — Execute batches

For each batch in order:

#### O-4a — Detect test runner

Before the first batch, detect the project's language and test runner (same logic as Phase 2 in single-task mode). Record the test run command — it will be embedded in every agent prompt.

#### O-4b — Spawn parallel agents

For each task in the batch, spawn one agent using the `Agent` tool with `isolation: "worktree"`. Send all agents for the batch in a **single message** (parallel tool calls).

**Before constructing each agent prompt**, resolve the `## Your job` content:

1. Read the task file's `skills:` frontmatter
2. Iterate the slugs in order; find the **first** slug whose file exists at `.goals/skills/{slug}.md` (in the main worktree — **not** inside the isolated worktree, which cannot access git-ignored files)
3. If found: read the skill file body (everything after the closing `---` of the frontmatter) — this becomes `{job steps}` below
4. If not found: use the default TDD steps as `{job steps}`

Each agent prompt must be fully self-contained. Use this template, substituting `{job steps}` with the resolved content above:

```
You are executing a task in an isolated git worktree. Work only within the files in this worktree — do not reference paths outside it.

Task: {TASK-NNNN}
Goal: {GOAL-NNNN}
Test command: {test run command}

## Setup

1. Locate the task file:
   - First check: .goals/{GOAL-NNNN-slug}/tasks/{TASK-NNNN-slug}.md
   - Then check: .goals/{GOAL-NNNN-slug}/tasks/{TASK-NNNN-slug}/TASK.md
   Read it fully — title, summary, acceptance criteria, notes.

2. Read goal context:
   - .goals/{GOAL-NNNN-slug}/GOAL.md
   - .goals/{GOAL-NNNN-slug}/CONTEXT.md (apply this language throughout)

3. Update the task file's status frontmatter to `in-progress`.

## Your job

{job steps}

## Finish

When all work is complete:
- Update task status to `done`
- If a test command applies to this task type, run {test run command} one final time to confirm no regressions
- Stage all changed files: git add -A
- Commit: git commit -m "{TASK-NNNN}: {short description of what was implemented}"
- Report: "TASK-NNNN complete."
```

**Default TDD steps** (used as `{job steps}` when no skill file is found):

```
Derive the test plan:
For each acceptance criterion, expand into TDD test cases:
- Happy path: criterion works under normal conditions
- Edge cases: boundary values, empty/min/max inputs
- Failure cases: invalid input, error conditions

Auto-confirm the test plan — do not pause for user input. Proceed immediately.

Red-green-refactor loop (strictly one test at a time):

For each test case:

RED: Write one failing test using the project's test framework and conventions.
     Run: {test run command}
     Confirm it fails. If it passes without implementation, report the anomaly and stop.

GREEN: Write the minimal implementation to make this one test pass.
       Run: {test run command}
       If still failing after 3 attempts, output the exact string STUCK_HALT on its own line and stop.

REFACTOR: Review the code. Apply any obvious improvements. Re-run tests to confirm still green. Do not ask — just refactor and proceed.

TICK: After all tests for a criterion pass, update `- [ ] {criterion}` → `- [x] {criterion}` in the task file.
```

#### O-4c — Collect batch results

After all agents in the batch finish, collect their results:

- **Success**: agent reported task complete; note the worktree branch returned by the Agent tool
- **Failure**: agent output contained `STUCK_HALT` or the agent did not mark the task `done`

For failed tasks, update that task's `status` frontmatter to `failed` in the main worktree, write a failure note beside the task file (`{TASK-NNNN-slug}-failure.md`) containing the agent's last output, and record it for the final report. Do not stop the whole batch — continue merging the successful ones.

#### O-4d — Merge worktrees

For each **successful** agent in this batch, merge its worktree branch back to the current branch:

```bash
git merge --no-ff {branch} -m "Merge {TASK-NNNN}: {title}"
```

Merge in the order agents completed. If a merge produces conflicts, stop and report:

```
Merge conflict when integrating {TASK-NNNN}.
Conflicting files: {list}
Resolve the conflicts manually, then run /burn GOAL-NNNN to continue from where it left off.
```

After all merges succeed, clean up each agent's worktree: `git worktree remove --force {path}`.

#### O-4e — Recompute ready set

Re-read all task statuses from the now-merged main worktree. Recompute the next batch using the ready-set algorithm (Phase O-2). If the next batch is non-empty, return to Phase O-4b.

### Phase O-5 — Close

When all batches are done (or no more tasks are schedulable):

```
Goal GOAL-NNNN — {Title}

Results:
  Batch 1: TASK-NNNN ✓  TASK-NNNN ✓
  Batch 2: TASK-NNNN ✓
  Batch 3: TASK-NNNN ✗ (STUCK — see TASK-NNNN-slug-failure.md)

{N} tasks done, {M} failed.
```

If all tasks are done, update the goal's `status` frontmatter to `done`.

---

## Single-task mode — TASK or STASK argument

### Phase 1 — Identify the task

If an argument was passed (e.g., `/burn TASK-0001` or `/burn STASK-0002`), use that reference directly.

If no argument was passed:
- Scan the current conversation for a recently mentioned `TASK-NNNN` or `STASK-NNNN`
- If exactly one is unambiguous, use it
- If ambiguous or none found, ask: "Which task should I execute? (e.g. TASK-0001)"

#### Locate the task file

Tasks may exist in two forms. Check in this order:

1. **Flat file:** `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md`
2. **Directory form** (created by `/task-breakdown`): `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/TASK.md`

Use whichever form exists. If neither exists, report: "Task file not found for TASK-NNNN. Check the goal directory."

Read the task file fully — title, summary, acceptance criteria, notes, goal reference, and `skills:` frontmatter.

#### Check blockers

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

#### Handle sub-tasks

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

#### Read goal context

- **`.goals/GOAL-NNNN-slug/GOAL.md`** — parent goal context
- **`.goals/GOAL-NNNN-slug/CONTEXT.md`** — agent steering context: canonical terms, resolved decisions, and constraints. Apply this language throughout the session.

#### Load task skills

If the active task's frontmatter contains a `skills:` list:

- Iterate the slugs in order; find the **first** slug whose file exists at `.goals/skills/{slug}.md` and read it
- The skill body (everything after the closing `---` of the frontmatter) **replaces** Phase 4 (red-green-refactor loop) entirely — do not run the default TDD loop
- If no matching file is found for any slug, proceed with the default TDD phases below
- Skills not found in `.goals/skills/` are silently skipped (a slug may refer to an installed global skill used as a label; that does not change behaviour here)

---

### Phase 2 — Detect the project

Before writing any tests, detect the project's language and test runner:

1. Look for `package.json` → infer Node.js; check `scripts.test` for the test command
2. Look for `pyproject.toml` or `setup.py` → infer Python; check for `pytest` or `unittest`
3. Look for `go.mod` → infer Go; test command is `go test ./...`
4. Look for `Cargo.toml` → infer Rust; test command is `cargo test`
5. Look for other build/config files as needed

If no test runner can be inferred, ask the user: "What test command should I run? (e.g. `npm test`, `pytest`, `go test ./...`)"

Record the **test run command** — it will be used in every red and green check.

---

### Phase 3 — Derive the test plan

For each acceptance criterion in the active task file (TASK or STASK), expand it into granular TDD test cases following TDD best practices:

- **Happy path**: the criterion works under normal conditions
- **Edge cases**: boundary values, empty inputs, minimum/maximum values
- **Failure cases**: invalid input, error conditions, constraint violations

Use the task summary, acceptance criteria wording, and notes to inform realistic test names and scenarios.

Produce a numbered flat list across all criteria:

```
Test plan for TASK-NNNN — {Title}

From: "{Criterion 1 text}"
  T-01: {test name} — {one-line description}
  T-02: {test name} — {one-line description}

From: "{Criterion 2 text}"
  T-03: {test name} — {one-line description}
  T-04: {test name} — {one-line description}
…

Total: {N} test cases

Does this test plan look right? Add, remove, or adjust test cases before I begin.
```

Wait for the user to confirm or correct. Apply corrections. Re-present only if changes are significant.

---

### Phase 4 — Red-green-refactor loop

Update the active task file's `status` frontmatter to `in-progress` before starting the loop.

For each test case in the approved plan, execute this loop strictly in order:

#### Step 1 — Write the test (RED)

Write exactly one test case. The test must:
- Be placed in the appropriate test file for the project (create it if it doesn't exist)
- Use the project's existing test framework and conventions
- Reference only the interface/API that *should* exist, not what currently exists
- Have a clear assertion that will fail because the implementation does not exist yet

Run the test command. **Confirm it fails.** If it passes without any implementation, stop and report: "T-{NN} passed without implementation — this test may not be testing the right thing. Investigate before continuing."

Report the red result:
```
T-{NN}: {test name} — RED ✗
{failing output summary}
```

#### Step 2 — Implement (GREEN)

Write the minimal implementation needed to make this one test pass. Do not implement anything beyond what is needed for the current test.

Run the test command. If it passes, report:
```
T-{NN}: {test name} — GREEN ✓
```

If it still fails, revise and retry. After **3 failed attempts**, stop and report:
```
T-{NN}: {test name} — STUCK after 3 attempts

Tried:
1. {description of attempt 1}
2. {description of attempt 2}
3. {description of attempt 3}

Last error:
{error output}

How should I proceed?
```

Wait for user direction before continuing.

#### Step 3 — Refactor

Review the code just written (test + implementation). Ask:
```
T-{NN} is green. Anything to refactor before I move to T-{NN+1}?
(Reply "no" or describe what to change)
```

If the user says no or replies quickly with "no"/"skip"/"continue", proceed immediately.
If the user describes a refactor, apply it, re-run the test to confirm still green, then proceed.

#### Step 4 — Tick the criterion

After all test cases derived from a given acceptance criterion go green, check off that criterion in the active task file:

Change `- [ ] {criterion}` → `- [x] {criterion}`

---

### Phase 5 — Close

When all test cases are green:

1. Update the active task file's `status` frontmatter to `done`
2. Run the full test suite one final time to confirm no regressions
3. Report:

```
Task complete: TASK-NNNN — {Title}

Test results:
  T-01: {test name} — GREEN ✓
  T-02: {test name} — GREEN ✓
  …

All {N} tests passing. Task marked done.
```

#### Sub-task continuation

If the completed task was a STASK, check whether the next STASK exists in filename order:

- If a next STASK exists and is `open`: report "Next up: STASK-NNNN — {Title}. Run `/burn` to continue." and stop.
- If all STASKs are now `done`: update the parent task `status` to `done` and report "All sub-tasks complete. Parent TASK-NNNN marked done."

Tell the user the file path(s) changed so they can commit.
