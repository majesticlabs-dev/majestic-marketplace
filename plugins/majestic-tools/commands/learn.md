---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
description: Extract cross-session patterns from git history and handoffs, recommend artifacts (skill/rule/hook/agent) based on frequency.
model: haiku
---

# Learn

Extract patterns from git history, PRs, and handoffs to create durable artifacts (skills, rules, hooks).

**For single-session reflection, use `/reflect` instead.**

**Methodology:** Use `compound-learnings` skill for frequency thresholds and artifact categorization logic.

## Data Sources

| Source | Command | What to Extract |
|--------|---------|-----------------|
| Git commits | `git log --oneline -100` | Repeated fix types, patterns |
| PR descriptions | `gh pr list --state merged -L 20 --json title,body` | Lessons, decisions |
| Handoffs | `.agents-os/handoffs/*.md` (main worktree) | Patterns, What Worked/Failed |
| Existing learnings | `CLAUDE.md` Key Learnings section | Already encoded patterns |

## Process

### Step 1: Locate Main Worktree

```bash
MAIN_WORKTREE=$(git worktree list --porcelain | grep "^worktree" | head -1 | cut -d' ' -f2)
HANDOFF_DIR="$MAIN_WORKTREE/.agents-os/handoffs"
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

### Step 3: Analyze Patterns

Apply `compound-learnings` skill methodology:
1. Consolidate similar patterns by semantic meaning
2. Apply frequency thresholds (skip 1x, note 2x, recommend 3+, strong recommend 4+)
3. Categorize into artifact types using the decision tree

### Step 4: Present Findings

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

### Step 5: Create Artifacts

Use `AskUserQuestion` to confirm each recommendation:
- "Create these artifacts?"

If approved, create using appropriate tools:
- **Rules** → Edit CLAUDE.md or create lesson in .agents-os/lessons/
- **Skills** → Create in appropriate plugin's skills directory
- **Hooks** → Create in .claude/hooks/
- **Commands** → Create in appropriate plugin's commands directory
