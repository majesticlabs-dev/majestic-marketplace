---
name: majestic-relay:init-playlist
description: Create playlist.yml from epics in relay/epics/ folder
argument-hint: "[name]"
---

# Initialize Epic Playlist

Create a `playlist.yml` file from epics in `.agents-os/relay/epics/`.

## Input

```yaml
name: string  # Optional playlist name
```

## Workflow

### 1. Discover Epics

```
RELAY_DIR = ".agents-os/relay"
EPICS_DIR = "{RELAY_DIR}/epics"

If not exists(EPICS_DIR):
  Error: "No epics folder found at {EPICS_DIR}"
  Suggest: "Run `/relay:init <blueprint.md>` to create epics first"
  Exit

EPIC_FILES = Glob("{EPICS_DIR}/*.yml") → sort alphabetically
```

### 2. Validate Discovery

```
If EPIC_FILES is empty:
  Error: "No epic files found in {EPICS_DIR}"
  Suggest: "Run `/relay:init <blueprint.md>` to create epics"
  Exit

Print:
  Found {count(EPIC_FILES)} epics:
  {for each file: "  - {basename(file)}"}
```

### 3. Gather User Preferences

```
AskUserQuestion:
  header: "Epics"
  question: "Which epics should be included in this playlist?"
  options:
    - "All epics in order (Recommended)"
    - "Let me select specific epics"
  multiSelect: false

If user selects specific:
  AskUserQuestion:
    header: "Select"
    question: "Which epics to include?"
    options: [list of epic filenames]
    multiSelect: true

  SELECTED_EPICS = user_response
Else:
  SELECTED_EPICS = EPIC_FILES
```

### 4. Confirm Order

```
If count(SELECTED_EPICS) > 1:
  Print:
    Execution order:
    {for index, file in SELECTED_EPICS: "  {index + 1}. {basename(file)}"}

  AskUserQuestion:
    header: "Order"
    question: "Is this order correct?"
    options:
      - "Yes, proceed (Recommended)"
      - "Let me reorder"

  If reorder:
    AskUserQuestion:
      header: "Sequence"
      question: "Enter epic numbers in desired order (e.g., 3,1,2)"

    SELECTED_EPICS = reorder(SELECTED_EPICS, user_input)
```

### 5. Get Playlist Name

```
If $ARGUMENTS is not empty:
  PLAYLIST_NAME = $ARGUMENTS
Else:
  AskUserQuestion:
    header: "Name"
    question: "What should this playlist be called?"
    options:
      - "Auto-generate from date"
      - "Let me specify"

  If auto:
    PLAYLIST_NAME = "{YYMMDD}-playlist"
  Else:
    PLAYLIST_NAME = user_input
```

### 6. Generate Playlist File

```yaml
# playlist.yml
version: 1
name: "{PLAYLIST_NAME}"
created_at: "{ISO timestamp}"

# Progress tracking (updated by run-playlist)
status: pending        # pending | in_progress | completed | failed
current: 0             # Index of current/next epic (0-based)
started_at: null
ended_at: null
duration_minutes: null

epics:
  - file: 260119-01-infrastructure.yml
    status: pending
  - file: 260119-02-database-models.yml
    status: pending
  - file: 260119-03-authentication.yml
    status: pending
```

### 7. Write File

```
PLAYLIST_PATH = "{RELAY_DIR}/playlist.yml"

If exists(PLAYLIST_PATH):
  AskUserQuestion:
    header: "Overwrite"
    question: "Playlist already exists. Overwrite?"
    options:
      - "Yes, overwrite"
      - "No, cancel"

  If cancel: Exit

Write(PLAYLIST_PATH, playlist_content)
```

### 8. Output Summary

```
✅ Playlist created: {PLAYLIST_NAME}

📋 Epics ({count(SELECTED_EPICS)}):
   1. {epic1}
   2. {epic2}
   3. {epic3}

📁 File: {PLAYLIST_PATH}

🚀 Next: Run `/relay:run-playlist` to start execution
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No epics folder | Error with init suggestion |
| No epics found | Error with init suggestion |
| Playlist exists | Ask to overwrite |
| Invalid reorder input | Re-prompt |
