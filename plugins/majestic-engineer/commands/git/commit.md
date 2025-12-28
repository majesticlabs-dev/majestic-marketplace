---
name: commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git show:*), Read, Grep, Edit
description: Create a git commit with conventional commit format
model: sonnet
---

## Context

- Current git status: !`git status`
- Staged changes: !`git diff --cached`
- Unstaged changes: !`git diff`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5 2>/dev/null || echo "(no commits yet)"`

## Hooks

- Pre-commit prompt: !`claude -p "/majestic:config commit.pre_prompt ''"`
- Post-commit prompt: !`claude -p "/majestic:config commit.post_prompt ''"`

## Workflow

### Step 1: Pre-commit Hook

If pre-commit prompt is configured (non-empty):
1. Execute the prompt instructions against staged changes
2. Use Read/Grep to examine files as needed
3. Report any issues found (e.g., debug statements, TODOs)
4. Continue to commit (non-blocking)

### Step 2: Create Commit

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

### Step 3: Post-commit Hook

If commit succeeded AND post-commit prompt is configured (non-empty):
1. Execute the prompt instructions
2. Use Edit tool if updates are needed (e.g., CHANGELOG.md)
3. Report what was done
