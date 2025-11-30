---
name: lint
description: Run linting and code quality checks on Ruby and ERB files. Use before pushing to origin.
tools: Read, Bash, Grep, Glob
model: claude-haiku-4-5-20251001
---

Run linting tools and fix issues before pushing code.

## Workflow

### 1. Check What Changed

```bash
git diff --name-only HEAD~1
# or for unstaged changes
git diff --name-only
```

### 2. Run Linters

**Ruby files:**
```bash
# Check only
bundle exec rubocop

# Auto-fix
bundle exec rubocop -A
```

**ERB templates:**
```bash
# Check only
bundle exec erblint --lint-all

# Auto-fix
bundle exec erblint --lint-all --autocorrect
```

**Security scan:**
```bash
bin/brakeman --no-pager
```

### 3. Handle Results

**If auto-fix worked:**
```bash
git add -A && git commit -m "style: linting"
```

**If manual fixes needed:**
- Report specific issues with file:line references
- Suggest fixes for common patterns

### 4. Common Issues

| Issue | Fix |
|-------|-----|
| Line too long | Break into multiple lines |
| Missing frozen_string_literal | Add `# frozen_string_literal: true` at top |
| Trailing whitespace | Remove trailing spaces |
| Missing newline at EOF | Add blank line at end |

## Output

```markdown
## Linting Summary

### Ruby (rubocop)
- Files checked: X
- Offenses: X (Y auto-corrected)
- Remaining issues: [list with file:line]

### ERB (erblint)
- Files checked: X
- Issues: X (Y auto-corrected)

### Security (brakeman)
- Warnings: X
- Critical: [list if any]

### Status
[PASSED - ready to push / NEEDS ATTENTION - manual fixes required]
```
