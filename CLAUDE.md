# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of custom Claude Code skills published via `npx skills add estines/skills`. Each skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Skills are installed into `~/.claude/skills/` on the consuming machine and exposed as slash commands.

## Skill file structure

Every skill lives at `{skill-name}/SKILL.md`. Required frontmatter fields:

```yaml
---
name: skill-name          # slug used to reference the skill
description: ...          # one-line description shown in skill lists and used for trigger matching
trigger: /skill-name      # slash command that invokes it
argument-hint: "..."      # optional; shown as autocomplete hint
---
```

The markdown body contains the skill's execution instructions — phases, decision rules, file templates, and output formats. These instructions are read by Claude at runtime.

## The two systems

**System 1 — Goals & Task Execution** (`/goals-init → /set-goal → /brief → /breakdown → /burn`): A workflow for planning and implementing features. All state lives in `.goals/` at the consuming project root. Skills in this system read and write `.goals/GOAL-NNNN-slug/` directories.

**System 2 — Project Documentation** (`/kb-init → /kb-update`): Scaffolds and maintains a `knowledge-base/` directory. Independent of the goals flow.

## Skills in this repo

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `goals-init` | `/goals-init` | One-time scaffold of `.goals/` + wires `CLAUDE.md` |
| `set-goal` | `/set-goal` | Captures a goal into `.goals/GOAL-NNNN-slug/` |
| `brief` | `/brief` | Grills a plan against a goal's CONTEXT.md and ADRs |
| `breakdown` | `/breakdown` | Decomposes a goal into Fibonacci-estimated tasks |
| `task-breakdown` | `/task-breakdown` | Splits an 8+ point task into sub-tasks |
| `burn` | `/burn` | Executes tasks with TDD — `/burn GOAL-NNNN` runs all tasks in parallel batches by sequence (isolated worktrees); `/burn TASK-NNNN` runs a single task interactively |
| `kb-init` | `/kb-init` | Scaffolds `knowledge-base/` from codebase |
| `kb-update` | `/kb-update` | Fills or refreshes a knowledge-base section |

## Installation

```bash
npx skills add estines/skills          # all skills
npx skills add estines/skills/burn     # single skill
```

## run-tasks.sh

Autonomous batch runner. Finds all `status: open` tasks for a goal and calls `claude --dangerously-skip-permissions -p "/burn TASK-NNNN"` for each in sequence. Halts on the first failure and writes a `{TASK-NNNN}-failure.md` report beside the task file.

**Note:** `run-tasks.sh` currently looks for goals under `knowledge-base/goals/` (old path). The repo has since migrated to `.goals/`. Update that path if using the script.

```bash
./run-tasks.sh GOAL-0001
```

## Goals directory layout (for consuming projects)

```
.goals/
  adr/                        ← project-local Architecture Decision Records
  skills/                     ← task-execution skills (git-ignored)
  GOAL-0001-slug/
    GOAL.md                   ← title, why, acceptance criteria, task refs
    CONTEXT.md                ← canonical terms and resolved decisions
    tasks/
      TASK-0001-slug.md                    ← flat task file
      TASK-0002-slug/                      ← directory form (post /task-breakdown)
        TASK.md
        subtasks/
          STASK-0001-slug.md
```

## Task file frontmatter

```yaml
---
status: open | in-progress | done
story_points: 1 | 2 | 3 | 5 | 8 | 13
goal: GOAL-NNNN
blocked_by: [TASK-NNNN]      # omit for unblocked tasks
skills: [burn]               # omit if none
---
```

# Goals

@.goals/README.md
