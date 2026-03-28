# SQLite Administration Reference

## Production Configuration

```yaml
# config/database.yml
production:
  primary:
    adapter: sqlite3
    database: storage/production.sqlite3
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    timeout: 5000
  cache:
    adapter: sqlite3
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
  queue:
    adapter: sqlite3
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
  cable:
    adapter: sqlite3
    database: storage/production_cable.sqlite3
    migrations_paths: db/cable_migrate
```

```ruby
# config/initializers/sqlite_optimizations.rb
if ActiveRecord::Base.connection.adapter_name == "SQLite"
  ActiveRecord::Base.connection.execute("PRAGMA journal_mode=WAL")
  ActiveRecord::Base.connection.execute("PRAGMA synchronous=NORMAL")
  ActiveRecord::Base.connection.execute("PRAGMA busy_timeout=5000")
  ActiveRecord::Base.connection.execute("PRAGMA cache_size=-64000")
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys=ON")
  ActiveRecord::Base.connection.execute("PRAGMA temp_store=MEMORY")
end
```

## Backup

```ruby
# lib/tasks/sqlite_backup.rake
namespace :db do
  desc "Backup SQLite database"
  task backup: :environment do
    db_path = ActiveRecord::Base.connection_db_config.database
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    backup_path = "backups/production_#{timestamp}.sqlite3"

    # Checkpoint WAL before backup
    ActiveRecord::Base.connection.execute("PRAGMA wal_checkpoint(TRUNCATE)")

    FileUtils.cp(db_path, backup_path)
    puts "Backup created: #{backup_path}"
  end
end
```

## VACUUM Guide

### Why VACUUM Matters

SQLite doesn't automatically reclaim space from deleted rows. Without VACUUM:
- Database file grows but never shrinks
- Fragmentation degrades read performance
- Solid Queue and Solid Cache churn creates significant bloat

### VACUUM Types

| Type | Command | Lock | Use When |
|------|---------|------|----------|
| Full VACUUM | `VACUUM` | Exclusive (blocks all access) | Weekly maintenance window |
| VACUUM INTO | `VACUUM INTO 'path/to/new.db'` | Read lock only | Zero-downtime compaction |
| Incremental | `PRAGMA incremental_vacuum(N)` | Brief lock per page | Continuous, low-impact cleanup |
| Auto VACUUM | `PRAGMA auto_vacuum=INCREMENTAL` | Per-transaction | Set once, runs automatically |

### Full VACUUM

Rebuilds the entire database file. Most thorough but locks the database:

```ruby
# lib/tasks/sqlite_maintenance.rake
namespace :db do
  namespace :maintenance do
    desc "VACUUM all SQLite databases"
    task vacuum: :environment do
      databases = %w[primary cache queue]

      databases.each do |db_name|
        config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: db_name)
        next unless config&.adapter == "sqlite3"

        conn = ActiveRecord::Base.establish_connection(db_name.to_sym).connection
        before_size = File.size(config.database)
        conn.execute("VACUUM")
        conn.execute("ANALYZE")
        after_size = File.size(config.database)
        saved = before_size - after_size

        puts "#{db_name}: #{(before_size / 1.megabyte).round(1)}MB → #{(after_size / 1.megabyte).round(1)}MB (freed #{(saved / 1.megabyte).round(1)}MB)"
      end

      ActiveRecord::Base.establish_connection(:primary)
    end
  end
end
```

### VACUUM INTO (Zero-Downtime)

Creates a compacted copy without blocking writers:

```ruby
def vacuum_into(db_name)
  config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: db_name)
  conn = ActiveRecord::Base.establish_connection(db_name.to_sym).connection
  temp_path = "#{config.database}.vacuumed"

  conn.execute("VACUUM INTO '#{temp_path}'")

  # Atomic swap — brief window where DB is unavailable
  File.rename(temp_path, config.database)

  ActiveRecord::Base.establish_connection(:primary)
end
```

**Warning:** `VACUUM INTO` + rename is NOT atomic for active connections. Use full VACUUM during low-traffic windows instead, or stop the app briefly.

### Incremental VACUUM (Recommended for Production)

Set once, then trigger periodically with minimal locking:

