# Beads Viewer (bv) Reference

High-performance terminal UI for Beads with dependency graph analysis and AI agent "robot mode".

## Prerequisites

- beads (`bd`) installed and initialized
- bv installed:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh | bash
  ```
- Verify: `which bv`

## Robot Mode Commands

AI-facing commands that return deterministic JSON output:

| Command | Purpose | Speed |
|---------|---------|-------|
| `bv --robot-help` | List all robot commands | Instant |
| `bv --robot-insights` | Graph metrics (PageRank, betweenness, HITS, critical path, cycles) | Phase 2 |
| `bv --robot-plan` | Execution plan: parallel tracks, unblocks lists | Phase 1 |
| `bv --robot-priority` | Priority recommendations with reasoning | Phase 2 |
| `bv --robot-recipes` | List available recipes (actionable, blocked, etc.) | Instant |
| `bv --robot-diff --diff-since <commit\|date>` | Issue changes, new/closed, cycles delta | Phase 2 |

## When to Use

| Scenario | Command |
|----------|---------|
| What should I work on next? | `bv --robot-plan` |
| Where are the bottlenecks? | `bv --robot-insights` |
| What changed since last sprint? | `bv --robot-diff --diff-since HEAD~10` |
| Pre-filter issues | `bv --recipe actionable --robot-plan` |

## Performance Tiers

bv uses two-phase startup:

| Phase | Metrics | Availability |
|-------|---------|--------------|
| Phase 1 | Degree, topo sort, basic stats | Instant |
| Phase 2 | PageRank, betweenness, HITS, cycles | Background (async) |

### Large Graphs (>500 nodes)

- Expensive metrics (betweenness) may be skipped
- Cycle detection limited to prevent blowup
- Check `--robot-insights` output for `skipped` flags
- All algorithms have 500ms timeouts

### Diagnostics

```bash
bv --profile-startup           # Timing breakdown
bv --profile-startup --profile-json  # Machine-readable
```

## Best Practices for Agents

1. **Use `--robot-plan` for immediate work** - Fast, Phase 1 only
2. **Use `--robot-insights` for analysis** - Waits for Phase 2
3. **Avoid `--force-full-analysis`** unless absolutely needed
4. **Handle partial data gracefully** - Check timeout flags
5. **Prefer bv over hand-rolled graph logic** - bv precomputes the hard parts

## vs bd CLI

| Need | Use |
|------|-----|
| Create/update/close issues | `bd` |
| List ready work | `bd ready` or `bv --robot-plan` |
| Graph analysis, bottlenecks | `bv --robot-insights` |
| Execution planning | `bv --robot-plan` |
| Dependency visualization | `bv` (interactive TUI) |
