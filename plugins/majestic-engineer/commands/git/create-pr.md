---
name: create-pr
allowed-tools: Bash(git *), Bash(gh *), Task
description: Create a pull request for the current feature branch
model: haiku
---

## Context

**Get project config:** Invoke `config-reader` agent with `field: default_branch, default: main`

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Pending changes: !`git diff --stat`
- Recent commits: !`git log --oneline -5`

## Your task
Create a pull request for the current feature branch. Follow these steps:

1. **Analyze the current state**:
   - Check if there are uncommitted changes that need to be committed first
   - Verify the current branch is different from the default branch (shown in Context)
   - Review all commits that will be included in the PR

2. **Push branch if needed**:
   - Check if current branch tracks a remote branch
   - Push with `-u` flag if this is the first push: `git push -u origin <branch-name>`

3. **Create pull request** using GitHub CLI:
   ```bash
   gh pr create --title "Clear descriptive title" --body "$(cat <<'EOF'
   ## Summary
   • Brief bullet point of key changes
   • Main features/fixes implemented
   • Any breaking changes or important notes

   ## Test plan
   - [ ] Unit tests pass (`rails test`)
   - [ ] Manual testing completed
   - [ ] [Add specific test scenarios for this PR]
   EOF
   )"
   ```

## Arguments
- Use `$ARGUMENTS` for additional context or PR title/description
- Example: `/pr Fix R2 storage issue` will customize the PR title

## Expected Output
- Confirmation that branch was pushed (if needed)
- Pull request URL for easy access
- Summary of what was included in the PR
