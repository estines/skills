# Templates — forward pipeline artifacts

Each `## ` section is one template. The orchestrator copies the relevant section,
fills the `{{placeholders}}`, and writes it to the artifact path named in the
workflow. Keep filled docs concise — a reader should scan in under a minute.

---

## execution-preview.md (Phase P — ALL modes)

```markdown
# Execution Preview — {{mode}}: {{title}}

> ⏸ NOTHING EXECUTED YET. Squad waits for approval at the decision gate below.

## 1. Intent — what the squad understood you want
{{2–3 sentence restatement, problem vs solution}}

**Acceptance criteria**
- AC-1: {{observable outcome}}
- AC-2: …

## 2. Plan of record
Phases/roles that will run: {{list}}

**File tree** (new / touched / unchanged)
{{tree; for feature/brownfield mark blast radius}}

## 3. Test-case scenarios (the contract)
- **SC-1** [acceptance] Given … When … Then …
- **SC-2** [regression] Given … When … Then … (existing flow stays identical)
- **SC-3** [edge] Given … When … Then …

## 4. Open questions
- Q1: {{ambiguity}} (assumed: {{default}})

## 5. Decision: Approve / Revise / Reject
On approve, these scenarios become QA's acceptance + regression suite.
```

---

## project-charter.md (Phase 0)

```markdown
# Project Charter — {{name}}
- **Vision:** {{one line}}
- **Problem:** {{what hurts today}}
- **Target users:** {{who}}
- **Success metrics:** {{measurable}}
- **In scope (v1):** {{bullets}}
- **Out of scope (v1):** {{bullets}}
```

---

## brd.md (Phase 1)

```markdown
# Business Requirements — {{name}}
## Functional
- FR-1: {{behavior}}
## Non-functional
- NFR-1: {{perf/security/a11y/compliance, measurable}}
## Constraints & assumptions
- {{bullets}}
```

## user-stories.md (Phase 1)

```markdown
# User Stories
## US-1 — {{title}}
As a {{role}}, I {{action}} so that {{value}}.
- AC: {{observable}}
- AC: {{observable}}
```

---

## design.md (Phase 2)

```markdown
# System Design — {{name}}
## Components
{{diagram or list: component → responsibility}}
## Data flow
{{request path}}
## Technology stack
{{choices + 1-line rationale each}}
```

## ADR-NNNN.md (Phase 2)

```markdown
# ADR-{{NNNN}} — {{decision title}}
- **Status:** Proposed | Accepted | Superseded
- **Decision:** {{what was chosen}}
- **Context:** {{forces, alternatives}}
- **Consequences:** {{trade-offs, follow-ups}}
```

## api-contracts.md (Phase 2)

```markdown
# API Contracts
{{METHOD}} {{path}} → {{status}} {{response shape}}
  request: {{shape}}
  errors: {{code → meaning}}
```

## nfr.md (Phase 2)

```markdown
# Non-Functional Targets
| Concern | Target |
|---------|--------|
| Latency | {{e.g. p95 < 100ms}} |
| Availability | {{e.g. 99.9%}} |
```

---

## backlog.md / task-breakdown.md (Phase 3 / B5 / F0)

```markdown
# Backlog
| ID | Task | Owner (platform) | Pts | Story |
|----|------|------------------|-----|-------|
| T1 | {{task}} | SE·{{platform}} | {{1/2/3/5/8}} | US-1 |
```

---

## dev-notes.md + changelog.md (Phase 4 / F5)

```markdown
# Dev Notes — {{platform}}
## What was built
{{bullets}}
## Deviations / decisions
{{bullets, link ADRs}}

# Changelog
- {{type}}: {{summary}}
```

---

## review-report.md (Phase 5 / F6)

```markdown
# Review Report — round {{n}}
| File:line | Severity | Finding → fix |
|-----------|----------|---------------|
| {{path:line}} | 🔴/🟠/🟡 | {{problem}} → {{fix}} |

**Excluded (verified safe):** {{location — why}}

**Verdict:** PASS | FAIL  {{if FAIL: blocking items, loop to Phase 4}}
```

---

## test-plan.md + test-cases.md + bug-report.md + signoff.md (Phase 6 / F7)

```markdown
# Test Plan
Scope, environments, suite mapping to approved scenarios.

# Test Cases
| TC | Scenario | Tag | Input | Expected | Result |
|----|----------|-----|-------|----------|--------|
| TC-1 | SC-1 | acceptance | … | … | ✅/❌ |

# Bug Report
| ID | Severity | Steps | Expected | Actual |
|----|----------|-------|----------|--------|

# QA Sign-off
Acceptance: {{n/n}} · Regression: {{n/n}} · Open high-sev: {{count}}
**Verdict:** PASS | FAIL
```

---

## runbook.md + ci-cd.md + release-notes.md (Phase 7 / F8)

```markdown
# Runbook
Deploy steps · health checks · **rollback procedure** · feature-flag rollout

# CI/CD
build → test (QA gate) → deploy → smoke. {{pipeline config}}

# Release Notes — {{version}}
- {{user-facing change mapped to acceptance criteria}}
```
