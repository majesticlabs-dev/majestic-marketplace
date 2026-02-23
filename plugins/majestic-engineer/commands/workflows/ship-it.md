---
name: majestic:ship-it
description: Complete checkout workflow - runs linting, creates commit, and opens PR
argument-hint: "[closes #issue]"
---

# Ship It!

Execute the complete code shipping workflow using the ship agent:

```
agent ship "$ARGUMENTS"
```

**Arguments:** Pass `closes #123` to link and auto-close a GitHub issue when merged.

This agent will:
1. **Detect project type and run linters** with auto-fix
2. **Create git commit** using `/commit` command
3. **Open pull request** using `/create-pr` command (with closes reference if provided)

The agent handles Ruby, JavaScript/TypeScript, and Python projects automatically.
