# Default TDD steps

Used when no matching file exists in `.goals/skills/` for the task's `skills:` frontmatter.

Two variants — pick by mode:

- **Autonomous** — orchestrator subagents (`{job steps}` in [subagent-prompt.md](subagent-prompt.md))
- **Interactive** — single-task mode Phases 3–4 in [single-task.md](single-task.md)

Both variants share the rules below.

---

## Scope — two test layers

Every task uses the layer(s) that apply. Name **business-logic files** and **UI files** before deriving tests.

### Business logic — unit TDD (AAA)

Strict red-green-refactor, one unit test at a time:

- Domain rules, calculations, validations, state transitions
- Use cases / application services (collaborators mocked or stubbed)
- Pure functions, entities, value objects, policy objects

### UI — behavior tests (Given–When–Then)

UI is **not** unit-TDD'd. When the task touches components, pages, or flows, cover each acceptance criterion with **behavior tests** per [ui-behavior-tests.md](ui-behavior-tests.md) — one user-visible behavior at a time, same red-green-refactor discipline.

UI-only tasks: behavior tests only. Mixed tasks: unit TDD for logic, then behavior tests for UI **per criterion** before ticking.

### Out of scope (implement directly; no forced tests)

- Route handlers, middleware, DI glue, serializers with no rules
- Database migrations, config, env, build scripts
- Third-party SDK calls (integration/contract tests outside this loop unless the task is an adapter)
- Generated code, thin DTOs, mappers with no branching

---

## AAA pattern — required on every unit test

Applies to **T-** unit tests on business logic. UI **B-** tests use Given–When–Then per [ui-behavior-tests.md](ui-behavior-tests.md).

Every test case uses **Arrange–Act–Assert**, visibly separated:

```text
// Arrange — inputs, fixtures, mocks, preconditions
// Act     — one call to the unit under test
// Assert  — outcome(s) for that single behaviour
```

Rules:
- **One Act** per test — one method/function/event invocation
- **Arrange** only what this test needs; no shared mutable state between tests
- **Assert** one logical behaviour (multiple `expect`/`assert` lines are fine if they describe the same outcome)
- Test names describe behaviour: `when_{condition}_then_{outcome}` or equivalent project convention
- Mock only at boundaries (repos, clocks, external APIs) — never mock the unit under test

---

## Line coverage — business logic files

Target **≥ 90% line coverage** on every business-logic file touched by the task. Aim for **100%** on pure domain modules (no I/O, no framework imports).

After each acceptance criterion's tests go green, run the **coverage command** from [detect-test-runner.md](detect-test-runner.md) scoped to business-logic files only.

If coverage is below 90% on any in-scope file:
1. List uncovered line ranges
2. Add AAA tests for those branches (happy, edge, failure) before ticking the criterion
3. Re-run coverage until the threshold is met or report why a line is legitimately unreachable

At task close, run coverage one final time and report per-file line % for all business-logic files changed.

---

## Autonomous

Identify business-logic files and UI files from the task acceptance criteria and notes.

Derive the test plan — for each acceptance criterion:
- **T-** cases: AAA unit tests for business logic (skip if UI-only)
- **B-** cases: behavior tests for UI per [ui-behavior-tests.md](ui-behavior-tests.md) (skip if no UI)

For logic cases, expand into:
- Happy path: rule holds under normal conditions
- Edge cases: boundaries, empty/min/max, off-by-one
- Failure cases: invalid input, rejected transitions, constraint violations

Auto-confirm the test plan — do not pause for user input. Proceed immediately.

Red-green-refactor loop (strictly one test at a time):

For each test case:

RED: Write one failing **AAA** unit test against business logic only.
     Run: {test run command}
     Confirm it fails. If it passes without implementation, report the anomaly and stop.

GREEN: Write the minimal business-logic implementation to make this one test pass.
       Run: {test run command}
       If still failing after 3 attempts, output the exact string STUCK_HALT on its own line and stop.

REFACTOR: Review the code. Apply any obvious improvements. Re-run tests to confirm still green. Do not ask — just refactor and proceed.

COVERAGE: After all tests for a criterion pass, run {coverage command} on business-logic files. Add tests for gaps below 90% before ticking.

BEHAVIOR: If this criterion has UI files, run the behavior loop from [ui-behavior-tests.md](ui-behavior-tests.md) using {ui test command} — all B cases for this criterion must pass.

