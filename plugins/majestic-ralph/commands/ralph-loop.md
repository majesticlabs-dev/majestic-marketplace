---
name: majestic-ralph:start
description: Start Ralph Loop in current session
argument-hint: '"<prompt>" [--max-iterations N] [--completion-promise "<text>"]'
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh:*)
hide-from-slash-command-tool: true
---

# Ralph Loop

Start an autonomous iteration loop that re-feeds the same prompt until completion.

## Input

<arguments> $ARGUMENTS </arguments>

**Format:** `"<prompt>" [--max-iterations N] [--completion-promise "<text>"]`

## How It Works

1. **Task Iteration:** You work on the provided task, tracked in files and git history
2. **Loop Continuation:** When you try to exit, Ralph re-feeds the **same prompt** back to you
3. **Learnings Compound:** Each iteration sees previous work via modified files and git history
4. **Completion Promise:** Output the promise text ONLY when genuinely complete

## Execute Setup

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" $ARGUMENTS
```

## Critical Rules

**Completion Promise Integrity:**
- You may ONLY output `<promise>YOUR_PHRASE</promise>` when the statement is **completely and unequivocally TRUE**
- Do NOT output false promises to escape the loop, even if stuck
- The loop is designed to continue until genuine completion

**State File:**
- Location: `.claude/ralph-loop.local.md`
- Contains iteration count, max iterations, completion promise, and prompt
- Check progress: `grep '^iteration:' .claude/ralph-loop.local.md`

## Examples

```bash
# Basic autonomous loop
/ralph "Build a REST API for todos with CRUD, validation, and tests. Output <promise>COMPLETE</promise> when done."

# With iteration limit
/ralph "Implement feature X" --max-iterations 20 --completion-promise "DONE"

# Blueprint execution
/ralph "/majestic:run-blueprint docs/plans/add-auth.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## Monitoring

```bash
# Check current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# Watch progress
tail -f .claude/ralph-loop.local.md
```

## Safety

- Always use `--max-iterations` as a safeguard
- Include fallback instructions in prompts for stuck scenarios
- Use `/cancel-ralph` to stop the loop manually
