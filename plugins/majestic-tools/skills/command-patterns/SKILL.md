---
name: command-patterns
description: Advanced patterns for generating high-quality Claude Code commands. Used by /new-command.
---

# Command Patterns Skill

Expert patterns for generating production-quality Claude Code commands.

## Core Requirements

1. **Multiple Action Modes** - Never single-purpose commands
   - `analyze` - Deep analysis
   - `optimize` - Performance improvements
   - `fix` - Automated remediation
   - `monitor` - Continuous watching

2. **Real, Working Code** - Every example must be executable
3. **Intelligent Recommendations** - Prioritized, actionable insights
4. **Interactive Intelligence** - Guide users to optimal solutions
5. **Visual Outputs** - Include diagrams/charts when helpful

## Advanced Patterns

### Progressive Disclosure
```bash
# Simple for beginners
claude /your-command

# Power user with full control
claude /your-command analyze --depth=comprehensive --output=json
```

### Safe Automation with Rollbacks
```bash
apply_change() {
  # Snapshot current state
  kubectl get deployment $1 -o yaml > "/tmp/rollback-$$.yaml"

  # Apply change
  kubectl patch deployment $1 --patch "$2"

  # Monitor and rollback if needed
  if ! monitor_health $1 60; then
    kubectl apply -f "/tmp/rollback-$$.yaml"
  fi
}
```

## Quality Checklist

### Intelligence
- [ ] Recognizes patterns from past executions
- [ ] Provides insights humans would miss
- [ ] Explains reasoning behind recommendations

### User Experience
- [ ] Works with zero configuration
- [ ] Provides meaningful progress indicators
- [ ] Offers escape hatches at every step

### Safety
- [ ] Every change has a rollback
- [ ] Dry-run mode available
- [ ] Confirms destructive operations

### Integration
- [ ] Outputs in multiple formats
- [ ] Works in CI/CD pipelines
- [ ] Provides hooks for customization

## Frontmatter Template

```yaml
---
description: Brief description  # REQUIRED
model: haiku                    # OPTIONAL - use full ID
allowed-tools: Bash, Read       # OPTIONAL
argument-hint: "[action]"       # OPTIONAL
---
```

## The Ultimate Test

> "Would a senior engineer with 10 years experience be impressed?"

If not emphatic YES, keep improving.
