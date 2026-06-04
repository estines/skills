# Task File Template

Use this template when writing tasks for the pingo pipeline.
Sections marked **optional** are skipped by the harness if absent — old tasks without them work as-is.

---

## Minimal task (no optional sections)

For simple, well-scoped changes where acceptance criteria are self-evident.

```markdown
---
status: open
goal: GOAL-NNNN-<slug>
story_points: <1|2|3|5>
---

# <Short imperative title — verb + noun, e.g. "Fix nil panic in Close stage">

## Summary

One or two sentences: what problem this solves and why it belongs here.
Skip if the title is already self-explanatory.

## Acceptance criteria

- [ ] <One testable behaviour per bullet — observable output, not implementation detail>
- [ ] <Another criterion>

## Notes

- <Hard constraint: stdlib only, no globals, nil-safe, etc.>
- <Default values or edge-case rules the agent must honour>
```

---

## Full task (all optional sections)

For tasks where you want to lock test scope, prevent coverage gate retries, and control which
test cases the implement agent writes.

```markdown
---
status: open
goal: GOAL-NNNN-<slug>
story_points: <1|2|3|5>
test_cmd: go test ./internal/<pkg>/... -count=1
coverage_cmd: go test ./internal/<pkg>/... -cover -count=1
---

# <Short imperative title>

## Summary

One or two sentences: what problem this solves and why it belongs here.

## Acceptance criteria

- [ ] <Criterion 1 — one testable behaviour>
- [ ] <Criterion 2>
- [ ] <Criterion 3>

## Notes

- <Hard constraint, e.g. stdlib only (`time`, `sync`) — no external deps>
- <Default value, e.g. default rate: 1 token/second>
- <Edge-case rule, e.g. zero or negative N disables limiting (treated as nil)>

## Test spec

| Criterion | Required test cases |
|-----------|---------------------|
| <Criterion 1 short label> | `Test<Type>_<behaviour>`, `Test<Type>_<edgeCase>` |
| <Criterion 2 short label> | `Test<Type>_<behaviour>` |
| <Notes constraint label>  | `Test<Type>_<constraint>` |
```

---

## Field reference

### Frontmatter


| Field          | Required    | Description                                                                                           |
| -------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `status`       | Yes         | Always `open` for new tasks. Pipeline sets `in-progress` → `done`.                                    |
| `goal`         | Recommended | Parent goal ID, e.g. `GOAL-0002-pipeline-hardening`.                                                  |
| `story_points` | Recommended | Fibonacci: 1 (trivial) · 2 (small) · 3 (medium) · 5 (large). Tasks above 5 should be split.           |
| `test_cmd`     | Optional    | Scoped test command the harness runs instead of auto-detecting. Locks the agent to the right package. |
| `coverage_cmd` | Optional    | Coverage variant of `test_cmd`. Inferred from `test_cmd` if omitted.                                  |


**When to set `test_cmd`:** any task touching a specific package. Example:

```
test_cmd: go test ./internal/pipeline/... -count=1
coverage_cmd: go test ./internal/pipeline/... -cover -count=1
```

Without it the implement agent chooses scope; wrong scope is the most common non-code failure.

### `## Acceptance criteria`

- Use `- [ ]` bullets (GitHub task list syntax). The pipeline counts them.
- Each bullet is one observable, testable behaviour — not an implementation step.
- Wrong: `- [ ] Create a RateLimiter struct with a mutex field`
- Right: `- [ ] \`Allow() returns false when the token bucket is empty`

### `## Notes`

Hard constraints the implement agent treats as non-negotiable. Common uses:

- Dependency restrictions: `stdlib only (`time`,` sync`) — no external deps`
- Nil / zero semantics: `when limiter is nil, no rate limiting is applied`
- Default values: `default rate: 10 req/sec`
- Scope limits: `touch only files in internal/ratelimit/ — do not refactor callers`

### `## Test spec` (optional)

A table of required test function names, one row per acceptance criterion plus one row per testable `## Notes` constraint.

**When to include it:**

- The acceptance criteria have non-obvious edge cases (zero/negative values, nil inputs, concurrency).
- You want to guarantee coverage map completeness without relying on the agent's discretion.
- The task has previously failed the coverage gate in earlier cycles.

**When to omit it:**

- Acceptance criteria are simple and unambiguous.
- Exploratory tasks where the right test structure is discovered during implementation.

**Rules for naming test cases:**


| Rule                                                               | Example                                                                |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| Name by observable behaviour, not implementation                   | `TestRateLimiter_denyWhenExhausted` not `TestRateLimiter_case2`        |
| Use `Test<Type>_<whatHappens>` format                              | `TestRunner_blocksWhenRateLimited`                                     |
| Multiple names per row for multi-branch criteria (comma-separated) | `TestRateLimiter_allowsWhenToken`, `TestRateLimiter_denyWhenExhausted` |
| One row per `## Notes` edge case                                   | `TestRateLimiter_zeroNDisables`, `TestRateLimiter_negativeNDisables`   |
| Do not name the test file — the agent picks the file               | ✓                                                                      |


**How the gate uses it:** after the implement agent writes evidence, the harness scans the evidence body for each backtick-quoted name in the table. Any missing name fails the gate with a list of what is absent — before running tests or measuring coverage.

---

## Worked example

```markdown
---
status: open
goal: GOAL-0002-pipeline-hardening
story_points: 2
test_cmd: go test ./internal/pipeline/... -count=1
coverage_cmd: go test ./internal/pipeline/... -cover -count=1
---

# Add in-memory rate limiter

## Summary

The pipeline runner has no back-pressure against the agent backend.
Add a token-bucket rate limiter so `runAgent` calls are throttled to N req/sec.

## Acceptance criteria

- [ ] `RateLimiter` type with `Allow() bool` — token bucket, N tokens/sec
- [ ] `Runner` calls `Allow()` before each `runAgent`; blocks until a token is available
- [ ] Rate limiter is injectable; when nil, no limiting is applied (default behaviour unchanged)

## Notes

- stdlib only (`time`, `sync`) — no external deps
- Default rate: 1 token/second
- Zero or negative N disables limiting (treated as nil)

## Test spec

| Criterion | Required test cases |
|-----------|---------------------|
| Allow() returns true when token available | `TestRateLimiter_allowsWhenToken` |
| Allow() returns false when bucket exhausted | `TestRateLimiter_denyWhenExhausted` |
| Bucket refills over time | `TestRateLimiter_refillsOverTime` |
| Runner blocks until token available | `TestRunner_blocksWhenRateLimited` |
| nil limiter → no blocking | `TestRunner_nilLimiterAllowed` |
| Zero N disables limiting | `TestRateLimiter_zeroNDisables` |
| Negative N disables limiting | `TestRateLimiter_negativeNDisables` |
```

