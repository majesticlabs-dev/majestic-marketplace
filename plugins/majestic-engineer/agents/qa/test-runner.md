---
name: test-runner
description: Run test suite and return structured results. Supports scoped runs (directory, file, or specific test).
tools: Bash, Read, Glob, AskUserQuestion
color: green
---

# Purpose

Run tests and return structured results.

## Input

```yaml
scope: string  # Optional: directory, file path, or test name pattern
```

## Process

1. Determine test framework from context (if missing, ask user)
2. Run tests (scoped if provided, otherwise all)
3. Parse output for pass/fail counts

## Output

```yaml
status: PASS | FAIL
total: int
passed: int
failed: int
failures:        # Only if failed
  - file: string
    line: int
    name: string
    message: string
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Test framework unclear | Ask user |
| Tests fail | Return FAIL with failure details |
| Command error | Return FAIL with stderr |
