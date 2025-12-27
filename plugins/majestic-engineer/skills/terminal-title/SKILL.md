---
name: terminal-title
description: Set terminal window title using inline execution. Pattern for commands.
---

# Terminal Title

Set terminal window title to show what you're working on.

## Pattern

Use `!` backtick notation in commands:

```markdown
**Set terminal title:** !`echo -ne "\033]0;<title>\007"`
```

The `!` prefix executes directly in terminal with TTY access.

## Usage

| Command | When | Title |
|---------|------|-------|
| build-task | After fetch | `#42: Add auth` |
| plan | Start research | `Add user auth` |

## Script (Optional)

`scripts/set_title.sh` for shell hook integration.
