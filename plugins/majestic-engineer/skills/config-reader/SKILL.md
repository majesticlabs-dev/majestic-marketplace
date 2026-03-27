---
name: config-reader
description: "Read and merge .agents.yml with .agents.local.yml using dot-notation field lookup. Use when reading project config values, checking agent settings, or resolving config overrides."
---

# Config Reader

Read and merge `.agents.yml` and `.agents.local.yml` configuration files. Local config overrides base config.

**Requires:** yq (`brew install yq` or `snap install yq`)

## Arguments

`$ARGUMENTS` format: `FIELD [DEFAULT]`

- `auto_preview false` — top-level field, default "false"
- `plan.auto_create_task false` — nested field via dot notation
- `tech_stack generic` — top-level field, default "generic"
- `toolbox.build_task.design_system_path` — deeply nested field

## Execution

```bash
bash {baseDir}/scripts/config_reader.sh FIELD DEFAULT
```

Return ONLY the resolved value (single line, no decoration).

## Merge Logic

1. `.agents.local.yml` checked first — local wins if key exists
2. `.agents.yml` used as fallback
3. Provided default if neither file has the key

## Common Fields

| Field | Description | Typical Default |
|-------|-------------|-----------------|
| `auto_preview` | Auto-open markdown files | `false` |
| `plan.auto_create_task` | Auto-create tasks from plans | `false` |
| `tech_stack` | Primary tech stack | `generic` |
| `task_management` | Task tracking backend | `none` |
| `workflow` | Git workflow style | `branches` |
| `toolbox.build_task.design_system_path` | Design system location | (none) |
