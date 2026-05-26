# Skills — Development Workflow

Custom Claude Code skills for knowledge-driven development. Each skill is a slash command that handles one phase of the cycle: understand → plan → execute.

---

## The Workflow

```
/kb-init  →  /brief  →  /set-goal  →  /breakdown  →  /burn
    ↑                                                     |
    └──────────────── /kb-update ◄────────────────────────┘
```

---

## Skills

### `/kb-init` — Initialize the Knowledge Base

**When:** First time setting up a project, or onboarding to an unfamiliar codebase.

Scaffolds `knowledge-base/` and then explores the codebase to produce:
- `knowledge-base/agents/CONTEXT.md` — domain glossary
- `knowledge-base/agents/ARCHITECTURE.md` — tech stack and structure
- `knowledge-base/adr/` — architecture decision records

```
/kb-init
```

After this runs, the other skills have the context they need to do their jobs well.

---

### `/brief` — Stress-Test a Plan

**When:** Before writing code. You have an idea or plan; you want to challenge it.

Runs a grilling session against the knowledge base — checks your plan against the glossary, existing ADRs, and architecture docs. Sharpens fuzzy language, surfaces contradictions, and updates `CONTEXT.md` and `knowledge-base/adr/` as decisions crystallise.

```
/brief
/brief Add a caching layer to the API
```

Requires `knowledge-base/` (run `/kb-init` first).

---

### `/set-goal` — Record a Goal

**When:** You know what you want to build. Capture it as a durable, structured goal.

Extracts a Goal from the current conversation, refines it into title + description + why + acceptance criteria, confirms with you, then writes it to `knowledge-base/goals/`.

```
/set-goal
/set-goal Support CSV export for all reports
```

Output: `knowledge-base/goals/GOAL-NNNN-slug.md`

---

### `/breakdown` — Decompose a Goal into Tasks

**When:** A Goal exists and you're ready to plan the work.

Reads the Goal's acceptance criteria, checks ADRs and domain language for constraints, then decomposes into vertical-slice Tasks with Fibonacci story point estimates. Confirms the full breakdown before writing.

```
/breakdown
/breakdown GOAL-0003
```

Output: `knowledge-base/goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md` per task.

Each task is independently reviewable and delivers an observable, testable outcome.

---

### `/burn` — Execute a Task with TDD

**When:** A Task exists and you're ready to implement.

Reads the Task's acceptance criteria, derives a test plan (happy path + edge cases + failure cases), confirms the full plan upfront, then runs strict red-green-refactor — one test at a time.

```
/burn
/burn TASK-0001
```

Loop:
1. Write one failing test → RED
2. Implement minimally → GREEN
3. Refactor → ask before moving on
4. Tick the criterion when all its tests pass
5. Mark task `done` when all criteria pass

---

### `/kb-update` — Commit Decisions to the Knowledge Base

**When:** After a grilling session, design review, or any conversation where architectural or domain decisions were reached.

Scans the conversation for ADR-worthy decisions and domain term changes, previews each proposed update, then writes confirmed changes to `knowledge-base/adr/`, `CONTEXT.md`, and `ARCHITECTURE.md`.

```
/kb-update
```

---

## Typical Session

### Starting a new project

```
/kb-init          ← scaffold knowledge-base/, document architecture
/brief            ← grill yourself on the first plan
/kb-update        ← commit decisions from the grilling session
/set-goal         ← record what you're building
/breakdown        ← decompose into tasks
/burn TASK-0001   ← implement first task with TDD
/burn TASK-0002
…
```

### Picking up existing work

```
/brief            ← re-ground before starting something new
/set-goal         ← if the work warrants a new goal
/breakdown        ← decompose the goal
/burn TASK-NNNN   ← implement
```

### After a long design conversation

```
/kb-update        ← commit any decisions reached to the knowledge base
```

---

## Knowledge Base Layout

```
knowledge-base/
  README.md
  agents/
    CONTEXT.md          ← domain glossary (owned by /brief, updated by /kb-update)
    ARCHITECTURE.md     ← tech stack and structure (owned by /kb-init)
  adr/
    0001-slug.md        ← architecture decision records
    0002-slug.md
  goals/
    GOAL-0001-slug/
      GOAL.md
      tasks/
        TASK-0001-slug.md
        TASK-0002-slug.md
    GOAL-0002-slug.md   ← flat file before /breakdown runs
```

---

## Key Terms

| Term | Meaning |
|------|---------|
| **Goal** | A high-level objective with acceptance criteria. Lives in `knowledge-base/goals/`. |
| **Task** | A vertical-slice unit of work derived from a Goal. Has its own criteria and story point estimate. |
| **Acceptance Criterion** | An observable, testable outcome that defines when a Goal or Task is complete. |
| **Test Plan** | The full ordered list of test cases for a Task, confirmed before the TDD loop begins. |
| **ADR** | Architecture Decision Record — a short doc capturing a hard-to-reverse, non-obvious decision. |

Full glossary: `knowledge-base/agents/CONTEXT.md`
