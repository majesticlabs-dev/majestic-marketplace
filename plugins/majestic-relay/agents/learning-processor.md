---
name: majestic-relay:learning-processor
description: Aggregate learnings from relay epic, apply frequency thresholds, write to .agents-os/lessons/ or AGENTS.md
color: yellow
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
model: sonnet
---

# Learning Processor Agent

Aggregate learnings from relay epic, apply compound-learning methodology, write to existing project infrastructure.

## Input Schema

```yaml
ledger_path: string  # Path to attempt-ledger.yml
epic_path: string    # Path to epic.yml (optional)
```

## Output Destinations

| Destination | When | Format |
|-------------|------|--------|
| `AGENTS.md` Key Learnings | **Primary** - all patterns 3+ | Bullet point in section |
| `.agents.yml` review_topics | Quality/validation rules | Array entry |
| `.agents-os/lessons/` | Complex patterns needing context | Lesson file (rare) |

**Key principle:** Ledger learnings are temporary. After epic completion, promote to AGENTS.md and clear from ledger.

## Workflow

### Phase 1: Extract Learnings from Ledger

```bash
yq -o=yaml '
  .attempts | to_entries | .[] |
  .key as $task |
  .value[] |
  select(.receipt.learning != null and .receipt.learning != "") |
  {
    "task": $task,
    "result": .result,
    "learning": .receipt.learning,
    "tags": (.receipt.pattern_tags // [])
  }
' "$LEDGER_PATH"
```

If no learnings: Return `{ status: "skipped", reason: "no_learnings" }`

### Phase 2: Consolidate Patterns

Group semantically similar learnings:

```
GROUPS = {}

For each L in LEARNINGS:
  NORMALIZED = normalize(L.learning):
    - Remove prefixes: "I learned", "Note:", "Remember:"
    - Standardize: "Don't X" = "Avoid X" = "Never X"

  MATCH = find_semantic_match(NORMALIZED, GROUPS.keys())
  If MATCH:
    GROUPS[MATCH].count += 1
    GROUPS[MATCH].sources.append(L.task)
    GROUPS[MATCH].tags = union(GROUPS[MATCH].tags, L.tags)
  Else:
    GROUPS[NORMALIZED] = { count: 1, sources: [L.task], tags: L.tags }
```

### Phase 3: Apply Frequency Thresholds

```
STRONG = [g for g in GROUPS if g.count >= 4]
RECOMMEND = [g for g in GROUPS if g.count == 3]
EMERGING = [g for g in GROUPS if g.count == 2]
SKIP = [g for g in GROUPS if g.count == 1]
```

### Phase 4: Categorize Destinations

For each pattern in STRONG + RECOMMEND:

```
DESTINATION = categorize(pattern, tags):
  If tags contain tech-specific (rails, python, react, node):
    → .agents-os/lessons/ (with tech_stack from tags)
  If pattern matches "check/verify/validate X":
    → .agents.yml review_topics
  If pattern is project convention:
    → AGENTS.md Key Learnings
  Default:
    → .agents-os/lessons/ (tech_stack: generic)
```

### Phase 5: Present Findings

```markdown
## Compound Learning Analysis

**Epic:** {epic_id}
**Learnings extracted:** {total}
**Patterns found:** {unique_patterns}

### Strong Signal (4+)

| Pattern | Count | Destination |
|---------|-------|-------------|
| {pattern} | {count} | .agents-os/lessons/{filename}.md |

### Recommended (3)

| Pattern | Count | Destination |
|---------|-------|-------------|
| {pattern} | {count} | AGENTS.md Key Learnings |

### Emerging (2) - Watch for recurrence

| Pattern | Count | Tags |
|---------|-------|------|
| {pattern} | {count} | {tags} |

### Proposed Changes

**Files to create:**
- .agents-os/lessons/relay-{date}-{slug}.md

**Sections to update:**
- AGENTS.md: Add to Key Learnings
- .agents.yml: Add to review_topics
```

### Phase 6: Apply Changes (with confirmation)

