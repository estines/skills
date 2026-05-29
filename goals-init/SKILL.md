---
name: goals-init
description: Scaffold the .goals/ directory with adr/ and skills/ subfolders, add .goals/skills/ to .gitignore, and wire @.goals/README.md into CLAUDE.md. Run once per project before using /set-goal, /brief, or /breakdown.
trigger: /goals-init
---

# Goals Init

Scaffold `.goals/` and connect it to `CLAUDE.md`. One-time setup per project.

---

## Phase 1 — Check preconditions

1. Check if `.goals/` already exists at the project root.
   - If it does, report: "`.goals/` already exists. Nothing to do." and stop.

2. Check if `CLAUDE.md` exists at the project root.
   - If it does not exist, create an empty one.

---

## Phase 2 — Scaffold `.goals/`

Create the following structure:

```
.goals/
├── README.md
├── adr/
│   └── .gitkeep
└── skills/
```

### `.goals/README.md` content

```md
# Goals

High-level objectives — features, capabilities, improvements — that drive task creation.

Directories: `GOAL-0001-slug/`, `GOAL-0002-slug/`, …

Each goal directory contains:
- `GOAL.md` — goal definition, acceptance criteria, task references
- `CONTEXT.md` — agent steering context for this goal (terms, decisions)
- `tasks/` — task files created by /breakdown

Status values: `open` | `in-progress` | `done` | `deferred` | `cancelled`

## Structure

\```
.goals/
  adr/           — project-local Architecture Decision Records
  skills/        — reusable task-execution skills (git-ignored)
  GOAL-0001-slug/
    GOAL.md
    CONTEXT.md
    tasks/
      TASK-0001-slug.md
\```

## Skills loading

Skills in `.goals/skills/` are never auto-loaded. They are only read when a task's
`skills:` frontmatter references the skill's slug.
```

Create `adr/` with a `.gitkeep` so it is committed. Create `skills/` — it will be git-ignored.

---

## Phase 3 — Add to `.gitignore`

Open `.gitignore` at the project root (create if absent).

Check if `.goals/skills/` is already listed. If not, append:

```
# Project-local task-execution skills — not for version control
.goals/skills/
```

---

## Phase 4 — Wire into `CLAUDE.md`

Open `CLAUDE.md`. Check if `@.goals/README.md` is already present anywhere in the file.

If not, append the following block at the end of `CLAUDE.md`:

```md
# Goals

@.goals/README.md
```

---

## Phase 5 — Close

Report:

```
.goals/ scaffolded:
  .goals/README.md
  .goals/adr/
  .goals/skills/

.gitignore updated — .goals/skills/ will not be committed.
CLAUDE.md updated — README is @ imported and will load automatically.

You can now use /set-goal, /brief, and /breakdown.
```
