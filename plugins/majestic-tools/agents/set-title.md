---
name: mj:set-title
description: Set terminal window title to identify what the current session is working on. Use from workflows like build-task to display the active task.
tools: Bash
---

Set the terminal window title using ANSI escape sequences. This helps developers identify what each Claude Code session is working on when managing multiple terminals.

## Input

You will receive a title string to display in the terminal window.

## Execution

1. **Check for custom prefix** (optional):
   - If `CLAUDE_TITLE_PREFIX` environment variable is set, prepend it to the title

2. **Set the title** using ANSI OSC escape sequence:

```bash
# Without prefix
printf '\033]0;%s\007' "Your Title Here"

# With prefix (if CLAUDE_TITLE_PREFIX is set)
printf '\033]0;%s\007' "${CLAUDE_TITLE_PREFIX} | Your Title Here"
```

## Implementation

```bash
# Check for prefix and set title
if [ -n "$CLAUDE_TITLE_PREFIX" ]; then
  printf '\033]0;%s | %s\007' "$CLAUDE_TITLE_PREFIX" "<TITLE>"
else
  printf '\033]0;%s\007' "<TITLE>"
fi
```

## Title Guidelines

- Keep titles concise (under 60 characters)
- Use format: `emoji #issue-number: short-description`
- Examples:
  - `🔨 #42: Add user authentication`
  - `🚀 Shipping: PR #156`
  - `📝 Planning: API redesign`
  - `🔍 Review: Database migrations`

## Terminal Compatibility

This uses the standard OSC 0 escape sequence which works with:
- iTerm2
- Ghostty
- Alacritty
- Kitty
- GNOME Terminal
- Windows Terminal (WSL)
- Most xterm-compatible terminals

## Example Usage

When called with: `Set title to "🔨 #42: Add user authentication"`

Execute:
```bash
if [ -n "$CLAUDE_TITLE_PREFIX" ]; then
  printf '\033]0;%s | %s\007' "$CLAUDE_TITLE_PREFIX" "🔨 #42: Add user authentication"
else
  printf '\033]0;%s\007' "🔨 #42: Add user authentication"
fi
```

## Response

After setting the title, confirm with:
```
Terminal title set: <title>
```
