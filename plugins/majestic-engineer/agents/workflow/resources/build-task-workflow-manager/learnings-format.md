# Implementation Learnings Format

Reference for Step 10 of build-task-workflow-manager. Defines what to capture and how to format it for AGENTS.md.

## What to Capture

### Patterns

Conventions that emerged consistently across 2+ modified files:

- Import organization (grouping, ordering)
- Naming conventions (methods, variables, files)
- File structure patterns (where things go)
- Code organization (module boundaries, layering)

### Gotchas

Non-obvious requirements discovered during build or fix loop:

- Hidden dependencies between components
- Ordering constraints not documented
- Framework quirks requiring workarounds
- Environment-specific behaviors

### Anti-Patterns

Approaches that failed during the fix loop (only when ATTEMPTS > 1):

- What was tried and failed
- Why it failed
- What worked instead

## Output Format

Append to the nearest AGENTS.md, organized by type:

```markdown
## Patterns

| Pattern | Location |
|---------|----------|
| Consistent import grouping: stdlib, gems, app | `app/services/` |
| Form objects inherit from ApplicationForm | `app/forms/` |

## Gotchas

- ActiveJob must be configured before Turbo broadcasts work — missing config causes silent failures
- Stimulus controller names must match filename exactly — no aliases

## Anti-Patterns

| Don't | Why | Do Instead |
|-------|-----|------------|
| Inline SQL in controllers | Breaks when schema changes | Use scope methods on model |
| Skip N+1 checks in dev | Explodes in production | Use strict_loading or bullet gem |
```

## Rules

- **Dedupe:** Compare against existing AGENTS.md content before appending
- **Skip when:** No files modified, all learnings already documented, or trivial changes only
- **Location:** Walk up from primary modified directory until AGENTS.md found (fallback: root)
- **Merge:** Append to existing sections if they exist, create new sections if not
