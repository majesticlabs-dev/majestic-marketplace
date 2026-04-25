# PostgreSQL Administration Reference

## Backup Commands

```bash
# Full database backup (compressed)
pg_dump -Fc -Z9 -h localhost -U app_user -d production_db > backup_$(date +%Y%m%d_%H%M%S).dump

# Schema only
pg_dump -s -h localhost -U app_user -d production_db > schema.sql

# Exclude large tables
pg_dump -Fc --exclude-table='logs' --exclude-table='events' production_db > backup.dump

# Restore from custom format
pg_restore -d production_db -c --if-exists backup.dump

# Parallel restore (faster)
pg_restore -d production_db -j 4 backup.dump
```

## Rails Backup Task

```ruby
# lib/tasks/db_backup.rake
namespace :db do
  desc "Backup database to S3"
  task backup: :environment do
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    filename = "backup_#{timestamp}.dump"
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    system(
      "PGPASSWORD=#{config[:password]} pg_dump",
      "-Fc", "-Z9", "-h", config[:host],
      "-U", config[:username], "-d", config[:database],
      "-f", filename
    )

    S3Bucket.upload(filename)
    File.delete(filename)
  end
end
```

## Connection Pooling

### database.yml
```yaml
production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  checkout_timeout: 5
  idle_timeout: 300
  variables:
    statement_timeout: 30000
```

### PgBouncer Setup
```ini
# pgbouncer.ini
[databases]
production = host=localhost port=5432 dbname=production_db

[pgbouncer]
listen_port = 6432
pool_mode = transaction
default_pool_size = 20
max_client_conn = 100
```

Rails with PgBouncer requires `prepared_statements: false`.

## Monitoring Queries

### Slow Queries (pg_stat_statements)
```sql
SELECT
  round(total_exec_time::numeric, 2) AS total_time_ms,
  calls,
  round(mean_exec_time::numeric, 2) AS mean_ms,
  substring(query, 1, 100) AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
```

### Connection Stats
```sql
SELECT datname, usename, state, COUNT(*) as count
FROM pg_stat_activity
GROUP BY datname, usename, state;
```

### Long-Running Queries
```sql
SELECT pid, now() - query_start AS duration, query, state
FROM pg_stat_activity
WHERE state != 'idle' AND query_start < now() - interval '5 minutes';

-- Kill: SELECT pg_terminate_backend(pid);
```

### Cache Hit Ratio
```sql
SELECT sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit) + sum(heap_blks_read), 0) AS ratio
FROM pg_statio_user_tables;  -- Should be > 99%
```

## Rails Slow Query Monitoring

### ActiveSupport Notifications

Subscribe to SQL events and alert on slow queries:

```ruby
# config/initializers/slow_query_monitor.rb
class SlowQueryError < StandardError; end

SLOW_QUERY_THRESHOLD = ENV.fetch("SLOW_QUERY_THRESHOLD_SECONDS", 3).to_f

ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, start, finish, _id, payload|
  duration = finish.to_f - start.to_f

  next if duration < SLOW_QUERY_THRESHOLD
  next if payload[:name] == "SCHEMA"  # Skip schema queries

  # Send to error tracker
  Honeybadger.notify(
    SlowQueryError.new(payload[:sql].to_s.truncate(500)),
    context: {
      duration_seconds: duration.round(2),
      sql: payload[:sql].to_s.truncate(2000),
      name: payload[:name],
      binds: payload[:binds]&.map { |b| [b.name, b.value] }
    }
  )

  # Also log locally
  Rails.logger.warn("[SLOW QUERY] #{duration.round(2)}s: #{payload[:sql].truncate(200)}")
end
```

### Structured Logging Version

For JSON logging pipelines (DataDog, CloudWatch, etc.):

```ruby
# config/initializers/query_logger.rb
ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, start, finish, _id, payload|
  duration_ms = ((finish - start) * 1000).round(2)

  next if duration_ms < 1000  # Only log queries > 1s
  next if payload[:name] == "SCHEMA"

  Rails.logger.info({
    event: "slow_query",
    duration_ms: duration_ms,
    query: payload[:sql].to_s.truncate(1000),
    name: payload[:name],
    cached: payload[:cached] || false
  }.to_json)
end
```

### With Sampling for High-Traffic Apps

```ruby
# config/initializers/query_sampler.rb
SAMPLE_RATE = ENV.fetch("QUERY_SAMPLE_RATE", 0.01).to_f  # 1% of queries

ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, start, finish, _id, payload|
  duration = finish.to_f - start.to_f

  # Always capture very slow queries, sample normal ones
  should_log = duration > 5.0 || rand < SAMPLE_RATE

  next unless should_log
  next if payload[:name] == "SCHEMA"

  QueryMetric.create_async(
    duration_ms: (duration * 1000).round,
    query_fingerprint: Digest::MD5.hexdigest(payload[:sql].to_s),
    query_sample: payload[:sql].to_s.truncate(500)
  )
end
```

## Maintenance

### VACUUM and ANALYZE
```sql
VACUUM ANALYZE;  -- Routine maintenance
VACUUM FULL table_name;  -- Full vacuum (locks table)

-- Check bloat
SELECT tablename, n_dead_tup, n_live_tup,
  round(n_dead_tup::numeric / NULLIF(n_live_tup, 0) * 100, 2) AS dead_ratio
FROM pg_stat_user_tables WHERE n_dead_tup > 1000;
```

### Autovacuum Tuning
```sql
-- Per-table for hot tables
ALTER TABLE events SET (
  autovacuum_vacuum_scale_factor = 0.01,
  autovacuum_vacuum_cost_limit = 2000
);

-- Monitor autovacuum
SELECT relname, last_autovacuum, n_dead_tup FROM pg_stat_user_tables;
```

### Index Maintenance
```sql
-- Unused indexes
SELECT indexrelname, pg_size_pretty(pg_relation_size(indexrelid)), idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan < 50 AND NOT indisunique;

-- Rebuild bloated index
REINDEX INDEX CONCURRENTLY index_name;
```

## Table Partitioning
```sql
CREATE TABLE events (
  id bigserial, event_type varchar(50), payload jsonb,
  created_at timestamptz NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2024_01 PARTITION OF events
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

DROP TABLE events_2023_01;  -- Instant cleanup
```

## Materialized Views
```sql
CREATE MATERIALIZED VIEW daily_sales AS
SELECT date_trunc('day', created_at) AS day, SUM(total) as revenue
FROM orders GROUP BY 1;

REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales;
```

## Emergency Procedures

```sql
-- Kill runaway queries
SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE state = 'active' AND query_start < now() - interval '10 minutes';

-- Emergency read-only mode
ALTER DATABASE production SET default_transaction_read_only = on;
```
