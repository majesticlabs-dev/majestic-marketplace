---
name: majestic-relay:run-playlist
description: Execute epic playlist sequentially (fail-fast)
argument-hint: "[playlist.yml]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/relay-playlist.sh:*)
---

# Execute Epic Playlist

Run multiple epics sequentially from a `playlist.yml` file. Stops on first failure.

## Input

```yaml
playlist_path: string  # Path to playlist.yml (default: .agents-os/relay/playlist.yml)
```

## Workflow

```
If not exists(".agents-os/relay/playlist.yml") AND $ARGUMENTS is empty:
  Error: "No playlist found. Run `/relay:init-playlist` first."

Execute: "${CLAUDE_PLUGIN_ROOT}/scripts/relay-playlist.sh" $ARGUMENTS
```

## What the Script Does

1. **Load playlist** from `.agents-os/relay/playlist.yml`
2. **Validate** all epics exist in `epics/` folder
3. **For each epic** (starting from `current` index):
   - 🎬 Announce epic started
   - Create symlink: `ln -sf epics/{file} epic.yml`
   - Initialize fresh ledger
   - Update playlist status → `in_progress`
   - Run `relay-work.sh`
   - If completed: ✅ Announce, update status, continue
   - If failed: ❌ Announce, mark failed, EXIT
4. **On completion**: 🎉 Announce playlist complete

## Playlist Schema

```yaml
# playlist.yml (updated by script)
version: 1
name: "Bina MVP"
created_at: "2024-01-15T10:00:00Z"
status: in_progress    # pending | in_progress | completed | failed
current: 2             # Index of current/next epic (0-based)
started_at: "2024-01-15T10:00:00Z"
ended_at: null
duration_minutes: null

epics:
  - file: 260119-01-infrastructure.yml
    status: completed
    started_at: "2024-01-15T10:00:00Z"
    completed_at: "2024-01-15T10:15:00Z"
  - file: 260119-02-database-models.yml
    status: in_progress
    started_at: "2024-01-15T10:15:00Z"
  - file: 260119-03-authentication.yml
    status: pending
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Playlist not found | Error with init-playlist suggestion |
| Epic file missing | Error before starting |
| Epic fails | Record failure, stop playlist |
| Ctrl+C | Save progress, exit cleanly |
| Resume after failure | Fix epic, run `/relay:run-playlist` again |
