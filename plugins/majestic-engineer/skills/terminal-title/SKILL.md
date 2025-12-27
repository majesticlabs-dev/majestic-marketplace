---
name: terminal-title
description: Set terminal window title. Invoke with args containing the title text.
argument-hint: "<title>"
allowed-tools: Bash
---

# Terminal Title

Set terminal window title to show what you're working on.

## Arguments

`$ARGUMENTS` = the title text to display

## Execution

Run this command via Bash tool:

```bash
echo -ne "\033]0;$ARGUMENTS\007"
```
