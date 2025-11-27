---
allowed-tools: Bash(gh *), Bash(git *), Read, Edit, MultiEdit, Write
description: Review and address Pull Request comments from GitHub
---

## Context
- Pull Request details: !`gh pr view $ARGUMENTS --json number,title,body,state,author`
- PR comments and reviews: !`gh pr view $ARGUMENTS --json reviews,comments`
- Current git status: !`git status`
- Current branch: !`git branch --show-current`

## Your task
Review and address Pull Request comments for PR #$ARGUMENTS. Follow these steps:

1. **Analyze the PR comments**:
   - Review all comments from the PR reviews and general comments
   - Categorize comments by priority:
     - **Must Fix**: Critical issues (security, bugs, breaking changes)
     - **Should Fix**: Important issues (code quality, best practices)
     - **Nice to Have**: Suggestions for improvement (style, minor optimizations)

2. **Address comments in priority order**:
   - Start with Must Fix items
   - Then Should Fix items
   - Finally Nice to Have items (if time permits)

3. **For each comment addressed**:
   - Use appropriate tools (Read, Edit, MultiEdit, Write) to make changes
   - Provide brief explanation of the fix
   - If skipping a comment, explain why

4. **Create commit with changes**:
   - Stage all changes: `git add .`
   - Create descriptive commit message addressing the feedback
   - Commit: `git commit -m "Address PR feedback: [summary of changes]"`

5. **Push and verify**:
   - Push changes: `git push`
   - Check CI status: `gh run list --limit 1 --json conclusion --jq '.[].conclusion'`

## Arguments
- `$ARGUMENTS` should be the PR number (e.g., `/project:pr-review 123`)

## Expected Output
Provide a summary in this format:

```markdown
## PR Review Summary

### Comments Addressed
- [List of comments that were fixed with brief explanation]

### Comments Skipped
- [List of comments not addressed with reasons]

### Changes Made
- [Summary of code changes]

### CI Status
- [Result of CI check]
```

## Example Usage
```bash
/pr-review 123
```
This will review and address comments for PR #123.
