---
name: kb-update
description: Surface unfilled knowledge-base/ sections, or target a specific section with --section to re-scan the codebase and update a knowledge-base document. Use when the user wants to fill gaps in knowledge-base/ or refresh a specific section.
trigger: /kb-update
---

# Knowledge Base Update

Two modes:

- **`/kb-update`** — surface any unfilled `knowledge-base/` sections
- **`/kb-update --section <target>`** — re-scan the codebase to fill or refresh a specific section

---

## Phase 0 — Prerequisite Check

Check that `knowledge-base/` exists in the current working directory.

If it does **not** exist, stop immediately:

> No `knowledge-base/` found. Run `/kb-init` first.

### Argument parsing

If the user passed `--section <target>`, extract the section target and jump to **Mode B**.

Otherwise continue to **Mode A**.

---

## Mode A — Surface Empty Sections

Scan `knowledge-base/` for files that still contain `{TBD}` placeholders or are entirely empty. Group by section.

If any are found, present:

```
The following knowledge-base sections are incomplete:

  - Development/Developer Guide/API.md (deferred from /kb-init)
  - Development/Technical Debt/Technical Debt List.md (empty)
  - Product Overview.md (partial — 3 {TBD} fields)

Fill now? Run `/kb-update --section <name>` for any of the above.
```

If none are found:

> All `knowledge-base/` sections look complete. Run `/kb-update --section <name>` to refresh a specific section.

---

## Mode B — Section-targeted Update

### Valid section targets

Top-level targets (fills the entire group):

| Target | Fills |
|---|---|
| `product-overview` | `knowledge-base/Product Overview.md` |
| `technology-stack` | `knowledge-base/Development/Technology Stack/Technology Stack.md` |
| `technical-debt` | `knowledge-base/Development/Technical Debt/Technical Debt List.md` |
| `developer-guide` | All 6 files under `knowledge-base/Development/Developer Guide/` |

Sub-section targets:

| Target | Fills |
|---|---|
| `developer-guide/api` | `knowledge-base/Development/Developer Guide/API.md` |
| `developer-guide/guideline` | `knowledge-base/Development/Developer Guide/Guideline.md` |
| `developer-guide/prerequisites` | `knowledge-base/Development/Developer Guide/Prerequisites.md` |
| `developer-guide/testing` | `knowledge-base/Development/Developer Guide/Testing.md` |
| `developer-guide/debugging` | `knowledge-base/Development/Developer Guide/Debugging.md` |
| `developer-guide/workflow` | `knowledge-base/Development/Developer Guide/Workflow.md` |

If the target is not in the list above, tell the user the valid targets and stop.

---

### B1. Language Detection

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

---

### B2. Read codebase signals

Use the section signal map from the kb-init skill to identify which files to read for this section:

| Section | Signals to read |
|---|---|
| Product Overview | README.md, entry point file, package manifest (`name`, `description`) |
| Technology Stack | Package manifest (full), lock file summary, Docker/config files |
| Prerequisites | README setup section, `.nvmrc`/`.tool-versions`/`engines`, docker-compose |
| API | Language-specific route files, openapi/swagger files, README API section |
| Guideline | CONTRIBUTING.md, lint config, README conventions section |
| Debugging | `.vscode/launch.json`, README debug section, Makefile debug targets |
| Testing | Test dir, test config files, CI test steps |
| Workflow | `.github/workflows/`, `Makefile`, `scripts/`, `Jenkinsfile` |
| Technical Debt | grep TODO/FIXME in source files, deprecated packages in manifest |

API route signal by language:

| Language | Route signal paths |
|---|---|
| Node.js/Express | `routes/`, `router/`, `api/` |
| Python/FastAPI | `routers/`, `api/`, `views/` |
| Python/Django | `urls.py` files |
| Go | `handlers/`, `api/`, `routes/` |
| Java/Spring | `*Controller.java` files |
| Ruby/Rails | `config/routes.rb`, `app/controllers/` |

---

### B3. Generate new content

Produce the updated file content using the template from `../kb-init/templates/<name>.md` (peer skill directory) and the codebase signals you read. Replace all `{TBD}` fields you can infer. Leave `{TBD}` in place for anything genuinely unknown — do not fabricate.

---

### B4. Version the existing file

Before writing, check if the target file already exists and has content beyond the scaffold template (i.e., contains non-`{TBD}` content).

If yes, save the current file as a versioned copy:

1. Create `knowledge-base/<section-path>/versions/` if it doesn't exist.
2. Find the highest existing version number in that folder (e.g., `Guideline.v2.md`).
3. Save current content as `Guideline.v{N+1}.md` (start at `v1` if no versions exist yet).

If no, proceed directly to writing (no version to save).

---

### B5. Write the new file

Write the generated content to the target path (e.g., `knowledge-base/Development/Developer Guide/API.md`).

---

### B6. Report

```
Updated:
- knowledge-base/Development/Developer Guide/API.md (new content from codebase scan)
- knowledge-base/Development/Developer Guide/versions/API.v1.md (previous version archived)
```

Then ask: "Anything missing or wrong?"
