# Skills — Development Workflow

Custom Claude Code skills for knowledge-driven development. Two independent systems: a **goals and task execution flow** (`.goals/`) and a **project documentation tool** (`knowledge-base/`).

---

## Installation

Install all skills into your Claude Code environment:

```bash
npx skills add estines/skills
```

Or install individual skills:

```bash
npx skills add estines/skills/goals-init
npx skills add estines/skills/set-goal
npx skills add estines/skills/brief
npx skills add estines/skills/breakdown
npx skills add estines/skills/task-breakdown
npx skills add estines/skills/burn
npx skills add estines/skills/kb-init
npx skills add estines/skills/kb-update
```

After installing, the slash commands are immediately available in any Claude Code session.

### Automation Script

The `run-tasks.sh` script runs all open tasks for a goal autonomously. Install it separately via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/estines/skills/main/run-tasks.sh -o run-tasks.sh && chmod +x run-tasks.sh
```

Usage:

```bash
./run-tasks.sh GOAL-0001
```

---

## System 1 — Goals & Task Execution

Plan and implement features using goals, tasks, and TDD.

```
/goals-init  →  /set-goal  →  /brief  →  /breakdown  →  /burn
                                                ↓
                                        /task-breakdown
                                    (for 8+ point tasks)
```

All state lives in `.goals/` at the project root.

---

### `/goals-init` — Set Up the Goals Directory

**When:** Once per project, before using any other goals-flow skill.

Scaffolds `.goals/`, wires `@.goals/README.md` into `CLAUDE.md`, and adds `.goals/skills/` to `.gitignore`.

```
/goals-init
```

Output:
```
.goals/
  README.md
  adr/
  skills/
```

---

### `/set-goal` — Record a Goal

**When:** You know what you want to build. Capture it as a durable, structured goal.

Extracts a goal from the current conversation, refines it into title + description + why + acceptance criteria, confirms with you, then writes it to `.goals/`.

```
/set-goal
/set-goal Support CSV export for all reports
```

Output:
```
.goals/GOAL-NNNN-slug/
  GOAL.md      — title, description, why, acceptance criteria, task references
  CONTEXT.md   — per-goal glossary and resolved decisions (updated by /brief)
```

---

### `/brief` — Stress-Test a Plan Against a Goal

**When:** Before writing code. You have an idea or plan; you want to challenge it against the goal's context.

Runs a grilling session scoped to a specific goal — checks your plan against the goal's glossary (`.goals/GOAL-NNNN-slug/CONTEXT.md`) and existing ADRs (`.goals/adr/`). Sharpens fuzzy language, surfaces contradictions, and updates `CONTEXT.md` and `.goals/adr/` as decisions crystallise.

```
/brief
/brief GOAL-0003
```

Requires a goal directory (run `/set-goal` first).

---

### `/breakdown` — Decompose a Goal into Tasks

**When:** A goal exists and you're ready to plan the work.

Reads the goal's acceptance criteria, checks `.goals/adr/` and the goal's `CONTEXT.md` for constraints, then decomposes into vertical-slice tasks with Fibonacci story point estimates. Confirms the full breakdown before writing. Tasks estimated at 8+ points are flagged for `/task-breakdown`.

```
/breakdown
/breakdown GOAL-0003
```

Output: `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md` per task.

Each task is independently reviewable and delivers an observable, testable outcome.

---

### `/task-breakdown` — Split a Large Task into Sub-tasks

**When:** A task is 8+ story points and too large to deliver cleanly in one TDD loop.

Reads the parent task file, decomposes it into sub-tasks of 1–3 points each, converts the parent task to a directory form, and writes sub-tasks under `subtasks/`.

```
/task-breakdown
/task-breakdown TASK-0003
```

Output:
```
.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug/
  TASK.md
  subtasks/
    STASK-0001-slug.md
    STASK-0002-slug.md
