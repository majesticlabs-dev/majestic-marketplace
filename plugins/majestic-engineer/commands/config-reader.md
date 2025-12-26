---
name: majestic:config
description: Get a config value from .agents.yml (with local overrides)
argument-hint: "<field> [default]"
allowed-tools: Bash
---

# Config Reader

Get a config value from `.agents.yml` with `.agents.local.yml` overrides.

## Arguments

`$ARGUMENTS` = `<field> [default]`

## Execute

```bash
bash -c '
FIELD="$1"
DEFAULT="${2:-}"
value=""
[[ -f .agents.local.yml ]] && value=$(grep -m1 "^${FIELD}:" .agents.local.yml 2>/dev/null | cut -d: -f2- | sed "s/^ *//")
[[ -z "$value" && -f .agents.yml ]] && value=$(grep -m1 "^${FIELD}:" .agents.yml 2>/dev/null | cut -d: -f2- | sed "s/^ *//")
echo "${value:-$DEFAULT}"
' -- $ARGUMENTS
```

Report the value to the user.
