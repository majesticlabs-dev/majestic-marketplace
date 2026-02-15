---
name: majestic-engineer:git:triage-prs
description: Triage all open PRs with parallel review agents, label, group, and walk through one-by-one for merge/comment/close decisions
argument-hint: "[optional: owner/repo or GitHub PRs URL]"
allowed-tools: Bash(gh *), Bash(git log *)
disable-model-invocation: true
---

## Context

- Current repo: !`gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "no repo detected"`
- Current branch: !`git branch --show-current 2>/dev/null`

If `$ARGUMENTS` contains a GitHub URL or `owner/repo`, use that instead. Confirm repo with user if ambiguous.

Set REPO = resolved owner/repo

## Step 1: Gather Context (Parallel)

Run in parallel:

```
PR_LIST = gh pr list --repo REPO --state open --limit 50
ISSUE_LIST = gh issue list --repo REPO --state open --limit 50
LABELS = gh label list --repo REPO --limit 50
RECENT_MERGES = git log --oneline -20 main
```

If PR_LIST is empty: report "No open PRs" → exit

## Step 2: Batch PRs by Theme

Group PRs into batches of 4-6 by type:

| Theme | Signal |
|-------|--------|
| Bug fixes | titles with `fix`, `bug`, error descriptions |
| Features | titles with `feat`, `add`, new functionality |
| Documentation | titles with `docs`, `readme` |
| Configuration | titles with `config`, `setup`, `install` |
| Stale | PRs older than 30 days |

## Step 3: Parallel Review (Agents)

For each BATCH in BATCHES:

```
Task(subagent_type: "general-purpose", model: "haiku", prompt: """
Review these PRs from REPO:

For each PR:
1. gh pr view --repo REPO <number> --json title,body,files,additions,deletions,author,createdAt
2. gh pr diff --repo REPO <number> | head -200

Determine for each:
- Description: 1-2 sentence summary
- Label: best-fit from LABELS
- Action: merge | request-changes | close | needs-discussion
- Related: PRs touching same files or feature
- Quality: code quality, test coverage, staleness concerns

Flag:
- PRs touching same files (merge conflict risk)
- PRs duplicating recently merged work
- PRs solving same problem differently

Return as markdown table:
| PR | Title | Author | Description | Label | Action | Flags |
""")
```

Collect all BATCH_RESULTS.

## Step 4: Cross-Reference Issues

Match issues to PRs:
- Check PR titles/bodies for `Fixes #X` or `Closes #X`
- Match issue titles to PR topics
- Identify duplicate issues

Build mapping:

```
| Issue | PR | Relationship |
|-------|-----|-------------|
| #N | #M | PR fixes issue |
```

## Step 5: Identify Themes

Group all issues into 3-6 themes:
- Count issues per theme
- Note themes with PRs addressing them vs. unaddressed
- Flag themes with competing/overlapping PRs

## Step 6: Compile Triage Report

Present single report:

```
## Triage Report: REPO

### Stats
X open PRs, Y open issues, Z themes

### PR Groups
[For each group: name, PRs with #, title, author, description, label, recommended action]

### Issue-to-PR Mapping
[Table from Step 4]

### Themes
[From Step 5]

### Suggested Cleanup
[Spam issues, duplicates, stale items]
```

## Step 7: Apply Labels

AskUserQuestion: "Apply these labels to all PRs on GitHub?"

If yes:
```
For each PR in LABELED_PRS:
  gh pr edit --repo REPO <number> --add-label "<label>"
```

## Step 8: One-by-One Review

AskUserQuestion: "Walk through PRs one-by-one for merge/comment decisions?"

If no: exit with report

Priority order: bug fixes → docs → features → config → stale

For each PR:

```
### PR #<number> - <title>
Author: <author> | Files: <count> | +<additions>/-<deletions> | <age>
Label: <label>

<description>

Fixes: <linked issues>
Related: <related PRs>
```

Show key diff sections (trimmed for large diffs).

AskUserQuestion with options:
- **Merge** — squash merge this PR
- **Comment & skip** — leave feedback, keep open
- **Close** — close with comment
- **Skip** — move to next

Execute decision:
- Merge: `gh pr merge --repo REPO <number> --squash`
  - If PR fixes an issue, close the issue too
- Comment: `gh pr comment --repo REPO <number> --body "<comment>"`
  - Ask user what to say, or generate constructive feedback
- Close: `gh pr close --repo REPO <number> --comment "<reason>"`
- Skip: proceed

Comments on declined PRs must be grateful and constructive.

## Step 9: Summary

After all PRs reviewed:

1. Close issues resolved by merged PRs
2. Close spam/duplicate issues (confirm with user first)
3. Report:

```
## Triage Complete

Merged: X PRs
Commented: Y PRs
Closed: Z PRs
Skipped: W PRs

Issues closed: A
Labels applied: B
```

## Step 10: Post-Triage

AskUserQuestion:
- **Generate changelog** — for merged PRs
- **Done** — wrap up

## Constraints

- NEVER merge without explicit user approval per PR
- NEVER force push or run destructive commands
- When PRs conflict, note this and suggest merge order
- When multiple PRs solve same problem, flag for user to pick one
