---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
description: Extract cross-session patterns from git history and handoffs, recommend artifacts (skill/rule/hook/agent) based on frequency.
model: haiku
---

# Learn

Extract patterns from git history, PRs, and handoffs to create durable artifacts (skills, rules, hooks).

**For single-session reflection, use `/reflect` instead.**

**Reference**: Use methodology from `compound-learnings` skill.

## Data Sources

| Source | Command | What to Extract |
|--------|---------|-----------------|
| Git commits | `git log --oneline -100` | Repeated fix types, patterns |
| PR descriptions | `gh pr list --state merged -L 20 --json title,body` | Lessons, decisions |
| Handoffs | `.claude/handoffs/*.md` (main worktree) | Patterns, What Worked/Failed |
| Existing learnings | `CLAUDE.md` Key Learnings section | Already encoded patterns |

## Process

### Step 1: Locate Main Worktree

```bash
MAIN_WORKTREE=$(git worktree list --porcelain | grep "^worktree" | head -1 | cut -d' ' -f2)
HANDOFF_DIR="$MAIN_WORKTREE/.claude/handoffs"
```

### Step 2: Gather Patterns

**Git history:**
```bash
git log --oneline -100 | cut -d' ' -f2-
```

**Merged PRs (if gh available):**
```bash
gh pr list --state merged -L 20 --json title,body 2>/dev/null
```

**Handoff files:**
```bash
ls "$HANDOFF_DIR"/*.md 2>/dev/null && cat "$HANDOFF_DIR"/*.md
```

**Existing Key Learnings:**
```bash
grep -A 50 "Key Learnings" CLAUDE.md 2>/dev/null
```

### Step 3: Consolidate Similar Patterns

Before counting, normalize patterns:
- "Always validate X" + "Validate X before Y" → "Validate X"
- "Don't use Z" + "Avoid Z" → "Avoid Z"

Group by semantic meaning, not exact wording.

### Step 4: Apply Frequency Thresholds

| Count | Action |
|-------|--------|
| 1 | Skip (noise) |
| 2 | Note (emerging pattern) |
| 3+ | Recommend artifact |
| 4+ | Strong recommend |

### Step 5: Categorize Artifacts

Use this decision tree:

```
Is it a sequential workflow with distinct phases?
  YES → COMMAND (user-invoked) or AGENT (autonomous)
  NO ↓

Should it trigger on file/context patterns?
  YES → SKILL (probabilistic)
    Is enforcement critical?
      YES → HOOK (deterministic)
  NO ↓

Is it a simple rule or convention?
  YES → RULE
    Project-specific? → review-topics.md
    Universal? → CLAUDE.md
  NO ↓

Does it enhance existing agent behavior?
  YES → AGENT UPDATE
```

### Step 6: Present Findings

```markdown
## Compound Learnings Analysis

**Sources scanned:**
- Git commits: X
- PRs: Y
- Handoffs: Z

### Strong Signal (4+ occurrences)

| Pattern | Count | Artifact | Rationale |
|---------|-------|----------|-----------|
| ... | ... | ... | ... |

### Emerging Patterns (2-3 occurrences)

| Pattern | Count | Potential | Notes |
|---------|-------|-----------|-------|
| ... | ... | ... | ... |

### Recommended Actions

1. **[Artifact Type]**: `name`
   - Draft content: ...
```

### Step 7: Create Artifacts

Use `AskUserQuestion` to confirm each recommendation:
- "Create these artifacts?"

If approved:
- **Rules** → Edit CLAUDE.md or review-topics.md
- **Skills** → Create in appropriate plugin's skills directory
- **Hooks** → Create in .claude/hooks/
- **Commands** → Create in appropriate plugin's commands directory

## Quality Checks

Before recommending, verify:
- [ ] **Generality**: Applies beyond specific incidents
- [ ] **Specificity**: Concrete enough to act on
- [ ] **Uniqueness**: Doesn't duplicate existing rules/skills
- [ ] **Correct Type**: Matches categorization logic

## Example Output

```
## Compound Learnings Analysis

**Sources scanned:**
- Git commits: 87
- PRs: 12
- Handoffs: 5

### Strong Signal (4+ occurrences)

| Pattern | Count | Artifact | Rationale |
|---------|-------|----------|-----------|
| Always run tests before commit | 6 | Hook | Enforcement needed |
| Use kebab-case for filenames | 4 | Rule | Simple convention |

### Emerging Patterns (2-3 occurrences)

| Pattern | Count | Potential | Notes |
|---------|-------|-----------|-------|
| Prefer composition over inheritance | 2 | Skill | Watch for recurrence |

### Recommended Actions

1. **Hook**: `pre-commit-tests`
   - Run `bin/rails test` before allowing commit

2. **Rule** → CLAUDE.md:
   - "Use kebab-case for all file names"

Create these artifacts?
```
