---
name: database-admin
description: PostgreSQL and SQLite database administration for Rails apps. Use when the user asks about backups, monitoring, connection pooling, vacuum/analyze, emergency procedures, restore testing, or production database health checks.
allowed-tools: Read Grep Glob Bash
---

# Database Admin

**Audience:** Rails operators managing PostgreSQL or SQLite in production.
**Goal:** Provide ready-to-run commands for backup, monitoring, connection management, and emergency recovery.

Detailed PostgreSQL commands: `references/postgresql.md`. SQLite commands: `references/sqlite.md`.

## PostgreSQL Quick Reference

| Task | Command |
|------|---------|
| Backup | `pg_dump -Fc -Z9 dbname > backup.dump` |
| Restore | `pg_restore -d dbname backup.dump` |
| Vacuum | `VACUUM ANALYZE` |
| Kill query | `SELECT pg_terminate_backend(pid)` |

### Monitoring Queries

```sql
-- Slow queries (requires pg_stat_statements)
SELECT calls, mean_exec_time, query FROM pg_stat_statements
ORDER BY total_exec_time DESC LIMIT 10;

-- Active connections
SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state;

-- Cache hit ratio (target > 99%)
SELECT sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit + heap_blks_read), 0)
FROM pg_statio_user_tables;

-- Table bloat
SELECT tablename, n_dead_tup FROM pg_stat_user_tables
WHERE n_dead_tup > 1000 ORDER BY n_dead_tup DESC;
```

### Connection Pooling

- PgBouncer with `pool_mode = transaction`
- Rails requires `prepared_statements: false` with PgBouncer

### Tools

| Tool | Purpose |
|------|---------|
| `pghero` gem | Slow queries, missing indexes dashboard |
| `pg_stat_statements` | Query performance tracking |
| `pganalyze` | Automated index recommendations |

## SQLite Quick Reference

### Production PRAGMAs

```ruby
ActiveRecord::Base.connection.execute("PRAGMA journal_mode=WAL")
ActiveRecord::Base.connection.execute("PRAGMA synchronous=NORMAL")
ActiveRecord::Base.connection.execute("PRAGMA busy_timeout=5000")
ActiveRecord::Base.connection.execute("PRAGMA cache_size=-64000")
```

### Backup Strategy

```ruby
ActiveRecord::Base.connection.execute("PRAGMA wal_checkpoint(TRUNCATE)")
FileUtils.cp(db_path, backup_path)
```

### Maintenance

```ruby
ActiveRecord::Base.connection.execute("VACUUM")
ActiveRecord::Base.connection.execute("ANALYZE")
```

## Backup Schedule

| Strategy | Frequency | Retention |
|----------|-----------|-----------|
| Hourly | Every hour | 24 hours |
| Daily | Midnight | 7 days |
| Weekly | Sunday | 4 weeks |
| Monthly | 1st of month | 12 months |

Test restores monthly. Untested backups don't exist.

## Data Lifecycle

| Strategy | When |
|----------|------|
| Archival tables | Move old data to `*_archive` |
| Table partitioning | Time-series data, instant partition drops |
| Materialized views | Pre-compute expensive aggregations |
| Rollups | Aggregate detail → summary tables |

## Emergency Procedures (PostgreSQL)

```sql
-- Kill long queries
SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE state = 'active' AND query_start < now() - interval '10 minutes';

-- Emergency read-only
ALTER DATABASE production SET default_transaction_read_only = on;
```

## Output Schema

```yaml
database_status:
  size_gb: number
  connections: { active: int, max: int }
  cache_hit_ratio: float    # 0.0–1.0
  dead_tuples: { total: int, tables: int }
issues:
  - title: string
    impact: critical | high | medium | low
    resolution: string      # specific commands
maintenance_recommendations:
  - action: string
    command: string
backup_status:
  last_backup: timestamp
  last_tested_restore: date
```

Always provide both PostgreSQL and SQLite alternatives where applicable.
