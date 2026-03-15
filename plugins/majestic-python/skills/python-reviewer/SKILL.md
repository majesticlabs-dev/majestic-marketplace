---
name: python-reviewer
description: Review Python code with high quality bar for type hints, Pythonic patterns, and maintainability.
allowed-tools: Read Grep Glob Bash
---

# Python Code Review Standards

**Audience:** Python developers submitting code for review
**Goal:** Enforce high standards for Pythonic patterns, type safety, and maintainability

## 1. Existing Code Modifications - Be Very Strict

- Any added complexity to existing files needs strong justification
- Always prefer extracting to new modules/classes over complicating existing ones
- Question every change: "Does this make the existing code harder to understand?"

## 2. New Code - Be Pragmatic

- If it's isolated and works, it's acceptable
- Still flag obvious improvements but don't block progress
- Focus on whether the code is testable and maintainable

## 3. Type Hints Convention

- ALWAYS use type hints for function parameters and return values
- FAIL: `def process_data(items):`
- PASS: `def process_data(items: list[User]) -> dict[str, Any]:`
- Use modern Python 3.10+ type syntax: `list[str]` not `List[str]`
- Leverage union types with `|` operator: `str | None` not `Optional[str]`

## 4. Testing as Quality Indicator

For every complex function, ask:

- "How would I test this?"
- "If it's hard to test, what should be extracted?"
- Hard-to-test code = Poor structure that needs refactoring

## 5. Critical Deletions & Regressions

For each deletion, verify:

- Was this intentional for THIS specific feature?
- Does removing this break an existing workflow?
- Are there tests that will fail?
- Is this logic moved elsewhere or completely removed?

## 6. Naming & Clarity - The 5-Second Rule

If you can't understand what a function/class does in 5 seconds from its name:

- FAIL: `do_stuff`, `process`, `handler`
- PASS: `validate_user_email`, `fetch_user_profile`, `transform_api_response`

## 7. Module Extraction Signals

Consider extracting to a separate module when you see multiple of these:

- Complex business rules (not just "it's long")
- Multiple concerns being handled together
- External API interactions or complex I/O
- Logic you'd want to reuse across the application

## 8. Pythonic Patterns

- Use context managers (`with` statements) for resource management
- Prefer list/dict comprehensions over explicit loops (when readable)
- Use dataclasses or Pydantic models for structured data
- FAIL: Getter/setter methods (this isn't Java)
- PASS: Properties with `@property` decorator when needed

## 9. Import Organization

- Follow PEP 8: stdlib, third-party, local imports
- Use absolute imports over relative imports
- Avoid wildcard imports (`from module import *`)
- FAIL: Circular imports, mixed import styles
- PASS: Clean, organized imports with proper grouping

## 10. Modern Python Features

- Use f-strings for string formatting (not % or .format())
- Leverage pattern matching (Python 3.10+) when appropriate
- Use walrus operator `:=` for assignments in expressions when it improves readability
- Prefer `pathlib` over `os.path` for file operations

## 11. Core Philosophy

- **Explicit > Implicit**: "Readability counts" - follow the Zen of Python
- **Duplication > Complexity**: Simple, duplicated code is BETTER than complex DRY abstractions
- "Adding more modules is never a bad thing. Making modules very complex is a bad thing"
- **Duck typing with type hints**: Use protocols and ABCs when defining interfaces
- Follow PEP 8, but prioritize consistency within the project

## Review Workflow

1. Start with the most critical issues (regressions, deletions, breaking changes)
2. Check for missing type hints and non-Pythonic patterns
3. Evaluate testability and clarity
4. Suggest specific improvements with examples
5. Be strict on existing code modifications, pragmatic on new isolated code
6. Always explain WHY something doesn't meet the bar
