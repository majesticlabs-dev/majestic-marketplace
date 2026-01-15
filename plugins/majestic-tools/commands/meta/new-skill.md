---
name: majestic:new-skill
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Bash, Glob
argument-hint: "[skill-description]"
---

# New Skill Builder `/new-skill`

Generate Claude Code skills following Anthropic best practices and agentskills.io specification.

## Arguments

- `[skill-description]` - Description of the skill you want to create

## Example Usage

```bash
# Create a coding skill
/new-skill "best practices for writing Stimulus controllers"

# Create a workflow skill
/new-skill "TDD workflow for Python pytest"

# Create a tool-integrated skill
/new-skill "PDF processing with extraction and form filling"
```

## What Makes Skills Valuable

Skills provide **knowledge and context**, not autonomous execution. If it needs to DO work autonomously, make it an agent instead.

### ✅ Good Skill Examples

| Skill | Why It Works |
|-------|--------------|
| `dhh-coder` | Coding style guidance - patterns Claude applies when writing code |
| `tdd-workflow` | Methodology knowledge - steps Claude follows for test-driven development |
| `stimulus-coder` | Framework patterns - conventions Claude uses for Stimulus controllers |
| `pdf-processing` | Tool knowledge - how to use specific libraries and scripts |

**Pattern:** Skills TEACH Claude patterns, conventions, and approaches.

### ❌ Bad Skill Examples

| Skill | Why It Fails |
|-------|--------------|
| "Code reviewer" | Does autonomous work - should be an agent |
| "Git helper" | Vague scope - what specifically does it teach? |
| "Best practices" | Too broad - not actionable |
| "Documentation generator" | Creates artifacts - should be an agent |

**Pattern:** These skills DO things instead of TEACHING things.

### The Knowledge Test

Ask: **"Does this TEACH Claude or DO something?"**

| TEACH (Skill) | DO (Agent) |
|---------------|------------|
| Coding conventions | Run linters and fix code |
| Workflow methodology | Execute multi-step processes |
| Framework patterns | Generate reports |
| Tool usage guidance | Fetch and analyze data |

**Rule:** If it produces artifacts without user guidance, it's probably an agent.

## Common Skill Archetypes

When creating a skill, identify which archetype fits best and follow its structure:

### CLI Reference Skill

For tools, CLIs, APIs. Structure by operations, minimize prose.

```markdown
## Authentication
[How to authenticate]

## Core Operations
| Command | Description |
|---------|-------------|
| `tool init` | Initialize project |
| `tool run` | Execute task |

## Common Workflows
[Task-oriented examples]
```

**Examples:** `kamal-coder`, `wrangler-coder`, `gh-cli`

### Methodology Skill

For development practices, workflows, philosophies.

```markdown
## Core Philosophy
[Why this approach matters - 2-3 sentences max]

## The Process
1. [Step with criteria]
2. [Step with criteria]

## Decision Criteria
| Situation | Action |
|-----------|--------|
| [condition] | [response] |
```

**Examples:** `tdd-workflow`, `dhh-coder`, `founder-mode`

### Safety/Security Skill

For operations with risk. Include tiered approvals.

```markdown
## Risk Tiers

| Tier | Operations | Approval |
|------|------------|----------|
| Low | Read-only queries | Auto |
| Medium | Modifications | Confirm |
| High | Destructive ops | Explicit |

## Blocking Patterns
[What to never do]

## Allowing Patterns
[Safe operations]
```

**Examples:** `infra-security-review`, `devops-verifier`

### Orchestration Skill

For multi-step processes that coordinate other tools.

```markdown
## Quick Start
[Minimal invocation]

## Workflow Phases
1. [Phase]: [What happens]
2. [Phase]: [What happens]

## Machine-Readable Output
[JSON/YAML schema for automation]
```

**Examples:** `build-task-workflow`, `quality-gate`

## Instructions

### Step 1: Clarify Requirements

If skill description is vague, use `AskUserQuestion`:

- What specific patterns or conventions should this teach?
- What triggers should activate this skill? (file types, keywords, contexts)
- Should it have tool access? Which tools?
- Location: project (`.claude/skills/`) or plugin (`plugins/*/skills/`)?

### Step 2: Fetch Latest Documentation

Scrape official Claude Code skills documentation:

```
WebFetch("https://docs.anthropic.com/en/docs/claude-code/skills", "Extract skill structure, frontmatter fields, and best practices")
```

### Step 3: Generate Skill Name

The `name` field is the skill identifier used for validation and display.

**Naming Rules:**

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

**Flat vs Nested Directory Structure:**

```
# Flat structure (most skills)
plugins/majestic-rails/skills/stimulus-coder/SKILL.md
→ name: stimulus-coder
→ invoked as: skill majestic-rails:stimulus-coder

# Nested structure (categorized skills)
plugins/majestic-company/skills/ceo/strategic-planning/SKILL.md
→ name: strategic-planning
→ invoked as: skill majestic-company:ceo:strategic-planning

plugins/majestic-company/skills/fundraising/objection-destroyer/SKILL.md
→ name: objection-destroyer
→ invoked as: skill majestic-company:fundraising:objection-destroyer
```

**Key Points:**

- The `name` field is ONLY the final skill name (not the full path)
- Directory name must match `name` exactly
- Invocation path = `plugin-name:category:skill-name` (for nested)
- Use nesting to group related skills (ceo/, fundraising/, research/)

