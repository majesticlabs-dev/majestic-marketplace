---
name: majestic:refactor-agents
description: Refactor existing AGENTS.md to follow progressive disclosure principles
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
  - Skill
disable-model-invocation: true
---

# Refactor AGENTS.md

Optimize an existing AGENTS.md file using progressive disclosure principles. Extracts essentials to root, groups related instructions into sub-files, and flags content for deletion.

## Step 1: Load Current State

```
AGENTS_FILES = Glob("**/AGENTS.md")
ROOT_AGENTS = Read("AGENTS.md")
```

If no AGENTS.md exists: suggest `/majestic:init` instead.

## Step 2: Find Contradictions

Analyze ROOT_AGENTS for conflicting instructions:

| Contradiction Type | Example |
|-------------------|---------|
| Version conflicts | "Use Node 18" vs "Requires Node 20" |
| Style conflicts | "Use tabs" vs "2-space indent" |
| Tool conflicts | "Use npm" vs "pnpm install" |
| Process conflicts | "Always write tests first" vs "Tests optional for prototypes" |

For each contradiction found:
```
AskUserQuestion:
  question: "Found conflicting instructions: [A] vs [B]. Which should we keep?"
  options: [A, B, "Keep both with context", "Remove both"]
```

## Step 3: Identify Essentials

Extract ONLY content that belongs in root AGENTS.md:

| Keep in Root | Move to Sub-file |
|--------------|------------------|
| One-sentence project description | Detailed architecture docs |
| Package manager (if not npm) | Framework-specific patterns |
| Non-standard build/test commands | Testing conventions |
| Universal security rules | Component-specific rules |
| Links to sub-files | Verbose examples |

**Root target:** 60-100 lines (max 200)

## Step 4: Group Remaining Content

Categorize instructions into logical groups:

| Category | Typical Content |
|----------|-----------------|
| `conventions/typescript.md` | TS strict mode, type patterns, import style |
| `conventions/testing.md` | Test structure, mocking rules, coverage |
| `conventions/git.md` | Branch naming, commit format, PR process |
| `conventions/api.md` | Endpoint patterns, error handling, auth |
| `conventions/styling.md` | CSS approach, component styling, themes |

For ambiguous content:
```
AskUserQuestion:
  question: "Where should '[instruction]' live?"
  options: [category suggestions based on content]
```

## Step 5: Flag for Deletion

Identify instructions that should be removed:

| Flag | Reason | Example |
|------|--------|---------|
| REDUNDANT | Agent already knows | "Use meaningful variable names" |
| VAGUE | Not actionable | "Write clean code" |
| OBVIOUS | No new information | "Test your changes" |
| OUTDATED | No longer applies | References deprecated tools |
| DUPLICATE | Already stated elsewhere | Same rule in multiple places |

Present flagged items for confirmation:
```
AskUserQuestion:
  question: "These instructions seem [redundant/vague/obvious]. Delete them?"
  options: ["Delete all", "Review each", "Keep all"]
```

## Step 6: Generate New Structure

Create the refactored file structure:

```
AGENTS.md                      # Minimal root (60-100 lines)
.agents/                       # Sub-files directory
  conventions/
    typescript.md
    testing.md
    git.md
  patterns/
    [domain-specific].md
```

### Root AGENTS.md Template

```markdown
# [Project Name]

[One sentence description]

## Quick Reference

- **Stack:** [tech stack summary]
- **Build:** `[build command]`
- **Test:** `[test command]`
- **Lint:** `[lint command]`

## Conventions

See detailed guides in `.agents/conventions/`:
- [TypeScript](.agents/conventions/typescript.md)
- [Testing](.agents/conventions/testing.md)
- [Git Workflow](.agents/conventions/git.md)

## Security

- Never commit secrets or `.env` files
- [Other universal security rules]

## Before PR

\`\`\`bash
[single command that runs all checks]
\`\`\`
```

## Step 7: Write Files

1. Backup original: `mv AGENTS.md AGENTS.md.backup`
2. Write new root AGENTS.md
3. Create `.agents/` directory structure
4. Write each sub-file

## Step 8: Verify

Report refactoring results:

```
## Refactoring Complete

### Before
- Root AGENTS.md: [X] lines
- Sub-files: [Y]

### After
- Root AGENTS.md: [X] lines (target: 60-100)
- Sub-files: [list with line counts]

### Changes
- Contradictions resolved: [count]
- Instructions moved: [count]
- Instructions deleted: [count]
  - Redundant: [count]
  - Vague: [count]
  - Obvious: [count]

### Backup
Original saved to: AGENTS.md.backup
```

## Error Handling

| Condition | Action |
|-----------|--------|
| No AGENTS.md found | Suggest `/majestic:init` |
| Already minimal (<100 lines) | Ask if optimization still wanted |
| No contradictions found | Skip to Step 3 |
| User cancels at any step | Preserve original, no changes |
