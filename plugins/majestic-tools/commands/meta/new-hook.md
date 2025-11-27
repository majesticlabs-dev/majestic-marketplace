---
description: Create and configure Claude Code hooks for automating workflows and behavior control
allowed-tools: Read, Edit, Write, Bash, WebFetch
model: opus
---

# New Hook Builder `/new-hook`

Create and configure Claude Code hooks for automating workflows, notifications, formatting, and behavior control.

## Arguments

- `[hook-description]` - Description of the hook you want to create

## Example Usage

```bash
# Create a logging hook
/new-hook "log all bash commands to a file"

# Create a protection hook
/new-hook "prevent editing .env files"

# Create a formatting hook
/new-hook "auto-format TypeScript files after editing"

# Create a notification hook
/new-hook "send desktop notification when Claude needs input"
```

## Hook Events Overview

Claude Code provides these hook events:

- **PreToolUse**: Runs before tool calls (can block them with exit codes)
- **PostToolUse**: Runs after tool calls complete
- **UserPromptSubmit**: Runs when user submits a prompt, before Claude processes it
- **Notification**: Runs when Claude Code sends notifications
- **Stop**: Runs when Claude Code finishes responding
- **SubagentStop**: Runs when subagent tasks complete
- **PreCompact**: Runs before Claude Code runs a compact operation
- **SessionStart**: Runs when Claude Code starts/resumes a session

## Documentation References

For comprehensive information, refer to:
- [Claude Code Hooks Guide](https://docs.anthropic.com/en/docs/claude-code/hooks-guide) - Complete documentation and examples
- [Claude Code Hooks Reference](https://docs.anthropic.com/en/docs/claude-code/hooks) - Technical reference and API details

## Instructions

When creating hooks, follow these steps:

1. **Analyze Requirements**: Understand what the user wants to automate or control
2. **Select Hook Event**: Choose the appropriate event type based on when the action should occur
3. **Design Matcher**: Create matcher patterns to target specific tools (use `*` for all tools)
4. **Write Hook Command**: Create the shell command that will execute
5. **Consider Security**: Review security implications and add safeguards
6. **Choose Storage Location**: Decide between user settings (global) or project settings (local)
7. **Generate Configuration**: Create proper JSON configuration
8. **Test Hook**: Verify the hook works as expected

## Common Hook Patterns

**Tool Matchers:**
- `Bash` - Shell commands only
- `Edit|MultiEdit|Write` - File editing operations
- `Read` - File reading operations
- `*` - All tools

**Exit Codes (PreToolUse only):**
- `0` - Allow tool execution
- `2` - Block tool execution with feedback
- Other non-zero - Block silently

## Security Considerations

⚠️ **CRITICAL**: Hooks run automatically with your environment's credentials. Always:
- Review hook commands before registering
- Validate file paths and inputs
- Use absolute paths when possible
- Avoid executing untrusted code
- Test hooks in safe environments first

## Configuration Format

Hooks are stored in JSON format in `~/.claude/settings.json` (user) or `<project>/.claude/settings.json` (project):

```json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<tool-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell-command>"
          }
        ]
      }
    ]
  }
}
```

## Common Examples

**Command Logging (PreToolUse):**
```bash
jq -r '"\(.tool_input.command) - \(.tool_input.description // "No description")"' >> ~/.claude/command-log.txt
```

**Code Formatting (PostToolUse):**
```bash
jq -r '.tool_input.file_path' | { read file_path; if echo "$file_path" | grep -q '\.ts$'; then npx prettier --write "$file_path"; fi; }
```

**File Protection (PreToolUse):**
```bash
python3 -c "import json, sys; data=json.load(sys.stdin); path=data.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(p in path for p in ['.env', 'package-lock.json', '.git/']) else 0)"
```

**Desktop Notifications (Notification):**
```bash
notify-send 'Claude Code' 'Awaiting your input'
```

## Best Practices

- Start with simple hooks and iterate
- Use descriptive matcher patterns
- Include error handling in hook commands
- Test hooks thoroughly before deployment
- Document complex hook logic
- Use project settings for team-shared hooks
- Use user settings for personal preferences
- Monitor hook performance and logs
- Keep hook commands concise and focused

## Response Format

After creating a hook, provide:
1. **Hook Configuration**: Complete JSON configuration
2. **Installation Instructions**: Where to add the configuration
3. **Testing Steps**: How to verify the hook works
4. **Security Review**: Any security considerations
5. **Usage Examples**: How the hook will behave in practice

Always explain the hook's purpose, when it triggers, and what it accomplishes.

## Additional Resources

- Use the `/hooks` slash command in Claude Code to configure hooks interactively
- Check existing hook configurations in `~/.claude/settings.json` or `<project>/.claude/settings.json`
- Reference the [official Claude Code hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks-guide) for the latest examples and best practices