### Step 4: Write Effective Description

The description is **critical** for trigger matching. Must answer:

1. **What does this skill do?** (specific capabilities)
2. **When should Claude use it?** (trigger contexts)

**Template:**
```
[What it does]. Use when [trigger contexts]. Triggers on [specific keywords/patterns].
```

**Example:**
```yaml
description: Best practices for writing Stimulus controllers in Rails applications. Use when creating JavaScript controllers, handling DOM events, or adding interactivity. Triggers on Stimulus, controllers, data-action, data-target.
```

**Rules:**
- Max 1024 characters
- Third person ("Processes..." not "I process...")
- Include trigger keywords users would naturally say
- Be specific, not vague

### Step 5: Determine Tool Access

If the skill needs tools, specify `allowed-tools`:

| Tools Needed | Example Use Case |
|--------------|------------------|
| `Read, Grep, Glob` | Search codebase for patterns |
| `Bash(python:*)` | Execute Python scripts |
| `WebFetch` | Fetch external documentation |
| None | Pure knowledge/guidance |

**Note:** Restricting tools prevents the skill from doing things outside its scope.

### Step 6: Write Skill Content

**Structure (recommended):**

```markdown
# Skill Name

## Overview
[1-2 sentences explaining what this skill teaches]

## When to Use
- [Trigger context 1]
- [Trigger context 2]

## Core Patterns
[The actual knowledge/conventions/patterns]

## Examples
[Concrete examples of applying the patterns]

## Anti-Patterns
[What NOT to do]
```

**Content Rules:**

| Include | Exclude |
|---------|---------|
| Concrete patterns and conventions | Persona statements ("You are an expert...") |
| Specific templates and examples | Attribution ("Inspired by X...") |
| Decision criteria | Decorative quotes |
| Error handling guidance | ASCII art or box-drawing |
| Framework-specific idioms | Vague "best practices" |

**Line Limit:** Max 500 lines in SKILL.md

### Step 7: Use Progressive Disclosure

For complex skills, split into multiple files:

```
my-skill/
├── SKILL.md (overview, <500 lines)
├── references/
│   ├── patterns.md (detailed patterns)
│   └── examples.md (extended examples)
└── scripts/
    └── helper.py (utility scripts)
```

**Key rules:**
- References one level deep only (SKILL.md → reference.md, not → → deeper)
- Scripts execute without loading into context
- Keep SKILL.md focused on navigation and core content

### Step 8: Create Directory and Write Files

```bash
mkdir -p [target-path]/[skill-name]
# Write SKILL.md
# Write any reference files
```

### Step 9: Validate with Skill Linter

Run validation:

```bash
.claude/skills/skill-linter/scripts/validate-skill.sh [skill-path]
```

Expected output:
```
[PASS] SKILL.md exists
[PASS] Frontmatter delimiters present
[PASS] Name 'skill-name' valid (N chars)
[PASS] Name matches directory
[PASS] Description valid (N chars)
[PASS] Line count: N/500
[PASS] Subdirectories valid

Result: ALL CHECKS PASSED
```

## Advanced Patterns

### THE EXACT PROMPT Pattern

For reproducible agent-to-agent handoffs, encode prompts in ALL CAPS:

```markdown
## THE EXACT PROMPT

ANALYZE THE FOLLOWING CODE FOR SECURITY VULNERABILITIES:
1. CHECK FOR HARDCODED SECRETS
2. IDENTIFY SQL INJECTION RISKS
3. FLAG INSECURE DEPENDENCIES

RETURN FINDINGS AS JSON WITH SEVERITY LEVELS.
```

**Why it works:**
- Copy-paste ready between agents
- Removes ambiguity in multi-agent workflows
- Stream-deck/automation friendly

### Checklist Pattern

For multi-step processes with progress tracking:

```markdown
## Checklist

- [ ] Step 1: [Action with success criteria]
- [ ] Step 2: [Action with success criteria]
- [ ] Step 3: [Action with success criteria]

Mark each complete before proceeding.
```

### Feedback Loop Pattern

For operations requiring validation:

```markdown
## Validation Loop

1. Execute action
2. Verify result matches criteria
3. If FAIL: diagnose → fix → goto 1
4. If PASS: proceed to next step

Never advance without validation passing.
```

**Use for:** deployments, data migrations, security operations

## Output Format

Generate a complete skill following this structure:

```markdown
---
name: [skill-name]
description: [1024 chars max, third person, with trigger keywords]
allowed-tools: [optional, space-delimited]
---

# [Skill Title]

## Overview

[What this skill teaches]

## When to Use

- [Context 1]
- [Context 2]

## [Core Content Sections]

[The actual patterns, conventions, guidance]

## Examples

[Concrete usage examples]

## Anti-Patterns

[What to avoid]
```

## Validation Checklist

Before completing, verify:

- [ ] Name matches directory name exactly
- [ ] Name follows pattern `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- [ ] Description under 1024 chars with trigger keywords
- [ ] SKILL.md under 500 lines
- [ ] No persona statements or attribution
- [ ] No ASCII art or decorative elements
- [ ] Content teaches (not does)
- [ ] Subdirectories only: `scripts/`, `references/`, `assets/`
- [ ] Skill linter passes

## Quality Test

> "Does every line in this skill improve Claude's behavior?"

If any line is decorative, inspirational, or redundant - cut it.
