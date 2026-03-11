---
name: devops-verifier
description: Verify DevOps/infrastructure code against best practices, security, simplicity, and documentation standards. Use after implementing or before shipping infrastructure changes.
allowed-tools: Read Grep Glob Bash WebSearch
---

# DevOps Verifier

Comprehensive infrastructure code verification framework. Apply this when verifying DevOps/infrastructure code changes.

## Skill Routing

| Dimension | Skill | Content |
|-----------|-------|---------|
| Platform patterns | `devops-platform-patterns` | DO, Hetzner, AWS, Cloudflare checklists |
| Security | `infra-security-review` | State, secrets, network, compute, storage |
| Simplicity | `devops-simplicity-checker` | File count, modules, complexity scoring |
| Maintainability | `devops-maintainability-checker` | Naming, formatting, DRY, versions |

## Verification Process

### Step 1: Discover

- Find IaC files: *.tf, *.yml (ansible)
- Detect platforms from providers

### Step 2: Research

- Search for "terraform best practices 2025"
- Search for "[platform] terraform best practices 2025"

### Step 3: Run Dimension Checks

- Apply `devops-platform-patterns` for platform-specific checks
- Apply `infra-security-review` for security
- Apply `devops-simplicity-checker` for simplicity
- Apply `devops-maintainability-checker` for maintainability
- Check documentation exists

### Step 4: Score and Report

## Discovery Commands

```bash
# Find infrastructure files
find . -name "*.tf" -o -name "*.yml" | grep -E "(infra|ansible|terraform|tofu)" | head -50

# Detect platforms
grep -rh "provider\s" *.tf 2>/dev/null | head -10
```

## Documentation Checklist

| Check | Required |
|-------|----------|
| README.md exists | Yes |
| Architecture diagram | For 3+ resources |
| Variable descriptions | All variables |
| Output descriptions | All outputs |
| Cost estimate | Yes |

## Scoring

| Dimension | 10 Points | 7 Points | 4 Points | 0 Points |
|-----------|-----------|----------|----------|----------|
| Best Practices | Current patterns | Minor gaps | Outdated | Deprecated |
| Platform | All checks pass | 1-2 issues | Missing patterns | Wrong usage |
| Security | No issues | Low severity | Medium issues | Critical |
| Simplicity | ≤5 files, no modules | 6-10 files | 11-15 files | >15, deep nesting |
| Maintainability | Clean, documented | Minor issues | Multiple issues | Unmaintainable |
| Documentation | Complete | README only | Partial | None |

## Verdict Thresholds

| Score | Verdict | Action |
|-------|---------|--------|
| 50-60 | SHIP | Ready for production |
| 35-49 | REVIEW | Fix warnings first |
| 20-34 | BLOCK | Fix critical issues |
| 0-19 | REWRITE | Fundamental issues |

## Report Format

```markdown
# DevOps Verification Report

**Platforms:** [detected]
**Date:** [YYYY-MM-DD]

## Summary

| Dimension | Score | Status |
|-----------|-------|--------|
| Best Practices | X/10 | PASS/FAIL |
| Platform | X/10 | PASS/FAIL |
| Security | X/10 | PASS/FAIL |
| Simplicity | X/10 | PASS/FAIL |
| Maintainability | X/10 | PASS/FAIL |
| Documentation | X/10 | PASS/FAIL |

**Overall:** X/60 - SHIP/REVIEW/BLOCK

## Critical Issues
[List with code fixes]

## Warnings
[List with recommendations]
```
