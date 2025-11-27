# Advanced AST-Grep Rules and Configuration

## Table of Contents

- [Rule File Structure](#rule-file-structure)
- [Complex Pattern Matching](#complex-pattern-matching)
- [Rule Constraints](#rule-constraints)
- [Testing Rules](#testing-rules)
- [CI/CD Integration](#cicd-integration)


## Rule File Structure

### Basic Rule

Create `.ast-grep/rules/rule-name.yml`:

```yaml
id: rule-unique-id
message: Human-readable message
severity: error  # or warning, info, hint
language: javascript
rule:
  pattern: console.log($$$ARGS)
```

### Complete Rule

```yaml
id: no-direct-dom-manipulation
message: Direct DOM manipulation detected. Use React state instead.
note: Helps maintain React's virtual DOM integrity
severity: warning
language: typescript
rule:
  pattern: document.getElementById($ID)
fix: |
  const $ID_REF = useRef(null)
  // Access with: $ID_REF.current
url: https://react.dev/learn/manipulating-the-dom-with-refs
```

### Rule Fields

```yaml
id: unique-identifier          # Required
message: Description           # Required
note: Additional context       # Optional
severity: error|warning|info   # Required
language: <lang>               # Required
rule: <rule-spec>              # Required
fix: Suggested fix             # Optional
url: Documentation link        # Optional
```


## Complex Pattern Matching

### Multiple Conditions (AND)

```yaml
id: require-error-handling
message: Async function without try-catch
severity: warning
language: typescript
rule:
  all:
    - pattern: |
        async function $NAME($$$ARGS) {
          $$$BODY
        }
    - not:
        pattern: |
          try {
            $$$TRY
          } catch ($ERR) {
            $$$CATCH
          }
```

### Alternative Patterns (OR)

```yaml
id: deprecated-lifecycle-methods
message: Deprecated React lifecycle method
severity: error
language: typescript
rule:
  any:
    - pattern: componentWillMount($$$ARGS)
    - pattern: componentWillReceiveProps($$$ARGS)
    - pattern: componentWillUpdate($$$ARGS)
```

### Nested Patterns

```yaml
id: nested-conditionals
message: Deeply nested conditional logic
severity: warning
language: ruby
rule:
  pattern: |
    if $COND1
      if $COND2
        if $COND3
          $$$BODY
        end
      end
    end
```


## Rule Constraints

### Regex Constraints

```yaml
id: hardcoded-api-key
message: Potential hardcoded API key
severity: error
language: javascript
rule:
  pattern: const $KEY = "$VALUE"
  constraints:
    KEY:
      regex: "(?i)(api[_-]?key|secret|token|password)"
    VALUE:
      regex: "^[A-Za-z0-9]{20,}$"
```

### Kind Constraints

```yaml
id: require-const-for-literals
message: Use const for literal values
severity: info
language: typescript
rule:
  pattern: let $VAR = $VALUE
  constraints:
    VALUE:
      kind: string_literal  # or number_literal, boolean, etc.
```

### Context-Aware Rules

```yaml
id: no-setState-in-componentDidMount
message: Avoid setState in componentDidMount
severity: warning
language: typescript
rule:
  pattern: this.setState($$$ARGS)
  inside:
    pattern: |
      componentDidMount() {
        $$$BODY
      }
```


## Testing Rules

### Test File Structure

Create `.ast-grep/rules/rule-name.test.yml`:

```yaml
id: no-console-log
valid:
  - logger.info('message')
  - console.error('error')
invalid:
  - console.log('debug')
  - console.log($message)
```

### Comprehensive Test

```yaml
id: prefer-arrow-functions
valid:
  - const add = (a, b) => a + b
  - const greet = () => console.log('hi')
  - |
    class MyClass {
      method() {
        return 42
      }
    }
invalid:
  - function add(a, b) { return a + b }
  - const handler = function() { return 'value' }
  - |
    document.addEventListener('click', function() {
      console.log('clicked')
    })
```

### Running Tests

```bash
# Test all rules
ast-grep test

# Test specific rule
ast-grep test .ast-grep/rules/my-rule.yml

# Verbose output
ast-grep test --verbose

# Update snapshots
ast-grep test --update-all
```


## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/ast-grep.yml
name: AST-Grep Checks

on: [push, pull_request]

jobs:
  ast-grep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install ast-grep
        run: |
          curl -LsSf https://github.com/ast-grep/ast-grep/releases/latest/download/ast-grep-x86_64-unknown-linux-gnu.tar.gz | tar xz
          sudo mv ast-grep /usr/local/bin/

      - name: Run ast-grep scan
        run: ast-grep scan --exit-code=1

      - name: Run ast-grep tests
        run: ast-grep test
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running ast-grep checks..."

if ! ast-grep scan --exit-code=1; then
  echo "❌ ast-grep found issues. Fix them before committing."
  exit 1
fi

echo "✅ ast-grep checks passed"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

### GitLab CI

```yaml
# .gitlab-ci.yml
ast-grep-check:
  stage: test
  image: node:18
  before_script:
    - npm install -g @ast-grep/cli
  script:
    - ast-grep scan --exit-code=1
    - ast-grep test
```


## Advanced Use Cases

### Codemod with Rules

```yaml
id: migrate-to-new-api
message: Update to new API
severity: info
language: ruby
rule:
  pattern: OldAPI.call($METHOD, $$$ARGS)
fix: NewAPI.execute(method: $METHOD, args: [$$$ARGS])
```

Run as codemod:
```bash
ast-grep scan --rule .ast-grep/rules/migrate-to-new-api.yml --update-all
```

### Security Scanning

```yaml
id: sql-injection-risk
message: Potential SQL injection vulnerability
note: Use parameterized queries instead
severity: error
language: ruby
rule:
  any:
    - pattern: execute("SELECT * FROM users WHERE id = #{$ID}")
    - pattern: ActiveRecord::Base.connection.execute($SQL + $VAR)
    - pattern: User.where("name = '#{$NAME}'")
```

### Performance Linting

```yaml
id: inefficient-loop
message: Inefficient array operation in loop
severity: warning
language: javascript
rule:
  pattern: |
    for ($INIT; $COND; $UPDATE) {
      $$$BEFORE
      $ARRAY.push($ITEM)
      $$$AFTER
    }
fix: |
  // Consider using map, filter, or reduce
  $ARRAY = $SOURCE.map($ITEM => ...)
```


## Rule Organization

### Directory Structure

```
.ast-grep/
├── rules/
│   ├── security/
│   │   ├── sql-injection.yml
│   │   └── xss-prevention.yml
│   ├── performance/
│   │   └── inefficient-loops.yml
│   ├── style/
│   │   └── naming-conventions.yml
│   └── best-practices/
│       └── error-handling.yml
└── sgconfig.yml
```

### Configuration File

```yaml
# .ast-grep/sgconfig.yml
ruleDirs:
  - ./rules
testConfigs:
  - testDir: ./rules
languageGlobs:
  ruby:
    - "**/*.rb"
    - "**/Gemfile"
  typescript:
    - "**/*.ts"
    - "**/*.tsx"
```


## Best Practices

### 1. Clear Messages

```yaml
# ❌ Vague
message: Bad pattern

# ✅ Clear and actionable
message: |
  Direct DOM access detected. Use React refs instead.
  Replace document.getElementById() with useRef() hook.
```

### 2. Provide Context

```yaml
# Include note and URL
note: Direct DOM manipulation bypasses React's virtual DOM
url: https://react.dev/learn/manipulating-the-dom-with-refs
```

### 3. Test Thoroughly

```yaml
# Include both valid and invalid cases
valid:
  - const ref = useRef(null)
  - useEffect(() => { ref.current.focus() })
invalid:
  - document.getElementById('input').focus()
  - document.querySelector('.item').click()
```

### 4. Use Appropriate Severity

- **error**: Must be fixed (breaking changes, security)
- **warning**: Should be fixed (deprecated, code smells)
- **info**: Consider fixing (suggestions, optimizations)
- **hint**: Educational (best practices, tips)


## Quick Reference

### Common Rule Patterns

```yaml
# Simple pattern
rule:
  pattern: $PATTERN

# Multiple conditions (AND)
rule:
  all:
    - pattern: $PATTERN1
    - pattern: $PATTERN2

# Alternative patterns (OR)
rule:
  any:
    - pattern: $PATTERN1
    - pattern: $PATTERN2

# Negative match
rule:
  all:
    - pattern: $PATTERN
    - not:
        pattern: $EXCEPTION

# Context-aware
rule:
  pattern: $PATTERN
  inside:
    pattern: $CONTEXT
```


**Reference Status**: Complete - Advanced rules and configuration ✅
**Use with**: Main SKILL.md for comprehensive ast-grep mastery
