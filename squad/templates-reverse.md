# Templates — Brownfield & Feature recovery artifacts

Companion to [templates.md](templates.md) for `reverse` and `feature` modes.

---

## scope.md (B0)

```markdown
# Reverse scope — {{subsystem}}
- **Goal:** map | audit-crashes | refactor-plan | {{combination}}
- **Entry points:** {{activities/endpoints/screens}}
- **Out of scope:** {{bullets}}
```

---

## 01-flow.md (B1)

```markdown
# Recovered flow — {{subsystem}}
## Happy path
{{step → file:method → next}}
## Branches / error paths
{{bullets}}
## Cross-cutting (auth, session, refresh, flags)
{{notes}}
```

## glossary.md (B1)

```markdown
# Domain glossary (recovered)
| Term | Meaning | Where in code |
|------|---------|---------------|
| {{term}} | {{definition}} | {{file/enum/const}} |
```

---

## module-map.md (B2)

```markdown
# Module map — {{subsystem}}
## File tree (tag: new/clean · legacy · crash)
{{tree}}
## Dependency direction
{{module → module, note healthy vs tangled}}
## Verdict
{{where the rot is concentrated; how bounded the refactor surface is}}
```

---

## crash-report.md (B3 / audit)

```markdown
# Crash audit — {{subsystem}}  (tiered by reachability)

| Tier | Location | Bug | Trigger (reachable) | Behavior-preserving fix |
|------|----------|-----|---------------------|--------------------------|
| 🔴 P0 | {{file:line}} | {{bug}} | {{concrete trigger path}} | {{fix}} |
| 🟠 P2 | … | … | {{precondition}} | … |

## Excluded — verified NON-bugs (with reason safe)
- {{file:line}} — {{why it cannot crash}}

## Verdict
{{can the current build be certified safe? which P0/P1 block?}}
```

---

## impact-map.md (F1)

```markdown
# Impact map — feature: {{desc}}
## Recovered flow the feature touches
{{path}}
## Blast radius — file tree (new / touched / unchanged)
{{tree}}
## Contracts & callers affected
{{list}}
## Classification
extend | modify | strangler — {{rationale}}
## Regression scenarios to protect
- {{existing flow that must stay identical}}
```

---

## refactor.md (B4)

```markdown
# Refactor design — {{subsystem}}  (behavior-preserving)
## Root cause
{{what makes change expensive / crash-prone}}
## Before → After
{{two trees or seam diagram}}
## Existing seams to extend behind
{{interfaces/providers already present}}
## Ordered steps (each shippable alone)
| # | Step | Risk | Owner |
|---|------|------|-------|
| 1 | {{guard/fix}} | trivial | SE·{{platform}} |
| 2 | {{extract behind seam, characterization tests first}} | medium | … |
## Behavior-frozen guarantee
{{why no user-visible flow changes}}
```
