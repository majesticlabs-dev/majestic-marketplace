# SQLite Administration Reference

## Production Configuration

```yaml
# config/database.yml
production:
  adapter: sqlite3
  database: storage/production.sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
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

## Maintenance

```ruby
# Reclaim space and defragment
ActiveRecord::Base.connection.execute("VACUUM")

# Rebuild statistics
ActiveRecord::Base.connection.execute("ANALYZE")

# Integrity check
result = ActiveRecord::Base.connection.execute("PRAGMA integrity_check")
raise "Database corruption" unless result.first["integrity_check"] == "ok"
```

## Size Management

```sql
-- Check database size
SELECT page_count * page_size as size_bytes
FROM pragma_page_count(), pragma_page_size();

-- Check table sizes
SELECT name, SUM(pgsize) as size
FROM dbstat GROUP BY name ORDER BY size DESC;
```
