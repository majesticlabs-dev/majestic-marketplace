---
name: majestic-relay:init
description: Parse blueprint markdown into epic.yml for fresh-context execution
argument-hint: "<path/to/blueprint.md>"
---

# Initialize Epic from Blueprint

Parse a blueprint markdown file and generate `.majestic/epic.yml` + `.majestic/attempt-ledger.yml` for fresh-context task execution.

## Input

```
<blueprint_path> $ARGUMENTS </blueprint_path>
```

**If empty:** Ask user to provide the blueprint file path.

## Workflow

### 1. Validate Input

```
If blueprint_path is empty:
  AskUserQuestion: "Which blueprint file should I initialize?"
  Options: List recent files in docs/plans/

If file doesn't exist:
  Error: "Blueprint not found: {path}"
  Exit
```

### 2. Setup Project (First Run)

**Add `.majestic/` to `.gitignore`:**

```
GITIGNORE = Read(".gitignore") or ""

If ".majestic/" not in GITIGNORE:
  Append to .gitignore:
    # Relay epic state (ephemeral)
    .majestic/
```

**Initialize relay config in `.agents.yml`:**

```
If not exists(".agents.yml"):
  Create .agents.yml with relay defaults

Else If "relay:" not in .agents.yml:
  Append relay section to .agents.yml
```

Default relay configuration:

```yaml
relay:
  version: 1
  max_attempts_per_task: 3
  timeout_minutes: 15
  review:
    enabled: false
    provider: none  # repoprompt | gemini | none
```

### 3. Read Blueprint

```
BLUEPRINT_CONTENT = Read(blueprint_path)

If "## Implementation Tasks" not in BLUEPRINT_CONTENT:
  Error: "Blueprint missing '## Implementation Tasks' section. Run /majestic:blueprint first."
  Exit
```

### 4. Parse Blueprint Structure

Extract from the blueprint:

**Epic metadata:**
- Title (from `# ` heading or filename)
- Source path
- Description (first paragraph or summary)

**Parallelization matrix:**
```markdown
| Group | Tasks | Blocked By |
|-------|-------|------------|
| A | T1: [title] | - |
| B | T2: [title], T3: [title] | A |
```

**Task details:**
```markdown
##### T1: [title]
- **Priority:** p1 | **Points:** 2
- **Files:** [files]
- **Depends on:** —

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
```

### 5. Generate epic.yml

Write to `.majestic/epic.yml`:

```yaml
version: 1
id: "{YYYYMMDD}-{slugified-title}"
source: "{blueprint_path}"
created_at: "{ISO timestamp}"

title: "{extracted title}"
description: |
  {extracted description}

parallelization:
  - group: A
    tasks: [T1]
    blocked_by: []
  - group: B
    tasks: [T2, T3]
    blocked_by: [A]

tasks:
  T1:
    title: "{task title}"
    priority: p1
    points: 2
    files:
      - {file1}
      - {file2}
    depends_on: []
    acceptance_criteria:
      - "{criterion 1}"
      - "{criterion 2}"
```

### 6. Load Settings from .agents.yml

```
MAX_ATTEMPTS = config-reader("relay.max_attempts_per_task", 3)
TIMEOUT = config-reader("relay.timeout_minutes", 15)
REVIEW_ENABLED = config-reader("relay.review.enabled", true)
REVIEW_PROVIDER = config-reader("relay.review.provider", "none")
```

### 7. Generate attempt-ledger.yml

Write to `.majestic/attempt-ledger.yml`:

```yaml
version: 1
epic_id: "{epic.id}"
started_at: "{ISO timestamp}"
ended_at: null           # Set when epic completes
duration_minutes: null   # Calculated on completion

settings:
  max_attempts_per_task: {MAX_ATTEMPTS}
  timeout_minutes: {TIMEOUT}
  review:
    enabled: {REVIEW_ENABLED}
    provider: "{REVIEW_PROVIDER}"

task_status:
  T1: pending
  T2: pending
  # ... all tasks start as pending

attempts: {}

gated_tasks: {}

relay_status:
  state: idle
  pid: null
  started_at: null
  stopped_at: null
  last_exit_code: null
  last_exit_reason: null
```

### 8. Create Directory

```bash
mkdir -p .majestic
```

### 9. Write Files

```
Write(.majestic/epic.yml, epic_content)
Write(.majestic/attempt-ledger.yml, ledger_content)
```

### 10. Output Summary

```
✅ Epic initialized: {epic.id}

📋 Tasks: {task_count}
   Group A: T1
   Group B: T2, T3 (blocked by A)
   Group C: T4 (blocked by B)

📁 Files created/updated:
   - .majestic/epic.yml
   - .majestic/attempt-ledger.yml
   - .gitignore (added .majestic/)
   - .agents.yml (added relay config)

🚀 Next: Run `/relay:work` to start execution
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Blueprint not found | Error with path suggestion |
| Missing ## Implementation Tasks | Error suggesting /majestic:blueprint |
| Malformed task format | Warning, skip task, continue |
| .majestic/ already exists | Ask to overwrite or abort |
| Config read fails | Use default values |

## Notes

- Epic ID format: `YYYYMMDD-slugified-title` (e.g., `20260111-user-authentication`)
- All tasks start as `pending` status
- Settings inherit from `.agents.yml` with `.agents.local.yml` overrides
- Parallelization groups are extracted from the matrix table
