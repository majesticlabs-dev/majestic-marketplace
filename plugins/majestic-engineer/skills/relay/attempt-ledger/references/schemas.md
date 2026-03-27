# Attempt Ledger Schemas

## Epic Schema

```yaml
# .agents/relay/epic.yml
version: 2
id: "20260111-feature-name"
source: "docs/plans/xxx.md"
created_at: "2026-01-11T17:30:00Z"

title: "Feature Name"
description: |
  Brief description of the epic.

tasks:
  T1:
    title: "Create users migration"
    priority: p1
    points: 2
    files:
      - db/migrate/xxx_create_users.rb
    depends_on: []
    acceptance_criteria:
      - "Migration creates users table with email and password_digest"
      - "Migration is reversible"
      - "Email column has unique index"
```

## Ledger Schema

```yaml
# .agents/relay/attempt-ledger.yml
version: 1
epic_id: "20260111-feature-name"
started_at: "2026-01-11T17:30:00Z"

settings:
  max_attempts_per_task: 3
  timeout_minutes: 15

task_status:
  T1: completed
  T2: in_progress
  T3: pending
  T4: blocked

attempts:
  T1:
    - id: 1
      started_at: "..."
      ended_at: "..."
      result: success
      receipt:
        summary: "Created migration and model"
        files_changed: [file1.rb, file2.rb]

  T2:
    - id: 1
      result: failure
      receipt:
        error_category: missing_dependency
        error_summary: "Database not migrated"
        suggestion: "Run db:migrate first"

gated_tasks:
  T5:
    reason: "max_attempts_exceeded"
    gated_at: "..."
```

## Success Receipt

```yaml
receipt:
  summary: "Brief description of what was done"
  files_changed: [list, of, files]
  quality_gate_verdict: APPROVED
  learning: "Reusable insight from this task"
  pattern_tags: [yq, shell, quoting]
```

## Failure Receipt

```yaml
receipt:
  error_category: missing_dependency | code_error | test_failure | quality_gate | cli_error
  error_summary: "What went wrong"
  quality_gate_verdict: NEEDS CHANGES | BLOCKED
  quality_gate_findings: |
    ## Finding 1: Missing test coverage
    **Severity:** HIGH
    **File:** app/models/user.rb:15
    **Fix:** Add unit tests for validation
  suggestion: "What to try differently"
  learning: "What was learned from the failure"
  pattern_tags: [migration, database]
```
