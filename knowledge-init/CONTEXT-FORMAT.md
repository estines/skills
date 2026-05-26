# CONTEXT.md Format

`CONTEXT.md` lives in `knowledge-base/agents/` for a single-context repo, or a `CONTEXT-MAP.md` at the root for multi-context repos.

Create lazily — only when the first term is resolved.

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

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project.** General programming concepts don't belong.
- **Group terms under subheadings** when natural clusters emerge.

## Single vs multi-context repos

**Single context (most repos):** One `knowledge-base/agents/CONTEXT.md`.

**Multiple contexts:** A `CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate:

```md
# Context Map

## Contexts

- [Ordering](./knowledge-base/agents/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./knowledge-base/agents/billing/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them to generate invoices
```

The skill infers which structure applies:

- If `CONTEXT-MAP.md` exists at the root, read it to find contexts
- If only `knowledge-base/agents/CONTEXT.md` exists, single context
- If neither exists, create `knowledge-base/agents/CONTEXT.md` lazily when the first term is resolved
