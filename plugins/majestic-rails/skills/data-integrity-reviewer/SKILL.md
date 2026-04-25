---
name: data-integrity-reviewer
description: Review data integrity for Rails changes. Use when the user asks for migration safety review, constraint validation, transaction boundary audit, or PII/privacy compliance review.
allowed-tools: Read Grep Glob Bash
---

# Data Integrity Reviewer

**Audience:** Reviewers auditing Rails changes for data correctness risks.
**Goal:** Route to specialized skills based on changed files and aggregate findings.

## Routing Table

| Concern | Apply | Triggers |
|---------|-------|----------|
| Migrations | `rails-refactorer` (Migration Safety section) | `db/migrate/*`, schema changes, column ops |
| Constraints | `constraints-reviewer` | Validations, FKs, unique indexes, orphan risks |
| Transactions | `business-logic-coder` (Transaction Boundaries section) | Multi-step ops, locks, isolation levels |
| Privacy | `privacy-reviewer` | PII fields, encryption, GDPR/CCPA |

## Workflow

```
CHANGED_FILES = git diff --name-only
SKILLS = []

If CHANGED_FILES matches db/migrate/*:
  SKILLS.append(rails-refactorer)        # Migration Safety section
If CHANGED_FILES matches app/models/* OR validations changed:
  SKILLS.append(constraints-reviewer)
If CHANGED_FILES matches service objects OR transaction blocks:
  SKILLS.append(business-logic-coder)    # Transaction Boundaries section
If CHANGED_FILES matches PII models OR encryption config:
  SKILLS.append(privacy-reviewer)

For each S in SKILLS:
  Read skills/<S>/SKILL.md and apply criteria to CHANGED_FILES → FINDINGS[S]

AGGREGATE FINDINGS into unified report
```

## Full Audit Mode

When user requests comprehensive data integrity audit, apply all 4 skills regardless of file diff.

## Input Schema

```yaml
scope:
  changed_files: [string]      # optional; default = git diff --name-only
  mode: routed | full-audit    # default routed
```

## Output Schema

```yaml
overall_status: PASS | WARN | FAIL
areas:
  migrations:    { status: PASS | WARN | FAIL, critical_count: int }
  constraints:   { status: PASS | WARN | FAIL, critical_count: int }
  transactions:  { status: PASS | WARN | FAIL, critical_count: int }
  privacy:       { status: PASS | WARN | FAIL, critical_count: int }
critical_risks:
  - area: migrations | constraints | transactions | privacy
    file: string
    line: int
    description: string
recommendations:
  - severity: P1 | P2 | P3
    action: string
```

## Error Handling

| Condition | Action |
|-----------|--------|
| No matching skills triggered | Return `overall_status: PASS`, empty findings, note "no data-integrity changes detected" |
| Skill file missing | Skip that area, mark status `WARN`, note in output |
| Git diff empty | Return `overall_status: PASS`, "no changes to review" |
