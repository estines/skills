---
name: kb-update
description: Scan the current conversation for decisions made, then commit them to knowledge-base/ — creating new ADRs and updating agent files (CONTEXT.md, ARCHITECTURE.md). Use after a grilling session, design review, or any conversation where architectural or domain decisions were reached.
trigger: /kb-update
---

# Knowledge Base Update

Scan the conversation for decisions made, propose updates to `knowledge-base/`, confirm each one, then write.

---

## Phase 0 — Prerequisite check

Check that `knowledge-base/` exists in the current working directory.

If it does **not** exist, stop immediately:

> No `knowledge-base/` found. Run `/kb-init` first.

---

## Phase 1 — Scan and propose

Read the entire conversation. Identify two categories of candidates:

### 1a. ADR candidates

Decisions that meet the ADR threshold (all three must be true):

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one

Also check: does any candidate **supersede** an existing ADR in `knowledge-base/adr/`? If so, note the ADR it replaces.

For each candidate, present a one-line summary before proposing the full text:

```
ADR candidate [1/N]: {One sentence: what was decided}
Confidence: high | medium
Reason qualifies: {Which of the 3 criteria it meets, in one phrase}
Supersedes: ADR-NNNN ({title}) — or "none"

Proposed text:
---
# {Short title}

{1–3 sentences: context, decision, why.}
---

Write this ADR? [yes / skip / edit]
```

Wait for the user to respond before moving to the next candidate.

### 1b. Agent file candidates

Changes to existing agent files that reflect decisions or domain terms resolved in the conversation:

- **`knowledge-base/agents/CONTEXT.md`** — new or updated terms, aliases to avoid, resolved ambiguities
- **`knowledge-base/agents/ARCHITECTURE.md`** — structural changes, tech stack updates, new patterns

For each candidate, show a diff-style preview before writing:

```
Agent file update [1/N]: knowledge-base/agents/CONTEXT.md
---
+ **{Term}**:
+ {Definition}
+ _Avoid_: {aliases}
---

Apply this change? [yes / skip / edit]
```

Wait for the user to respond before moving to the next candidate.

If no candidates are found in either category, tell the user:

> No ADR-worthy decisions or agent file updates found in this conversation.

---

## Phase 2 — Write confirmed changes

For each confirmed ADR:

1. Scan `knowledge-base/adr/` for the highest existing number. Increment by one.
2. Write `knowledge-base/adr/{NNNN}-{slug}.md` following the ADR format below.
3. If it supersedes an existing ADR:
   - Add `status: superseded by ADR-{NNNN}` frontmatter to the old ADR file.
   - Reference the old ADR in the new one: "Supersedes ADR-{NNNN}."
4. Add an entry to `knowledge-base/adr/README.md` index (append one line: `- [ADR-{NNNN}]({filename}) — {title}`). Create the README if it doesn't exist.

For each confirmed agent file change:

1. Edit the target file in place, adding or updating only the relevant section.
2. Do not rewrite sections unrelated to the confirmed change.

---

## Phase 3 — Report

List every file written or modified. One line per file, with what changed:

```
Written:
- knowledge-base/adr/0004-use-postgres-for-write-model.md (new ADR)
- knowledge-base/adr/0002-sqlite-for-write-model.md (marked superseded by ADR-0004)
- knowledge-base/adr/README.md (added ADR-0004 entry)
- knowledge-base/agents/CONTEXT.md (added: Order, Invoice)
```

Then ask: "Anything missing or wrong?"

---

## ADR format reference

```md
---
status: accepted
---

# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

Optional sections (only when they add genuine value):

- **Considered Options** — rejected alternatives worth remembering
- **Consequences** — non-obvious downstream effects
