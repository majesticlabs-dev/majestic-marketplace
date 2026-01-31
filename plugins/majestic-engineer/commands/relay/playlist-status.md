---
name: majestic-relay:playlist-status
description: Show playlist progress across all epics
argument-hint: ""
---

# Playlist Status

Display progress across all epics in a playlist.

## Workflow

### 1. Load Playlist

```
RELAY_DIR = ".agents-os/relay"
PLAYLIST_PATH = "{RELAY_DIR}/playlist.yml"

If not exists(PLAYLIST_PATH):
  Error: "No playlist found. Run `/majestic-relay:init-playlist` to create one."
  Exit

PLAYLIST = Read(PLAYLIST_PATH) → parse YAML
```

### 2. Calculate Stats

```
TOTAL_EPICS = count(PLAYLIST.epics)
COMPLETED = count where PLAYLIST.epics[i].status == "completed"
STATUS = PLAYLIST.status or "pending"
CURRENT = PLAYLIST.current or 0
```

### 3. Display Summary

```
STATUS_ICON = {
  "pending": "⚪",
  "in_progress": "🔄",
  "completed": "✅",
  "failed": "❌"
}

Print:
  Playlist: {PLAYLIST.name}
  Status: {STATUS_ICON[STATUS]} {STATUS}
  Progress: [{progress_bar}] {COMPLETED}/{TOTAL_EPICS} epics

If PLAYLIST.started_at:
  Print: "Started: {PLAYLIST.started_at}"

If PLAYLIST.ended_at:
  Print: "Completed: {PLAYLIST.ended_at} ({PLAYLIST.duration_minutes} min)"
```

### 4. Display Epic List

```
For INDEX, EPIC in enumerate(PLAYLIST.epics):
  EPIC_STATUS = EPIC.status or "pending"

  If EPIC_STATUS == "completed":
    Print: "✅ {INDEX + 1}. {EPIC.file}"

  Else If EPIC_STATUS == "in_progress":
    Print: "🔄 {INDEX + 1}. {EPIC.file} ← current"

  Else If EPIC_STATUS == "failed":
    Print: "❌ {INDEX + 1}. {EPIC.file} ← failed"

  Else:
    Print: "⏳ {INDEX + 1}. {EPIC.file}"
```

### 5. Show Current Epic Details (if running)

```
If STATUS == "in_progress":
  Print:
    ───────────────────────────────────
    Current Epic Details:

  /majestic-relay:status  # Delegate to existing status command
```

### 6. Show Failure Details (if failed)

```
If STATUS == "failed":
  FAILED_EPIC = find in PLAYLIST.epics where status == "failed"

  Print:
    ───────────────────────────────────
    ❌ Failure Details:
       Epic: {FAILED_EPIC.file}
       Failed at: {FAILED_EPIC.failed_at}

    To resume:
    1. Fix the failing epic manually or run `/majestic-relay:work` to retry
    2. Run `/majestic-relay:run-playlist` to continue from failed epic
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No playlist found | Error with init-playlist suggestion |
| Malformed YAML | Error with parse details |
