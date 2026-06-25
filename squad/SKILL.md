---
name: squad
description: A small software-dev-business squad (PO, BA, Architect, Principal reviewer, platform Seniors, QA, DevOps) that runs a project end-to-end through phase gates. Greenfield (build new), Brownfield (reverse-engineer/audit existing), and Feature (add to existing without breaking it) modes. Every mode starts with an Execution Preview the user approves before anything runs. Use when the user wants a full SDLC squad, types /squad, or asks to run requirements→deployment with role-based docs.
trigger: /squad
argument-hint: "[phase N | role <name> | reverse <path> | feature \"<desc>\" | status]"
---

# Squad — software-dev-business squad

A reusable squad of role personas that takes a project from requirements through
deployment, producing a real document at every gate. Each role is a persona file
in this bundle; the orchestrator spawns a `general-purpose` agent with that
persona as its prompt, so each role works in isolated context.

**Golden rule: the squad never assumes intent.** Every mode runs the
**Execution Preview** gate first (see [workflow.md](workflow.md) → "Phase P") and
waits for explicit user approval before writing or changing anything.

---

## Roles (personas in this bundle)

| Role | File | Owns |
|------|------|------|
| Product Owner | [role-product-owner.md](role-product-owner.md) | vision, backlog, acceptance criteria, sign-off |
| Business Analyst | [role-business-analyst.md](role-business-analyst.md) | requirements, user stories, process flows |
| Software Architect | [role-software-architect.md](role-software-architect.md) | system design, ADRs, API/NFR, refactor design |
| Senior Engineer | [role-senior-engineer.md](role-senior-engineer.md) | implementation + dev docs (platform-parameterized) |
| Principal Engineer | [role-principal-engineer.md](role-principal-engineer.md) | **review only** — pass/fail report, never edits code |
| QA Engineer | [role-qa-engineer.md](role-qa-engineer.md) | test strategy, cases, regression, sign-off |
| DevOps Engineer | [role-devops-engineer.md](role-devops-engineer.md) | CI/CD, IaC, runbook, release notes |

Senior Engineer takes a `platform` argument (frontend | backend | android | ios).
The squad activates only the roles a project needs.

---

## Modes & routing

Parse the argument to `/squad`:

| Argument | Mode | Read |
|----------|------|------|
| _(none)_ | resume | detect current phase from `dossier/README.md`; if absent → Greenfield Phase P |
| `feature "<desc>" [--path <repo>]` | **Feature** | [workflow-feature.md](workflow-feature.md) → F0–F8 |
| `reverse <path> [--subsystem X]` | **Brownfield** | [workflow-reverse.md](workflow-reverse.md) → B0–B5 |
| `phase N` | single phase | [workflow.md](workflow.md), run only phase N |
| `role <name> [--platform X]` | ad-hoc role | run one persona once, no gate |
| `status` | report | print the `dossier/README.md` phase index |
| anything else | Greenfield | [workflow.md](workflow.md) → Phase P then 0–7 |

`--execute` after any mode skips the Execution Preview gate **only** when the user
explicitly opts out.

---

## How the orchestrator runs a phase

For every execution phase (after the Preview is approved):

1. Read the lead `role-*.md` persona + any **support** personas for the phase.
2. Read the prior `dossier/` artifacts the persona lists as **Inputs**.
3. Spawn a `general-purpose` agent (`Task` tool) with: the persona body + the
   phase task + the artifact paths + the matching template from
   [templates.md](templates.md) / [templates-reverse.md](templates-reverse.md).
4. The agent writes the gate artifact to its `dossier/` path.
5. Orchestrator summarizes the artifact and — at a **gate phase** — asks the user
   to sign off (pass/fail). A fail loops back per the workflow's rules.
6. Update `dossier/README.md` (phase index) and open the next gate.

**Parallelism:** the Build phase may spawn several Senior Engineer agents (one per
platform) concurrently via `TaskCreate` / `TaskGet`, then merge their dev-notes —
mirroring the `burn` skill's orchestrator.

**Output format:** every artifact is markdown by default. On request (or by
default for previews/audits) also render the interactive single-file HTML from
[templates-html.md](templates-html.md) into a `reports/` folder.

---

## Tools used

| Tool | Purpose |
|------|---------|
| `Task` / `TaskCreate` / `TaskGet` / `TaskOutput` | spawn role agents; parallel seniors |
| `Read` / `Write` / `Edit` | read prior artifacts, write gate artifacts + state |
| `Grep` / `Glob` / `Bash` | brownfield/feature recon: map code, run tests |
| `AskUserQuestion` | the Execution Preview decision gate and sign-offs |

---

## First run in a project

If `dossier/` does not exist, create it from [dossier-layout.md](dossier-layout.md)
(scaffold `dossier/README.md` as the phase index) before running Phase P.