```

---

### `/burn` — Execute a Task with TDD

**When:** A task (or sub-task) exists and you're ready to implement.

Reads the task's acceptance criteria, derives a test plan (happy path + edge cases + failure cases), confirms the full plan upfront, then runs strict red-green-refactor — one test at a time. Handles both flat task files and directory-form tasks with sub-tasks.

```
/burn
/burn TASK-0001
/burn STASK-0002
```

Loop:
1. Write one failing test → RED
2. Implement minimally → GREEN
3. Refactor → ask before moving on
4. Tick the criterion when all its tests pass
5. Mark task `done` when all criteria pass

---

## System 2 — Project Documentation

Scaffold and maintain a `knowledge-base/` directory with project documentation. Independent of the goals flow.

```
/kb-init  →  /kb-update
```

---

### `/kb-init` — Initialize the Knowledge Base

**When:** First time setting up project documentation, or onboarding to an unfamiliar codebase.

Detects the project language/framework, scaffolds `knowledge-base/` with documentation templates, estimates fill scope, then populates each section by reading the codebase.

```
/kb-init
```

Output:
```
knowledge-base/
  Product Overview.md
  Development/
    Technology Stack/Technology Stack.md
    Developer Guide/
      API.md
      Debugging.md
      Guideline.md
      Prerequisites.md
      Testing.md
      Workflow.md
    Technical Debt/Technical Debt List.md
```

---

### `/kb-update` — Fill or Refresh a Knowledge Base Section

**When:** After `/kb-init`, to fill deferred sections or refresh a specific doc with latest codebase state.

With no arguments, surfaces all unfilled `knowledge-base/` sections. With `--section`, re-scans the codebase to fill or refresh a specific document (archiving the previous version).

```
/kb-update
/kb-update --section developer-guide/api
/kb-update --section technical-debt
```

Valid targets: `product-overview`, `technology-stack`, `technical-debt`, `developer-guide`, `developer-guide/api`, `developer-guide/guideline`, `developer-guide/prerequisites`, `developer-guide/testing`, `developer-guide/debugging`, `developer-guide/workflow`.

---

## Typical Sessions

### Starting work on a new feature

```
/goals-init       ← one-time per project
/set-goal         ← record what you're building
/brief GOAL-0001  ← grill the plan, sharpen terminology
/breakdown        ← decompose into tasks
/burn TASK-0001   ← implement with TDD
/burn TASK-0002
…
```

### Resuming existing work

```
/brief GOAL-0001  ← re-ground before continuing
/burn TASK-NNNN   ← pick up the next open task
```

### A large task needs splitting

```
/task-breakdown TASK-0003   ← split into sub-tasks
/burn STASK-0001            ← implement sub-task by sub-task
/burn STASK-0002
```

### Documenting a codebase

```
/kb-init                              ← scaffold and fill knowledge-base/
/kb-update --section technical-debt  ← fill deferred sections later
```

---

## Goals Directory Layout

```
.goals/
  adr/
    0001-slug.md        ← project-local Architecture Decision Records
  skills/               ← reusable task-execution skills (git-ignored)
  GOAL-0001-slug/
    GOAL.md             ← title, description, why, acceptance criteria
    CONTEXT.md          ← per-goal glossary and resolved decisions
    tasks/
      TASK-0001-slug.md                         ← flat task file
      TASK-0002-slug/                           ← directory form (after /task-breakdown)
        TASK.md
        subtasks/
          STASK-0001-slug.md
          STASK-0002-slug.md
```

---

## Key Terms

| Term | Meaning |
|------|---------|
| **Goal** | A high-level objective with acceptance criteria. Lives in `.goals/GOAL-NNNN-slug/`. |
| **Task** | A vertical-slice unit of work derived from a goal. Has its own criteria and story point estimate. |
| **Sub-task** | A 1–3 point slice of a large task, created by `/task-breakdown`. |
| **CONTEXT.md** | Per-goal glossary of canonical terms and resolved decisions. Updated by `/brief`. |
| **ADR** | Architecture Decision Record — a short doc capturing a hard-to-reverse, non-obvious decision. Lives in `.goals/adr/`. |
| **Acceptance Criterion** | An observable, testable outcome that defines when a goal or task is complete. |
| **Test Plan** | The full ordered list of test cases for a task, confirmed before the TDD loop begins. |
