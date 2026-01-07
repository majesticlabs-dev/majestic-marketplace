---
name: ralph-methodology
description: Best practices for autonomous AI coding loops - task breakdown, prompt writing, and learnings that compound
triggers:
  - ralph
  - autonomous loop
  - ship while sleeping
  - iteration loop
---

# Ralph Methodology

Patterns for effective autonomous AI coding loops.

## Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Small Stories** | Each task fits in one context window |
| **Fast Feedback** | Tests + typecheck validate each iteration |
| **Explicit Criteria** | Acceptance criteria, not vague goals |
| **Learnings Compound** | Patterns accumulate in progress file |
| **Iteration > Perfection** | Let the loop refine, don't aim for perfect first try |

## Task Size Rules

```
# Too big - spans multiple concerns
❌ "Build entire auth system"

# Right size - focused, verifiable
✅ "Add login form with email/password fields"
✅ "Add email format validation"
✅ "Add auth server action"
✅ "Add session management"
```

**Heuristic:** If you can't verify it with a single test run, it's too big.

## Acceptance Criteria Format

```markdown
## Story: Add login form

**Acceptance Criteria:**
- [ ] Email and password input fields
- [ ] Client-side email format validation
- [ ] Submit button disabled until valid
- [ ] Error message on invalid submission
- [ ] typecheck passes
- [ ] Tests pass
- [ ] Verify at localhost:3000/login

**Output `<promise>DONE</promise>` when ALL criteria met.**
```

## Progress File

Location: `.claude/ralph-progress.local.yml` (gitignored)

```yaml
started_at: 2024-01-15T10:30:00Z
branch: feature/auth

patterns:
  migrations: "Use IF NOT EXISTS for all column additions"
  forms: "Zod schema validation, errors in schema not component"
  auth: "Server actions in actions.ts, session in httpOnly cookie"
  tests: "Use vitest, not jest"

stories:
  - id: US-001
    title: Add login form
    completed_at: 2024-01-15T10:45:00Z
    files:
      - app/login/page.tsx
      - app/auth/actions.ts
    learnings:
      - "Form validation uses zod"
      - "Submit handler in separate action file"

  - id: US-002
    title: Add validation
    completed_at: 2024-01-15T11:02:00Z
    files:
      - app/login/page.tsx
    learnings:
      - "Zod .email() handles format validation"
```

### Progress File Rules

1. **Read first** — Check patterns before starting each iteration
2. **Append after** — Add story entry after completing each task
3. **Patterns at top** — Key-value pairs for quick reference
4. **Promote at end** — Move valuable patterns to AGENTS.md when loop completes

### How Learnings Compound

| Iteration | What Claude Sees |
|-----------|------------------|
| 1 | Empty patterns |
| 2 | Patterns from story 1 |
| 5 | Patterns from stories 1-4 |
| 10 | Rich pattern library |

## AGENTS.md (Permanent Memory)

Durable patterns for humans and future agents:

```markdown
# app/auth/

## Patterns
- Server actions in `actions.ts`, not inline
- Use zod schemas for form validation
- Session stored in httpOnly cookie

## Gotchas
- Must call `revalidatePath` after auth changes
- Token refresh handled by middleware
```

**Promote from progress file at loop end.**

## Feedback Loop Requirements

**Mandatory:** Fast, automated verification each iteration.

| Check | Purpose | Example |
|-------|---------|---------|
| Typecheck | Catch type errors | `npm run typecheck` |
| Tests | Verify behavior | `npm test` |
| Lint | Code quality | `npm run lint` |
| Build | Catch build issues | `npm run build` |

**Without feedback loops, broken code compounds.**

## Prompt Templates

### Basic Autonomous Loop

```
Implement: [TASK TITLE]

Acceptance Criteria:
- [Criterion 1]
- [Criterion 2]
- typecheck passes
- tests pass

Update .claude/ralph-progress.local.yml with patterns discovered.
Output <promise>COMPLETE</promise> when ALL criteria met.
```

### With TDD

```
Implement [FEATURE] following TDD:
1. Write failing tests first
2. Implement minimum code to pass
3. Run typecheck and tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green

Update progress file with learnings.
Output <promise>COMPLETE</promise> when tests pass.
```

### With Escape Hatch

```
Implement [FEATURE].

After 15 iterations, if not complete:
- Document what's blocking progress
- List approaches attempted
- Suggest alternatives
- Output <promise>BLOCKED</promise>

Otherwise, output <promise>COMPLETE</promise> when done.
```

### Multi-Phase

```
Build [SYSTEM] in phases:

Phase 1: [Component A] - tests passing
Phase 2: [Component B] - tests passing
Phase 3: [Integration] - all tests passing

Update progress file after each phase.
Output <promise>COMPLETE</promise> when all phases done.
```

## Common Gotchas

### Idempotent Operations

```sql
-- Always use IF NOT EXISTS for migrations
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
```

### Non-Interactive Commands

```bash
# Pipe input to avoid interactive prompts
echo -e "\n\n\n" | npm run db:generate

# Use --yes flags where available
npm init -y
```

### Schema Cascade

After editing schema, check ALL dependent code:
- Server actions
- UI components
- API routes
- Tests

**Fixing related files is expected, not scope creep.**

## When NOT to Use Ralph

| Scenario | Why |
|----------|-----|
| Exploratory work | No clear success criteria |
| Major refactors | Needs human architecture decisions |
| Security-critical | Requires careful human review |
| Production debugging | Too risky for autonomous changes |
| Design decisions | Subjective, needs human judgment |

## Monitoring Commands

```bash
# Current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# View progress
cat .claude/ralph-progress.local.yml

# Recent commits
git log --oneline -10
```

## Integration with Blueprints

Use Ralph with `/majestic:run-blueprint` for multi-task features:

```bash
/ralph "/majestic:run-blueprint docs/plans/add-auth.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

The blueprint provides:
- Task breakdown with dependencies
- Structured progress tracking
- Quality gates per task
- Batch shipping at end
