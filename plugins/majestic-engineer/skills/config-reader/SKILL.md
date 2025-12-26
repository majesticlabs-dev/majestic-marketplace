---
name: config-reader
description: Read project config from .agents.yml and .agents.local.yml with local overrides. Use when checking config values like auto_preview, tech_stack, task_management. Invoke with args "<field> <default>".
argument-hint: "<field> [default]"
---

# Config Reader

Read and merge `.agents.yml` and `.agents.local.yml` configuration files. Local config overrides base config.

## Arguments

`$ARGUMENTS` format: `<field> [default]`

Examples:
- `auto_preview false` - get auto_preview, default to "false"
- `tech_stack generic` - get tech_stack, default to "generic"
- `task_management` - get task_management, no default (empty if not found)

## Execution

Parse the arguments and run:

```bash
bash -c '
FIELD="$1"
DEFAULT="${2:-}"
value=""
[[ -f .agents.local.yml ]] && value=$(grep -m1 "^${FIELD}:" .agents.local.yml 2>/dev/null | cut -d: -f2- | sed "s/^ *//")
[[ -z "$value" && -f .agents.yml ]] && value=$(grep -m1 "^${FIELD}:" .agents.yml 2>/dev/null | cut -d: -f2- | sed "s/^ *//")
echo "${value:-$DEFAULT}"
' -- FIELD DEFAULT
```

Replace `FIELD` and `DEFAULT` with the parsed arguments.

## Return Value

Return ONLY the config value (single line):
- `true`
- `rails`
- `github`

## Merge Logic

1. **Local checked first** - `.agents.local.yml` wins if key exists
2. **Fall back to base** - `.agents.yml` if not in local
3. **Default** - provided default if neither has the key

## Common Fields

| Field | Description | Typical Default |
|-------|-------------|-----------------|
| `auto_preview` | Auto-open generated files | `false` |
| `auto_create_task` | Auto-create tasks from plans | `false` |
| `tech_stack` | Primary tech stack | `generic` |
| `task_management` | Task tracking backend | `none` |
| `workflow` | Git workflow style | `branches` |
| `default_branch` | Main branch name | `main` |
