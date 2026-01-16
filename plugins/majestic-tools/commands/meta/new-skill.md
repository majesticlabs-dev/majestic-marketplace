---
name: majestic:new-skill
description: Generate Claude Code skills following best practices. Creates skill files with proper structure, naming, and content.
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Bash, Glob
argument-hint: "[skill-description]"
---

# New Skill Builder

Generate Claude Code skills following Anthropic best practices.

## Input

```
skill_description: $ARGUMENTS
```

**If empty:** Ask user to describe what the skill should teach.

## Workflow

### Step 1: Load Design Philosophy

```
Skill(skill: "skill-design-philosophy")
```

Validate the request passes the knowledge test:
- Does this TEACH Claude or DO something?
- If it DOES things → suggest creating an agent instead

### Step 2: Clarify Requirements

```
AskUserQuestion:
  question: "What should this skill teach?"
  options:
    - "Coding conventions/patterns" → CLI Reference or Methodology archetype
    - "Workflow/process" → Methodology archetype
    - "Tool/CLI usage" → CLI Reference archetype
    - "Safety/security rules" → Safety archetype
```

Additional clarifications if needed:
- What triggers should activate this skill?
- Should it have tool access? Which tools?
- Location: project or plugin?

### Step 3: Fetch Latest Documentation

```
WebFetch("https://docs.anthropic.com/en/docs/claude-code/skills", "Extract skill frontmatter fields and best practices")
```

### Step 4: Load Archetype

```
Skill(skill: "skill-archetypes")
```

Select appropriate archetype based on Step 2 answer:
- CLI Reference
- Methodology
- Safety/Security
- Orchestration

### Step 5: Load Structure Rules

```
Skill(skill: "skill-structure")
```

Apply:
- Naming conventions
- Directory layout
- Frontmatter requirements
- Line limits

### Step 6: Generate Skill

Write skill following loaded patterns:

```markdown
---
name: [skill-name]
description: [1024 chars max, with trigger keywords]
allowed-tools: [optional]
---

# [Skill Title]

## Overview
[What this skill teaches]

## When to Use
- [Context 1]
- [Context 2]

## [Core Content]
[Patterns from selected archetype]

## Anti-Patterns
[What to avoid]
```

### Step 7: Create Files

```
mkdir -p [target-path]/[skill-name]
Write(file_path: "[target-path]/[skill-name]/SKILL.md", content: [generated])
```

### Step 8: Validate

```
Bash(command: ".claude/skills/skill-linter/scripts/validate-skill.sh [skill-path]")
```

If validation fails: fix issues and re-validate.

## Output

Report created skill:
- Path
- Name
- Description
- Archetype used
- Validation status
