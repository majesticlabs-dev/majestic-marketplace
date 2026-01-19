---
name: lessons-discoverer
description: Discover and rank relevant lessons using Claude headless mode for semantic scoring. Returns links (not content) to minimize token overhead.
tools: Read, Bash, Glob
model: haiku
color: cyan
---

# Lessons Discoverer Agent

Discover and rank relevant lessons from `.agents-os/lessons/` (configurable) using Claude headless mode for semantic scoring.

## Purpose

Surface institutional memory at the right moment:
- **Planning:** Lessons from past architectural decisions
- **Debugging:** Similar issues and their solutions
- **Review:** Critical anti-patterns to check
- **Implementation:** Patterns and gotchas for current work

## Input Format

```
workflow_phase: planning | debugging | review | implementation
tech_stack: [rails, react, ...]
task: <feature description or bug description>
filter: <optional: antipattern, critical, high>
```

## Process

### 1. Read Lessons Path from Config

```
Skill(skill: "config-reader", args: "lessons_path .agents-os/lessons/")
```

Store as `LESSONS_PATH`.

### 2. Check Directory Exists

```bash
[ -d "$LESSONS_PATH" ] && echo "EXISTS" || echo "NOT_FOUND"
```

**If not found:** Return early with:
```json
{"lessons": [], "error": "no_directory", "message": "Lessons directory not found"}
```

### 3. Discover Lesson Files

```bash
find "$LESSONS_PATH" -name "*.md" -type f 2>/dev/null | grep -v "/patterns/"
```

**If no files found:** Return early with:
```json
{"lessons": [], "total_found": 0}
```

### 4. Extract YAML Frontmatter

For each discovered file, extract frontmatter using yq or grep:

```bash
# Extract frontmatter fields as JSON
for f in $(find "$LESSONS_PATH" -name "*.md" -type f); do
  # Extract YAML between --- markers
  awk '/^---$/{if(++n==1)next; if(n==2)exit} n==1' "$f" | \
    yq -o json '.' 2>/dev/null | \
    jq -c --arg path "$f" '. + {path: $path}'
done | jq -s '.'
```

**Alternative (simpler grep approach):**
```bash
# Just extract key fields we need for scoring
for f in $(find "$LESSONS_PATH" -name "*.md" -type f); do
  PHASE=$(grep -m1 "^workflow_phase:" "$f" | sed 's/workflow_phase://')
  STACK=$(grep -m1 "^tech_stack:" "$f" | sed 's/tech_stack://')
  TYPE=$(grep -m1 "^lesson_type:" "$f" | sed 's/lesson_type://')
  IMPACT=$(grep -m1 "^impact:" "$f" | sed 's/impact://')
  SEVERITY=$(grep -m1 "^severity:" "$f" | sed 's/severity://')

  echo "$f|$PHASE|$STACK|$TYPE|$IMPACT|$SEVERITY"
done
```

**Filter for workflow_phase:** Only include lessons that have `workflow_phase` field containing the requested phase.

### 5. Invoke Claude Headless for Semantic Scoring

Prepare lessons summary and invoke Claude:

```bash
# Collect lesson metadata as JSON
LESSONS_JSON='[
  {"path": "{lessons_path}/perf/n-plus-one.md", "workflow_phase": ["debugging", "review"], "tech_stack": ["rails"], "lesson_type": "antipattern", "severity": "high"},
  {"path": "{lessons_path}/auth/token-refresh.md", "workflow_phase": ["planning", "implementation"], "tech_stack": ["generic"], "lesson_type": "pattern", "severity": "medium"}
]'

claude -p "Score these lessons for relevance to the task.

## Context
- workflow_phase: $WORKFLOW_PHASE
- tech_stack: $TECH_STACK
- task_description: $TASK_DESCRIPTION

## Lessons
$LESSONS_JSON

## Instructions
Return JSON array with top 5 most relevant lessons, scored 0-100.

Scoring criteria:
1. workflow_phase match (required): Lesson must include requested phase
2. tech_stack match: Higher if matches project stack, still include if generic
3. Semantic relevance: How related is the lesson to the task description?
4. Impact/severity: Prioritize critical > high > medium > low
5. Recency bonus: Newer lessons slightly preferred (from date field)

Minimum threshold: 30 points. Only include lessons scoring 30+.

## Output Format (JSON only, no markdown)
{
  \"lessons\": [
    {\"path\": \"...\", \"score\": 85, \"reason\": \"One sentence why this is relevant\"},
    {\"path\": \"...\", \"score\": 72, \"reason\": \"...\"}
  ],
  \"total_found\": 2,
  \"threshold\": 30
}" \
  --output-format json \
  --allowedTools ""
```