```ruby
# config/initializers/sqlite_optimizations.rb
if ActiveRecord::Base.connection.adapter_name == "SQLite"
  # Enable incremental auto_vacuum (must be set before any data)
  ActiveRecord::Base.connection.execute("PRAGMA auto_vacuum=INCREMENTAL")
  # ... other PRAGMAs
end
```

```ruby
# Reclaim up to 1000 pages (~4MB with default 4096 page size)
ActiveRecord::Base.connection.execute("PRAGMA incremental_vacuum(1000)")
```

**Note:** `auto_vacuum` mode can only be set on an empty database. For existing databases, run full `VACUUM` once after setting the PRAGMA to convert.

### Per-Database VACUUM Strategy

| Database | Churn Level | Strategy | Frequency |
|----------|------------|----------|-----------|
| primary | Low-medium | Full VACUUM or incremental | Weekly |
| cache | Very high | Full VACUUM | Daily (Solid Cache expires entries constantly) |
| queue | High | Full VACUUM | Daily (Solid Queue completes/deletes jobs) |
| cable | Ephemeral | Skip VACUUM | Never (data expires in hours, DB stays small) |

### Scheduling with Solid Queue

```ruby
# app/jobs/database_maintenance_job.rb
class DatabaseMaintenanceJob < ApplicationJob
  queue_as :maintenance

  def perform(db_name = "primary")
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: db_name)
    return unless config&.adapter == "sqlite3"

    conn = ActiveRecord::Base.establish_connection(db_name.to_sym).connection
    conn.execute("VACUUM")
    conn.execute("ANALYZE")
    ActiveRecord::Base.establish_connection(:primary)

    Rails.logger.info("[maintenance] VACUUM #{db_name} complete")
  end
end
```

```yaml
# config/recurring.yml
vacuum_primary:
  class: DatabaseMaintenanceJob
  args: ["primary"]
  schedule: every Sunday at 3am

vacuum_cache:
  class: DatabaseMaintenanceJob
  args: ["cache"]
  schedule: every day at 3am

vacuum_queue:
  class: DatabaseMaintenanceJob
  args: ["queue"]
  schedule: every day at 3:15am
```

### WAL Interaction

- `VACUUM` requires an **exclusive lock** — blocks all readers and writers
- WAL checkpoint happens automatically before VACUUM
- Schedule during low-traffic windows (e.g., 3am)
- VACUUM on a WAL-mode database temporarily switches to rollback journal, then back

### Litestream Impact

- Full `VACUUM` rewrites the entire database — Litestream triggers a **full snapshot**
- This is expected and safe, but increases backup storage briefly
- Don't VACUUM all databases at the same time if bandwidth-constrained
- Stagger: primary at 3:00, cache at 3:15, queue at 3:30

### When to VACUUM

Monitor and trigger based on thresholds:

```ruby
# Check freelist pages (reclaimable space)
freelist = conn.execute("PRAGMA freelist_count").first["freelist_count"]
page_size = conn.execute("PRAGMA page_size").first["page_size"]
wasted_mb = (freelist * page_size) / 1.megabyte.to_f

# VACUUM if more than 100MB reclaimable
if wasted_mb > 100
  conn.execute("VACUUM")
end
```

## Size Management

```sql
-- Check database size
SELECT page_count * page_size as size_bytes
FROM pragma_page_count(), pragma_page_size();

-- Check freelist (reclaimable space)
SELECT freelist_count * page_size as reclaimable_bytes
FROM pragma_freelist_count(), pragma_page_size();

-- Check table sizes
SELECT name, SUM(pgsize) as size
FROM dbstat GROUP BY name ORDER BY size DESC;

-- WAL file size
SELECT * FROM pragma_wal_checkpoint;
```

## Integrity Check

```ruby
# Full integrity check (slow on large DBs)
result = ActiveRecord::Base.connection.execute("PRAGMA integrity_check")
raise "Database corruption" unless result.first["integrity_check"] == "ok"

# Quick check (faster, less thorough)
result = ActiveRecord::Base.connection.execute("PRAGMA quick_check")
raise "Database corruption" unless result.first["quick_check"] == "ok"
```

Schedule `quick_check` daily, full `integrity_check` weekly.
