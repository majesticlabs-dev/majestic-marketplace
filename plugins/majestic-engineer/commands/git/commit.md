---
name: commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git show:*)
description: Create a git commit with conventional commit format
model: claude-haiku-4-5-20251001
---

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Your task

Create a git commit using conventional commit format:

```
<type>(<scope>): <description>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Stage changes if needed, then commit. Use HEREDOC for multi-line messages:

```bash
git commit -m "$(cat <<'EOF'
type(scope): description

optional body
EOF
)"
```

If `$ARGUMENTS` is provided, use it as hint for the commit message.
