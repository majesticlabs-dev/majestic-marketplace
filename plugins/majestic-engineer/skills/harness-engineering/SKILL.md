---
name: harness-engineering
description: Repository structure methodology for maximum AI agent effectiveness. Three pillars — context engineering (repo as knowledge product), architectural constraints (deterministic enforcement), garbage collection (active entropy fighting). Use when setting up repos for AI development, diagnosing repeated agent failures, writing AGENTS.md, or designing CI gates and structural tests.
---

# Harness Engineering

## Core Principle

**The repo is the harness. Agent failures are harness failures. When an agent breaks a rule, fix the harness — not the agent.**

| Pillar | What It Solves |
|--------|---------------|
| Context Engineering | Agent hallucinations, wrong tool usage, stale docs |
| Architectural Constraints | Boundary violations, silent regressions, ambiguous failures |
| Garbage Collection | Entropy accumulation, dead code, doc drift |

## When to Apply

| Situation | Action |
|-----------|--------|
| New repo setup for AI development | Apply all three pillars from day one |
| Agent repeatedly hallucinating tools/APIs | Pillar 1: add tool declarations to AGENTS.md |
| Agent crossing module boundaries | Pillar 2: add structural test enforcing boundary |
| Agent producing code that passes CI but breaks conventions | Pillar 2: convert convention to linter rule or structural test |
| Docs drifting from implementation | Pillar 1: add CI cross-link validation |
| Codebase growing, agent quality degrading | Pillar 3: schedule GC agent for dead code and unused exports |
| Agent ignoring AGENTS.md guidance | Check: is guidance generic advice or a specific failure lesson? Rewrite as failure ledger entry |
| Post-incident on agent-generated code | Add failure to AGENTS.md, add constraint to prevent recurrence |

## Pillar 1: Context Engineering

**Goal:** Make the repository a knowledge product that agents can consume without hallucination.

### 1.1 AGENTS.md as Failure Ledger

Every line in AGENTS.md should trace to a real failure, not generic best practice.

```
# Pattern
BAD:  "Follow clean code principles"
BAD:  "Use meaningful variable names"
GOOD: "Never import from packages/internal — agent imported shared/db directly on 2025-12-03, broke build"
GOOD: "Always use OrderService.create(), not Order.new — direct instantiation skips validation (incident #247)"
```

**Failure ledger entry format:**
```yaml
rule: Never call PaymentGateway directly from controllers
context: Agent bypassed service layer, sent duplicate charges (2025-11-15)
fix: Use PaymentService.charge() which handles idempotency
```

When writing or updating AGENTS.md:
- If the rule doesn't reference a specific failure or concrete constraint → cut it
- If the rule says "should" → rewrite as "must" with consequence
- If the rule has no enforcement mechanism → pair it with a Pillar 2 constraint

### 1.2 Tool Declaration Mandate

Undeclared tools don't exist for agents. Explicitly list available tools, commands, and scripts.

```markdown
## Available Tools
- `bin/test` — Run test suite (prefer over raw pytest/rspec)
- `bin/lint` — Run linters with auto-fix
- `bin/db-reset` — Reset dev database
- `make deploy-staging` — Deploy to staging (requires approval)

## DO NOT USE
- `rm -rf` on any directory
- Direct database queries in production
- `curl` to external APIs without going through ApiClient
```

If an agent uses a tool not in this list → add it (if valid) or add it to DO NOT USE (if dangerous).

### 1.3 Docs as System of Record

```
RULE: docs/ is canonical truth
ENFORCEMENT: CI validates cross-links between docs/ and source code
MECHANISM:
  - Every public API must have a corresponding docs/ entry
  - CI script checks: for each @api-doc tag in source → matching file in docs/
  - Broken link = CI failure, not warning
```

Stale docs are worse than no docs — agents trust what they read.

### 1.4 Isolated Observability Per Task

Each agent task gets its own log context, not a shared monitoring stream.

```
PATTERN:
  - Assign task_id to each agent invocation
  - Route logs to task-specific output (file, log group, trace)
  - Post-task: review task log for failures, add to AGENTS.md if new pattern
```

Shared monitoring hides individual agent failures in noise.

## Pillar 2: Architectural Constraints

**Goal:** Make violations impossible or immediately visible through deterministic enforcement.

### 2.1 Teaching Linter Errors

Failure messages must include remediation, not just violation.

```
# BAD linter output
ERROR: Import violation in src/api/handler.ts

# GOOD linter output
ERROR: Import violation in src/api/handler.ts
  ↳ Cannot import from 'packages/db' in 'src/api/'
  ↳ Use 'packages/db-client' instead (facade pattern)
  ↳ See: docs/architecture/data-access.md
```

Agents read error messages literally. A teaching error message prevents the same mistake on next attempt.

### 2.2 Structural Tests

Enforce architectural boundaries in CI, not in documentation.

