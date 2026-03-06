---
name: majestic:skill-optimize
description: Optimize a skill's description for better trigger accuracy. Generates eval queries, runs automated optimization loop with train/test split, and applies the best description. Use after creating or improving a skill.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[path/to/skill]"
disable-model-invocation: true
---

# Skill Description Optimizer

Optimize a skill's description for accurate triggering using automated eval loops.

## Input

```
SKILL_PATH = $ARGUMENTS
```

If empty: `AskUserQuestion("Which skill do you want to optimize? Provide the path.")`

## Workflow

### Step 1: Validate Skill

```
If not exists(SKILL_PATH/SKILL.md):
  ERROR "No SKILL.md found at SKILL_PATH"

SKILL_CONTENT = Read(SKILL_PATH/SKILL.md)
SKILL_NAME = extract name from frontmatter
CURRENT_DESCRIPTION = extract description from frontmatter
```

Show current description to user.

### Step 2: Generate Trigger Eval Queries

Create 20 eval queries — mix of should-trigger (8-10) and should-not-trigger (8-10).

**Should-trigger queries:**
- Different phrasings of the same intent (formal + casual)
- Cases where user doesn't name the skill but clearly needs it
- Uncommon use cases
- Cases competing with similar skills

**Should-not-trigger queries:**
- Near-misses sharing keywords but needing something different
- Adjacent domains with ambiguous phrasing
- Queries where naive keyword matching would trigger but shouldn't

**Quality rules:**
- Realistic, detailed prompts (file paths, personal context, specifics)
- Mix of lengths, some casual/abbreviated
- Near-misses are more valuable than obviously irrelevant negatives
- Bad: "Format this data" — Good: "ok so my boss sent me this xlsx file..."

```json
[
  {"query": "detailed realistic prompt", "should_trigger": true},
  {"query": "near-miss realistic prompt", "should_trigger": false}
]
```

### Step 3: Review with User

Present the eval set:

```
AskUserQuestion:
  question: |
    Here are 20 eval queries for testing description triggering.
    [list queries with should_trigger labels]
    Want to modify any, add more, or proceed?
```

Save confirmed eval set to `SKILL_PATH/evals/trigger-evals.json`.

### Step 4: Run Optimization Loop

```
SCRIPTS_DIR = find skill-optimize scripts directory
Bash(command: """
python3 SCRIPTS_DIR/run_loop.py \
  --eval-set SKILL_PATH/evals/trigger-evals.json \
  --skill-path SKILL_PATH \
  --max-iterations 5 \
  --runs-per-query 3 \
  --verbose
""", timeout: 600000)
```

Tell user: "This will take a few minutes. Running optimization loop — testing descriptions against your eval queries with a 60/40 train/test split to prevent overfitting."

### Step 5: Apply Best Description

Parse output JSON for `best_description` and `best_score`.

Show before/after:

```
BEFORE: CURRENT_DESCRIPTION
AFTER:  best_description
SCORE:  best_score (on held-out test set)
```

```
AskUserQuestion("Apply this description to your skill?")
If yes:
  Edit(SKILL_PATH/SKILL.md, replace description in frontmatter)
```

## How Triggering Works

Skills appear in Claude's `available_skills` list with name + description. Claude decides whether to consult a skill based on that description.

Key insight: Claude only consults skills for tasks it can't easily handle alone. Simple one-step queries may not trigger even with a perfect description. Eval queries should be substantive enough that Claude would benefit from consulting the skill.

## Error Handling

| Condition | Action |
|-----------|--------|
| run_loop.py not found | Check scripts directory, report path issue |
| All iterations score 0 | Description may be fundamentally misaligned — suggest manual rewrite |
| claude -p not available | Error — requires Claude Code CLI |
| Timeout (10 min) | Show partial results from last completed iteration |
