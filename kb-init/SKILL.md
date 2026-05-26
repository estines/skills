---
name: kb-init
description: Scaffold a knowledge-base/ directory, then explore and document the current codebase architecture, structure, naming conventions, and key decisions as ADRs. Use when the user wants to initialise a new project's knowledge base, mentions "kb-init", or asks to set up project documentation structure.
trigger: /kb-init
---

# Knowledge Base Init

Two phases: **scaffold** the knowledge-base/ directory, then **explore and document** the codebase. No git access required.

---

## Phase 1 — Scaffold

Create the following structure. Skip any item that already exists — never overwrite.

```
knowledge-base/
  README.md
  adr/
    README.md
  agents/
    README.md
  goals/
    README.md
  tasks/
    README.md
```

### File templates

#### `knowledge-base/README.md`

```md
# Knowledge Base

Central repository for project decisions, agent context, and task tracking.

| Folder    | Purpose                                      |
|-----------|----------------------------------------------|
| `adr/`    | Architecture Decision Records                |
| `agents/` | Agent instructions and context files         |
| `goals/`  | Goals (features, objectives, outcomes)       |
| `tasks/`  | Local task tracking (markdown-based)         |
```

#### `knowledge-base/adr/README.md`

```md
# Architecture Decision Records

Sequential decision log. See [ADR-FORMAT.md](../agents/ADR-FORMAT.md) for authoring guidance.

Files: `0001-slug.md`, `0002-slug.md`, …
```

#### `knowledge-base/agents/README.md`

```md
# Agent Context

CONTEXT.md, CONTEXT-MAP.md, and any agent-specific instruction files live here.

- `CONTEXT.md` — domain glossary for a single-context repo
- `CONTEXT-MAP.md` — multi-context map (create only when needed)
```

#### `knowledge-base/goals/README.md`

```md
# Goals

High-level objectives — features, capabilities, improvements — that drive task creation.

Files: `GOAL-0001-slug.md`, `GOAL-0002-slug.md`, …

Status values: `open` | `in-progress` | `done` | `deferred` | `cancelled`

See [GOAL-FORMAT.md](../agents/GOAL-FORMAT.md) for authoring guidance.
```

### `knowledge-base/tasks/README.md`

```md
# Tasks

Local task tracking using markdown files. No external issue tracker required.

Files: `TASK-0001-slug.md`, `TASK-0002-slug.md`, …

See [TASK-FORMAT.md](../agents/TASK-FORMAT.md) for authoring guidance.
```

Tell the user what was created (list new files only, skip pre-existing ones). Then proceed to Phase 2.

---

## Phase 2 — Explore and Document

Explore the codebase and produce three outputs:

1. **`knowledge-base/agents/CONTEXT.md`** — domain glossary
2. **`knowledge-base/agents/ARCHITECTURE.md`** — project structure and technical summary
3. **ADRs** in `knowledge-base/adr/` — one per key architectural decision found

### 2a. Explore

Read the codebase to gather:

- **Project structure**: top-level folders, entry points, build/config files
- **Tech stack**: languages, frameworks, package manager, test runner, lint/format tools
- **Naming conventions**: file naming, function/variable style, folder organisation patterns
- **Architectural patterns**: how concerns are separated (layers, modules, features, domains)
- **Key dependencies**: what the project relies on and why (infer from package files, imports)
- **Boundaries and data flow**: how the main parts of the system communicate

Start broad (directory tree, package.json / Cargo.toml / pyproject.toml / go.mod, README), then drill into the most structurally important files.

### 2b. Interview the user

After exploring, surface every gap or ambiguity you found. Ask questions **one at a time** — do not dump a list. For each question, provide your best inference from the code and ask the user to confirm or correct.

Categories to cover (ask only what you genuinely couldn't infer):

- **Intent**: What problem does this project solve? Who uses it?
- **Domain language**: Are there terms the code uses that have specific business meaning?
- **Naming decisions**: Any naming you found surprising or inconsistent — is that intentional?
- **Architectural decisions**: Did you spot a pattern that looks deliberate but non-obvious (e.g. no ORM, specific folder structure, avoided framework feature)?
- **Future plans**: Are there areas actively in flux that should be flagged in the docs?

Keep going until no open questions remain.

### 2c. Write the documents

#### `knowledge-base/agents/CONTEXT.md`

Follow [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md). Include only domain-specific terms — skip general programming concepts. Use exact wording the codebase uses.

#### `knowledge-base/agents/ARCHITECTURE.md`

```md
# Architecture

## Project

{One paragraph: what the system does and who it's for.}

## Tech stack

| Concern        | Choice            | Notes                        |
|----------------|-------------------|------------------------------|
| Language       |                   |                              |
| Framework      |                   |                              |
| Package manager|                   |                              |
| Testing        |                   |                              |
| Lint / Format  |                   |                              |

## Structure

{Annotated directory tree — top two levels, with one-line purpose per folder.}

## Naming conventions

{List observed conventions: file names, function names, folder organisation.}

## Key patterns

{Bullet list of architectural patterns in use, each with a one-sentence explanation.}

## Boundaries and data flow

{How the main parts communicate. Use a simple text diagram if helpful.}
```

#### ADRs

For each architectural decision that meets the ADR threshold (see [ADR-FORMAT.md](ADR-FORMAT.md)):

- Hard to reverse
- Surprising without context
- Result of a real trade-off

Write `knowledge-base/adr/0001-slug.md`, `0002-slug.md`, etc. Prefer fewer, higher-quality ADRs over exhaustive coverage.

---

## Phase 3 — Confirm and close

List every file written. Ask the user if anything is missing, wrong, or needs a follow-up task. If yes, create a task per [TASK-FORMAT.md](TASK-FORMAT.md).
