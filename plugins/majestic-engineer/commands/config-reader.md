---
name: majestic:config
description: Get a config value from .agents.yml (with local overrides)
argument-hint: "<field> [default]"
allowed-tools: Bash, Skill
---

# Config Reader

Get a config value from `.agents.yml` with `.agents.local.yml` overrides.

## Arguments

`$ARGUMENTS` = `<field> [default]`

Supports dot notation for nested fields: `plan.auto_create_task`, `toolbox.build_task.design_system_path`

## Execute

Invoke the config-reader skill which provides the script and merge logic:

```
Skill(skill="config-reader")
```

Follow the skill's instructions to run the config reader script with `$ARGUMENTS`.

Report the value to the user.
