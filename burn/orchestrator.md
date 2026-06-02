# Orchestrator mode — GOAL argument

Execute all open tasks for a goal in parallel batches ordered by sequence. Each batch contains all tasks whose blockers are done. Tasks within a batch run in parallel using **Virtual Branching** — one Task subagent per task, each on its own logical branch `burn/{GOAL-NNNN}/{TASK-NNNN}`, with changes applied back to the orchestrator's working branch after the batch completes.

Re-running `/burn GOAL-NNNN` while orchestrator state exists **resumes** pending parallel agents instead of restarting finished or in-flight work.

**Invariants:**
- Use Virtual Branching, not git worktrees — no `git worktree add`, only branch merge
- AAA unit tests on business logic (≥90% line coverage); Given–When–Then behavior tests on UI
- One test at a time per subagent; never batch tests; never implement ahead of a failing test

---

## Phase O-0 — Resume or fresh start

Before loading tasks, check `.goals/GOAL-NNNN-slug/.burn-orchestrator.yaml`.

**If the file exists** and any entry in `agents:` has `status: pending` or `status: running`, or any task in `current_batch` has `status: in-progress` in the goal task files — enter **resume mode**:

1. Read the full orchestrator state (schema below)
2. Re-read task statuses from `.goals/GOAL-NNNN-slug/tasks/` and merge with state
3. Present a resume plan (do not wait for confirmation):

```
Goal: GOAL-NNNN — {Title} (resuming)

  Resume: TASK-NNNN — {Title} (agent {agent_id}, virtual branch burn/GOAL-NNNN/TASK-NNNN)
  Pending spawn: TASK-NNNN — {Title} (never started in interrupted batch)
  Already merged this goal run: TASK-NNNN ✓

Continuing from batch {N}. Interrupt at any time — run /burn GOAL-NNNN again to resume.
```

4. Skip Phase O-2 batch planning for batches already recorded in `completed_batches`
5. Jump to Phase O-4 for the current batch — use **O-4b resume** for agents with `pending`/`running`, spawn only tasks without an `agent_id`

**If the file does not exist** (or all agents are `complete`, `failed`, or `merged` and no `in-progress` tasks remain for an interrupted batch) — **fresh start**: proceed to Phase O-1. After Phase O-3, create `.burn-orchestrator.yaml` before the first O-4b spawn.

### Orchestrator state — `.burn-orchestrator.yaml`

Written at `.goals/GOAL-NNNN-slug/.burn-orchestrator.yaml` and updated after every O-4b spawn, O-4c collection, and O-4d apply:

```yaml
goal: GOAL-NNNN
started_at: "2026-06-01T12:00:00Z"
current_batch: 1
completed_batches: []   # batch indices fully applied (O-4d done)
agents:
  - task: TASK-0001
    virtual_branch: burn/GOAL-0001/TASK-0001
    agent_id: "<Task tool agent id from spawn or resume>"
    status: pending | running | complete | failed | merged
    git_branch: ""      # filled when subagent reports branch name (optional)
```

- Set `status: running` immediately after spawning or resuming a Task subagent
- Set `status: complete` when the subagent reports task done (before apply)
- Set `status: merged` after O-4d successfully integrates that virtual branch
- Set `status: failed` on STUCK_HALT or non-completion; on resume, clear `agent_id` and spawn a fresh virtual branch for that task (user may fix blockers first)

Delete or archive `.burn-orchestrator.yaml` when Phase O-5 closes with no pending agents and no schedulable open tasks.

---

## Phase O-1 — Load goal tasks

Locate `.goals/GOAL-NNNN-slug/`. If not found, report: "Goal directory not found for GOAL-NNNN."

Scan `.goals/GOAL-NNNN-slug/tasks/` for all task files (both flat `.md` files and `TASK.md` inside directory-form tasks). For each task, read:
- `status:` frontmatter (`open`, `in-progress`, `done`, etc.)
- `blocked_by:` frontmatter (may be absent)
- Task title

Build a task map: `{ id → { title, status, blocked_by[] } }`

If there are no tasks with `status: open` **and** Phase O-0 did not enter resume mode, report: "No open tasks found for GOAL-NNNN." and stop.

In resume mode, `in-progress` and orchestrator `pending`/`running` tasks are sufficient to continue — do not stop for lack of `open` tasks.

---

## Phase O-2 — Compute execution batches

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

**Parallel conflict guard:** Before finalizing each batch, check whether any two tasks in the same batch share likely file scope (inferred from task title, summary, and acceptance criteria — keywords like same module name, same component, same route). If two tasks clearly overlap on the same module or path, move the later task into the next batch rather than running them in parallel. Add a note to the O-3 plan output: "Serialized TASK-NNNN after TASK-NNNN (overlapping scope — conflict risk)."

---

## Phase O-3 — Present the execution plan

Present the plan before starting:

