# Detect test runner

Before writing any tests, detect the project's language, test runner, and coverage tooling.

## Test command

1. Look for `package.json` → infer Node.js; check `scripts.test` for the test command
2. Look for `pyproject.toml` or `setup.py` → infer Python; check for `pytest` or `unittest`
3. Look for `go.mod` → infer Go; test command is `go test ./...`
4. Look for `Cargo.toml` → infer Rust; test command is `cargo test`
5. Look for other build/config files as needed

If no test runner can be inferred, ask the user: "What test command should I run? (e.g. `npm test`, `pytest`, `go test ./...`)"

Record the **test run command** — used in every red and green check.

## Coverage command

Prefer an existing project script or config. Fall back to framework defaults:

| Stack | Look for | Default coverage command |
|-------|----------|--------------------------|
| Node.js | `scripts.test:coverage`, Vitest/Jest config | `npx vitest run --coverage` or `npm test -- --coverage` |
| Python | `[tool.coverage]`, `pytest.ini`, `--cov` in scripts | `pytest --cov={business_logic_package} --cov-report=term-missing` |
| Go | — | `go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out` |
| Rust | `cargo-tarpaulin`, `llvm-cov` | `cargo llvm-cov --line` or `cargo tarpaulin` |

Scope coverage to **business-logic files only** — pass explicit paths or package names, not the whole repo.

If no coverage tooling exists and the task adds business logic, add minimal coverage config (e.g. Vitest `coverage`, pytest-cov) as part of the first RED step — keep it scoped to business-logic paths.

If coverage cannot be measured, ask the user: "What coverage command should I run for business-logic files?"

Record the **coverage command** — used after each criterion and at task close per [tdd-default.md](tdd-default.md).

## UI / behavior test command

Detect tooling for component and end-to-end behavior tests:

| Stack | Look for | Default behavior test command |
|-------|----------|-------------------------------|
| Node.js (E2E) | `playwright.config.*`, `cypress.config.*` | `npx playwright test` or `npx cypress run` |
| Node.js (component) | `@testing-library/*`, Vitest/Jest + jsdom | `npx vitest run src/**/*.test.tsx` or project `test` script with UI path filter |
| React Native | Detox, Maestro config | project-specific e2e script |
| Flutter | `integration_test/` | `flutter test integration_test/` |

Prefer an existing `scripts.test:ui`, `scripts.test:e2e`, or `scripts.test:component` if present.

If the task has UI but no behavior-test tooling exists, add minimal setup (e.g. Vitest + Testing Library, or Playwright) scoped to the UI files in the task — as part of the first behavior RED step.

If UI is in scope and the command cannot be inferred, ask: "What command runs UI behavior tests? (e.g. `npx playwright test`, `npx vitest run --grep component`)"

Record the **ui test command** — used for all B- cases per [ui-behavior-tests.md](ui-behavior-tests.md). May equal the test command with a path/grep filter when component tests share the unit runner.
