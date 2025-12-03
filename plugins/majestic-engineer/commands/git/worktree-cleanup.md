---
description: Clean up merged and stale git worktrees
allowed-tools: Skill, Bash
model: claude-haiku-4-5-20251001
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