TICK: After coverage threshold is met (logic) and behavior tests pass (UI), update `- [ ] {criterion}` → `- [x] {criterion}` in the task file.

---

## Interactive

### Derive the test plan

Identify **business-logic files** and **UI files** this task will create or change. List both before the test cases.

For each acceptance criterion, expand into:
- **T-** cases: AAA unit tests for business logic (skip if criterion is UI-only)
- **B-** cases: Given–When–Then behavior tests for UI (skip if criterion has no UI) — see [ui-behavior-tests.md](ui-behavior-tests.md)

For logic, derive cases from:
- **Happy path**: the rule works under normal conditions
- **Edge cases**: boundary values, empty inputs, minimum/maximum values
- **Failure cases**: invalid input, error conditions, constraint violations

Use the task summary, acceptance criteria wording, and notes to inform realistic test names and scenarios.

Produce a numbered flat list across all criteria:

```
Test plan for TASK-NNNN — {Title}

Business-logic files: {path/to/module.ts, …}
UI files: {path/to/Component.tsx, …} (omit if none)

From: "{Criterion 1 text}"
  T-01: {when_X_then_Y} — AAA unit test; {one-line description}
  B-01: when_{situation}_user_{action}_then_{outcome} — behavior test (omit if no UI)

From: "{Criterion 2 text}"
  T-02: {when_X_then_Y} — AAA unit test; {one-line description}
  …

Total: {N} unit + {M} behavior tests | Coverage target: ≥90% line on business-logic files

Does this test plan look right? Add, remove, or adjust test cases before I begin.
```

Wait for the user to confirm or correct. Apply corrections. Re-present only if changes are significant.

### Red-green-refactor loop

Update the active task file's `status` frontmatter to `in-progress` before starting the loop.

For each test case in the approved plan, execute this loop strictly in order:

#### Step 1 — Write the test (RED)

Write exactly one **AAA** unit test against business logic. The test must:
- Live in the project's unit-test location (create the file if needed)
- Use the project's test framework and conventions
- Target only in-scope business-logic code — mock collaborators at boundaries
- Reference only the interface/API that *should* exist, not what currently exists
- Have a clear Assert that will fail because the implementation does not exist yet
- Label Arrange, Act, and Assert sections (comments or blank lines)

Run the test command. **Confirm it fails.** If it passes without any implementation, stop and report: "T-{NN} passed without implementation — this test may not be testing the right thing. Investigate before continuing."

Report the red result:
```
T-{NN}: {test name} — RED ✗
{failing output summary}
```

#### Step 2 — Implement (GREEN)

Write the minimal **business-logic** implementation needed to make this one test pass. Do not implement UI, routes, or glue beyond what the current test requires.

Run the test command. If it passes, report:
```
T-{NN}: {test name} — GREEN ✓
```

If it still fails, revise and retry. After **3 failed attempts**, stop and report:
```
T-{NN}: {test name} — STUCK after 3 attempts

Tried:
1. {description of attempt 1}
2. {description of attempt 2}
3. {description of attempt 3}

Last error:
{error output}

How should I proceed?
```

Wait for user direction before continuing.

#### Step 3 — Refactor

Review the business-logic code just written (test + implementation). Ask:
```
T-{NN} is green. Anything to refactor before I move to T-{NN+1}?
(Reply "no" or describe what to change)
```

If the user says no or replies quickly with "no"/"skip"/"continue", proceed immediately.
If the user describes a refactor, apply it, re-run the test to confirm still green, then proceed.

#### Step 4 — Coverage check (per criterion)

After all test cases for a given acceptance criterion go green, run {coverage command} scoped to business-logic files.

Report:
```
Coverage after "{Criterion N text}":
  {file}: {NN}% lines {✓ if ≥90%, ✗ if below}
```

If any in-scope file is below 90%, add AAA tests for uncovered lines before ticking. Do not check off the criterion until coverage passes.

#### Step 5 — UI behavior tests (per criterion)

If this criterion has UI files, run the behavior loop from [ui-behavior-tests.md](ui-behavior-tests.md) for each **B-** case in the approved plan — one behavior at a time using {ui test command}.

Report each result:
```
B-{NN}: {name} — GREEN ✓
```

#### Step 6 — Tick the criterion

Change `- [ ] {criterion}` → `- [x] {criterion}` only when unit coverage (logic) and behavior tests (UI) both pass.
