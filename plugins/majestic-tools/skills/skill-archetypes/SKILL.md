---
name: skill-archetypes
description: Four common skill archetypes with structure templates - CLI reference, methodology, safety/security, and orchestration. Use when creating new skills to select appropriate structure.
---

# Skill Archetypes

Identify which archetype fits best and follow its structure.

## 1. CLI Reference Skill

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

## 2. Methodology Skill

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

## 3. Safety/Security Skill

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

## 4. Orchestration Skill

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
