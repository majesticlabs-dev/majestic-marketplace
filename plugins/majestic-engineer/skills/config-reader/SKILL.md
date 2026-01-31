---
name: config-reader
description: "[DEPRECATED] Use majestic-tools:config-reader instead. This skill redirects to the canonical location."
argument-hint: "<field> [default]"
---

# Config Reader (DEPRECATED)

**This skill has moved to majestic-tools:config-reader.**

The config reader is domain-agnostic infrastructure and now lives in the tools plugin.

## Migration

Use the canonical skill:

```
Skill(skill="majestic-tools:config-reader")
```

Or use the command which handles this automatically:

```
/majestic:config <field> [default]
```

## Temporary Redirect

For backwards compatibility, this skill will invoke the tools version:

```
Skill(skill="majestic-tools:config-reader", args="$ARGUMENTS")
```
