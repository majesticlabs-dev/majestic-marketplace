---
name: git-worktree
description: Manage git worktrees for parallel development. Use when the user wants to work on multiple branches simultaneously, create isolated environments for features/fixes, or clean up completed worktrees.
---

# Git Worktree Manager

## Overview

This skill provides a unified interface for managing git worktrees, enabling isolated parallel development. Worktrees allow you to have multiple branches checked out simultaneously in separate directories.

## When to Use This Skill

- Creating isolated environments for feature development
- Working on multiple branches simultaneously
- Reviewing PRs without stashing current work
- Cleaning up completed feature branches

## Core Commands

All operations use the unified `worktree-manager.sh` script (located in this skill's `scripts/` folder):

```bash
./scripts/worktree-manager.sh <command> [options]
```

### Create Worktree

```bash
worktree-manager.sh create <branch-name> [source-branch]
```

Creates a new worktree in `.worktrees/<branch-name>`. If the branch exists, it checks it out. If not, creates a new branch from the source (defaults to main/master).

### List Worktrees

```bash
worktree-manager.sh list
```

Shows all worktrees with their branch, commit, and status (clean/dirty/missing).

### Switch Worktree

```bash
worktree-manager.sh switch <branch-name|path>
```

Provides information for switching to a worktree by branch name or path.

### Cleanup Worktrees

```bash
worktree-manager.sh cleanup [--force]
```

Identifies and removes:
- Worktrees with merged branches
- Worktrees with deleted remote branches
- Missing worktree directories

Use `--force` to skip confirmation prompt.

## Storage

Worktrees are stored in `.worktrees/` within the repository root. This directory is automatically added to `.gitignore`.

## Example Workflow

```bash
# Start new feature
worktree-manager.sh create feature-auth

# Work in the new worktree
cd .worktrees/feature-auth

# List all worktrees
worktree-manager.sh list

# When done, clean up
worktree-manager.sh cleanup
```
