---
name: pr-comment-resolver
description: Address PR review comments by implementing reviewer feedback and suggestions.
allowed-tools: Read Write Edit Grep Glob Bash
---

# PR Comment Resolver

**Audience:** Developers with PR review comments that need resolution.

**Goal:** Understand reviewer feedback, implement changes, verify fixes.

## PR Comment Commands

```bash
# List all PR comments
gh pr view <PR_NUMBER> --comments

# Get review comments on files
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# Get specific review details
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews
```

## Comment Types

| Type | Indicators | Action |
|------|------------|--------|
| Bug fix | "This will break...", "Missing check..." | Implement the fix |
| Refactor | "Extract this...", "This is too complex..." | Apply the pattern |
| Style | "Rename to...", "Format as..." | Adjust naming/format |
| Tests | "Add test for...", "Missing coverage..." | Add test cases |
| Docs | "Add comment...", "Document this..." | Add documentation |
| Questions | "Why...?", "What about...?" | Reply with explanation |

## Workflow

1. **Read** - Get comment content and context
2. **Locate** - Find the code being discussed
3. **Understand** - Note constraints/preferences
4. **Implement** - Make requested changes
5. **Verify** - Run tests if code changed
6. **Report** - Summarize resolution

## Implementation Principles

- Address the specific feedback
- Maintain existing code style
- Don't break other functionality
- Follow project conventions
- Ask if feedback is ambiguous

## Resolution Report

```
PR Comment Resolution

Comment: "[Quote or summary of feedback]"
   Location: `file:line`

Changes:
- `path/to/file`: [Change description]
- `path/to/test`: [Test updates if any]

Resolution:
[How changes address the feedback]

Verified:
- [Tests run, if applicable]

Notes:
[Any context for reviewer]
```

## Example Resolutions

### Refactoring Request

```
PR Comment Resolution

Comment: "This function is too complex, please extract validation"
   Location: `app/services/order.py:45`

Changes:
- `app/services/order.py`: Extracted to `_validate_items()`
- `tests/test_order.py`: Added tests for new method

Resolution:
Split 25-line method into two focused functions with single responsibility.

Verified:
- `pytest tests/test_order.py` - all passing
```

### Missing Test Coverage

```
PR Comment Resolution

Comment: "Add test for the edge case when list is empty"
   Location: `src/utils/helpers.ts:23`

Changes:
- `tests/utils/helpers.test.ts`: Added empty array test case

Resolution:
Added test that verifies graceful handling of empty input.

Verified:
- `npm test -- helpers` - all passing
```

## When Blocked

If comment is unclear or conflicting:
1. State your interpretation
2. Explain any constraints
3. Suggest alternatives if needed
4. Ask for clarification
