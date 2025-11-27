# Test-Driven Development (TDD) Workflow for Ruby on Rails

## Overview
You are developing a new feature in a Ruby on Rails project using **Test-Driven Development (TDD)**. The task is defined in a Product Requirements Document (PRD). Follow the instructions below step-by-step.

## Core Workflow Steps

### 1. Understand the Task
- Read the task description carefully.
- Identify the core feature and all expected behaviors.
- Break it down into small, testable units of functionality.
- Confirm which test framework is used (RSpec or Minitest).
- Determine affected parts of the Rails app (models, controllers, services, views, etc).

### 2. Write a Failing Test (Red)
- Choose one small behavior from the task.
- Create or update the appropriate test file under `spec/` or `test/`.
- Write a test that expresses the expected behavior.
  - RSpec: use `describe`, `context`, and `it` blocks.
  - Minitest: define methods starting with `test_` inside the appropriate test class.
- Run the test. It should **fail**.

### 3. Write Minimal Implementation (Green)
- Implement only the minimal code necessary to make the test pass.
- Place code in the appropriate file (model, controller, job, service, etc).
- Follow Rails naming and file conventions.
- Use clear, intention-revealing names.
- Run the test again. It should **pass**.

### 4. Refactor
- Improve the implementation:
  - Remove duplication
  - Improve clarity and maintainability
  - Use idiomatic Rails and Ruby
- Improve the test structure and readability.
- Ensure all tests still **pass** after refactoring.

### 5. Repeat for Each Behavior
- Return to step 2 and select the next smallest unimplemented behavior.
- Repeat Red → Green → Refactor.
- Cover all acceptance criteria, edge cases, and validation rules.

### 6. Finalize
- Run the full test suite. Ensure all tests **pass**.
- Cross-check against the PRD. Ensure all requirements are implemented and tested.
- Review code and test naming, organization, and readability.
- Remove debugging code, fix style issues.
- Commit the code in small, meaningful commits.

## Best Practices
- Never write implementation code before a failing test.
- Each test should cover exactly one behavior.
- Keep tests isolated, descriptive, and easy to read.
- Apply "fat model, skinny controller" and single responsibility principles.
- Follow the conventions and structure of the existing codebase.
- When in doubt, ask for clarification or review the PRD again.

You must follow this workflow strictly. Implement the feature one behavior at a time using Red → Green → Refactor.
