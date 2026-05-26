---
name: set-goal
description: Capture a goal from the current conversation context, refine it into a concise markdown file, and save it to knowledge-base/goals/. Use when the user wants to record a feature, objective, or intent as a goal, or mentions "set-goal" / "add a goal".
trigger: /set-goal
argument-hint: "[optional: brief description to anchor the goal]"
---

# Set Goal

Extract a goal from the current conversation, refine it, confirm with the user, and write it to `knowledge-base/goals/`.

---

## Phase 1 — Extract

Read the current conversation context. Identify what the user wants to achieve: a feature, capability, improvement, or outcome. If an argument was passed to `/set-goal`, use it as the anchor — otherwise infer from the conversation.

Distil it into:

- **Title**: 3–7 words, imperative form ("Add user authentication", "Support CSV export")
- **Description**: 2–3 sentences, what it is and what it enables
- **Why**: 1–2 sentences, the motivation or problem it solves
- **Acceptance criteria**: 2–5 bullet points — observable, testable outcomes that mean the goal is done

## Phase 2 — Confirm

Present the extracted goal to the user in this exact format before writing anything:

```
Goal: {Title}

Description: {Description}

Why: {Why}

Acceptance criteria:
- {criterion 1}
- {criterion 2}
…

Does this look right? Adjust anything before I write the file.
```

Wait for the user to confirm or correct. Apply any corrections. Re-present if changes are significant.

## Phase 3 — Write

Once confirmed, write the file to `knowledge-base/goals/`.

### Numbering

Scan `knowledge-base/goals/` for the highest existing `GOAL-NNNN` number. Increment by one. If the folder doesn't exist, create it with a `README.md` (see template below) before writing the goal file.

### File name

`GOAL-{NNNN}-{slug}.md` where slug is the title lowercased, spaces replaced with hyphens, punctuation stripped. Example: `GOAL-0003-support-csv-export.md`

### Goal file template

```md
---
status: open
---

# {Title}

## Description

{Description}

## Why

{Why}

## Acceptance criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Tasks

<!-- Populated when tasks are created from this goal. Use TASK-NNNN references. -->

## Notes

<!-- Optional: constraints, open questions, links to related goals or ADRs. -->
```

### `knowledge-base/goals/README.md` (create only if folder is new)

```md
# Goals

High-level objectives — features, capabilities, improvements — that drive task creation.

Files: `GOAL-0001-slug.md`, `GOAL-0002-slug.md`, …

Status values: `open` | `in-progress` | `done` | `deferred` | `cancelled`

See [GOAL-FORMAT.md](../agents/GOAL-FORMAT.md) for authoring guidance.
```

## Phase 4 — Close

Tell the user the file path written. Ask if they want to break this goal into tasks now. If yes, use [TASK-FORMAT.md](../knowledge-init/TASK-FORMAT.md) to create tasks and populate the `## Tasks` section of the goal file with `TASK-NNNN` references.
