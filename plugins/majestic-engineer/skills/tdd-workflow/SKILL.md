---
name: tdd-workflow
description: Test-driven development execution workflow with red-green-refactor cycle, increment decomposition, and pause/continue rules. Use when building features or fixing bugs using TDD. Framework-agnostic with language-specific configs for Python, TypeScript, Go, and Ruby delegation.
---

# TDD Workflow

## Core Principle

**Never write implementation code before a failing test exists for that behavior.**

## Execution Flow

### 1. Setup

```
LANG = /majestic:config tech_stack "unknown"
If LANG == "unknown": detect from project files (package.json → TypeScript, Gemfile → Ruby, go.mod → Go, pyproject.toml → Python)
If LANG == "unknown": AskUserQuestion("What language/framework?")

RUNNER = lookup LANG in [references/language-configs.md]
If LANG in [ruby]: delegate to `rspec-coder` or `minitest-coder` skill for runner details

INCREMENTS = decompose feature using patterns from [references/increments.md]
  - Read requirements/plan
  - Identify pattern (Data Transformation, CRUD, State Machine, Calculation, Integration)
  - Break into ordered increments: degenerate → happy path → variations → edge cases → errors

For each INCREMENT in INCREMENTS:
  TaskCreate(subject: INCREMENT.name, description: INCREMENT.test_description)

AskUserQuestion("Review increments. Adjust ordering or scope?", options: ["Looks good", "Modify"])
```

### 2. TDD Loop (per increment)

```
For each INCREMENT in INCREMENTS:
  TaskUpdate(INCREMENT.task_id, status: "in_progress")

  # RED
  Write failing test to real file (not code block)
  RUN = Bash(RUNNER.test_command)
  If RUN.status == PASS: STOP — investigate unexpected pass
  If RUN.status == FAIL (wrong reason): fix test, rerun
  PAUSE → show test + failure output, wait for user

  # GREEN
  Write minimal implementation code
  RUN = Bash(RUNNER.full_suite_command)
  If RUN.status == FAIL: show output, PAUSE → ask user to fix or hand off
  If RUN.status == PASS: auto-continue (no pause)

  # REFACTOR
  If improvement opportunities exist:
    Refactor implementation and/or test code
    RUN = Bash(RUNNER.full_suite_command)
    If RUN.status == FAIL: revert refactor, PAUSE → discuss
    If RUN.status == PASS: auto-continue (no pause)

  TaskUpdate(INCREMENT.task_id, status: "completed")
  Brief summary of what was implemented
  → immediately begin next increment (no pause between increments)
```

### 3. Wrap-up

```
RUN = Bash(RUNNER.full_suite_command)
Report: increments completed, total tests, pass/fail status
Suggest: remaining work, missed edge cases, integration tests needed
```

## Pause/Continue Rules

| Situation | Action |
|-----------|--------|
| RED: test fails (expected) | **Pause** — show test + failure, wait for user |
| RED: test passes unexpectedly | **Stop** — investigate, don't proceed |
| GREEN: all tests pass | **Auto-continue** to REFACTOR |
| GREEN: tests fail | **Pause** — show output, ask user |
| REFACTOR: tests pass | **Auto-continue** to next increment |
| REFACTOR: tests fail | **Revert + Pause** — discuss approach |
| Between increments | **Auto-continue** — no pause |

## Task Tracking Integration

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
WORKFLOW_ID = "tdd-{timestamp}"

If TASK_TRACKING:
  For each TaskCreate: add metadata {workflow: WORKFLOW_ID, phase: "tdd-loop"}
  For each TaskUpdate: wrap with If TASK_TRACKING: TaskUpdate(...)
  On Wrap-up: update ledger if LEDGER_ENABLED
    LEDGER_ENABLED = /majestic:config task_tracking.ledger false
    LEDGER_PATH = /majestic:config task_tracking.ledger_path .agents/workflow-ledger.yml
