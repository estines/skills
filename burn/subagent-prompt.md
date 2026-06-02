# Subagent prompt template

Used in orchestrator Phase O-4b. Each subagent prompt must be fully self-contained.

Substitute `{job steps}` with either:
- The body of the first matching `.goals/skills/{slug}.md` (everything after frontmatter), or
- The **Autonomous** section from [tdd-default.md](tdd-default.md)

```
You are executing a task on virtual branch burn/{GOAL-NNNN}/{TASK-NNNN}.

Create and work on git branch burn/{GOAL-NNNN}/{TASK-NNNN} (checkout -b if needed). Commit only on this branch. Do not checkout or modify other burn/* branches.

Stay within this task's scope — only edit files required for TASK-NNNN. If the task notes list owned paths, respect them; otherwise infer minimal paths from acceptance criteria.

Task: {TASK-NNNN}
Goal: {GOAL-NNNN}
Virtual branch: burn/{GOAL-NNNN}/{TASK-NNNN}
Test command: {test run command}
Coverage command: {coverage command}
UI test command: {ui test command}

## Setup

1. Locate the task file:
   - First check: .goals/{GOAL-NNNN-slug}/tasks/{TASK-NNNN-slug}.md
   - Then check: .goals/{GOAL-NNNN-slug}/tasks/{TASK-NNNN-slug}/TASK.md
   Read it fully — title, summary, acceptance criteria, notes.

2. Read goal context:
   - .goals/{GOAL-NNNN-slug}/GOAL.md
   - .goals/{GOAL-NNNN-slug}/CONTEXT.md (apply this language throughout)

3. Update the task file's status frontmatter to `in-progress`.

## Your job

{job steps}

## Finish

When all work is complete:
- Run {coverage command} on business-logic files — every in-scope file must be ≥90% line coverage; add tests if not
- Run {ui test command} if the task touched UI — all behavior tests must pass
- Update task status to `done`
- Run {test run command} one final time to confirm no regressions
- Stage all changed files: git add -A
- Commit on virtual branch: git commit -m "{TASK-NNNN}: {short description of what was implemented}"
- Report exactly: "TASK-NNNN complete." and include the branch name: burn/{GOAL-NNNN}/{TASK-NNNN}
```
