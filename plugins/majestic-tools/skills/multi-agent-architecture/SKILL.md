---
name: multi-agent-architecture
description: Patterns for designing multi-agent systems with Claude Code - job description method, shared folder communication, handbook consolidation, context management. Use when building complex agent orchestrations.
---

# Multi-Agent Architecture

Design principles for orchestrating many sub-agents without context overflow.

## Core Philosophy

Treat agent design like human hiring: write a job description first, then translate to architecture. The framing shapes every decision.

## The Job Description Method

Before writing any agent code:

1. **Write a human JD** — What would you want this person to do? What qualities? What indicates success?
2. **Identify handoff points** — Where would a human need to check in or escalate?
3. **Define the onboarding** — What handbook would you give a new hire?
4. **Translate to agents** — Each JD section becomes architecture

| JD Section | Architecture Element |
|------------|---------------------|
| Responsibilities | Agent workflows |
| Required skills | Tool permissions |
| Success indicators | Output schemas |
| Escalation criteria | Error handling |
| Onboarding materials | Skills/handbook |

## The Shared Folder Pattern

**Problem:** Orchestrator context overwhelmed when 10+ sub-agents return detailed reports simultaneously.

**Solution:** Sub-agents write to temp folder → downstream agents read directly.

```
.claude/workspace/
├── phase-1/
│   ├── gmail-analysis.md
│   ├── calendar-analysis.md
│   └── drive-inventory.md
├── phase-2/
│   ├── client-summary.md
│   └── action-items.md
└── manifest.yml
```

**Workflow:**

```
1. Orchestrator spawns sub-agents
2. Each sub-agent:
   - Does work
   - Writes report to .claude/workspace/{phase}/{name}.md
   - Returns only: { status: "complete", path: "..." }
3. Downstream agents read prior phase outputs directly
4. Orchestrator reads manifest, not full reports
```

**Benefits:**
- Orchestrator context stays minimal
- Sub-agents get full upstream context
- No signal loss from summarization relay

## The Handbook Pattern

**Problem:** Many narrow skills create fragility and maintenance burden.

**Solution:** One handbook organized by chapters, read foundation + relevant sections.

```
skills/project-manager/
├── SKILL.md              # Entry point, routes to chapters
└── resources/
    ├── 01-foundation.md  # Who we are, tools, escalation, standards
    ├── 02-daily-ops.md   # Data gathering procedures
    ├── 03-dashboards.md  # Structure, quality checks
    └── 04-onboarding.md  # New client setup
```

**Chapter Structure:**

| Chapter | Contents |
|---------|----------|
| Foundation | Team, tools, data sources, escalation rules, quality standards |
| Domain chapters | Specific procedures for each responsibility area |

**Reading Pattern:**

```
Sub-agent reads:
1. Foundation chapter (always)
2. Relevant domain chapter(s) (based on task)
```

## Context Budget Strategies

| Strategy | When to Use |
|----------|-------------|
| Shared folder | 5+ sub-agents, inter-agent dependencies |
| Context proxy | Research agents returning verbose results |
| Manifest files | Orchestrator needs status, not details |
| Chunked execution | Serial phases when parallel overwhelms |

## Architecture Decision Tree

```
How many sub-agents?
├── 1-3 → Direct orchestration (return reports to main)
├── 4-10 → Shared folder pattern
└── 10+ → Phased execution with manifest

Do teammates need direct communication?
├── No → Sub-agents (Task tool) — report results back only
└── Yes → Agent Teams — shared task list, inter-agent messaging
    ├── See agent-teams skill for full guide
    └── Best for: parallel review, competing hypotheses, multi-module features

Do sub-agents need each other's output?
├── No → Parallel execution, merge results
└── Yes → Shared folder, dependency ordering

Is orchestrator context a concern?
├── No → Return full reports
└── Yes → Status-only returns + file paths
```

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Slash commands as orchestration | Context exhaustion before work starts | Move to sub-agents |
| Orchestrator relays all context | Bottleneck, signal loss | Shared folder |
| One skill per micro-task | Fragile, hard to maintain | Handbook chapters |
| Sub-agents return full reports | Context overflow at 10+ agents | Path-only returns |

## Iteration Path

Most multi-agent systems evolve through:

1. **Slash commands** — Quick start, context limits emerge
2. **Orchestrator + sub-agents** — Solves context, creates relay bottleneck
3. **Shared folder** — Solves relay, reveals skill fragmentation
4. **Handbook consolidation** — Unified knowledge, maintainable

Skip earlier stages when building new systems.

## Agent Teams

When workers need to communicate directly with each other — not just report back to an orchestrator — use Agent Teams instead of sub-agents. Agent Teams provide shared task lists, inter-agent messaging, and independent context windows.

**Key differences from sub-agent patterns above:**
- Teammates message each other directly (not just back to caller)
- Shared task list with self-claiming and dependency auto-unblock
- Each teammate is a full Claude Code session with own context

**When to upgrade from sub-agents to Agent Teams:**
- Sub-agents need to share findings mid-task
- You need adversarial debate or competing hypotheses
- 3+ workers need self-organizing coordination

For full setup, operations reference, and orchestration patterns, apply the `agent-teams` skill.
