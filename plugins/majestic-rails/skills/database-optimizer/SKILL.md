---
name: database-optimizer
description: Optimize PostgreSQL/SQLite query performance for Rails. Use for EXPLAIN ANALYZE interpretation, composite/partial/expression/covering/GIN/GiST/BRIN index design, N+1 detection, eager loading strategy, and ActiveRecord batch processing.
allowed-tools: Read Grep Glob Bash
---

# Database Optimizer

**Audience:** Rails developers tuning query performance.
**Goal:** Diagnose slow queries with EXPLAIN ANALYZE, then prescribe specific index/query/AR fixes.

Detailed patterns (mechanical sympathy, complex SQL, pagination): `references/patterns.md`.

## Measure First

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT users.*, COUNT(orders.id) AS order_count
FROM users
LEFT JOIN orders ON orders.user_id = users.id
WHERE users.created_at > '2024-01-01'
GROUP BY users.id;
```

Key metrics: Seq Scan vs Index Scan, rows estimated vs actual, Buffers shared hit vs read.

```ruby
# Rails integration
User.where(active: true).includes(:orders).explain(:analyze)
```

## Index Design

### Composite (column order matters)

```ruby
# WHERE status = ? AND created_at > ? ORDER BY priority
add_index :tasks, [:status, :priority, :created_at]
```

### Partial (PostgreSQL)

```ruby
add_index :users, :email, where: "deleted_at IS NULL", name: "index_active_users_email"
add_index :jobs, :priority, where: "status = 'pending'"
```

### Expression

```ruby
add_index :users, 'LOWER(email)', name: 'index_users_on_lower_email'
add_index :products, "(metadata->>'category')", name: 'index_products_on_category'
```

### Covering (index-only scans)

```ruby
add_index :orders, [:user_id, :created_at], include: [:total, :status]
```

### GIN (JSONB / arrays)

```ruby
add_index :products, :metadata, using: :gin
add_index :products, :metadata, using: :gin, opclass: :jsonb_path_ops
```

### GiST (range / geometric / exclusion)

```ruby
add_index :reservations, :date_range, using: :gist
add_index :locations, :coordinates, using: :gist

execute <<-SQL
  ALTER TABLE reservations
  ADD CONSTRAINT no_overlap
  EXCLUDE USING gist (room_id WITH =, date_range WITH &&);
SQL
```

Use GiST for: range queries, geometric/spatial data, nearest-neighbor, exclusion constraints.

### BRIN (large correlated tables)

```ruby
add_index :events, :created_at, using: :brin
add_index :logs, :timestamp, using: :brin, with: { pages_per_range: 32 }
```

Tradeoffs: 100x smaller than B-tree, fast writes, less precise. Best for append-only >10M rows.

## Query Hints (sparingly)

```sql
SET LOCAL enable_seqscan = off;
SELECT * FROM large_table WHERE indexed_col = 'value';
RESET enable_seqscan;
```

If hints are needed regularly, statistics are stale or indexes are missing.

## ActiveRecord

```ruby
User.includes(:orders, :profile)                      # AR decides
User.preload(:orders).where(active: true)             # separate queries
User.eager_load(:orders).where("orders.total > 100")  # LEFT JOIN
User.strict_loading.includes(:orders)                 # prevent N+1 in dev

User.find_each(batch_size: 1000) { |u| process(u) }
User.in_batches(of: 1000).update_all(processed: true)

User.pluck(:email)   # not User.all.map(&:email)
User.count           # not User.all.size
```

## Workflow

1. Identify slow queries → logs or `pg_stat_statements`
2. EXPLAIN ANALYZE the suspect query
3. Inspect index usage: missing, unused, bloated
4. Compare row estimates vs actual → stale stats need ANALYZE
5. Flag sequential scans on large tables
6. Check buffer stats for disk I/O
7. Prescribe specific fix (index, rewrite, eager-load) with expected impact
8. Validate in staging with prod-like volume

## Output Schema

```yaml
analysis:
  query: string                # SQL or AR code
  current_time_ms: number
  bottleneck: string           # e.g. "seq scan on orders (1.2M rows)"
recommendations:
  - title: string
    impact: high | medium | low
    implementation: string     # code/SQL
    expected_time_ms: number
```
