# Learnings Discovery System

Unified institutional memory for Claude Code workflows.

## Overview

The learnings discovery system surfaces relevant knowledge at the right moment during development:

- **Planning** (`/majestic-engineer:blueprint`): Past architectural decisions, proven patterns
- **Debugging** (`/majestic-engineer:debug`): Similar issues and their solutions
- **Review** (`quality-gate`): Critical anti-patterns to check
- **Implementation** (`/majestic-engineer:build-task`): Patterns and gotchas for current work

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Workflow                        │
│                                                                  │
│  /blueprint  ──┐                                                │
│                │   ┌─────────────────────┐   ┌──────────────────┐ │
│  /debug     ───┼──►│ lessons-discoverer  │──►│ .agents/lessons/ │ │
│                │   │ (semantic scoring)  │   │                  │ │
│  quality-gate ─┘   └─────────────────────┘   │ ├─ antipatterns/ │ │
│                            │                  │ ├─ gotchas/      │ │
│                            ▼                  │ ├─ patterns/     │ │
│                    ┌───────────────┐         │ └─ ...           │ │
│                    │ Top 5 lessons │         └──────────────────┘ │
│                    │ (paths+scores)│                             │
│                    └───────────────┘                             │
│                            │                                     │
│                            ▼                                     │
│                    Inject into workflow context                  │
│                    (architect, debugger, reviewers)              │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration

Add to `.agents.yml`:

```yaml
# Default location (recommended)
lessons_path: .agents/lessons/

# Or custom location
lessons_path: docs/learnings/
```

## Directory Structure

```
.agents/lessons/
├── performance-issues/
│   └── n-plus-one-20251110.md
├── security-issues/
│   └── auth-bypass-20251020.md
├── build-errors/
│   └── missing-dependency-20251205.md
└── patterns/
    └── api-versioning.md
```

Categories match the `problem_type` field in lesson frontmatter.

## Lesson Format

```yaml
---
module: User Service
date: 2025-11-10
problem_type: performance_issue
component: model
symptoms:
  - "N+1 query when loading user records"
  - "API response taking >5 seconds"
root_cause: missing_eager_load
severity: high
tags: [n-plus-one, eager-loading, performance]

# Discovery fields (optional - enable auto-discovery)
lesson_type: antipattern
workflow_phase: [debugging, review]
tech_stack: [rails]
impact: major_time_sink
keywords: [includes, eager_load, preload]
---

# Troubleshooting: N+1 Query in User List API

## Problem
...

## Solution
...
```

## Discovery Fields

| Field | Values | Description |
|-------|--------|-------------|
| `lesson_type` | antipattern, gotcha, pattern, setup, workflow | Categorization for filtering |
| `workflow_phase` | planning, debugging, review, implementation | When to surface the lesson |
| `tech_stack` | rails, python, react, node, generic | Stack filtering |
| `impact` | blocks_work, major_time_sink, minor_inconvenience | Priority for ranking |
| `keywords` | array of strings | Semantic matching with task descriptions |

## Creating Lessons

### Automatic (Recommended)

Use `/report-fix` after solving a non-trivial problem:

```
User: "That worked! The N+1 query is fixed."
Claude: [Detects confirmation, invokes fix-reporter skill]
Claude: [Creates lesson in .agents/lessons/performance-issues/]
Claude: "Solution documented. Enable discovery for workflows?"
```

### Manual

Create a markdown file in the appropriate category directory with YAML frontmatter.

## Workflow Integration

### Blueprint (Planning Phase)

```
/majestic-engineer:blueprint "Add user authentication with OAuth"
```

1. Resolves toolbox configuration
2. **Discovers lessons with `workflow_phase: planning`**
3. Runs research agents
4. Passes lessons to architect agent
5. Architect considers past learnings in design

### Debug (Debugging Phase)

```
/majestic-engineer:debug "API returns 500 error on user update"
```

1. Gathers bug description
2. **Discovers lessons with `workflow_phase: debugging`**
3. If high-confidence match (>70 score), offers to read it first
4. User can apply documented solution or continue investigation

### Quality Gate (Review Phase)

```
agent quality-gate "Branch: feature/add-auth"
```

1. Reads configuration
2. **Discovers lessons with `workflow_phase: review`**
3. Formats critical patterns as checklist
4. **Injects patterns into ALL reviewer prompts**
5. Reviewers check for documented anti-patterns

## Semantic Scoring

The `lessons-discoverer` agent scores lessons directly using semantic matching:

1. **workflow_phase match** (required — skip if no match)
2. **tech_stack match** (higher if matches, include if generic)
3. **Semantic relevance** to task description
4. **Impact/severity** weighting
5. **Recency bonus** from date field

Benefits:
- No scoring algorithm to maintain
- Catches conceptual matches ("authorization" ↔ "access control")
- Adapts to any project domain

## Best Practices

1. **Be specific** - Include exact error messages and code examples
2. **Add keywords** - Help semantic discovery with domain-specific terms
3. **Set workflow_phase** - Lessons surface only when relevant
4. **Update lessons** - Add cross-references when related issues arise
5. **Review periodically** - Archive outdated lessons, consolidate patterns

## Troubleshooting

### Lessons not being discovered

1. Check directory exists: `ls .agents/lessons/`
2. Verify frontmatter includes `workflow_phase` for desired workflows
3. Check `tech_stack` matches project config
4. Ensure lesson has required frontmatter fields

### Too many/few lessons surfacing

Adjust the threshold in lessons-discoverer agent (default: 30 for inclusion, >70 for high-confidence prompts).

### Discovery failing

Ensure the `lessons-discoverer` agent is available and the lessons directory contains valid markdown files with proper frontmatter.
