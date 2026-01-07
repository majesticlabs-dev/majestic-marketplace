# File Backend Reference

This reference covers the file-based backlog system using markdown files in `docs/todos/`.

## File Naming Convention

Backlog files follow this naming pattern:

```
{issue_id}-{status}-{priority}-{description}.md
```

**Components:**
- **issue_id**: Sequential number (001, 002, 003...) - never reused
- **status**: `pending` (needs triage), `ready` (approved), `complete` (done)
- **priority**: `p1` (critical), `p2` (important), `p3` (nice-to-have)
- **description**: kebab-case, brief description

**Examples:**
```
001-pending-p1-mailer-test.md
002-ready-p1-fix-n-plus-1.md
005-complete-p2-refactor-csv.md
```

## File Structure

Each backlog item is a markdown file with YAML frontmatter. Use the template at `assets/backlog-template.md`.

**Required sections:**
- **Problem Statement** - What is broken, missing, or needs improvement?
- **Findings** - Investigation results, root cause, key discoveries
- **Proposed Solutions** - Multiple options with pros/cons, effort, risk
- **Recommended Action** - Clear plan (filled during triage)
- **Definition of Done** - Feature behaviors with verification methods
- **Work Log** - Chronological record with date, actions, learnings

**Optional sections:**
- **Technical Details** - Affected files, related components, DB changes
- **Resources** - Links to errors, tests, PRs, documentation
- **Notes** - Additional context or decisions

**YAML frontmatter fields:**
```yaml
---
status: ready              # pending | ready | complete
priority: p1              # p1 | p2 | p3
issue_id: "002"
tags: [rails, performance, database]
dependencies: ["001"]     # Issue IDs this is blocked by
---
```

## Operations

### CREATE - New Backlog Item

1. Determine next issue ID:
   ```bash
   ls docs/todos/ | grep -o '^[0-9]\+' | sort -n | tail -1
   ```

2. Copy template:
   ```bash
   cp assets/backlog-template.md docs/todos/{NEXT_ID}-pending-{priority}-{description}.md
   ```

3. Edit and fill required sections:
   - Problem Statement
   - Findings (if from investigation)
   - Proposed Solutions (multiple options)
   - Definition of Done
   - Add initial Work Log entry

4. Determine status: `pending` (needs triage) or `ready` (pre-approved)
5. Add relevant tags for filtering

### LIST - Query Items

```bash
# List highest priority unblocked work
grep -l 'dependencies: \[\]' docs/todos/*-ready-p1-*.md

# List all pending items needing triage
ls docs/todos/*-pending-*.md

# Count by status
for status in pending ready complete; do
  echo "$status: $(ls -1 docs/todos/*-$status-*.md 2>/dev/null | wc -l)"
done

# Search by tag
grep -l "tags:.*rails" docs/todos/*.md

# Search by priority
ls docs/todos/*-p1-*.md

# Full-text search
grep -r "payment" docs/todos/
```

### UPDATE - Triage/Modify

**Triage pending items:**

1. List pending: `ls docs/todos/*-pending-*.md`
2. For each item:
   - Read Problem Statement and Findings
   - Review Proposed Solutions
   - Make decision: approve, defer, or modify priority
3. Update approved items:
   - Rename file: `mv {file}-pending-{pri}-{desc}.md {file}-ready-{pri}-{desc}.md`
   - Update frontmatter: `status: pending` → `status: ready`
   - Fill "Recommended Action" section
   - Adjust priority if different from initial assessment
4. Deferred items stay in `pending` status

### COMPLETE - Mark Done

1. Verify all acceptance criteria checked off
2. Update Work Log with final session and results
3. Rename file:
   ```bash
   mv {file}-ready-{pri}-{desc}.md {file}-complete-{pri}-{desc}.md
   ```
4. Update frontmatter: `status: ready` → `status: complete`
5. Check for unblocked work:
   ```bash
   grep -l 'dependencies:.*"002"' docs/todos/*-ready-*.md
   ```
6. Commit with issue reference: `feat: resolve issue 002`

## Dependency Management

**Track dependencies:**
```yaml
dependencies: ["002", "005"]  # This item blocked by issues 002 and 005
dependencies: []               # No blockers - can work immediately
```

**Check what blocks an item:**
```bash
grep "^dependencies:" docs/todos/003-*.md
```

**Find what an item blocks:**
```bash
grep -l 'dependencies:.*"002"' docs/todos/*.md
```

**Verify blockers are complete:**
```bash
for dep in 001 002 003; do
  [ -f "docs/todos/${dep}-complete-*.md" ] || echo "Issue $dep not complete"
done
```

## Work Log Format

When working on an item, always add a work log entry:

```markdown
### YYYY-MM-DD - Session Title

**By:** Claude Code / Developer Name

**Actions:**
- Specific changes made (include file:line references)
- Commands executed
- Tests run
- Results of investigation

**Learnings:**
- What worked / what didn't
- Patterns discovered
- Key insights for future work
```

## Quick Reference

**Find next issue ID:**
```bash
ls docs/todos/ | grep -o '^[0-9]\+' | sort -n | tail -1 | awk '{printf "%03d", $1+1}'
```

**Dependency queries:**
```bash
# What blocks this item?
grep "^dependencies:" docs/todos/003-*.md

# What does this item block?
grep -l 'dependencies:.*"002"' docs/todos/*.md
```
