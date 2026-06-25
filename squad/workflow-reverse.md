# Workflow — Brownfield mode (`/squad reverse <path>`)

Run the pipeline **in reverse** over an existing codebase that has no requirements
doc. Same personas; artifacts are **recovered**, not authored. Use to understand a
system, audit it for crashes/risks, and design a behavior-preserving refactor.

Artifacts land under `dossier/reverse/`.

---

## Phase P — Execution Preview (runs first)

Same gate as greenfield (see [workflow.md](workflow.md) → Phase P), adapted:
- **Intent restatement**: which subsystem + what the user wants out (map? crash
  audit? refactor plan?).
- **Plan of record**: which B-phases will run + what each inspects.
- **Test-case scenarios**: for an audit, these are the *reachability scenarios*
  the squad will use to tier findings (how a crash is actually triggered).
- **Open questions**: scope boundaries, which entry points matter.

Approve → run B0–B5. Reject → stop.

---

## Phases B0–B5

| # | Phase | Lead | Gate artifact (`dossier/reverse/`) |
|---|-------|------|-------------------------------------|
| B0 | Intake | Product Owner | `scope.md` (subsystem + goal; no charter) |
| B1 | Recon & flow recovery | Business Analyst + Architect | `01-flow.md`, `glossary.md` |
| B2 | Reconstruct | Architect | `module-map.md` (file tree + dependency graph; legacy vs clean) |
| B3 | **Risk audit (GATE)** | Principal + QA | `crash-report.md` — tiered by reachability |
| B4 | Refactor design | Architect | `refactor.md` (before/after tree, seams, ordered steps) |
| B5 | Remediation | Product Owner | `backlog.md` → hands to forward Build→Review→QA→Deploy |

Templates: [templates-reverse.md](templates-reverse.md).

---

## Discipline that makes this mode valuable

**B3 must tier every finding by reachability, not by pattern:**

- **Verified-reachable** (a concrete trigger path exists) outranks **theoretical**
  (the pattern is risky but no reachable trigger found).
- **Read the surrounding code** before flagging — a `!!` / force-unwrap guarded by
  a null-check on the line above is NOT a bug.
- **List excluded non-bugs** explicitly (with the reason they are safe). A crash
  report that mixes false positives with real crashes loses the reader's trust.

Each finding row: `location (file:line) · bug · trigger/reachability · behavior-preserving fix`.

**B4 refactor is behavior-preserving:** prefer extending behind existing seams
(interfaces, providers) over modifying hot code. Recommend characterization tests
to pin current behavior before any change. Order steps so each is shippable alone.

## Handoff to the forward pipeline

B5's `backlog.md` feeds the greenfield Build→Review→QA→Deploy phases (or Feature
mode) to actually execute the fixes/refactors — each with its own Execution
Preview and gates.
