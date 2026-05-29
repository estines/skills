---
name: kb-init
description: Scaffold a knowledge-base/ directory with reference-style documentation templates, detect the project's language/framework, estimate documentation scope, and fill each section by reading the codebase. Use when the user wants to initialise a new project's knowledge base, mentions "kb-init", or asks to set up project documentation structure.
trigger: /kb-init
---

# Knowledge Base Init

Four phases: **scaffold** templates, **detect** language, **estimate** scope, **fill** sections.

---

## Phase 0 — Language Detection

Detect the project's primary language and framework from these signal files:

| Language | Signal files |
|---|---|
| JavaScript/Node.js | `package.json` |
| Python | `requirements.txt`, `pyproject.toml`, `setup.py` |
| Go | `go.mod` |
| Java/Kotlin | `pom.xml`, `build.gradle`, `build.gradle.kts` |
| Ruby | `Gemfile` |
| Rust | `Cargo.toml` |
| PHP | `composer.json` |

Read the detected signal file(s). Extract: language, framework, package manager, key dependencies. Store for use in the signal map below.

---

## Phase 1 — Scaffold

Create the following structure. Skip any item that already exists — never overwrite.

```
knowledge-base/
  Product Overview.md
  Development/
    Developer Guide/
      API.md
      Debugging.md
      Guideline.md
      Prerequisites.md
      Testing.md
      Workflow.md
    Technical Debt/
      Technical Debt List.md
    Technology Stack/
      Technology Stack.md
```

### File templates

Read each template from the `templates/` subdirectory of this skill (the base directory is provided in the system message) before writing.

| Output path | Template |
|---|---|
| `knowledge-base/Product Overview.md` | `templates/product-overview.md` |
| `knowledge-base/Development/Technology Stack/Technology Stack.md` | `templates/technology-stack.md` |
| `knowledge-base/Development/Developer Guide/Prerequisites.md` | `templates/prerequisites.md` |
| `knowledge-base/Development/Developer Guide/API.md` | `templates/api.md` |
| `knowledge-base/Development/Developer Guide/Guideline.md` | `templates/guideline.md` |
| `knowledge-base/Development/Developer Guide/Debugging.md` | `templates/debugging.md` |
| `knowledge-base/Development/Developer Guide/Testing.md` | `templates/testing.md` |
| `knowledge-base/Development/Developer Guide/Workflow.md` | `templates/workflow.md` |
| `knowledge-base/Development/Technical Debt/Technical Debt List.md` | `templates/technical-debt.md` |

Tell the user what was created (list new files only, skip pre-existing). Then proceed to Phase 2.

---

## Phase 2 — Estimate

Use the detected language from Phase 0 to map each section to the signals you need to read.

### Section signal map

| Section | Signals to read |
|---|---|
| Product Overview | README.md, entry point file, package manifest (`name`, `description`) |
| Technology Stack | package manifest (full), lock file summary, Docker/config files |
| Prerequisites | README setup section, `.nvmrc`/`.tool-versions`/`engines`, docker-compose |
| API | Language-specific route files (see below), openapi/swagger files, README API section |
| Guideline | CONTRIBUTING.md, lint config (`.eslintrc*`, `.flake8`, `pyproject.toml [tool.*]`), README conventions section |
| Debugging | `.vscode/launch.json`, README debug section, Makefile debug targets |
| Testing | test dir (`test/`, `__tests__/`, `spec/`), test config (`jest.config.*`, `pytest.ini`, `mocha.*`), CI test steps |
| Workflow | `.github/workflows/`, `Makefile`, `scripts/`, `Jenkinsfile`, `Dockerfile` |
| Technical Debt | grep TODO/FIXME in source files, deprecated packages in manifest |

### API route signal by language

| Language | Route signal paths |
|---|---|
| Node.js/Express | `routes/`, `router/`, `api/` |
| Python/FastAPI | `routers/`, `api/`, `views/` |
| Python/Django | `urls.py` files |
| Go | `handlers/`, `api/`, `routes/` |
| Java/Spring | `*Controller.java` files |
| Ruby/Rails | `config/routes.rb`, `app/controllers/` |

### Estimation logic

After identifying which signals exist, group sections into:

- **Light** (1–2 file reads): Product Overview, Prerequisites
- **Medium** (3–5 file reads): Technology Stack, Guideline, Testing
- **Heavy** (5+ file reads or grep required): API, Workflow, Technical Debt

If total estimated file reads across all sections exceeds **15**, or any "heavy" section spans more than 10 source files, flag it as multi-pass and propose splitting:

> This codebase has N sections to document. I can complete [sections A, B, C] in one pass (~X reads).
> Remaining sections [D, E] are heavy (routes span N files / grep needed). I recommend running:
> - `/kb-update --section developer-guide/api` separately
> - `/kb-update --section technical-debt` separately
>
> Proceed with [sections A, B, C] now?

---

## Phase 3 — Confirm Fill Plan

Present the plan to the user:

```
Fill plan for knowledge-base/:

  ✓ Product Overview          — README + package manifest
  ✓ Technology Stack          — package.json + config
  ✓ Developer Guide/Prerequisites — README + package engines
  ~ Developer Guide/API       — DEFERRED (heavy: N route files)
  ✓ Developer Guide/Guideline — CONTRIBUTING.md + lint config
  ~ Developer Guide/Debugging — PARTIAL (no .vscode/launch.json found)
  ✓ Developer Guide/Testing   — jest.config + test dir
  ~ Developer Guide/Workflow  — DEFERRED (no CI config found)
  ~ Technical Debt            — DEFERRED (heavy: requires grep)

Proceed with ✓ sections? [yes / adjust]
```

Wait for confirmation before writing anything.

---

## Phase 4 — Fill Sections

For each confirmed section, read its signals and populate the template fields:

- Replace `{TBD}` with inferred values from the codebase
- Replace `{Project Name}` with the actual project name
- Replace `{YYYY-MM-DD}` with today's date
- Leave `{TBD}` in place for anything genuinely unknown — do not fabricate
- Add a note at the top of any partially filled file: `> Auto-filled: partial — [reason]`

Write each file. Do not overwrite files that already exist with real content.

---

## Phase 5 — Confirm and Close

List every file written. Ask: "Anything missing or wrong? Run `/kb-update --section <name>` to fill deferred sections."
