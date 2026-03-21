---
name: majestic:skill-eval
description: Test and iterate on a skill using parallel eval runs. Spawns with-skill and baseline runs, grades results, and helps improve the skill based on feedback. Use when testing skill quality or iterating on skill improvements.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent
argument-hint: "[path/to/skill]"
---

# Skill Eval

Test a skill with parallel eval runs and iterate based on results.

## Input

```
SKILL_PATH = $ARGUMENTS
```

If empty: `AskUserQuestion("Which skill do you want to test? Provide the path.")`

## Workflow

### Step 1: Validate Skill Exists

```
If not exists(SKILL_PATH/SKILL.md):
  ERROR "No SKILL.md found at SKILL_PATH"

SKILL_CONTENT = Read(SKILL_PATH/SKILL.md)
SKILL_NAME = extract name from frontmatter
SKILL_DESCRIPTION = extract description from frontmatter
```

### Step 2: Load or Create Evals

```
EVALS_PATH = SKILL_PATH/evals/evals.json

If exists(EVALS_PATH):
  EVALS = Read(EVALS_PATH)
  Present evals to user, ask: "Use these evals, modify, or create new ones?"
Else:
  Generate 2-3 realistic test prompts based on SKILL_CONTENT
  Each prompt should be what a real user would actually say
  Include enough detail: file paths, context, specific requests
  Present to user: "Here are test cases I'd like to try. Look right, or want changes?"
```

Wait for user confirmation before proceeding.

**Eval format:**

```json
{
  "skill_name": "SKILL_NAME",
  "evals": [
    {
      "id": 1,
      "prompt": "User's realistic task prompt",
      "expected_output": "Description of expected result",
      "expectations": [
        "The output includes X",
        "The skill used approach Y"
      ]
    }
  ]
}
```

Save confirmed evals to EVALS_PATH.

### Step 3: Set Up Workspace

```
WORKSPACE = SKILL_PATH-workspace
ITERATION = find highest iteration-N in WORKSPACE + 1, or 1 if none
ITER_DIR = WORKSPACE/iteration-ITERATION

mkdir -p ITER_DIR
```

### Step 4: Spawn All Runs

For each EVAL in EVALS, spawn TWO subagents in the SAME turn:

**With-skill run:**

```
Agent(prompt: """
Execute this task:
- Read the skill at: SKILL_PATH/SKILL.md
- Follow the skill's instructions to complete this task: EVAL.prompt
- Save all outputs to: ITER_DIR/eval-EVAL.id/with_skill/outputs/
""")
```

**Baseline run (no skill):**

```
Agent(prompt: """
Execute this task (no special instructions):
- Task: EVAL.prompt
- Save all outputs to: ITER_DIR/eval-EVAL.id/without_skill/outputs/
""")
```

Launch ALL runs (with-skill + baseline for every eval) in parallel.

### Step 5: Draft Assertions While Runs Execute

While runs are in progress, draft quantitative assertions for each eval:

- Assertions must be objectively verifiable
- Give each a descriptive name
- Skip assertions for subjective outcomes (writing style, design quality)

Write `eval_metadata.json` for each eval directory:

```json
{
  "eval_id": 1,
  "eval_name": "descriptive-name",
  "prompt": "The user's task prompt",
  "assertions": ["Output includes X", "File is valid JSON"]
}
```

Explain assertions to user while waiting.

### Step 6: Grade Results

Once all runs complete:

For each run (with_skill and without_skill):

```
Agent(prompt: """
Read agents/skill-grader.md and follow its instructions.
- expectations: EVAL.expectations
- transcript_path: ITER_DIR/eval-EVAL.id/CONFIG/transcript.md
- outputs_dir: ITER_DIR/eval-EVAL.id/CONFIG/outputs/
- eval_prompt: EVAL.prompt
""", subagent_type: "majestic-tools:agents:skill-grader")
```

### Step 7: Present Results

For each eval, show:
- Prompt
- With-skill pass rate vs baseline pass rate
- Key differences in outputs
- Any eval feedback from grader

Summary table:

```
| Eval | With Skill | Baseline | Delta |
|------|-----------|----------|-------|
| 1    | 85%       | 35%      | +50%  |
```

Ask user: "How do these look? Any specific feedback on the outputs?"

### Step 8: Iterate (if needed)

```
If user has feedback:
  1. Analyze feedback — generalize, don't overfit to specific cases
  2. Improve the skill (Edit SKILL.md)
  3. Explain changes made and why
  4. Ask: "Want to rerun the evals with the updated skill?"
  5. If yes: goto Step 3 (new iteration)

If user is satisfied:
  "Skill looks good. Want to optimize the description for better triggering?"
  If yes: suggest /majestic:skill-optimize SKILL_PATH
```

## Improvement Guidelines

When rewriting skills based on feedback:

- **Generalize** — don't overfit to the 2-3 test cases; the skill will be used many times
- **Keep it lean** — remove instructions that aren't pulling their weight
- **Explain the why** — tell the model why things matter instead of rigid MUSTs
- **Look for repeated work** — if all runs wrote similar helper scripts, bundle the script in the skill
- **Read transcripts** — check if the skill wastes time on unproductive steps

## Error Handling

| Condition | Action |
|-----------|--------|
| Subagent run times out | Note timeout, grade available outputs |
| No outputs produced | FAIL all expectations for that run |
| Skill has syntax errors | Fix before running evals |
| User wants to stop iterating | Accept and summarize current state |