### 6. Parse and Return Results

Parse the JSON response from Claude headless:

```bash
echo "$RESPONSE" | jq '.result // .content // .'
```

## Output Format

Return JSON with ranked lessons:

```json
{
  "lessons": [
    {
      "path": "{lessons_path}/performance-issues/n-plus-one-20251110.md",
      "score": 85,
      "reason": "Directly addresses N+1 query patterns in Rails list views"
    },
    {
      "path": "{lessons_path}/security-issues/auth-bypass-20251020.md",
      "score": 72,
      "reason": "Authentication patterns relevant to user management feature"
    }
  ],
  "total_found": 2,
  "threshold": 30
}
```

## Error Handling

| Scenario | Response |
|----------|----------|
| Directory doesn't exist | `{"lessons": [], "error": "no_directory"}` |
| No lessons match phase | `{"lessons": [], "total_found": 0}` |
| No lessons above threshold | `{"lessons": [], "total_found": 0}` |
| Headless mode fails | `{"lessons": [], "error": "scoring_failed"}` |
| Malformed YAML | Skip file, continue with others |

## Token Budget

- Maximum 5 lessons returned per discovery
- Only paths/scores/reasons returned (not full content)
- Typical response: ~100-200 tokens

Calling workflows decide whether to read full lesson content:
```bash
TOP_LESSON=$(echo "$RESULT" | jq -r '.lessons[0].path')
cat "$TOP_LESSON"
```

## Filter Parameter

When `filter` is provided, additionally filter lessons:

| Filter | Behavior |
|--------|----------|
| `antipattern` | Only `lesson_type: antipattern` |
| `critical` | Only `severity: critical` |
| `high` | Only `severity: critical,high` |
| `pattern` | Only `lesson_type: pattern` |

Combine with `workflow_phase` for targeted discovery.

## Example Invocations

**From blueprint (planning phase):**
```
Task(subagent_type: "majestic-engineer:workflow:lessons-discoverer"):
  prompt: |
    workflow_phase: planning
    tech_stack: [rails]
    task: Add user authentication with OAuth support
```

**From debug (debugging phase):**
```
Task(subagent_type: "majestic-engineer:workflow:lessons-discoverer"):
  prompt: |
    workflow_phase: debugging
    tech_stack: [rails]
    task: API returns 500 error on user update
```

**From quality-gate (review phase with filter):**
```
Task(subagent_type: "majestic-engineer:workflow:lessons-discoverer"):
  prompt: |
    workflow_phase: review
    tech_stack: [rails]
    filter: antipattern,critical,high
```

## Why Headless Mode?

- **Semantic understanding:** Claude analyzes task description meaning, not just keyword overlap
- **No scoring algorithm maintenance:** LLM handles relevance judgment
- **Simpler implementation:** ~10 lines of bash vs 50+ lines of scoring code
- **Better results:** Catches conceptual matches ("authorization" ↔ "access control")

## Graceful Degradation

This agent is non-blocking. If discovery fails for any reason:
1. Log warning to console
2. Return empty lessons array
3. Calling workflow continues normally

```json
{"lessons": [], "error": "...", "message": "Discovery failed, continuing without lessons"}
```

Workflows MUST NOT fail if lessons-discoverer returns an error.
