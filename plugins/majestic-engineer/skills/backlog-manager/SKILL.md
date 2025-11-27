---
name: backlog-manager
description: This skill manages file-based backlog tracking in the docs/todos/ directory. Use for creating backlog items, managing status and dependencies, conducting triage, and integrating with code review processes.
---

# Backlog Manager Skill

## Overview

The `docs/todos/` directory contains a file-based tracking system for managing code review feedback, technical debt, feature requests, and work items. Each backlog item is a markdown file with YAML frontmatter and structured sections.

This skill should be used when:
- Creating new backlog items from findings or feedback
- Managing item lifecycle (pending → ready → complete)
- Triaging pending items for approval
- Checking or managing dependencies
- Converting PR comments or code findings into tracked work
- Updating work logs during item execution

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

Each backlog item is a markdown file with YAML frontmatter and structured sections. Use the template at `assets/backlog-template.md` as a starting point when creating new items.

**Required sections:**
- **Problem Statement** - What is broken, missing, or needs improvement?
- **Findings** - Investigation results, root cause, key discoveries
- **Proposed Solutions** - Multiple options with pros/cons, effort, risk
- **Recommended Action** - Clear plan (filled during triage)
- **Acceptance Criteria** - Testable checklist items
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

## Common Workflows

### Creating a New Backlog Item

**To create a new item from findings or feedback:**

1. Determine next issue ID: `ls docs/todos/ | grep -o '^[0-9]\+' | sort -n | tail -1`
2. Copy template: `cp assets/backlog-template.md docs/todos/{NEXT_ID}-pending-{priority}-{description}.md`
3. Edit and fill required sections:
   - Problem Statement
   - Findings (if from investigation)
   - Proposed Solutions (multiple options)
   - Acceptance Criteria
   - Add initial Work Log entry
4. Determine status: `pending` (needs triage) or `ready` (pre-approved)
5. Add relevant tags for filtering

**When to create a backlog item:**
- Requires more than 15-20 minutes of work
- Needs research, planning, or multiple approaches considered
- Has dependencies on other work
- Requires manager approval or prioritization
- Part of larger feature or refactor
- Technical debt needing documentation

**When to act immediately instead:**
- Issue is trivial (< 15 minutes)
- Complete context available now
- No planning needed
- User explicitly requests immediate action
- Simple bug fix with obvious solution

### Triaging Pending Items

**To triage pending backlog items:**

1. List pending items: `ls docs/todos/*-pending-*.md`
2. For each item:
   - Read Problem Statement and Findings
   - Review Proposed Solutions
   - Make decision: approve, defer, or modify priority
3. Update approved items:
   - Rename file: `mv {file}-pending-{pri}-{desc}.md {file}-ready-{pri}-{desc}.md`
   - Update frontmatter: `status: pending` → `status: ready`
   - Fill "Recommended Action" section with clear plan
   - Adjust priority if different from initial assessment
4. Deferred items stay in `pending` status

### Managing Dependencies

**To track dependencies:**

```yaml
dependencies: ["002", "005"]  # This item blocked by issues 002 and 005
dependencies: []               # No blockers - can work immediately
```

**To check what blocks an item:**
```bash
grep "^dependencies:" docs/todos/003-*.md
```

**To find what an item blocks:**
```bash
grep -l 'dependencies:.*"002"' docs/todos/*.md
```

**To verify blockers are complete before starting:**
```bash
for dep in 001 002 003; do
  [ -f "docs/todos/${dep}-complete-*.md" ] || echo "Issue $dep not complete"
done
```

### Updating Work Logs

**When working on an item, always add a work log entry:**

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

Work logs serve as:
- Historical record of investigation
- Documentation of approaches attempted
- Knowledge sharing for team
- Context for future similar work

### Completing a Backlog Item

**To mark an item as complete:**

1. Verify all acceptance criteria checked off
2. Update Work Log with final session and results
3. Rename file: `mv {file}-ready-{pri}-{desc}.md {file}-complete-{pri}-{desc}.md`
4. Update frontmatter: `status: ready` → `status: complete`
5. Check for unblocked work: `grep -l 'dependencies:.*"002"' docs/todos/*-ready-*.md`
6. Commit with issue reference: `feat: resolve issue 002`

## Integration with Development Workflows

| Trigger | Flow | Tool |
|---------|------|------|
| Code review | Review → Findings → Triage → Backlog items | Review agent + skill |
| PR comments | Resolve PR → Individual fixes → Backlog items | gh CLI + skill |
| Code TODOs | Resolve TODOs → Fixes + Complex items | Agent + skill |
| Planning | Brainstorm → Create item → Work → Complete | Skill |
| Feedback | Discussion → Create item → Triage → Work | Skill |

## Quick Reference Commands

**Finding work:**
```bash
# List highest priority unblocked work
grep -l 'dependencies: \[\]' docs/todos/*-ready-p1-*.md

# List all pending items needing triage
ls docs/todos/*-pending-*.md

# Find next issue ID
ls docs/todos/ | grep -o '^[0-9]\+' | sort -n | tail -1 | awk '{printf "%03d", $1+1}'

# Count by status
for status in pending ready complete; do
  echo "$status: $(ls -1 docs/todos/*-$status-*.md 2>/dev/null | wc -l)"
done
```

**Dependency management:**
```bash
# What blocks this item?
grep "^dependencies:" docs/todos/003-*.md

# What does this item block?
grep -l 'dependencies:.*"002"' docs/todos/*.md
```

**Searching:**
```bash
# Search by tag
grep -l "tags:.*rails" docs/todos/*.md

# Search by priority
ls docs/todos/*-p1-*.md

# Full-text search
grep -r "payment" docs/todos/
```

## Key Distinctions

**Backlog manager (this skill):**
- Markdown files in `docs/todos/` directory
- Development/project tracking
- Standalone markdown files with YAML frontmatter
- Used by humans and agents

**TodoWrite tool:**
- In-memory task tracking during agent sessions
- Temporary tracking for single conversation
- Not persisted to disk
- Different purpose from this file-based system