```
# Pseudocode structural tests
test "no cross-boundary imports":
  For each FILE in src/api/**:
    IMPORTS = parse_imports(FILE)
    FORBIDDEN = ["packages/internal", "src/admin", "src/worker"]
    assert IMPORTS intersection FORBIDDEN == empty

test "dependency direction":
  LAYERS = [presentation, application, domain, infrastructure]
  For each LAYER in LAYERS:
    For each IMPORT in LAYER.imports:
      assert IMPORT.layer_index >= LAYER.index  # only import same or lower

test "API contract stability":
  CURRENT = parse_openapi("api/openapi.yml")
  PREVIOUS = parse_openapi("api/openapi.yml", ref="main")
  assert no_breaking_changes(CURRENT, PREVIOUS)
```

### 2.3 Numeric CI Gates

Every check must be binary pass/fail. Advisory warnings are invisible to agents.

| Check Type | Gate Implementation |
|-----------|-------------------|
| Test coverage | `coverage >= 80%` or fail |
| Bundle size | `size <= 250KB` or fail |
| Lint errors | `errors == 0` or fail |
| Type errors | `errors == 0` or fail |
| Security vulns | `critical == 0` or fail |

**Rule:** If it matters, it's a gate. If it's a warning, agents will ignore it.

### 2.4 Dependency Layering

Make dependency direction explicit and enforced.

```
# .dependency-layers.yml (or equivalent config)
layers:
  - name: presentation
    paths: ["src/ui/**", "src/api/routes/**"]
    can_import: [application, domain]

  - name: application
    paths: ["src/services/**", "src/use-cases/**"]
    can_import: [domain, infrastructure]

  - name: domain
    paths: ["src/models/**", "src/entities/**"]
    can_import: []  # domain has no dependencies

  - name: infrastructure
    paths: ["src/db/**", "src/external/**"]
    can_import: [domain]
```

Without explicit layers, agents will create circular dependencies.

## Pillar 3: Garbage Collection

**Goal:** Actively fight entropy rather than accumulating technical debt.

### 3.1 Background GC Agents

Schedule periodic scans that produce small, auto-mergeable PRs.

```
GC_TASKS:
  - dead_code: find unused exports, unreachable functions → remove
  - stale_docs: find docs/ entries with no matching source → flag
  - unused_deps: find package.json/Gemfile entries with no imports → remove
  - orphan_tests: find test files with no matching source file → flag
  - config_drift: diff .env.example vs actual config usage → reconcile

FREQUENCY: weekly for active repos, monthly for stable repos
OUTPUT: one small PR per GC task (not one mega-PR)
MERGE: auto-merge if CI passes, otherwise flag for review
```

### 3.2 Custom Verification Tools

Build repo-specific fast-feedback tools instead of relying on generic linters.

```
PRINCIPLE: fast feedback > comprehensive analysis

Examples:
  - bin/check-api-contracts → validates OpenAPI spec matches routes (5s)
  - bin/check-imports → validates dependency layers (2s)
  - bin/check-docs → validates doc cross-links (3s)

RULE: if a custom check takes > 30s, it's too slow for agent feedback loops
```

### 3.3 Feedback Loop Discipline

When an agent produces bad output, follow this diagnostic order:

```
1. Check AGENTS.md — is the constraint documented?
   If NO → add it (Pillar 1 fix)
   If YES → is it enforced in CI?

2. Check CI — does a gate catch this failure?
   If NO → add structural test or linter rule (Pillar 2 fix)
   If YES → is the error message teaching?

3. Check error message — does it include remediation?
   If NO → improve the error message (Pillar 2.1 fix)
   If YES → the harness is correct, investigate agent-specific issue

NEVER: Skip to "the agent is broken" without completing steps 1-3
```

## Harness Assessment Checklist

Evaluate an existing repo's harness maturity:

### Context Engineering
- [ ] AGENTS.md exists at repo root
- [ ] AGENTS.md entries reference specific failures, not generic advice
- [ ] Available tools/scripts are explicitly listed
- [ ] Forbidden operations are explicitly listed
- [ ] `docs/` has CI-enforced cross-links to source

### Architectural Constraints
- [ ] Linter errors include remediation instructions
- [ ] At least one structural test enforces module boundaries
- [ ] All CI checks are binary pass/fail (no advisory warnings)
- [ ] Dependency direction is documented and enforced

### Garbage Collection
- [ ] Dead code removal happens on a schedule (not ad-hoc)
- [ ] Stale docs are detected automatically
- [ ] Custom verification tools exist for repo-specific invariants
- [ ] Post-failure diagnosis follows harness-first order (3.3)

**Scoring:** Count passing items per pillar. Below 3/5 in any pillar = harness gap.

## Cross-References

- `hierarchical-agents` — AGENTS.md structure, generation process, JIT indexing
- `tdd-workflow` — structural test implementation via red-green-refactor
- `structured-logging` — observability patterns for task-level isolation
- `quality-gate` agent — CI gate execution mechanics
- [references/patterns-catalog.md](references/patterns-catalog.md) — topology templates, AGENTS.md patterns, structural test examples, GC agent templates
