---
name: majestic-ralph:start
description: Start Ralph Loop in current session
argument-hint: '"<prompt>" [--max-iterations N] [--completion-promise "<text>"]'
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh:*)
hide-from-slash-command-tool: true
---

# Ralph Loop

## Input

```
<arguments> $ARGUMENTS </arguments>
Format: "<prompt>" [--max-iterations N] [--completion-promise "<text>"]
```

## Execute

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" $ARGUMENTS
```

## Rules

```
ONLY output <promise>PHRASE</promise> when statement is TRUE
NEVER output false promise to escape loop
State file: .claude/ralph-loop.local.yml
Cancel: /cancel-ralph
```
