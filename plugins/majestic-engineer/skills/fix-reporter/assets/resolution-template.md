---
module: [Module name or "System" for system-wide]
date: [YYYY-MM-DD]
problem_type: [build_error|test_failure|runtime_error|performance_issue|database_issue|security_issue|ui_bug|integration_issue|logic_error|developer_experience|workflow_issue|best_practice|documentation_gap]
component: [model|controller|view|service|worker|database|frontend|api|auth|config|test|cli|documentation|infrastructure]
symptoms:
  - [Observable symptom 1 - specific error message or behavior]
  - [Observable symptom 2 - what user actually saw/experienced]
root_cause: [missing_dependency|missing_eager_load|missing_index|wrong_api_usage|scope_issue|concurrency_issue|async_timing|memory_leak|config_error|logic_error|test_isolation|missing_validation|missing_permission|missing_workflow_step|inadequate_documentation|missing_tooling|incomplete_setup|type_error|null_reference]
framework_version: [e.g., Rails 7.1.2, Next.js 14.0 - optional]
resolution_type: [code_fix|migration|config_change|test_fix|dependency_update|environment_setup|workflow_improvement|documentation_update|tooling_addition]
severity: [critical|high|medium|low]
tags: [keyword1, keyword2, keyword3]
---

# Troubleshooting: [Clear Problem Title]

## Problem
[1-2 sentence clear description of the issue and what the user experienced]

## Environment
- Module: [Name or "System-wide"]
- Framework Version: [e.g., Rails 7.1.2, Node 20.0]
- Affected Component: [e.g., "User model", "Auth service", "API controller"]
- Date: [YYYY-MM-DD when this was solved]

## Symptoms
- [Observable symptom 1 - what the user saw/experienced]
- [Observable symptom 2 - error messages, visual issues, unexpected behavior]
- [Continue as needed - be specific]

## What Didn't Work

**Attempted Solution 1:** [Description of what was tried]
- **Why it failed:** [Technical reason this didn't solve the problem]

**Attempted Solution 2:** [Description of second attempt]
- **Why it failed:** [Technical reason]

[Continue for all significant attempts that DIDN'T work]

[If nothing else was attempted first, write:]
**Direct solution:** The problem was identified and fixed on the first attempt.

## Solution

[The actual fix that worked - provide specific details]

**Code changes** (if applicable):
```[language]
# Before (broken):
[Show the problematic code]

# After (fixed):
[Show the corrected code with explanation]
```

**Database migration** (if applicable):
```[language]
# Migration change:
[Show what was changed in the migration]
```

**Commands run** (if applicable):
```bash
# Steps taken to fix:
[Commands or actions]
```

## Why This Works

[Technical explanation of:]
1. What was the ROOT CAUSE of the problem?
2. Why does the solution address this root cause?
3. What was the underlying issue (API misuse, configuration error, version issue, etc.)?

[Be detailed enough that future developers understand the "why", not just the "what"]

## Prevention

[How to avoid this problem in future development:]
- [Specific coding practice, check, or pattern to follow]
- [What to watch out for]
- [How to catch this early]

## Related Issues

[If any similar problems exist in docs/solutions/, link to them:]
- See also: [another-related-issue.md](../category/another-related-issue.md)
- Similar to: [related-problem.md](../category/related-problem.md)

[If no related issues, write:]
No related issues documented yet.
