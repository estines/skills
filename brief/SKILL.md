---
name: brief
description: Grilling session that challenges your plan against the knowledge-base — domain glossary, architecture, and ADRs created by /kb-init. Sharpens terminology and updates knowledge-base/agents/CONTEXT.md and knowledge-base/adr/ inline as decisions crystallise. Use when user wants to stress-test a plan against their project's documented knowledge base.
trigger: /brief
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase or the knowledge-base, explore instead of asking.

</what-to-do>

<supporting-info>

## Prerequisites

This skill requires a `knowledge-base/` directory initialised by `/kb-init`. If it doesn't exist, stop and tell the user to run `/kb-init` first.

## Knowledge base awareness

Before grilling, read the following files to ground the session:

1. **`knowledge-base/agents/CONTEXT.md`** — domain glossary. Challenge every term the user uses against this.
2. **`knowledge-base/agents/ARCHITECTURE.md`** — project structure and tech-stack decisions. Use to challenge structural claims.
3. **`knowledge-base/adr/`** — existing decisions. If the user's plan contradicts a recorded decision, surface it immediately.

### Multi-context repos

If a `CONTEXT-MAP.md` exists at the repo root, read it to find all context files. Apply the same rules to each relevant context.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `knowledge-base/agents/CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Challenge against architecture

When the user's plan touches structure, layering, tech-stack, or boundaries, cross-reference against `knowledge-base/agents/ARCHITECTURE.md`. Surface contradictions: "ARCHITECTURE.md shows no layering pattern, but you're proposing a new service layer — is that a deliberate change?"

Do NOT update `knowledge-base/agents/ARCHITECTURE.md`. That file is owned by `/kb-init`. Flag structural changes as follow-up tasks instead.

### Challenge against existing ADRs

When the user's plan conflicts with a recorded ADR, surface it: "ADR-0003 says we avoid synchronous HTTP between contexts, but your plan proposes a REST call from Ordering to Billing — is this ADR superseded?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

Stress-test domain relationships with specific scenarios. Invent edge cases that force the user to be precise about concept boundaries.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it.

### Update CONTEXT.md inline

When a term is resolved, update `knowledge-base/agents/CONTEXT.md` right there. Don't batch — capture as they happen. Follow the format in the CONTEXT-FORMAT section below.

`knowledge-base/agents/CONTEXT.md` is a glossary only — no implementation details, no specs.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Write to `knowledge-base/adr/` following the ADR-FORMAT section below.

</supporting-info>

<CONTEXT-FORMAT>

# CONTEXT.md Format

`CONTEXT.md` lives in `knowledge-base/agents/`. Create lazily — only when the first term is resolved.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request
```

## Rules

- Be opinionated — pick the best word, list others as aliases to avoid.
- Flag conflicts explicitly under "Flagged ambiguities" with a clear resolution.
- Keep definitions to one or two sentences. Define what it IS, not what it does.
- Only include terms specific to this project.
- Group terms under subheadings when natural clusters emerge.

</CONTEXT-FORMAT>

<ADR-FORMAT>

# ADR Format

ADRs live in `knowledge-base/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Scan `knowledge-base/adr/` for the highest existing number and increment by one.

## Template

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

## Optional sections

Only when they add genuine value:

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`)
- **Considered Options** — only when rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need to be called out

</ADR-FORMAT>
