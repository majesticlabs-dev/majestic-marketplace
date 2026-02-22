# Language-Specific Test Runner Configs

## Python / pytest

| Setting | Value |
|---------|-------|
| Test command | `pytest {test_file} -v` |
| Full suite | `pytest -v --tb=short` |
| Test directory | `tests/` |
| File pattern | `test_*.py` or `*_test.py` |
| Naming | `test_` prefix for functions and classes |
| Assertion | Native `assert` statements |

```bash
# Single test
pytest tests/test_calculator.py::test_add -v
# Full suite
pytest -v --tb=short
```

## TypeScript / vitest

| Setting | Value |
|---------|-------|
| Test command | `npx vitest run {test_file}` |
| Full suite | `npx vitest run` |
| Test directory | `src/__tests__/` or colocated `*.test.ts` |
| File pattern | `*.test.ts` or `*.spec.ts` |
| Naming | `describe` + `it`/`test` blocks |
| Assertion | `expect()` API |

```bash
# Single test
npx vitest run src/__tests__/calculator.test.ts
# Full suite
npx vitest run
```

## Go / testing

| Setting | Value |
|---------|-------|
| Test command | `go test -v -run {TestName} ./{package}` |
| Full suite | `go test -v ./...` |
| Test directory | Same package as source |
| File pattern | `*_test.go` |
| Naming | `TestXxx` functions |
| Assertion | `testing.T` methods or testify |

```bash
# Single test
go test -v -run TestAdd ./calculator
# Full suite
go test -v ./...
```

## Ruby

Delegate to existing skills:
- **RSpec:** Apply `rspec-coder` skill — runner: `bundle exec rspec {spec_file}`
- **Minitest:** Apply `minitest-coder` skill — runner: `bundle exec rails test {test_file}`
