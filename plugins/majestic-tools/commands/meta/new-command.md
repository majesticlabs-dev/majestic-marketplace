---
description: Generate any Claude Code command with production-quality patterns
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Skill
---

# New Command Builder `/new-command`

Generate Claude Code commands with production-quality patterns.

## Arguments

- `[command-idea]` - Description of command to create
- `--style` - expert (default), interactive, autonomous, learning
- `--complexity` - simple (<100 lines), standard (<300 lines), advanced (300+)
- `--location` - project (default) or user

## Process

### Step 1: Clarify Options

If style, complexity, or location not provided, use `AskUserQuestion`:

- **Style**: expert (multiple modes), interactive (guided), autonomous (minimal interaction), learning (builds knowledge)
- **Complexity**: simple, standard, advanced
- **Location**: project (.claude/commands/) or user (~/.claude/commands/)

### Step 2: Load Patterns

Invoke command-patterns skill for best practices:

```
Skill(skill="command-patterns")
```

### Step 3: Generate Command

Apply patterns from skill:

1. **Understand the Domain** - What tools do experts use? Common pain points?
2. **Design Multiple Modes** - analyze, fix, monitor, report
3. **Include Real Commands** - Test every example, include error handling
4. **Build Intelligence** - Pattern recognition, correlation, predictions
5. **Ensure Safety** - Rollbacks, confirmations, audit trails

### Step 4: Required Sections

Every generated command must have:

1. **Arguments** with multiple action modes
2. **Workflow Steps** (minimum 6)
   - Initialize & Verify Access
   - Discovery & Inventory
   - Analysis
   - Generate Recommendations
   - Interactive Decision Points
   - Execute & Verify
3. **Multiple Output Formats** (human, JSON, HTML)
4. **Configuration** (behavioral settings, integrations, safety)

### Step 5: Frontmatter

```yaml
---
description: Brief description (1-2 sentences)  # REQUIRED
allowed-tools: Bash, Read, Edit                 # OPTIONAL
argument-hint: "[action] [target]"              # OPTIONAL
model: haiku                                    # OPTIONAL - omit to inherit
---
```

**Model notes:**
- Omit `model:` to inherit user's session (recommended)
- Use `haiku` for fast, cheap operations
- Use full model IDs, never short names

**Name field:** Omit to use path-based naming. Use `name:` only for short aliases.

## Quality Test

> "Would a senior engineer with 10 years experience be impressed?"

If not emphatic YES, keep improving.

## Example Usage

```bash
# Database optimization command
/new-command "optimize postgres databases"

# Interactive debugging
/new-command "debug microservices" --style interactive

# Learning code reviewer
/new-command "review code" --style learning
```
