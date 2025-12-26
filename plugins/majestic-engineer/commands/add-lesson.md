---
name: majestic:add-lesson
description: Add a custom lesson learned to your project's review topics file
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# Add Lesson

Add a custom lesson or convention to your project's review topics file for automated checking during code reviews.

## Context

- Review topics path: !`claude -p "/majestic:config review_topics_path ''"`

## Step 1: Find Topics File

Use "Review topics path" from Context above.

If empty:
- Default to `docs/agents/review-topics.md`
- Create the file and add config entry if it doesn't exist

## Step 2: Read Existing Categories

If the file exists, read it and extract existing category headers (lines starting with `###` or `##`).

## Step 3: Ask User for Input

Use `AskUserQuestion` to gather:

**Question 1: Category**
- Show existing categories as options (up to 3)
- Always include "Other" for new category

**Question 2: Topic Content**
- Ask: "What's the lesson or rule to add?"
- This will be a free-form "Other" response

Example:
```
Questions:
1. "Which category does this topic belong to?"
   Options based on existing categories + "New Category"

2. "What is the topic/lesson? (Be specific - include what to do or avoid)"
   Options: [Other only - free text input]
```

## Step 3b: New Category Name

If user selected "New Category", ask:
```
"What should the new category be named?"
Options: [Other only - free text input]
```

## Step 4: Add Topic

**If file doesn't exist**, create it:
```markdown
# Code Review Topics

Project-specific conventions and lessons learned.

### <Category>
- <Topic>
```

**If category exists**, append under it:
```markdown
### Existing Category
- Existing topic
- <New Topic>  ← Add here
```

**If new category**, append at end:
```markdown
### <New Category>
- <Topic>
```

## Step 5: Confirm

Show what was added:
```
Added to `<path>`:

### <Category>
- <Topic>
```

## Step 6: Ensure Config

If `review_topics_path` wasn't in `.agents.yml`, add it:
```bash
echo "review_topics_path: docs/agents/review-topics.md" >> "${AGENTS_CONFIG:-.agents.yml}"
```

Tell user: "Added `review_topics_path` to your config. Topics will be checked during code reviews."

## Example Flow

```
User: /majestic:add-lesson

Claude: [Reads .agents.yml, finds review_topics_path: docs/agents/review-topics.md]
Claude: [Reads file, finds categories: Security, Performance, API Conventions]
Claude: [AskUserQuestion]
  Q1: "Which category?" → Options: Security, Performance, API Conventions, New Category
  Q2: "What's the lesson?" → [Free text]

User:
  Q1: Security
  Q2: "Always sanitize user input before SQL interpolation"

Claude: [Edits docs/agents/review-topics.md, adds under ### Security]
Claude: "Added lesson to docs/agents/review-topics.md:

### Security
- Always sanitize user input before SQL interpolation

This will be checked during code reviews."
```