---
name: burn
description: Execute a task from .goals/ using strict TDD red-green-refactor. Derives test cases from the task's acceptance criteria, confirms the full test plan upfront, then runs one test at a time — write test → red → implement → green → refactor → next test. Use when the user wants to implement a task with TDD, mentions "burn", or types /burn.
trigger: /burn
argument-hint: "[optional: TASK-NNNN]"
---

# TDD Task

Execute a task strictly following the red-green-refactor cycle. One test at a time. Never batch. Never implement ahead of a failing test.

---

## Phase 1 — Identify the task

If an argument was passed (e.g., `/tdd-task TASK-0001`), use that task reference.

If no argument was passed:
- Scan the current conversation for a recently mentioned `TASK-NNNN`
- If exactly one task is unambiguous, use it
- If ambiguous or none found, ask: "Which task should I execute? (e.g. TASK-0001)"

Locate the task file at `.goals/GOAL-NNNN-slug/tasks/TASK-NNNN-slug.md`. Read it fully — title, summary, acceptance criteria, notes, goal reference, and `skills:` frontmatter.

Also read:
- **`.goals/GOAL-NNNN-slug/GOAL.md`** — parent goal context
- **`.goals/GOAL-NNNN-slug/CONTEXT.md`** — agent steering context: canonical terms, resolved decisions, and constraints for this goal. Apply this language throughout the session.

### Load task skills

If the task frontmatter contains a `skills:` list, load each referenced skill before proceeding:

- For each slug in `skills:`, check `.goals/skills/{slug}.md` and read it if it exists
- If a skill file contains full instructions, follow those instructions in place of or in addition to the default phases below
- Skills not found in `.goals/skills/` are silently ignored (the slug may refer to an installed global skill — proceed with default behaviour)

---

## Phase 2 — Detect the project

Before writing any tests, detect the project's language and test runner:

1. Look for `package.json` → infer Node.js; check `scripts.test` for the test command
2. Look for `pyproject.toml` or `setup.py` → infer Python; check for `pytest` or `unittest`
3. Look for `go.mod` → infer Go; test command is `go test ./...`
4. Look for `Cargo.toml` → infer Rust; test command is `cargo test`
5. Look for other build/config files as needed

If no test runner can be inferred, ask the user: "What test command should I run? (e.g. `npm test`, `pytest`, `go test ./...`)"

Record the **test run command** — it will be used in every red and green check.

---

## Phase 3 — Derive the test plan

For each acceptance criterion in the task file, expand it into granular TDD test cases following TDD best practices:

- **Happy path**: the criterion works under normal conditions
- **Edge cases**: boundary values, empty inputs, minimum/maximum values
- **Failure cases**: invalid input, error conditions, constraint violations

Use the task summary, acceptance criteria wording, and notes to inform realistic test names and scenarios.

Produce a numbered flat list across all criteria:

```
Test plan for TASK-NNNN — {Title}

From: "{Criterion 1 text}"
  T-01: {test name} — {one-line description}
  T-02: {test name} — {one-line description}

From: "{Criterion 2 text}"
  T-03: {test name} — {one-line description}
  T-04: {test name} — {one-line description}
…

Total: {N} test cases

Does this test plan look right? Add, remove, or adjust test cases before I begin.
```

Wait for the user to confirm or correct. Apply corrections. Re-present only if changes are significant.

---

## Phase 4 — Red-green-refactor loop

Update the task `status` frontmatter to `in-progress` before starting the loop.

For each test case in the approved plan, execute this loop strictly in order:

### Step 1 — Write the test (RED)

Write exactly one test case. The test must:
- Be placed in the appropriate test file for the project (create it if it doesn't exist)
- Use the project's existing test framework and conventions
- Reference only the interface/API that *should* exist, not what currently exists
- Have a clear assertion that will fail because the implementation does not exist yet

Run the test command. **Confirm it fails.** If it passes without any implementation, stop and report: "T-{NN} passed without implementation — this test may not be testing the right thing. Investigate before continuing."

Report the red result:
```
T-{NN}: {test name} — RED ✗
{failing output summary}
```

### Step 2 — Implement (GREEN)

Write the minimal implementation needed to make this one test pass. Do not implement anything beyond what is needed for the current test.

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

### Step 3 — Refactor

Review the code just written (test + implementation). Ask:
```
T-{NN} is green. Anything to refactor before I move to T-{NN+1}?
(Reply "no" or describe what to change)
```

If the user says no or replies quickly with "no"/"skip"/"continue", proceed immediately.
If the user describes a refactor, apply it, re-run the test to confirm still green, then proceed.

### Step 4 — Tick the criterion

After all test cases derived from a given acceptance criterion go green, check off that criterion in the task file:

Change `- [ ] {criterion}` → `- [x] {criterion}`

---

## Phase 5 — Close

When all test cases are green:

1. Update the task file's `status` frontmatter to `done`
2. Run the full test suite one final time to confirm no regressions
3. Report:

```
Task complete: TASK-NNNN — {Title}

Test results:
  T-01: {test name} — GREEN ✓
  T-02: {test name} — GREEN ✓
  …

All {N} tests passing. Task marked done.
```

Tell the user the task file path so they can commit the changes.
