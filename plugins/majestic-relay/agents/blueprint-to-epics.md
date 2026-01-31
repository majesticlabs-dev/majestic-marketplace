---
name: blueprint-to-epics
description: Split blueprint into multiple epics by logical phase (foundation, core, integration, polish)
color: cyan
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# Blueprint to Epics Agent

Convert one blueprint into multiple epics by logical phase.

## Input Schema

```yaml
blueprint_path: string  # Path to blueprint.md
```

## Output Schema

```yaml
status: success | error
error: string  # If status == error
epics_created:
  - id: string       # e.g., "260120-01-foundation"
    phase: string    # foundation | core | integration | polish
    tasks: [string]  # Task IDs: [T1, T2]
    file: string     # Path to epic file
summary:
  total_tasks: number
  phases_created: number
```

## Phase Classification

| Phase | Keywords | Purpose |
|-------|----------|---------|
| foundation | migration, model, schema, setup, config, database | Base infrastructure |
| core | service, logic, business, core, processor, handler | Main functionality |
| integration | controller, endpoint, view, api, route, interface | Connecting pieces |
| polish | test, validation, error, edge, spec, cleanup | Quality & verification |

## Workflow

### 1. Read Blueprint

```
BLUEPRINT = Read(blueprint_path)

If "## Implementation Tasks" not in BLUEPRINT:
  Return { status: "error", error: "Missing '## Implementation Tasks' section" }
```

### 2. Parse Tasks

Extract from `## Implementation Tasks` section:

```
TASKS = []

For each task block matching "##### T{N}: {title}":
  TASK = {
    id: "T{N}",
    title: extracted_title,
    priority: extract("Priority:"),
    points: extract("Points:"),
    files: extract("Files:"),
    depends_on: extract("Depends on:"),
    acceptance_criteria: extract_list("Acceptance Criteria:")
  }
  TASKS.append(TASK)
```

### 3. Extract Parallelization Matrix

```
PARALLELIZATION = []

For each row in parallelization table:
  GROUP = {
    group: letter,
    tasks: [task_ids],
    blocked_by: [group_letters]
  }
  PARALLELIZATION.append(GROUP)
```

### 4. Classify Tasks into Phases

```
PHASES = {
  foundation: [],
  core: [],
  integration: [],
  polish: []
}

FOUNDATION_KEYWORDS = ["migration", "model", "schema", "setup", "config", "database", "seed"]
CORE_KEYWORDS = ["service", "logic", "business", "core", "processor", "handler", "manager"]
INTEGRATION_KEYWORDS = ["controller", "endpoint", "view", "api", "route", "interface", "component"]
POLISH_KEYWORDS = ["test", "validation", "error", "edge", "spec", "cleanup", "refactor"]

For each TASK in TASKS:
  TITLE_LOWER = lowercase(TASK.title)

  If any(kw in TITLE_LOWER for kw in FOUNDATION_KEYWORDS):
    PHASES.foundation.append(TASK)
  Elif any(kw in TITLE_LOWER for kw in INTEGRATION_KEYWORDS):
    PHASES.integration.append(TASK)
  Elif any(kw in TITLE_LOWER for kw in POLISH_KEYWORDS):
    PHASES.polish.append(TASK)
  Else:
    PHASES.core.append(TASK)  # Default
```

### 5. Preserve Dependencies Across Phases

```
# Ensure phase ordering respects task dependencies
PHASE_ORDER = [foundation, core, integration, polish]

For each TASK in all_tasks:
  For each DEP in TASK.depends_on:
    DEP_PHASE = phase_containing(DEP)
    TASK_PHASE = phase_containing(TASK)

    If PHASE_ORDER.index(DEP_PHASE) > PHASE_ORDER.index(TASK_PHASE):
      # Move dependent task to later phase
      Move TASK from TASK_PHASE to DEP_PHASE
```

### 6. Generate Epic Files

```
DATE_PREFIX = strftime("%y%m%d")  # e.g., "260120"
TITLE_SLUG = slugify(blueprint_title)
EPICS_CREATED = []
SEQUENCE = 1

For each PHASE in [foundation, core, integration, polish]:
  If PHASES[PHASE] is not empty:
    EPIC_ID = f"{DATE_PREFIX}-{SEQUENCE:02d}-{PHASE}"

    # Extract metadata from blueprint
    TITLE = blueprint_title
    DESCRIPTION = blueprint_description
    SOURCE = blueprint_path

    # Filter parallelization for this phase's tasks
    PHASE_TASK_IDS = [t.id for t in PHASES[PHASE]]
    PHASE_PARALLELIZATION = filter_parallelization(PARALLELIZATION, PHASE_TASK_IDS)

    EPIC_CONTENT = generate_epic_yaml(
      id: EPIC_ID,
      title: f"{TITLE} - {capitalize(PHASE)}",
      source: SOURCE,
      description: DESCRIPTION,
      tasks: PHASES[PHASE],
      parallelization: PHASE_PARALLELIZATION
    )

    EPIC_PATH = f".agents-os/relay/epics/{EPIC_ID}.yml"
    Write(EPIC_PATH, EPIC_CONTENT)

    EPICS_CREATED.append({
      id: EPIC_ID,
      phase: PHASE,
      tasks: PHASE_TASK_IDS,
      file: EPIC_PATH
    })

    SEQUENCE += 1
```

### 7. Epic YAML Template

```yaml
version: 2
id: "{EPIC_ID}"
source: "{blueprint_path}"
created_at: "{ISO timestamp}"

title: "{title} - {Phase}"
description: |
  {description}

parallelization:
  - group: A
    tasks: [T1]
    blocked_by: []

tasks:
  T1:
    title: "{task title}"
    priority: p1
    points: 2
    files:
      - {file1}
    depends_on: []
    acceptance_criteria:
      - "{criterion 1}"
```

### 8. Return Summary

```yaml
status: success
epics_created:
  - id: "260120-01-foundation"
    phase: foundation
    tasks: [T1, T2]
    file: ".agents-os/relay/epics/260120-01-foundation.yml"
  - id: "260120-02-core"
    phase: core
    tasks: [T3, T4, T5]
    file: ".agents-os/relay/epics/260120-02-core.yml"
summary:
  total_tasks: 5
  phases_created: 2
```

## Error Handling

| Condition | Action |
|-----------|--------|
| Blueprint not found | Return error |
| No tasks found | Return error |
| All tasks in one phase | Create single epic (valid) |
| Task dependency across phases | Adjust phase assignment |
| Empty phase | Skip (don't create empty epic) |

## Size Constraint

If any phase exceeds 15 tasks:

```
If count(PHASES[PHASE]) > 15:
  # Split phase into numbered sub-phases
  CHUNKS = chunk(PHASES[PHASE], size=10)
  For i, CHUNK in enumerate(CHUNKS):
    Create epic: "{PHASE}-{i+1}"
```
