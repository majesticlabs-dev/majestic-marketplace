---
name: compound-learnings
description: Extract patterns from git history and session files, recommend artifacts (skill/rule/hook/agent) based on frequency thresholds
allowed-tools: [Bash, Read, Glob, Grep]
---

# Compound Learnings

Transform recurring patterns into durable artifacts. Use frequency-based thresholds to distinguish noise from signal.

## Data Sources

Scan these locations for patterns:

| Source | Command/Path | What to Extract |
|--------|--------------|-----------------|
| Git commits | `git log --oneline -100` | Repeated fix types, refactor patterns |
| Git commit bodies | `git log -50 --format="%B---"` | Lessons in commit descriptions |
| PR descriptions | `gh pr list --state merged -L 20` | Decisions, learnings |
| Handoffs | `$MAIN_WORKTREE/.agents/handoffs/*.md` | Patterns, What Worked/Failed |
| Key Learnings | `CLAUDE.md` (Key Learnings section) | Existing encoded patterns |

**Note:** Session ledger (`.agents/session_ledger.md`) is for `/reflect` only - ephemeral per-session state.

## Pattern Extraction

### Step 1: Gather Raw Patterns

```bash
# Git patterns (look for repeated prefixes/types)
git log --oneline -100 | cut -d' ' -f2- | sort | uniq -c | sort -rn

# Handoff patterns
grep -h "^- " .agents/handoffs/*.md 2>/dev/null | sort | uniq -c | sort -rn
```

### Step 2: Consolidate Similar Patterns

Before counting, normalize patterns:
- "Always validate X" + "Validate X before Y" → "Validate X"
- "Don't use Z" + "Avoid Z" + "Z causes issues" → "Avoid Z"

Group by semantic meaning, not exact wording.

### Step 3: Apply Frequency Thresholds

| Occurrences | Action | Rationale |
|-------------|--------|-----------|
| 1 | Skip | Could be noise, one-off incident |
| 2 | Note | Emerging pattern, watch for recurrence |
| 3+ | Recommend | Clear pattern, suggest artifact |
| 4+ | Strong recommend | Encode immediately |

## Artifact Categorization

Use this decision tree to determine artifact type:

```
Is it a sequential workflow with distinct phases?
  YES → Consider COMMAND (user-invoked) or AGENT (autonomous)
    Does it need user interaction during execution?
      YES → COMMAND
      NO → AGENT
  NO ↓

Should it trigger automatically on file/context patterns?
  YES → SKILL (probabilistic, Claude MAY follow)
    Is enforcement critical (must happen every time)?
      YES → Consider HOOK instead (deterministic)
  NO ↓

Is it a simple rule or convention?
  YES → RULE (add to CLAUDE.md or .agents/lessons/)
    Project-specific? → .agents/lessons/ (with workflow_phase: review)
    Universal? → CLAUDE.md
  NO ↓

Does it enhance an existing agent's behavior?
  YES → AGENT UPDATE (modify existing agent)
  NO → Likely doesn't need encoding
```

### Quick Reference

| Artifact | When to Use | Example |
|----------|-------------|---------|
| **Rule** | Simple convention, always applies | "Use kebab-case for file names" |
| **Skill** | Knowledge/context for specific work | "Stimulus controller patterns" |
| **Hook** | Must enforce behavior deterministically | "Run linter before commit" |
| **Command** | User-invoked workflow with arguments | "/deploy --env staging" |
| **Agent** | Autonomous task, returns report | "security-review agent" |

## Output Format

Present findings as:

```markdown
## Compound Learnings Analysis

### Strong Signal (4+ occurrences)
| Pattern | Count | Recommended Artifact | Rationale |
|---------|-------|---------------------|-----------|
| ... | ... | ... | ... |

### Emerging Patterns (2-3 occurrences)
| Pattern | Count | Potential Artifact | Notes |
|---------|-------|-------------------|-------|
| ... | ... | ... | ... |

### Recommended Actions
1. **[Artifact Type]**: `name` - description
   - Draft: [brief template or content]
```

## Quality Checks

Before recommending an artifact, verify:

- [ ] **Generality**: Applies beyond the specific incidents where it was observed
- [ ] **Specificity**: Concrete enough to act on (not vague advice)
- [ ] **Uniqueness**: Doesn't duplicate existing CLAUDE.md rules or skills
- [ ] **Correct Type**: Matches the categorization decision tree

## Integration with /learn

When invoked from `/learn`:

1. Locate main worktree for centralized handoffs
2. Gather patterns from git, PRs, and handoffs
3. Consolidate and count frequencies
4. Apply thresholds
5. Categorize recommended artifacts
6. Present findings with draft content
7. If approved, create artifacts using appropriate tools

**Note:** `/reflect` is for single-session analysis. `/learn` is for cross-session compound learning.
