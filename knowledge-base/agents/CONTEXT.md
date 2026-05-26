# Skills Repo

Custom Claude Code skills for knowledge management and task execution, built around the knowledge-base/ directory structure.

## Language

**Skill**:
A self-contained Claude Code slash command defined by a `SKILL.md` file. Encapsulates a repeatable workflow.
_Avoid_: plugin, command, tool

**Goal**:
A high-level objective with acceptance criteria that drives task creation. Lives in `knowledge-base/goals/`.
_Avoid_: feature, ticket, epic, story

**Task**:
A discrete, vertical-slice unit of work derived from a Goal. Has its own acceptance criteria and story point estimate. Lives under its parent Goal's directory.
_Avoid_: subtask, issue, ticket, to-do

**Acceptance Criterion**:
An observable, testable outcome that defines when a Goal or Task is complete. Written as a checkbox in the goal/task file.
_Avoid_: requirement, spec, condition

**Test Case**:
A single, granular automated test derived from an Acceptance Criterion. One criterion typically expands into multiple test cases (happy path, edge cases, failure cases).
_Avoid_: test, spec, scenario (when referring to an individual TDD test)

**Test Plan**:
The full ordered list of test cases for a given Task, confirmed by the user before the TDD loop begins.
_Avoid_: test suite, test list

**Red-Green-Refactor**:
The TDD cycle: write a failing test (red), implement until it passes (green), then improve the code without breaking the test (refactor).
_Avoid_: TDD loop, test cycle

**Knowledge Base**:
The `knowledge-base/` directory at the project root. Contains goals, tasks, ADRs, and agent context files.
_Avoid_: docs folder, project docs
