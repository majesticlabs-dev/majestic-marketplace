---
name: majestic-relay:run-playlist
description: Output terminal command to execute playlist
argument-hint: "[playlist.yml]"
---

# Run Playlist

Output the terminal command to execute the playlist script. User runs it in a separate terminal.

## Input

```yaml
playlist_path: string  # Path to playlist.yml (default: .agents-os/relay/playlist.yml)
```

## Workflow

```
PLAYLIST_PATH = $ARGUMENTS or ".agents-os/relay/playlist.yml"

If not exists(PLAYLIST_PATH):
  Error: "No playlist found at {PLAYLIST_PATH}"
  Suggest: "Run `/majestic-relay:init-playlist` first"
  Exit

SCRIPT_PATH = "${CLAUDE_PLUGIN_ROOT}/scripts/relay/relay-playlist.sh"

Print:
  Run this command in a separate terminal:

  ```bash
  {SCRIPT_PATH} {PLAYLIST_PATH}
  ```

  Or with tmux (recommended for long runs):

  ```bash
  tmux new -s relay '{SCRIPT_PATH} {PLAYLIST_PATH}'
  ```

  Monitor progress:

  ```bash
  /majestic-relay:playlist-status
  ```
```

## Why Not Execute Directly?

- Playlist execution can take hours (multiple epics)
- Should run in dedicated terminal (tmux/screen)
- Survives Claude session disconnects
- User controls Ctrl+C directly
