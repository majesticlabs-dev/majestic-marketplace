---
allowed-tools: Bash(git *)
description: Create a git commit with proper message formatting
model: haiku
---

## Context
- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`
- Recent commits: !`git log --oneline -5`

## Your task
Create a well-formatted git commit with appropriate staging and commit message. Follow these steps:

1. **Analyze current changes**:
   - Review staged and unstaged changes from context
   - Identify the scope and type of changes made
   - Determine if additional files need to be staged

2. **Stage files if needed**:
   - If no files are staged: `git add .` or selectively stage files
   - If only specific files should be committed: `git add <specific-files>`
   - Verify staging: `git status`

3. **Generate commit message**:
   Follow conventional commit format:
   ```
   <type>(<scope>): <description>

   <body (optional)>
   ```

   **Types:**
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `style`: Code style changes (formatting, semicolons, etc.)
   - `refactor`: Code refactoring
   - `test`: Adding or updating tests
   - `chore`: Build process or auxiliary tool changes

4. **Create commit**:
   Use HEREDOC format for multi-line messages:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <optional body explaining what and why>
   EOF
   )"
   ```

5. **Verify commit**:
   - Show the created commit: `git show --stat`
   - Confirm commit is on correct branch

## Arguments
- `$ARGUMENTS` can specify commit type/scope or custom message
- Examples:
  - `fix R2 storage` → `fix(storage): resolve R2 attachment upload issue`
  - `feat email parser` → `feat(email): add robust email parsing with attachment support`
  - Custom message will be used as-is if it starts with conventional format

## Expected Output
```markdown
## Commit Created

### Changes Committed
- [Summary of files and changes included]

### Commit Message
```
<the actual commit message>
```

### Commit Hash
- `<commit-hash>` on branch `<branch-name>`

### Next Steps
- [Suggestions like running tests, creating PR, etc.]
```

## Example Usage
```bash
# Auto-generate commit message based on changes
/project:commit

# Specify type and scope
/project:commit fix email parser

# Custom commit message
/project:commit "feat(api): add new email endpoint for status checks"
```

## Commit Message Guidelines
- **Keep first line under 50 characters**
- **Use imperative mood** ("add" not "added" or "adds")
- **Include scope** when changes are focused on specific area
- **Add body** for complex changes explaining why not just what
- **Reference issues** if applicable (e.g., "Fixes #123")
- **NEVER** disclose your identity in commits! Never reveal it's a robot made commit or CLAUDE!
