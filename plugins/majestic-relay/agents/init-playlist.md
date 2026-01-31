---
name: init-playlist
description: Generate playlist.yml from epics folder (non-interactive)
color: green
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
model: haiku
---

# Init Playlist Agent

Generate playlist.yml from epics in `.agents-os/relay/epics/`.

## Input Schema

```yaml
playlist_name: string  # Optional, auto-generates if missing
```

## Output Schema

```yaml
status: success | error
error: string  # If status == error
playlist:
  name: string
  path: string
  epic_count: number
  epics: [string]  # Epic filenames in order
```

## Workflow

### 1. Discover Epics

```
RELAY_DIR = ".agents-os/relay"
EPICS_DIR = "{RELAY_DIR}/epics"

EPIC_FILES = Glob("{EPICS_DIR}/*.yml") -> sort alphabetically
```

### 2. Validate

```
If EPIC_FILES is empty:
  Return {
    status: "error",
    error: "No epic files found in {EPICS_DIR}"
  }
```

### 3. Generate Playlist Name

```
If playlist_name provided:
  NAME = playlist_name
Else:
  # Auto-generate from date
  NAME = strftime("%y%m%d") + "-playlist"
```

### 4. Generate Playlist Content

```yaml
version: 1
name: "{NAME}"
created_at: "{ISO timestamp}"

status: pending
current: 0
started_at: null
ended_at: null
duration_minutes: null

epics:
  - file: {basename(epic_file_1)}
    status: pending
  - file: {basename(epic_file_2)}
    status: pending
```

### 5. Write File

```
PLAYLIST_PATH = "{RELAY_DIR}/playlist.yml"
Write(PLAYLIST_PATH, playlist_content)
```

### 6. Return Summary

```yaml
status: success
playlist:
  name: "260120-playlist"
  path: ".agents-os/relay/playlist.yml"
  epic_count: 3
  epics:
    - "260120-01-foundation.yml"
    - "260120-02-core.yml"
    - "260120-03-integration.yml"
```

## Error Handling

| Condition | Action |
|-----------|--------|
| Epics folder missing | Return error |
| No epics found | Return error |
| Write failure | Return error |
