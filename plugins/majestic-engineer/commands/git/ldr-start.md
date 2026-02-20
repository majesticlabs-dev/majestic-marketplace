---
name: ldr-start
allowed-tools: Bash(git *), Bash(mkdir *), Bash(ls *), Read, Write, Glob
description: Start a Linked Decision Record — creates numbered branch, prompt, and blueprint files
argument-hint: "[short description of the feature or fix]"
model: haiku
disable-model-invocation: true
---

## Context

- Current branch: !`git branch --show-current`
- Default branch: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main"`
- Git user: !`git config user.name 2>/dev/null || echo "unknown"`
- Today: !`date +%Y-%m-%d`
- Existing prompts: !`ls docs/prompts/*.md 2>/dev/null | sort -t/ -k3 | tail -5 || echo "(none yet)"`

## Workflow

### Step 1: Parse Arguments

```
DESCRIPTION = $ARGUMENTS
If DESCRIPTION is empty:
  AskUserQuestion: "What feature or fix are you starting?"
```

### Step 2: Generate Sequence Number

```
EXISTING = Glob("docs/prompts/*.md")
If EXISTING is empty:
  NNN = "001"
Else:
  LAST = extract highest number from filenames (pattern: NNN-*.md)
  NNN = zero-pad(LAST + 1, 3)
```

### Step 3: Generate Slug

```
SLUG = DESCRIPTION
  → lowercase
  → replace spaces/special chars with hyphens
  → remove consecutive hyphens
  → truncate to 50 chars
  → trim trailing hyphens
```

### Step 4: Create Directories

```
Bash: mkdir -p docs/prompts docs/blueprints
```

### Step 5: Create Branch

```
DEFAULT_BRANCH = from Context above
Bash: git checkout <DEFAULT_BRANCH> && git pull origin <DEFAULT_BRANCH> 2>/dev/null; git checkout -b feature/{NNN}-{SLUG}
```

If branch already exists: checkout existing, warn user, continue.

### Step 6: Create Prompt File

Read template from `resources/ldr-start/prompt-template.txt`.

Replace placeholders:
- `{NNN}` → sequence number
- `{SLUG}` → generated slug
- `{DATE}` → today's date
- `{AUTHOR}` → git user name

Write to `docs/prompts/{NNN}-{SLUG}.md`.

### Step 7: Create Blueprint File

Read template from `resources/ldr-start/blueprint-template.txt`.

Replace same placeholders.

Write to `docs/blueprints/{NNN}-{SLUG}.md`.

### Step 8: Stage and Report

```
Bash: git add docs/prompts/{NNN}-{SLUG}.md docs/blueprints/{NNN}-{SLUG}.md
```

## Output

```
## LDR Created

**Number:** {NNN}
**Branch:** `feature/{NNN}-{SLUG}`
**Prompt:** `docs/prompts/{NNN}-{SLUG}.md`
**Blueprint:** `docs/blueprints/{NNN}-{SLUG}.md`

Next steps:
1. Fill in the prompt file with your problem statement
2. Fill in the blueprint with your implementation plan
3. Implement, commit with `feat:`/`fix:` prefix
4. `/create-pr` when ready
```

## Commit Prefix Reference

| Prefix | Use |
|--------|-----|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructuring |
| `docs:` | Documentation only |
| `test:` | Test additions/changes |
| `chore:` | Maintenance tasks |
