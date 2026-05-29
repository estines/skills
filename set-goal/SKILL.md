---
name: set-goal
description: Capture a goal from the current conversation context, refine it into a concise markdown file, and save it to .goals/. Use when the user wants to record a feature, objective, or intent as a goal, or mentions "set-goal" / "add a goal".
trigger: /set-goal
argument-hint: "[optional: brief description to anchor the goal]"
---

# Set Goal

Extract a goal from the current conversation, refine it, confirm with the user, and write it to `.goals/`.

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

## Phase 3 — Bootstrap `.goals/` if missing

Check if `.goals/` exists at the project root.

If it does **not** exist, run the `/goals-init` scaffold (Phases 2–4) before continuing, then tell the user: "`.goals/` bootstrapped. Consider running `/goals-init` on future projects to set this up in advance."

## Phase 4 — Write

### Numbering

Scan `.goals/` for existing `GOAL-NNNN-*` directories. Find the highest existing number. Increment by one. Start at `GOAL-0001` if none exist.

### Directory name

`GOAL-{NNNN}-{slug}` where slug is the title lowercased, spaces replaced with hyphens, punctuation stripped. Example: `GOAL-0003-support-csv-export`

### `GOAL.md` — goal definition

Write to `.goals/GOAL-{NNNN}-{slug}/GOAL.md`:

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

### `CONTEXT.md` — agent steering context

Write to `.goals/GOAL-{NNNN}-{slug}/CONTEXT.md`:

```md
# Context — {Title}

Agent context for GOAL-{NNNN}. Updated by /brief as decisions are made.

## Language

<!-- Goal-specific terms, definitions, and avoid-lists added here. -->
```

## Phase 5 — Close

Tell the user the files written (`GOAL.md` and `CONTEXT.md`). Ask if they want to break this goal into tasks now with `/breakdown`.
