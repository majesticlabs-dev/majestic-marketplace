---
name: majestic:debug
description: Debug errors, test failures, or unexpected behavior. Auto-detects project type.
argument-hint: "[error message or description]"
---

# Debug Command

## Bug Description

<bug_description>$ARGUMENTS</bug_description>

**If the bug description above is empty**, ask the user: "What error or issue are you experiencing? Please paste the error message or describe the unexpected behavior."

Do not proceed until you have a clear bug description.

## Project Context Detection

**Step 1: Check AGENTS.md first**

Look for `AGENTS.md` in the project root. This file is the authoritative source for:
- Project type and stack
- Debugging workflows
- Testing commands
- Project-specific conventions

If AGENTS.md exists and contains debugging guidance, follow those instructions.

**Step 2: Fall back to file-based detection only if needed**

If AGENTS.md is missing or lacks debugging context, detect project type from files:

```bash
ls Gemfile package.json pyproject.toml setup.py go.mod Cargo.toml 2>/dev/null
```

| File Found | Project Type | Debugger |
|------------|--------------|----------|
| Gemfile | Ruby/Rails | `agent rails-debugger` |
| package.json | Node.js | General debugging |
| pyproject.toml / setup.py | Python | General debugging |
| go.mod | Go | General debugging |
| Cargo.toml | Rust | General debugging |

## Workflow

### For Rails Projects (from AGENTS.md or Gemfile detected)

Invoke the specialized Rails debugger agent:

```
agent rails-debugger "<bug_description>"
```

The rails-debugger will:
- Analyze stack traces and error messages
- Check recent git changes
- Inspect logs and database state
- Identify root cause and propose fixes

### For Other Projects

1. **Analyze the error message** - Parse for error types, file paths, line numbers
2. **Check recent changes** - `git log --oneline -10` and `git diff HEAD~3`
3. **Search for solutions** - Use web-research agent if needed
4. **Propose fix** - Provide minimal code changes to resolve

## Output Format

After debugging, provide:

1. **Root Cause** - What's actually wrong (explain *why*, not just *what*)
2. **Evidence** - Specific logs, traces, or code proving the cause
3. **Fix** - Minimal code changes to resolve the issue
4. **Verification** - Commands or tests to confirm the fix works
