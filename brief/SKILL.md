---
name: brief
description: Grilling session that challenges your plan against a goal's context — domain glossary and ADRs. Sharpens terminology and updates the goal's CONTEXT.md and .goals/adr/ inline as decisions crystallise. Use when user wants to stress-test a plan against their project's documented knowledge base.
trigger: /brief
argument-hint: "[optional: GOAL-NNNN]"
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase or `.goals/`, explore instead of asking.

</what-to-do>

<supporting-info>

## Prerequisites

### Check `.goals/` exists

If `.goals/` does not exist at the project root, stop: "`.goals/` not found. Run `/goals-init` first."

### Identify the goal

If an argument was passed (e.g., `/brief GOAL-0003`), use that goal reference.

Otherwise scan the current conversation for a recently mentioned `GOAL-NNNN`. If exactly one is unambiguous, use it. If ambiguous or none found, ask: "Which goal are we briefing? (e.g. GOAL-0001)"

Locate `.goals/GOAL-NNNN-slug/CONTEXT.md`. If the directory doesn't exist, stop: "No goal directory found for GOAL-NNNN. Run `/set-goal` first."

## Knowledge base awareness

Before grilling, read the following files to ground the session:

1. **`.goals/GOAL-NNNN-slug/CONTEXT.md`** — goal-specific glossary and resolved decisions. Challenge every term the user uses against this.
2. **`.goals/adr/`** — existing decisions. If the user's plan contradicts a recorded ADR, surface it immediately.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `.goals/GOAL-NNNN-slug/CONTEXT.md`, call it out immediately. "Your context defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Challenge against existing ADRs

When the user's plan conflicts with a recorded ADR in `.goals/adr/`, surface it: "ADR-0003 says we avoid synchronous HTTP between contexts, but your plan proposes a REST call from Ordering to Billing — is this ADR superseded?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

Stress-test domain relationships with specific scenarios. Invent edge cases that force the user to be precise about concept boundaries.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it.

### Update CONTEXT.md inline

When a term is resolved, update `.goals/GOAL-NNNN-slug/CONTEXT.md` right there. Don't batch — capture as they happen.

Format for terms:

```md
## Language

**{Term}**:
{One or two sentence definition of what it IS.}
_Avoid_: {comma-separated aliases to avoid}
```

`.goals/GOAL-NNNN-slug/CONTEXT.md` is a glossary only — no implementation details, no specs.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR.

Write ADRs to `.goals/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`, etc. Scan `.goals/adr/` for the highest existing number and increment by one.

ADR template:

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

</supporting-info>
