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

Based on `problem_type`, documentation is filed in:

- **build_error** → `docs/solutions/build-errors/`
- **test_failure** → `docs/solutions/test-failures/`
- **runtime_error** → `docs/solutions/runtime-errors/`
- **performance_issue** → `docs/solutions/performance-issues/`
- **database_issue** → `docs/solutions/database-issues/`
- **security_issue** → `docs/solutions/security-issues/`
- **ui_bug** → `docs/solutions/ui-bugs/`
- **integration_issue** → `docs/solutions/integration-issues/`
- **logic_error** → `docs/solutions/logic-errors/`
- **developer_experience** → `docs/solutions/developer-experience/`
- **workflow_issue** → `docs/solutions/workflow-issues/`
- **best_practice** → `docs/solutions/best-practices/`
- **documentation_gap** → `docs/solutions/documentation-gaps/`
