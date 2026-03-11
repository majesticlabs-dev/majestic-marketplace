---
name: skill-grader
description: Evaluate skill test run outputs against expectations and extract implicit claims.
allowed-tools: Read Grep Glob Write
---

# Skill Grader

Evaluate skill test run outputs against expectations and extract implicit claims.

## Input Schema

```yaml
expectations:        # List of verifiable statements
  - "Output includes X"
  - "Skill used script Y"
transcript_path:     # Path to execution transcript
outputs_dir:         # Directory containing output files
eval_prompt:         # Original task prompt
```

## Grading Process

### Step 1: Read Context

```
TRANSCRIPT = Read(transcript_path)
OUTPUT_FILES = Glob(outputs_dir + "/**/*")
For each FILE in OUTPUT_FILES:
  CONTENT[FILE] = Read(FILE)
```

Note: eval_prompt, execution steps, errors, final result.

### Step 2: Grade Expectations

For each EXPECTATION in expectations:

```
EVIDENCE = search TRANSCRIPT and CONTENT for EXPECTATION
If EVIDENCE confirms EXPECTATION genuinely (not superficially):
  verdict = PASS
Else:
  verdict = FAIL
```

**PASS criteria:**
- Clear evidence in transcript or outputs
- Evidence reflects genuine task completion, not surface compliance
- A correct filename with wrong content is FAIL, not PASS

**FAIL criteria:**
- No evidence found
- Evidence contradicts expectation
- Evidence is superficial (right format, wrong substance)
- Cannot be verified from available information

When uncertain: burden of proof is on the expectation to pass.

### Step 3: Extract Claims

Beyond predefined expectations, find implicit claims:

```
For each CLAIM in (TRANSCRIPT + CONTENT):
  CLAIM.type = "factual" | "process" | "quality"
  CLAIM.verified = verify(CLAIM, available_evidence)
  CLAIM.evidence = supporting_or_contradicting_text
```

- Factual: "The form has 12 fields" — check against outputs
- Process: "Used pypdf to fill the form" — verify from transcript
- Quality: "All fields filled correctly" — evaluate if justified

Flag unverifiable claims.

### Step 4: Critique the Evals

After grading, assess whether the evals themselves could improve.
Only surface suggestions when there's a clear gap:

- Assertion that passed but would also pass for clearly wrong output
- Important outcome (good or bad) that no assertion covers
- Assertion that can't actually be verified from available outputs

Keep bar high. Flag things the eval author would say "good catch" about.

### Step 5: Write Results

```
Write(outputs_dir + "/../grading.json", RESULTS)
```

## Output Schema

```json
{
  "expectations": [
    {
      "text": "The output includes X",
      "passed": true,
      "evidence": "Found in transcript Step 3: '...'"
    }
  ],
  "summary": {
    "passed": 2,
    "failed": 1,
    "total": 3,
    "pass_rate": 0.67
  },
  "claims": [
    {
      "claim": "The form has 12 fillable fields",
      "type": "factual",
      "verified": true,
      "evidence": "Counted 12 fields in output"
    }
  ],
  "eval_feedback": {
    "suggestions": [
      {
        "assertion": "Output includes name",
        "reason": "A hallucinated doc mentioning the name would also pass"
      }
    ],
    "overall": "No suggestions, evals look solid."
  }
}
```

**Field requirements:**
- expectations[].text, .passed, .evidence — all required (viewer depends on exact names)
- summary.pass_rate — float 0.0 to 1.0
- claims[] — optional but encouraged
- eval_feedback — include only when warranted; "No suggestions" is fine

## Error Handling

| Condition | Action |
|-----------|--------|
| Transcript not found | FAIL all expectations, note in evidence |
| Output files empty | FAIL expectations requiring output content |
| Binary files in outputs | Note as unreadable, skip content check |
| Malformed JSON in outputs | FAIL expectations about JSON structure |
