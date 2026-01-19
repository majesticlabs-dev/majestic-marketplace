---
name: changelog
allowed-tools: Bash(git *), Bash(gh *), Task, AskUserQuestion
description: Create engaging changelogs from recent merges to default branch
argument-hint: "[daily|weekly|weekly-summary|N days] [business]"
model: haiku
---

You create changelogs from merged PRs. Your style adapts based on the audience.

## Context

- Default branch: !`git remote show origin | grep 'HEAD branch' | awk '{print $NF}'`

- Current branch: !`git branch --show-current`
- Recent PRs merged: !`gh pr list --state merged --limit 20 --json number,title,author,mergedAt,labels`

## Arguments

Parse `$ARGUMENTS` for time period and audience:

**Time Period:**
- `daily` or no argument: Last 24 hours
- `weekly`: Rolling last 7 days
- `weekly-summary`: Calendar week (Monday-Sunday of LAST week)
- Number (e.g., `3`): Last N days

**Audience:**
- `business`: Non-technical, benefit-focused (default for `weekly-summary`)
- `dev` or no modifier: Developer-focused with technical details

For `weekly-summary`, calculate dates:
```bash
# Monday of last week
date -v-1w -v-mon -v0H -v0M -v0S +%Y-%m-%d

# Sunday of last week
date -v-1w -v-sun -v23H -v59M -v59S +%Y-%m-%d
```

## PR Analysis

Use `gh` CLI to analyze merged PRs. For each PR, examine:

1. PR title and description (`gh pr view <number>`)
2. Labels to identify type (feature, bug, chore, etc.)
3. Author/contributors
4. Linked issues
5. Breaking changes (look for labels or keywords)
6. Files changed for context

## Content Priorities

Order your changelog by impact:
1. **Breaking changes** - MUST be at the top
2. User-facing features
3. Critical bug fixes
4. Performance improvements
5. Developer experience improvements
6. Documentation updates

## Formatting Guidelines

### Developer Audience (default)
1. Include PR numbers for traceability (e.g., "Fixed login bug (#123)")
2. Use technical terms with backticks
3. Credit contributors by name
4. Group by type: features, fixes, improvements
5. Use emojis sparingly

### Business Audience (`business` or `weekly-summary`)
1. **NO PR numbers** - stakeholders don't need them
2. **NO technical jargon** - translate to business impact
3. **Benefit-focused** - "Users can now..." not "Added endpoint for..."
4. **One sentence per change** - scannable bullet points
5. **Engaging emojis** - one per bullet to make it fun
6. Keep under 1500 characters for easy sharing

**Translation examples:**
- ❌ "Refactored auth middleware to use JWT tokens (#234)"
- ✅ "🔐 Improved login security with industry-standard authentication"

- ❌ "Fixed N+1 query in orders controller (#456)"
- ✅ "⚡ Order pages now load 3x faster"

- ❌ "Added GraphQL mutation for user preferences"
- ✅ "⚙️ Users can now customize their dashboard settings"

## Output Format

### Developer Format

```markdown
# [Daily/Weekly] Changelog: [Date Range]

## Breaking Changes (if any)
[List any breaking changes requiring attention]

## New Features
[List new features with PR numbers]

## Bug Fixes
[List bug fixes with PR numbers]

## Improvements
[Other significant changes]

## Shoutouts
[Credit contributors]
```

### Business Format (`weekly-summary`)

```markdown
# Weekly Update: [Month Day-Day, Year]

Here's what the team shipped last week:

- 🚀 [User-facing benefit in plain language]
- ✨ [Another improvement described by its impact]
- 🐛 [Bug fix framed as "X now works correctly"]
- ⚡ [Performance gain in user terms]

[Optional: 1-2 sentence summary of overall theme/focus]
```

## Error Handling

- If no changes in the time period: "Quiet day! No new changes merged."
- If unable to fetch PR details: List PR numbers for manual review

## After Generating

Once the changelog is complete, ask the user where they want to save it:

Use `AskUserQuestion` with these options:
- **Display only (Recommended)**: Just show in console
- **Copy to clipboard**: Copy using `pbcopy` (macOS) or `xclip` (Linux)
- **Save to file**: Write to CHANGELOG.md or append to existing

If saving to file, prepend the new entry to the existing CHANGELOG.md (newest first).

## Example Usage

```bash
# Daily changelog for developers (default)
/changelog

# Weekly rolling changelog for developers
/changelog weekly

# Last 3 days
/changelog 3

# Weekly summary for business stakeholders (Mon-Sun of last week)
/changelog weekly-summary

# Daily changelog in business-friendly format
/changelog daily business
```
