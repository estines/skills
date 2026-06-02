---
name: burn
description: Execute .goals/ tasks with strict red-green-refactor TDD. GOAL mode runs parallel batches via Virtual Branching; TASK/STASK mode runs interactively. Use when the user wants to implement tasks with TDD, mentions "burn", or types /burn.
trigger: /burn
argument-hint: "[GOAL-NNNN | TASK-NNNN | STASK-NNNN]"
---

# TDD Task

Execute a task or a whole goal with strict red-green-refactor. **Business logic:** AAA unit tests, ≥90% line coverage. **UI:** Given–When–Then behavior tests. One test at a time. Never batch tests. Never implement ahead of a failing test.

---

## Entry — Single task or whole goal?

**Guard:** If `.goals/` does not exist at the project root, stop: "`.goals/` not found. Run `/goals-init` first."

Check the argument:

- **`GOAL-NNNN`** → read [orchestrator.md](orchestrator.md) and follow it end-to-end
- **`TASK-NNNN` or `STASK-NNNN`** → read [single-task.md](single-task.md) and follow it end-to-end
- **No argument** → scan the current conversation for a recently mentioned `GOAL-NNNN`, `TASK-NNNN`, or `STASK-NNNN`
  - If exactly one reference is unambiguous, use it
  - If ambiguous or none found, ask: "Which goal or task should I burn? (e.g. GOAL-0001 or TASK-0001)"

---

## Tools used

| Tool | Used by |
|------|---------|
| `TaskCreate` / `TaskGet` / `TaskOutput` / `TaskStop` | Orchestrator (O-4b/c): spawn and monitor parallel subagents |
| `Bash` | Both modes: run tests, coverage, git commits |
| `Read` / `Edit` / `Write` | Both modes: read task files, update status, write `.burn-orchestrator.yaml` |

---

## Mode summary

| Argument | Mode | Behaviour |
|----------|------|-----------|
| `GOAL-NNNN` | Orchestrator | Parallel batches via Virtual Branching; resumable via `.burn-orchestrator.yaml` |
| `TASK-NNNN` / `STASK-NNNN` | Single-task | Interactive TDD with user-confirmed test plan and refactor checkpoints |

---

## Shared references

Read these when the active mode file points to them:

| File | Used by |
|------|---------|
| [detect-test-runner.md](detect-test-runner.md) | Both modes — infer unit, coverage, and UI behavior test commands |
| [tdd-default.md](tdd-default.md) | Test strategy and loops; **Autonomous** for subagents, **Interactive** for single-task |
| [ui-behavior-tests.md](ui-behavior-tests.md) | Given–When–Then behavior tests for components, pages, and flows |
| [subagent-prompt.md](subagent-prompt.md) | Orchestrator O-4b only — subagent prompt template |

---

## Key invariants (both modes)

- **Virtual Branching** (orchestrator only): tasks commit on logical branches `burn/{GOAL}/{TASK}` on the shared working tree — no `git worktree` or branch switching; merged back after each batch completes
- **Two layers**: unit TDD on business logic; behavior tests on UI ([tdd-default.md](tdd-default.md), [ui-behavior-tests.md](ui-behavior-tests.md))
- **Task skills**: first matching `.goals/skills/{slug}.md` replaces default TDD steps for that task
- **STUCK_HALT**: subagents emit this after 3 failed green attempts; orchestrator writes a `{TASK-NNNN}-failure.md` report and continues the batch; failed tasks are surfaced at close so the user can retry interactively with `/burn TASK-NNNN`
- **Resume**: re-run `/burn GOAL-NNNN` to pick up pending/running orchestrator agents from `.burn-orchestrator.yaml`

---

## Headless / CI mode

To run a full goal non-interactively, use `run-tasks.sh`:

```bash
./run-tasks.sh GOAL-NNNN
```

This finds all `status: open` tasks and calls `claude --dangerously-skip-permissions -p "/burn TASK-NNNN"` for each in sequence. It halts on the first `STUCK_HALT` or non-zero exit and writes a failure report beside the task file.

**Note:** `run-tasks.sh` runs tasks sequentially (not in parallel batches). For parallel orchestrated execution, use `/burn GOAL-NNNN` directly.