```
Goal: GOAL-NNNN — {Title}

Execution plan:

  Batch 1 (parallel): TASK-NNNN — {Title}, TASK-NNNN — {Title}
  Batch 2 (parallel): TASK-NNNN — {Title}
  Batch 3 (parallel): TASK-NNNN — {Title}, TASK-NNNN — {Title}

{N} tasks across {M} batches. Each batch uses Virtual Branching (parallel Task subagents).

Proceeding — interrupt at any time. Run /burn GOAL-NNNN again to resume pending parallel work.
```

Do not wait for confirmation. Print the plan and immediately begin Phase O-4.

---

## Phase O-4 — Execute batches

For each batch in order:

### O-4a — Detect test runner

Before the first batch, follow [detect-test-runner.md](detect-test-runner.md). Record the test, coverage, and UI behavior test commands — all will be embedded in every agent prompt.

### O-4b — Spawn parallel agents (Virtual Branching)

Each task in the batch gets a logical branch id `burn/{GOAL-NNNN}/{TASK-NNNN}` and a dedicated Task subagent.

**Spawn (fresh batch tasks):** For each task in the batch that has no `agent_id` in `.burn-orchestrator.yaml` (or no orchestrator file yet), call the **Task** tool with `subagent_type: "generalPurpose"`. Send all spawns for the batch in a **single message** (parallel Task tool calls).

**Resume (interrupted batch):** For each orchestrator `agents:` entry in this batch with `status: pending` or `status: running` and a non-empty `agent_id`, call the **Task** tool with the same `resume: {agent_id}` (one resume call per agent, parallel in a single message). Do not spawn a duplicate for that task.

After each spawn or resume returns, persist the returned **agent id** and set `status: running` in `.burn-orchestrator.yaml`.

**Before constructing each subagent prompt**, resolve the `## Your job` content (orchestrator reads these from the project root — `.goals/skills/` is git-ignored but visible to the orchestrator, not to subagents unless copied into the prompt):

1. Read the task file's `skills:` frontmatter
2. Iterate the slugs in order; find the **first** slug whose file exists at `.goals/skills/{slug}.md`
3. If found: read the skill file body (everything after the closing `---` of the frontmatter) — this becomes `{job steps}`
4. If not found: use the **Autonomous** section from [tdd-default.md](tdd-default.md) as `{job steps}`

Build each prompt from [subagent-prompt.md](subagent-prompt.md).

### O-4c — Collect batch results

After all Task subagents in the batch finish (or are resumed to completion), collect their results:

- **Success**: subagent reported `TASK-NNNN complete.` and task file is `done` on virtual branch `burn/{GOAL-NNNN}/{TASK-NNNN}`; record `git_branch` in orchestrator state
- **Failure**: subagent output contained `STUCK_HALT`, or task status is not `done`, or subagent exited without completion

For failed tasks: set orchestrator `status: failed`, update task `status` frontmatter to `failed` on the orchestrator's current branch, write `{TASK-NNNN-slug}-failure.md` beside the task file with the subagent's last output. Do not stop the whole batch — continue applying successful virtual branches in O-4d.

**Timeout / hung-agent detection:** If a subagent has not produced output or updated task status after a reasonable window (10 min for 1–3 pt tasks, 20 min for 5–8 pt tasks), call `TaskStop` for that agent, record it as `STUCK_HALT` with reason `timeout`, and write a failure report. Continue the batch with remaining agents.

For successful tasks: set orchestrator `status: complete` (not yet `merged`).

If the orchestrator session ends before all subagents finish, leave `.burn-orchestrator.yaml` with `running`/`pending` entries — `/burn GOAL-NNNN` resumes via Phase O-0.

### O-4d — Apply virtual branches

Ensure the orchestrator is on the integration branch (the branch the user started on — usually `main` or the current feature branch). For each **successful** subagent in this batch, in the order they completed:

```bash
git merge --no-ff burn/{GOAL-NNNN}/{TASK-NNNN} -m "Merge {TASK-NNNN}: {title}"
```

Use the branch name from the subagent report or orchestrator `git_branch`.

If a merge produces conflicts, stop and report:

```
Merge conflict when integrating {TASK-NNNN} (virtual branch burn/{GOAL-NNNN}/{TASK-NNNN}).
Conflicting files: {list}
Resolve the conflicts manually, then run /burn GOAL-NNNN to resume orchestration.
```

After each successful merge: set orchestrator agent `status: merged`. Optionally delete the virtual branch: `git branch -d burn/{GOAL-NNNN}/{TASK-NNNN}` (only if fully merged).

Append `current_batch` to `completed_batches` in `.burn-orchestrator.yaml`. Increment `current_batch` for the next batch.

### O-4e — Recompute ready set

Re-read all task statuses from the integration branch. Recompute the next batch using the ready-set algorithm (Phase O-2). If the next batch is non-empty, return to Phase O-4b. If no open tasks remain, proceed to Phase O-5 and clean up orchestrator state.

---

## Phase O-5 — Close

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

If any tasks failed, list each with its failure report path and suggest next steps:

```
Failed tasks — retry each interactively:
  TASK-NNNN — {Title}  →  see .goals/{GOAL-SLUG}/tasks/{TASK-NNNN-slug}-failure.md
  Run: /burn TASK-NNNN
```
