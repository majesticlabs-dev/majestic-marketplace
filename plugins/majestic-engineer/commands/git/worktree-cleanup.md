---
name: git:worktree-cleanup
description: Clean up merged and stale git worktrees
allowed-tools: Bash
model: haiku
disable-model-invocation: true
---

# Worktree Cleanup

Use the git-worktree skill to clean up merged and stale worktrees:

```
skill git-worktree
```

Then run:
```bash
worktree-manager.sh cleanup
```

Report what was cleaned up.