```

## Red-Green-Refactor Cycle

### 1. Red Phase: Write a Failing Test

- Select one small, specific behavior from the increment
- Write a descriptive test that expresses the expected behavior
- Run the test to confirm it **fails** (red)
- The failure should be for the right reason (not syntax error or missing dependency)

### 2. Green Phase: Minimal Implementation

- Implement only the minimal code necessary to pass the failing test
- Resist adding extra features or handling edge cases not yet covered by tests
- Run the test to confirm it **passes** (green)

### 3. Refactor Phase: Improve Quality

- Review both implementation and test code for improvements
- Remove duplication, improve naming, extract methods
- Apply language-specific idioms and patterns
- Run tests after each refactoring step to ensure they still **pass**

## Test Sequencing Strategy

**Order tests from simple to complex:**

1. **Happy path** — The core behavior with valid inputs
2. **Validation tests** — Required fields, format constraints
3. **Edge cases** — Boundary conditions, empty values, unusual inputs
4. **Error handling** — Invalid inputs, failure scenarios
5. **Integration points** — Interactions with other components

## Test Quality Guidelines

**Each test should:**
- Cover exactly one behavior
- Be isolated — no shared state between tests
- Have a clear, descriptive name
- Fail for only one reason

**Avoid:**
- Testing implementation details instead of behavior
- Writing tests after the code
- Sharing test setup that creates hidden dependencies
- Skipping the refactor phase

## Framework-Specific Implementation

For language-specific test runner commands, see [references/language-configs.md](references/language-configs.md).

For Ruby projects:
- **RSpec:** Apply `rspec-coder` skill
- **Minitest:** Apply `minitest-coder` skill

A Rails example is available in [references/rails-tdd-workflow.md](references/rails-tdd-workflow.md).

## Test Generation Patterns

When writing tests outside a TDD loop (e.g., adding coverage to existing code), follow these patterns.

### Framework Detection

| Evidence | Framework |
|----------|-----------|
| `spec/` + `_spec.rb` + `.rspec` | RSpec |
| `test/` + `_test.rb` + `test_helper.rb` | Minitest |
| `*.test.js` + `jest.config.js` | Jest |
| `*.spec.ts` in `tests/` or `e2e/` | Playwright |
| `vitest.config.js` | Vitest |

### Test Plan Structure

Before writing tests, create a plan covering:

1. **Scope** - What functionality will be tested
2. **Happy path scenarios** - Expected successful flows
3. **Sad path scenarios** - Error handling, validations, failures
4. **Edge cases** - Boundary conditions, null/empty values, unusual inputs
5. **Auth checks** - Authorization/authentication (if applicable)
6. **Test data requirements** - Fixtures or data needed
7. **Mocking strategy** - External services/dependencies to mock

### Test Case Matrix

Use for complex scenarios with multiple parameters:

| Objective | Inputs | Expected Output | Test Type |
|-----------|--------|-----------------|-----------|
| Validate creation | valid params | Created, 201 | Happy Path |
| Reject duplicate | existing data | Error, 422 | Sad Path |
| Handle empty | missing field | Validation error | Edge Case |

### Completion Criteria

Tests are complete when ALL of these are met:

**Coverage:** All public methods tested, happy/sad/edge paths covered, auth checks included.

**Quality:** Tests pass (verified by running), isolated (no shared state), follow AAA pattern (Arrange-Act-Assert), descriptive names.

**Framework compliance:** Proper matchers, appropriate mocking, follows project patterns.

### Test Writing Best Practices

- Test behavior, not implementation details
- One assertion focus per test
- Use descriptive test names that document expected behavior
- Prefer explicit assertions over implicit ones
- Use test doubles sparingly and purposefully
- Group related tests with describe/context blocks
- Test data should be minimal but sufficient
- For Rails: use transactional fixtures and database cleaner
- For Playwright: proper waiting strategies, avoid flaky selectors
