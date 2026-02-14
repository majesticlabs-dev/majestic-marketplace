---
name: skill-structure
description: Skill file structure, naming conventions, directory layout, frontmatter requirements, and invocation control. Use when creating skill files or slash commands to ensure correct format and validation.
---

# Skill Structure

## Commands and Skills Are Merged

Custom slash commands and skills are the same thing. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review`. Existing `.claude/commands/` files keep working. Skills add: a directory for supporting files, frontmatter to control invocation, and automatic context loading.

If a skill and command share the same name, the skill takes precedence.

**When to use which:**

| Type | When |
|------|------|
| Command file (`commands/name.md`) | Simple single-file workflow, no supporting files |
| Skill directory (`skills/name/SKILL.md`) | Needs references, background knowledge, or progressive disclosure |

## Naming Rules

| Rule | Example |
|------|---------|
| Format | `kebab-case`, lowercase, 1-64 chars |
| Pattern | `^[a-z][a-z0-9]*(-[a-z0-9]+)*$` |
| Must match | Directory name exactly |

**Good/Bad Examples:**

| Good | Bad | Why |
|------|-----|-----|
| `stimulus-coder` | `MySkill` | Uppercase not allowed |
| `tdd-workflow` | `skill_helper` | Underscores not allowed |
| `pdf-processing` | `-invalid` | Can't start with hyphen |
| `seo-content` | `skill--bad` | No consecutive hyphens |

## Directory Structure

### Flat Structure (most skills)

```
plugins/majestic-rails/skills/stimulus-coder/SKILL.md
-> name: stimulus-coder
-> invoked as: /majestic-rails:stimulus-coder
```

### Nested Structure (categorized skills)

```
plugins/majestic-company/skills/ceo/strategic-planning/SKILL.md
-> name: strategic-planning
-> invoked as: /majestic-company:ceo:strategic-planning
```

**Key Points:**
- The `name` field is ONLY the final skill name (not the full path)
- Directory name must match `name` exactly
- Use nesting to group related skills (ceo/, fundraising/, research/)

## Progressive Disclosure

For complex skills, split into multiple files:

```
my-skill/
+-- SKILL.md (overview, <500 lines)
+-- references/
|   +-- patterns.md (detailed patterns)
|   +-- examples.md (extended examples)
+-- scripts/
    +-- helper.py (utility scripts)
```

**Rules:**
- References one level deep only (SKILL.md to reference.md, not deeper)
- Scripts execute without loading into context
- Keep SKILL.md focused on navigation and core content
- Subdirectories only: `scripts/`, `references/`, `assets/`

## Frontmatter

### Core Fields

```yaml
---
name: skill-name              # Matches directory, defaults to dir name if omitted
description: What it does...  # Recommended, max 1024 chars
allowed-tools: Read, Bash     # Optional, space-delimited
---
```

### All Fields Reference

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Lowercase letters, numbers, hyphens (max 64 chars). Defaults to directory name. |
| `description` | Recommended | What it does AND when to use it. Max 1024 chars. |
| `argument-hint` | No | Hint during autocomplete. Example: `[issue-number]` |
| `disable-model-invocation` | No | `true` = Claude cannot auto-load. For manual workflows. Default: `false` |
| `user-invocable` | No | `false` = hidden from `/` menu. For background knowledge. Default: `true` |
| `allowed-tools` | No | Tools without permission prompts. Example: `Read, Bash(git *)` |
| `model` | No | `haiku`, `sonnet`, or `opus` |
| `context` | No | `fork` to run in isolated subagent context |
| `agent` | No | Subagent type when `context: fork`: `Explore`, `Plan`, `general-purpose`, or custom |

### Description Template

```
[What it does]. Use when [trigger contexts]. Triggers on [specific keywords].
```

**Rules:**
- Max 1024 characters
- Third person ("Processes..." not "I process...")
- Include trigger keywords users would naturally say

## Invocation Control

| Frontmatter | User can invoke | Claude can invoke | When loaded |
|-------------|----------------|-------------------|-------------|
| (default) | Yes | Yes | Description always in context, full content on invocation |
| `disable-model-invocation: true` | Yes | No | Description not in context, loads only on user invoke |
| `user-invocable: false` | No | Yes | Description always in context, loads when relevant |

**Decision guide:**
- Side-effect workflows (`/deploy`, `/commit`, `/triage-prs`) -> `disable-model-invocation: true`
- Background knowledge (conventions, domain context) -> `user-invocable: false`
- General guidance (coding patterns, best practices) -> defaults

## Dynamic Features

### Arguments

Use `$ARGUMENTS` for user input. If not present in content, arguments are appended automatically.

```yaml
---
name: fix-issue
disable-model-invocation: true
---
Fix GitHub issue $ARGUMENTS following our coding standards.
```

Individual args: `$ARGUMENTS[0]` or shorthand `$0`, `$1`, `$2`.

### Dynamic Context Injection

The `` !`command` `` syntax runs shell commands before content reaches Claude:

```markdown
## Context
- Current branch: !`git branch --show-current`
- PR diff: !`gh pr diff`
```

Commands execute immediately; output replaces the placeholder.

### Subagent Execution

Add `context: fork` to run in isolation (no conversation history):

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---
Research $ARGUMENTS thoroughly...
```

## Tool Access

| Tools Needed | Example Use Case |
|--------------|------------------|
| `Read, Grep, Glob` | Search codebase for patterns |
| `Bash(git *)` | Git operations only |
| `Bash(gh *)` | GitHub CLI operations |
| `WebFetch` | Fetch external documentation |
| None | Pure knowledge/guidance |

## Limits

- **SKILL.md:** Max 500 lines
- **Name:** Max 64 characters
- **Description:** Max 1024 characters

## Validation Checklist

- [ ] Name matches directory name exactly
- [ ] Name follows pattern `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- [ ] Description under 1024 chars with trigger keywords
- [ ] Uses standard markdown headings (not XML tags)
- [ ] SKILL.md under 500 lines
- [ ] `disable-model-invocation: true` if skill has side effects
- [ ] `allowed-tools` set if specific tools needed
- [ ] No persona statements or attribution
- [ ] Subdirectories only: `scripts/`, `references/`, `assets/`
- [ ] Tested with real usage
