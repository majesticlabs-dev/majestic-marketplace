---
name: skill-design-philosophy
description: Core philosophy for designing Claude Code skills - when to use skills vs agents, the knowledge test, and what makes skills valuable. Use when deciding component type or evaluating skill quality.
disable-model-invocation: true
---

# Skill Design Philosophy

Skills provide **knowledge and context**, not autonomous execution.

## The Knowledge Test

Ask: **"Does this TEACH Claude or DO something?"**

| TEACH (Skill) | DO (Agent) |
|---------------|------------|
| Coding conventions | Run linters and fix code |
| Workflow methodology | Execute multi-step processes |
| Framework patterns | Generate reports |
| Tool usage guidance | Fetch and analyze data |

**Rule:** If it produces artifacts without user guidance, it's probably an agent.

## Good Skill Examples

| Skill | Why It Works |
|-------|--------------|
| `dhh-coder` | Coding style guidance - patterns Claude applies when writing code |
| `tdd-workflow` | Methodology knowledge - steps Claude follows for test-driven development |
| `stimulus-coder` | Framework patterns - conventions Claude uses for Stimulus controllers |
| `pdf-processing` | Tool knowledge - how to use specific libraries and scripts |

**Pattern:** Skills TEACH Claude patterns, conventions, and approaches.

## Bad Skill Examples

| Skill | Why It Fails |
|-------|--------------|
| "Code reviewer" | Does autonomous work - should be an agent |
| "Git helper" | Vague scope - what specifically does it teach? |
| "Best practices" | Too broad - not actionable |
| "Documentation generator" | Creates artifacts - should be an agent |

**Pattern:** These skills DO things instead of TEACHING things.

## Content Rules

| Include | Exclude |
|---------|---------|
| Concrete patterns and conventions | Persona statements ("You are an expert...") |
| Specific templates and examples | Attribution ("Inspired by X...") |
| Decision criteria | Decorative quotes |
| Error handling guidance | ASCII art or box-drawing |
| Framework-specific idioms | Vague "best practices" |

## Quality Test

> "Does every line in this skill improve Claude's behavior?"

If any line is decorative, inspirational, or redundant - cut it.
