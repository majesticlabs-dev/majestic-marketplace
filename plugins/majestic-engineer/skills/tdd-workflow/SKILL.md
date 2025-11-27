---
name: tdd-workflow
description: This skill implements test-driven development workflow using the red-green-refactor cycle. Use when building new features or fixing bugs that require test coverage. Framework-agnostic methodology that works with any testing framework and programming language. Triggers on requests to implement features using TDD, write tests first, or follow test-driven development practices.
---

# TDD Workflow

## Overview

This skill guides the implementation of features using Test-Driven Development (TDD) principles. TDD is a disciplined, framework-agnostic approach where tests are written before implementation code, ensuring comprehensive test coverage and driving clean, testable design.

## Core Principle

**Never write implementation code before a failing test exists for that behavior.**

## Red-Green-Refactor Cycle

### 1. Red Phase: Write a Failing Test

**Goal:** Express the expected behavior through a test that fails.

**Process:**
- Select one small, specific behavior from the requirements
- Write a descriptive test that clearly expresses the expected behavior
- Run the test to confirm it **fails** (red)
- The failure should be for the right reason (not a syntax error or missing dependency)

**Why it must fail first:** A test that passes before any implementation is written might be testing the wrong thing or not actually exercising the code.

### 2. Green Phase: Minimal Implementation

**Goal:** Make the test pass with the simplest possible implementation.

**Process:**
- Implement only the minimal code necessary to pass the failing test
- Resist the urge to add extra features or handle edge cases not yet covered by tests
- Focus on making it work, not making it perfect
- Run the test to confirm it **passes** (green)

**Key principle:** Write the simplest code that could possibly work. Even hardcoding values is acceptable if it makes the current test pass - subsequent tests will force generalization.

### 3. Refactor Phase: Improve Quality

**Goal:** Improve code quality while maintaining passing tests.

**Process:**
- Review both implementation and test code for improvements
- Remove duplication (DRY principle)
- Improve naming and clarity
- Extract methods or classes if responsibilities are growing
- Apply language-specific idioms and patterns
- Ensure tests remain readable and maintainable
- Run tests after each refactoring step to ensure they still **pass**

**Safety net:** Tests provide confidence that refactoring doesn't break functionality.

## Workflow Decision Tree

**Starting a new feature or bug fix:**
1. Understand requirements and identify testable behaviors
2. Break down into small, independent behaviors
3. Prioritize behaviors from simple to complex
4. Enter Red-Green-Refactor cycle for each behavior

**For each behavior:**
1. **Red:** Write failing test → Confirm failure
2. **Green:** Minimal implementation → Confirm pass
3. **Refactor:** Improve code → Confirm still passing
4. Repeat for next behavior

**When all behaviors are complete:**
1. Run full test suite
2. Verify all requirements are met
3. Review code organization and naming
4. Clean up any debugging code or commented-out code
5. Commit in small, meaningful commits

## Test Sequencing Strategy

**Order tests from simple to complex:**

1. **Happy path** - The core behavior with valid inputs
   - Start here to establish the foundation
   - Example: "User can successfully log in with valid credentials"

2. **Validation tests** - Required fields, format constraints
   - Example: "Email must be present", "Password must be at least 8 characters"

3. **Edge cases** - Boundary conditions, empty values, unusual inputs
   - Example: "Handles empty string", "Handles maximum length input"

4. **Error handling** - Invalid inputs, failure scenarios
   - Example: "Returns error for invalid email format", "Handles network timeout"

5. **Integration points** - Interactions with other components
   - Example: "Sends welcome email after registration", "Updates user profile in database"

## Test Quality Guidelines

**Each test should:**
- **Cover exactly one behavior** - If a test name includes "and", it might be testing multiple things
- **Be isolated** - Tests should not depend on each other or share state
- **Have a clear, descriptive name** - Should explain what behavior is being tested
- **Be easy to read** - Test code should be even clearer than production code
- **Fail for only one reason** - When a test fails, it should be obvious why

**Avoid:**
- Testing implementation details instead of behavior
- Writing tests after the code (not TDD)
- Making tests too broad or too narrow
- Sharing test setup that creates hidden dependencies
- Skipping the refactor phase

## When to Use TDD

**Ideal for:**
- New feature development
- Bug fixes (write test that reproduces the bug first)
- Refactoring existing code (write characterization tests first)
- Complex business logic
- Code that will be maintained long-term

**May skip for:**
- Quick prototypes or proof-of-concepts
- Simple glue code
- UI layout and styling (consider other testing approaches)
- Well-understood, trivial implementations

## Benefits of TDD

- **Comprehensive test coverage** - Every line of code has a corresponding test
- **Better design** - Writing tests first forces consideration of interfaces and dependencies
- **Documentation** - Tests serve as executable specifications
- **Confidence to refactor** - Tests provide safety net for improvements
- **Fewer bugs** - Issues are caught during development, not production
- **Faster debugging** - When tests fail, the problem is in recently written code

## Framework-Specific Implementation

This skill provides the framework-agnostic TDD workflow. For framework-specific implementation details, use the appropriate testing skill for your project:

- **RSpec (Ruby):** Use the `rspec-coder` skill for RSpec syntax and patterns
- **Minitest (Ruby):** Use the `minitest-coder` skill for Minitest syntax and patterns
- **Other frameworks:** Consult framework-specific documentation or skills

## Example Reference

A Ruby on Rails example implementation is available in `references/rails-tdd-workflow.md` to illustrate how these principles apply in a specific framework, but the TDD workflow itself remains the same across all languages and frameworks.
