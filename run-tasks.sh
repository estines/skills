#!/usr/bin/env bash
set -euo pipefail

GOAL_ID="${1:-}"

if [[ -z "$GOAL_ID" ]]; then
  echo "Usage: $0 GOAL-NNNN" >&2
  exit 1
fi

# Locate goal directory
GOAL_DIR=$(find knowledge-base/goals -maxdepth 1 -type d -name "${GOAL_ID}-*" | head -1)

if [[ -z "$GOAL_DIR" ]]; then
  echo "Error: No directory found for goal ${GOAL_ID}" >&2
  exit 1
fi

TASKS_DIR="${GOAL_DIR}/tasks"

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: No tasks directory at ${TASKS_DIR}" >&2
  exit 1
fi

# Collect open tasks in filename order (TASK-0001 before TASK-0002, etc.)
OPEN_TASKS=()
while IFS= read -r -d '' f; do
  if grep -q "^status: open" "$f" 2>/dev/null; then
    OPEN_TASKS+=("$f")
  fi
done < <(find "${TASKS_DIR}" -maxdepth 1 -name "TASK-*.md" -print0 | sort -z)

if [[ ${#OPEN_TASKS[@]} -eq 0 ]]; then
  echo "No open tasks found in ${TASKS_DIR}"
  exit 0
fi

echo "Found ${#OPEN_TASKS[@]} open task(s) under ${GOAL_DIR}"

for TASK_FILE in "${OPEN_TASKS[@]}"; do
  TASK_ID=$(basename "$TASK_FILE" .md | grep -oE 'TASK-[0-9]+')

  echo ""
  echo "=========================================="
  echo "  ${TASK_ID}  →  $(basename "$TASK_FILE")"
  echo "=========================================="

  # Mark in-progress before handing off to claude
  sed -i '' 's/^status: open$/status: in-progress/' "$TASK_FILE"

  PROMPT="/burn ${TASK_ID}

You are running in fully autonomous mode. Follow these rules strictly and without exception:
- Phase 3 (test plan confirmation): auto-confirm immediately — do not pause or wait for user input, proceed straight to the red-green-refactor loop
- Phase 4 refactor step: after every green test, always perform a refactor pass — do not ask, just refactor then proceed to the next test
- If STUCK after 3 failed attempts on any test: output the exact string STUCK_HALT on its own line and stop immediately
- Never ask for any confirmation or user input at any point
- Complete the full task end-to-end, marking it done when all tests are green
- After marking the task done, stage all changed files with git and create a commit with the message: \"${TASK_ID}: <short description of what was implemented>\""

  CLAUDE_EXIT=0
  OUTPUT=$(claude --dangerously-skip-permissions -p "$PROMPT" 2>&1) || CLAUDE_EXIT=$?

  echo "$OUTPUT"

  if echo "$OUTPUT" | grep -qF "STUCK_HALT" || [[ $CLAUDE_EXIT -ne 0 ]]; then
    sed -i '' 's/^status: in-progress$/status: failed/' "$TASK_FILE"

    FAILURE_FILE="${TASK_FILE%.md}-failure.md"
    {
      printf -- "---\n"
      printf "date: %s\n" "$(date +%Y-%m-%d)"
      printf "task: %s\n" "${TASK_ID}"
      printf "exit_code: %s\n" "${CLAUDE_EXIT}"
      printf -- "---\n\n"
      printf "# Failure Report: %s\n\n" "${TASK_ID}"
      printf "## Output\n\n\`\`\`\n"
      printf "%s\n" "$OUTPUT"
      printf "\`\`\`\n"
    } > "$FAILURE_FILE"

    echo ""
    echo "HALT: ${TASK_ID} failed (exit ${CLAUDE_EXIT})"
    echo "Report written: ${FAILURE_FILE}"

    osascript -e "display notification \"${TASK_ID} failed — see ${FAILURE_FILE}\" with title \"run-tasks: HALTED\"" 2>/dev/null || true

    exit 1
  fi
done

echo ""
echo "=========================================="
echo "  ${GOAL_ID}: all ${#OPEN_TASKS[@]} task(s) done"
echo "=========================================="

osascript -e "display notification \"All ${#OPEN_TASKS[@]} tasks completed for ${GOAL_ID}\" with title \"run-tasks: DONE\"" 2>/dev/null || true
