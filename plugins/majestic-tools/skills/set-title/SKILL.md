---
name: set-title
description: Set terminal window title to identify what the current session is working on. Use from workflows like build-task to display the active task.
allowed-tools: Bash
---

Set the terminal window title using ANSI escape sequences.

## Execution

Run this Bash command immediately with the provided title:

```bash
printf '\033]0;<TITLE>\007'
```

Replace `<TITLE>` with the title provided by the user.

## Title Guidelines

- Keep titles concise (under 60 characters)
- Use format: `emoji #issue-number: short-description`
- Examples:
  - `🔨 #42: Add user authentication`
  - `🚀 Shipping: PR #156`
  - `📝 Planning: API redesign`

## After Setting

Confirm with a brief message:
```
Terminal title set: <title>
```