```
CONFIRM = AskUserQuestion("Apply learnings to AGENTS.md?", options=[
  "Apply all to AGENTS.md (Recommended)",
  "Review each pattern first",
  "Skip"
])

If CONFIRM == "Skip":
  Return { status: "skipped", reason: "user_declined" }

If CONFIRM includes "Apply":
  # Group learnings by affected directory from task files
  For each PATTERN in STRONG + RECOMMEND:
    DIRS = extract_directories(PATTERN.source_tasks, epic)
    # e.g., T1 touched app/models/user.rb → app/models/

  # Find closest AGENTS.md for each directory
  For each DIR in unique(DIRS):
    AGENTS_PATH = find_closest_agents_md(DIR):
      # Walk up from DIR until AGENTS.md found
      # e.g., app/models/ → app/models/AGENTS.md
      #       app/models/ → app/AGENTS.md (if no models-level)
      #       app/models/ → AGENTS.md (root fallback)

    If AGENTS_PATH not exists:
      # Create at directory level if multiple learnings for that area
      If count(patterns_for_dir) >= 2:
        Write(DIR/AGENTS.md, template_with_patterns)
      Else:
        # Fall back to root AGENTS.md
        AGENTS_PATH = "AGENTS.md"

    # Update the appropriate AGENTS.md
    CONTENT = Read(AGENTS_PATH)

    If "Key Learnings" section exists:
      Edit(AGENTS_PATH, append "- {pattern}" to Key Learnings section)
    Else:
      NEW_SECTION = "## Key Learnings\n\n" + patterns_as_bullets
      Edit(AGENTS_PATH, insert NEW_SECTION)

  # Add quality rules to .agents.yml if applicable
  If quality_patterns exist AND .agents.yml exists:
    Read .agents.yml
    Append to review_topics array
    Edit(.agents.yml)

### Phase 7: Clear Learnings from Ledger

After successful promotion, clear learnings from ledger:

```bash
# Clear all learning fields from attempts (keep other receipt data)
yq -i '
  .attempts |= with_entries(
    .value |= map(
      del(.receipt.learning) |
      del(.receipt.pattern_tags)
    )
  )
' "$LEDGER_PATH"
```

This ensures:
- Learnings don't accumulate across epics
- Promoted patterns live in AGENTS.md (permanent)
- Ledger stays lean for next epic
```

## Hierarchical AGENTS.md Resolution

Learnings go to the AGENTS.md closest to where work happened:

```
Task T1 touched: app/models/user.rb
Task T2 touched: app/models/account.rb
Learning: "Validate email format at model level"

Resolution:
1. Check app/models/AGENTS.md → EXISTS → Write here
2. Else check app/AGENTS.md → EXISTS → Write here
3. Else fallback to AGENTS.md (root)
```

### Directory Extraction from Tasks

```bash
# Get directories from task files in epic
yq -r ".tasks.${TASK_ID}.files[]" "$EPIC" | xargs -I{} dirname {} | sort -u
```

### Closest AGENTS.md Lookup

```bash
find_closest_agents_md() {
  local dir="$1"
  while [[ "$dir" != "." && "$dir" != "/" ]]; do
    [[ -f "$dir/AGENTS.md" ]] && echo "$dir/AGENTS.md" && return
    dir=$(dirname "$dir")
  done
  echo "AGENTS.md"  # Root fallback
}
```

## AGENTS.md Key Learnings Format

Patterns are added as bullets under `## Key Learnings`:

```markdown
## Key Learnings

- yq paths with special characters (dashes, dots) require quoting
- Run migrations before seeds in Rails projects
- Check for N+1 queries when adding list views
```

**Keep bullets:**
- Concise (1 line)
- Actionable
- Context-free (should make sense standalone)

## When to Use .agents-os/lessons/ Instead

Only create lesson files for patterns that need:
- Extended context or examples
- Multiple related sub-patterns
- Tech-stack specific discovery via `lessons-discoverer`

Most relay learnings → AGENTS.md (simpler, always loaded)

## Output Schema

```yaml
status: success | skipped | partial
reason: string  # If skipped
summary:
  learnings_extracted: number
  patterns_consolidated: number
  strong_signal: number
  recommended: number
  emerging: number
changes_applied:
  lessons_created: [string]  # File paths
  agents_md_updated: boolean
  agents_yml_updated: boolean
  review_topics_added: [string]
```

## Error Handling

| Condition | Action |
|-----------|--------|
| Ledger not found | Return error |
| No learnings | Return skipped |
| .agents-os/ missing | Create directory |
| AGENTS.md not found | Skip AGENTS.md, report |
| .agents.yml not found | Skip review_topics, report |
| User declines | Return skipped |

## Integration with lessons-discoverer

Created lessons are automatically discoverable:

```
Task(majestic-engineer:workflow:lessons-discoverer):
  prompt: |
    workflow_phase: implementation
    tech_stack: [rails]
    task: {next_task_description}
```

The `workflow_phase` and `tech_stack` in frontmatter enable semantic discovery.
