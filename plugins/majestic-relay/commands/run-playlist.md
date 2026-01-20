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

## Error Handling

| Scenario | Action |
|----------|--------|
| Playlist not found | Error with init-playlist suggestion |
| Epic file missing | Error before starting |
| Epic fails | Record failure, stop playlist |
| Ctrl+C | Save progress, exit cleanly |
| Resume after failure | Fix epic, run `/relay:run-playlist` again |
