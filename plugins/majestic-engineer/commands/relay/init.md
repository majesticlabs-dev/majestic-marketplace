---
name: majestic-relay:init
description: Parse blueprint markdown into epic.yml for fresh-context execution
argument-hint: "<path/to/blueprint.md>"
---

# Initialize Relay from Blueprint

Parse a blueprint markdown file, split into multiple epics by phase, and generate playlist for execution.

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

### 2. Setup Project

```
GITIGNORE = Read(".gitignore") or ""

If ".agents-os/" not in GITIGNORE:
  Append to .gitignore:
    # Agent state (ephemeral)
    .agents-os/

Bash: mkdir -p .agents-os/relay/epics/
```

### 3. Call blueprint-to-epics Agent

```
RESULT = Task(subagent_type="majestic-relay:blueprint-to-epics"):
  prompt: |
    Split the blueprint into epics by logical phase.

    Blueprint path: {blueprint_path}

    Read the blueprint and:
    1. Parse all tasks from "## Implementation Tasks"
    2. Classify into phases: foundation, core, integration, polish
    3. Generate epic files in .agents-os/relay/epics/
    4. Return summary of epics created

If RESULT.status == "error":
  Error: RESULT.error
  Exit

EPICS_CREATED = RESULT.epics_created
```

### 4. Call init-playlist Agent

```
PLAYLIST = Task(subagent_type="majestic-relay:init-playlist"):
  prompt: |
    Generate playlist.yml from epics folder.

    Playlist name: auto-generate from date

If PLAYLIST.status == "error":
  Error: PLAYLIST.error
  Exit
```

### 5. Generate attempt-ledger.yml

Initialize empty ledger for the first epic:

```yaml
version: 1
epic_id: "{first_epic_id}"
started_at: "{ISO timestamp}"
ended_at: null
duration_minutes: null

settings:
  max_attempts_per_task: 3
  timeout_minutes: 15

task_status:
  # Will be populated when epic is loaded

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

Write to `.agents-os/relay/attempt-ledger.yml`

### 6. Create Native Tasks

Create Claude Code Tasks from epic tasks for real-time coordination:

```
EPIC_ID = "relay-$(date +%y%m%d%H%M%S)"  # e.g., "relay-260122195930"
export CLAUDE_CODE_TASK_LIST_ID="${EPIC_ID}"

For each task in first_epic.tasks:
  TaskCreate:
    subject: task.title
    description: task.spec
    metadata: { epic_id: EPIC_ID, task_id: task.id, phase: task.phase }

  If task.depends_on:
    TaskUpdate: blockedBy = [dependency_task_ids]
```

**Note:** Native Tasks provide real-time progress visibility. Ledger provides detailed attempt history.

### 7. Output Summary

```
✅ Initialized from: {blueprint_path}

📋 Created {n} epics:
   1. {epic_id_1} ({task_count} tasks) - {phase}
   2. {epic_id_2} ({task_count} tasks) - {phase}
   3. {epic_id_3} ({task_count} tasks) - {phase}

📁 Files created:
   - .agents-os/relay/epics/{epic_id_1}.yml
   - .agents-os/relay/epics/{epic_id_2}.yml
   - .agents-os/relay/playlist.yml
   - .agents-os/relay/attempt-ledger.yml

🚀 Next: Run `/majestic-relay:work` to start execution
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Blueprint not found | Error with path suggestion |
| Missing ## Implementation Tasks | Error suggesting /majestic:blueprint |
| No tasks parsed | Error with details |
| blueprint-to-epics fails | Report error, exit |
| init-playlist fails | Report error, exit |
| .agents-os/relay/ exists | Warn and ask to overwrite or abort |
