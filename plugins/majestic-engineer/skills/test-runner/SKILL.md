---
name: test-runner
description: Run test suite and return structured pass/fail results. Supports scoped runs by directory, file, or test name pattern. Triggers on run tests, execute tests, test results, check tests, verify tests pass.
---

# Test Runner

Run tests and return structured results.

## Input

```yaml
scope: string  # Optional: directory, file path, or test name pattern
```

## Process

1. **Detect framework** from project files (if not provided):
   - `spec/` + `_spec.rb` + `.rspec` = RSpec
   - `test/` + `_test.rb` = Minitest
   - `jest.config.js` or `*.test.js` = Jest/Vitest
   - `go.mod` + `_test.go` = Go test
   - `pytest.ini` or `conftest.py` = pytest

2. **Run tests** (scoped if provided, otherwise full suite)

3. **Parse output** for pass/fail counts and failure details

## Framework Commands

| Framework | Run All | Run File | Run Single |
|-----------|---------|----------|------------|
| RSpec | `bundle exec rspec` | `bundle exec rspec path/to/spec.rb` | `bundle exec rspec path:LINE` |
| Minitest | `bundle exec rake test` | `ruby -Itest path/to/test.rb` | `ruby -Itest path -n test_name` |
| Jest | `npx jest` | `npx jest path/to/test.js` | `npx jest path -t "name"` |
| pytest | `pytest` | `pytest path/to/test.py` | `pytest path::test_name` |
| Go | `go test ./...` | `go test ./path/` | `go test ./path/ -run TestName` |

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
