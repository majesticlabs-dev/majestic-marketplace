# YAML Frontmatter Schema

**See `schema.yaml` for the complete schema specification.**

## Required Fields

- **module** (string): Module name (e.g., "User Service") or "System" for system-wide issues
- **date** (string): ISO 8601 date (YYYY-MM-DD)
- **problem_type** (enum): One of [build_error, test_failure, runtime_error, performance_issue, database_issue, security_issue, ui_bug, integration_issue, logic_error, developer_experience, workflow_issue, best_practice, documentation_gap]
- **component** (enum): One of [model, controller, view, service, worker, database, frontend, api, auth, config, test, cli, documentation, infrastructure]
- **symptoms** (array): 1-5 specific observable symptoms
- **root_cause** (enum): One of [missing_dependency, missing_eager_load, missing_index, wrong_api_usage, scope_issue, concurrency_issue, async_timing, memory_leak, config_error, logic_error, test_isolation, missing_validation, missing_permission, missing_workflow_step, inadequate_documentation, missing_tooling, incomplete_setup, type_error, null_reference]
- **resolution_type** (enum): One of [code_fix, migration, config_change, test_fix, dependency_update, environment_setup, workflow_improvement, documentation_update, tooling_addition]
- **severity** (enum): One of [critical, high, medium, low]

## Optional Fields

- **framework_version** (string): Framework version (e.g., "Rails 7.1.0", "Next.js 14.0")
- **tags** (array): Searchable keywords (lowercase, hyphen-separated)

### Learnings Discovery Fields (Optional)

These fields enable automatic discovery by the lessons-discoverer agent:

- **lesson_type** (enum): One of [antipattern, gotcha, pattern, setup, workflow]
  - `antipattern`: "Never do X because Y"
  - `gotcha`: "Watch out for X in context Y"
  - `pattern`: "When doing X, follow pattern Y"
  - `setup`: "Missing setup/config step"
  - `workflow`: "Process or workflow improvement"

- **workflow_phase** (array): When should this lesson surface? One or more of [planning, debugging, review, implementation]
  - `planning`: Before architecture design in /blueprint
  - `debugging`: During /debug initialization
  - `review`: For quality-gate reviewers
  - `implementation`: During build-task coding

- **tech_stack** (array): Which stacks apply? (rails, python, react, node, generic). Defaults to [generic].

- **impact** (enum): One of [blocks_work, major_time_sink, minor_inconvenience]
  - Maps to severity for discovery prioritization

- **keywords** (array): Semantic keywords for task matching (e.g., "authentication", "oauth", "token")

## Validation Rules

1. All required fields must be present
2. Enum fields must match allowed values exactly (case-sensitive)
3. symptoms must be YAML array with 1-5 items
4. date must match YYYY-MM-DD format
5. tags should be lowercase, hyphen-separated

## Example

```yaml
module: User Service
date: 2025-11-12
problem_type: performance_issue
component: model
symptoms:
  - "N+1 query when loading user records"
  - "API response taking >5 seconds"
root_cause: missing_eager_load
framework_version: Rails 7.1.2
resolution_type: code_fix
severity: high
tags: [n-plus-one, eager-loading, performance]
```

## Category Mapping

Based on `problem_type`, documentation is filed in `lessons_path` (default: `.claude/lessons/`):

- **build_error** → `{lessons_path}/build-errors/`
- **test_failure** → `{lessons_path}/test-failures/`
- **runtime_error** → `{lessons_path}/runtime-errors/`
- **performance_issue** → `{lessons_path}/performance-issues/`
- **database_issue** → `{lessons_path}/database-issues/`
- **security_issue** → `{lessons_path}/security-issues/`
- **ui_bug** → `{lessons_path}/ui-bugs/`
- **integration_issue** → `{lessons_path}/integration-issues/`
- **logic_error** → `{lessons_path}/logic-errors/`
- **developer_experience** → `{lessons_path}/developer-experience/`
- **workflow_issue** → `{lessons_path}/workflow-issues/`
- **best_practice** → `{lessons_path}/best-practices/`
- **documentation_gap** → `{lessons_path}/documentation-gaps/`

**Configuration:**
```bash
# Read lessons_path from config (default: .claude/lessons/)
LESSONS_PATH=$(claude -p "/majestic:config lessons_path .claude/lessons/")
```
