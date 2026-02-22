# Harness Engineering — Patterns Catalog

Implementation patterns for the three pillars. Referenced from [../SKILL.md](../SKILL.md).

## Harness Topologies

### Topology Selection

| Topology | AGENTS.md Style | CI Gates | GC Frequency |
|----------|----------------|----------|-------------|
| Single-service | Single root file, detailed | Standard suite | Monthly |
| Monorepo | Hierarchical (root + sub-folder) | Per-package gates + repo-wide | Weekly |
| Distributed agents | Per-service + shared conventions repo | Service-level + contract tests | Weekly per service |

### Day-1 Starter Harness

**Single-service:**
```
1. Create AGENTS.md at root (failure ledger + tool list)
2. Add one structural test (import boundary)
3. Add one numeric CI gate (coverage threshold)
4. Create bin/check script for fastest invariant
```

**Monorepo:**
```
1. Create root AGENTS.md (lightweight, links to sub-folders)
2. Create AGENTS.md per major package (detailed, failure-specific)
3. Add structural test per package boundary
4. Add per-package CI gates (each package owns its thresholds)
5. Schedule weekly GC agent for cross-package dead code
```

**Distributed agents:**
```
1. Create shared conventions repo with canonical AGENTS.md template
2. Each service inherits template + adds service-specific failures
3. Add API contract tests between services
4. Add cross-service dependency direction enforcement
5. Schedule GC per service + cross-service stale contract detection
```

## AGENTS.md Pattern Library

### Failure Ledger Entry Schema

```yaml
# Each entry in AGENTS.md should follow this structure
entries:
  - rule: string        # imperative statement ("Never X", "Always Y")
    context: string     # what happened (date, incident, consequence)
    fix: string         # correct approach with specific tool/method
    enforcement: string # optional — CI gate or linter that catches this
```

### Tool Declaration Template

```markdown
## Available Commands
| Command | Purpose | Safe to Auto-Run |
|---------|---------|------------------|
| `bin/test` | Run full test suite | Yes |
| `bin/lint --fix` | Lint with auto-fix | Yes |
| `bin/db-migrate` | Run pending migrations | Yes (dev only) |
| `bin/deploy staging` | Deploy to staging | No — requires approval |

## Forbidden Operations
| Operation | Why | Alternative |
|-----------|-----|------------|
| `DROP TABLE` | Irreversible data loss | Use migration with `safety_assured` |
| Direct SQL in controllers | Bypasses model validations | Use model methods or service objects |
| `git push --force` on main | Destroys shared history | Use `--force-with-lease` on feature branches |
```

### Cross-Link Rule Format

```yaml
# CI enforcement config for docs-as-system-of-record
cross_links:
  - source_pattern: "src/**/*.ts"
    source_tag: "@api-doc"
    target_dir: "docs/api/"
    rule: "every tagged source file must have matching doc"

  - source_pattern: "docs/api/**/*.md"
    target_pattern: "src/**/*.ts"
    rule: "every doc must reference existing source file"

  - check_command: "bin/check-docs"
    ci_gate: true  # failure blocks merge
```

## Structural Test Patterns

### No Cross-Boundary Imports

```python
# ArchUnit-style (Python example)
def test_api_does_not_import_internal():
    for file in glob("src/api/**/*.py"):
        imports = extract_imports(file)
        for imp in imports:
            assert not imp.startswith("src.internal"), \
                f"{file} imports {imp} — use src.api.clients instead"
```

### Dependency Direction

```javascript
// eslint-plugin-import example
// .eslintrc.js
rules: {
  "import/no-restricted-paths": ["error", {
    zones: [
      { target: "./src/domain", from: "./src/infrastructure", message: "Domain cannot import infrastructure" },
      { target: "./src/domain", from: "./src/presentation", message: "Domain cannot import presentation" },
      { target: "./src/application", from: "./src/presentation", message: "Application cannot import presentation" }
    ]
  }]
}
```

### API Contract Stability

```ruby
# RSpec example for Rails
RSpec.describe "API contract" do
  it "has no breaking changes" do
    current = OpenAPIParser.parse("docs/api/openapi.yml")
    previous = `git show main:docs/api/openapi.yml`
    diff = OpenAPIDiff.compare(previous, current)
    expect(diff.breaking_changes).to be_empty,
      "Breaking changes found:\n#{diff.breaking_changes.map(&:description).join("\n")}"
  end
end
```

### Ecosystem Tools

| Language | Structural Test Tool | Import Enforcement |
|----------|--------------------|--------------------|
| Java/Kotlin | ArchUnit | Built-in |
| TypeScript | eslint-plugin-import | `no-restricted-paths` |
| Python | import-linter | Layer contracts |
| Ruby | packwerk (Shopify) | Package boundaries |
| Go | depguard | Package allow/deny lists |

## GC Agent Templates

### Scheduled CI Cron

```yaml
# .github/workflows/gc.yml
name: Harness GC
on:
  schedule:
    - cron: "0 6 * * 1"  # Monday 6am UTC
  workflow_dispatch: {}   # manual trigger

jobs:
  dead-code:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bin/find-dead-code --output gc-report.json
      - run: bin/gc-pr --type dead-code --input gc-report.json
        # Creates PR removing dead code, auto-merges if CI passes

  stale-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bin/check-docs --stale --output stale-report.json
      - run: bin/gc-pr --type stale-docs --input stale-report.json
```

### On-Demand Invocation

```bash
# bin/gc — run specific GC task locally
#!/usr/bin/env bash
TASK=${1:?Usage: bin/gc <dead-code|stale-docs|unused-deps|orphan-tests>}
bin/find-${TASK} --output /tmp/gc-${TASK}.json
echo "Found $(jq length /tmp/gc-${TASK}.json) items to clean"
echo "Review: /tmp/gc-${TASK}.json"
echo "Apply:  bin/gc-apply /tmp/gc-${TASK}.json"
```

### GC Agent Output Schema

```yaml
# Standard output format for all GC tasks
gc_result:
  task: string          # dead-code, stale-docs, unused-deps, orphan-tests
  timestamp: string     # ISO 8601
  items_found: integer
  items:
    - path: string      # file or symbol path
      type: string      # unused-export, stale-doc, unused-dep, orphan-test
      confidence: float # 0.0-1.0
      evidence: string  # why this is flagged
      auto_fix: boolean # safe to auto-remove?
  summary:
    auto_fixable: integer
    needs_review: integer
```
