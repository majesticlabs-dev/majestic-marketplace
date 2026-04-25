# Database Optimizer Patterns Reference

## Aggregate Functions

### Conditional Aggregation with FILTER

PostgreSQL's `FILTER` clause is cleaner than `CASE WHEN` for conditional counts:

```sql
-- Instead of verbose CASE WHEN
SELECT
  COUNT(*) as "All Users",
  COUNT(CASE WHEN verified THEN 1 END) AS "Verified",
  COUNT(CASE WHEN NOT verified THEN 1 END) AS "Unverified"
FROM users;

-- Use FILTER (PostgreSQL 9.4+)
SELECT
  COUNT(*) as "All Users",
  COUNT(*) FILTER (WHERE verified) AS "Verified Users",
  COUNT(*) FILTER (WHERE NOT verified) AS "Unverified Users"
FROM users;
```

Works with any aggregate function:

```sql
SELECT
  department,
  AVG(salary) AS avg_salary,
  AVG(salary) FILTER (WHERE tenure_years > 5) AS avg_senior_salary,
  SUM(bonus) FILTER (WHERE performance = 'A') AS top_performer_bonuses
FROM employees
GROUP BY department;
```

Rails scope example:

```ruby
scope :with_verification_stats, -> {
  select(<<~SQL)
    COUNT(*) as total_count,
    COUNT(*) FILTER (WHERE verified) as verified_count,
    COUNT(*) FILTER (WHERE NOT verified) as unverified_count
  SQL
}
```

### Period-Over-Period Comparisons with LAG/LEAD

Use `LAG()` to compare current values with previous periods:

```sql
WITH monthly_stats AS (
  SELECT
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS signups,
    SUM(CASE WHEN subscribed THEN 1 ELSE 0 END) AS subscribers
  FROM users
  GROUP BY 1
  ORDER BY 1 DESC
)
SELECT
  month::date,
  signups,
  LAG(signups, 1) OVER (ORDER BY month) AS prev_month_signups,
  LAG(signups, 12) OVER (ORDER BY month) AS prev_year_signups,
  subscribers,
  LAG(subscribers, 12) OVER (ORDER BY month) AS prev_year_subscribers
FROM monthly_stats;
```

Calculate growth rates:

```sql
WITH monthly AS (
  SELECT DATE_TRUNC('month', created_at) AS month, COUNT(*) AS signups
  FROM users GROUP BY 1
)
SELECT
  month::date,
  signups,
  LAG(signups, 1) OVER w AS prev_month,
  ROUND((signups - LAG(signups, 1) OVER w)::numeric /
        NULLIF(LAG(signups, 1) OVER w, 0) * 100, 1) AS mom_growth_pct,
  LAG(signups, 12) OVER w AS prev_year,
  ROUND((signups - LAG(signups, 12) OVER w)::numeric /
        NULLIF(LAG(signups, 12) OVER w, 0) * 100, 1) AS yoy_growth_pct
FROM monthly
WINDOW w AS (ORDER BY month);
```

Rails integration:

```ruby
# app/models/user.rb
def self.monthly_growth_report
  sql = <<~SQL
    WITH monthly AS (
      SELECT DATE_TRUNC('month', created_at) AS month, COUNT(*) AS signups
      FROM users GROUP BY 1
    )
    SELECT
      month::date,
      signups,
      LAG(signups, 1) OVER (ORDER BY month) AS prev_month,
      LAG(signups, 12) OVER (ORDER BY month) AS prev_year
    FROM monthly
    ORDER BY month DESC
    LIMIT 24
  SQL
  connection.select_all(sql).to_a
end
```

## Mechanical Sympathy

Understanding *why* patterns are slow helps you make better optimization decisions.

### Pages and Buffers

PostgreSQL reads 8KB pages, not individual rows:

```
┌─────────────────────────────────────────────────┐
│  Page (8KB)                                     │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │ Row 1  │ │ Row 2  │ │ Row 3  │ │ Row 4  │   │
│  └────────┘ └────────┘ └────────┘ └────────┘   │
└─────────────────────────────────────────────────┘
```

- **Sequential scan**: Reads pages in order (fast—OS prefetches next pages)
- **Index scan**: Random I/O to fetch individual pages (slower per-row)
- **Small tables**: Seq scan often beats index scan (fewer total pages)
- **Buffers: shared hit**: Data found in memory (fast)
- **Buffers: read**: Data read from disk (slow)

### MVCC and Dead Tuples

PostgreSQL's Multi-Version Concurrency Control:

```
UPDATE users SET name = 'New' WHERE id = 1;

Before:  [id=1, name='Old', xmax=NULL]  ← visible
After:   [id=1, name='Old', xmax=100]   ← dead tuple (invisible)
         [id=1, name='New', xmin=100]   ← new version (visible)
```

- **UPDATE** creates new row version, marks old as dead
- **DELETE** marks row dead but doesn't reclaim space
- **VACUUM** reclaims dead tuples
- High-churn tables accumulate bloat without adequate vacuum

### HOT Updates (Heap-Only Tuples)

Updates that don't change indexed columns can be "HOT":

```ruby
# HOT-eligible: no indexed columns change
user.update!(last_seen_at: Time.current)

# NOT HOT: email is indexed
user.update!(email: "new@example.com")
```

- HOT updates avoid index maintenance (faster)
- Keep `fillfactor < 100` for HOT-eligible tables
- Check effectiveness:
  ```sql
  SELECT relname, n_tup_hot_upd, n_tup_upd,
         round(n_tup_hot_upd::numeric / NULLIF(n_tup_upd, 0) * 100) AS hot_pct
  FROM pg_stat_user_tables
  WHERE n_tup_upd > 1000
  ORDER BY n_tup_upd DESC;
  ```

### Why Common Patterns Are Slow

| Pattern | Problem |
|---------|---------|
| `SELECT *` | Reads more pages than needed, prevents index-only scans |
| Large `IN` lists | Planner can't optimize, sequential scan likely |
| `NOT IN` with NULLs | Semantic issues + full table scan |
| Lazy loading | Network round-trips dominate (N+1) |
| `OFFSET 10000` | Scans and discards 10000 rows |
| Unbounded `ORDER BY` | Sorts entire result set |

## Complex SQL Patterns

### Common Table Expressions (CTEs)

```ruby
# Hierarchical data traversal
scope :with_ancestors, -> {
  from(<<~SQL)
    WITH RECURSIVE ancestors AS (
      SELECT * FROM categories WHERE id = #{id}
      UNION ALL
      SELECT c.* FROM categories c
      JOIN ancestors a ON c.id = a.parent_id
    )
    SELECT * FROM ancestors
  SQL
}

# Reusable subquery
sql = <<~SQL
  WITH recent_orders AS (
    SELECT user_id, COUNT(*) as order_count, SUM(total) as total_spent
    FROM orders
    WHERE created_at > NOW() - INTERVAL '30 days'
    GROUP BY user_id
  )
  SELECT users.*, ro.order_count, ro.total_spent
  FROM users
  JOIN recent_orders ro ON ro.user_id = users.id
  WHERE ro.order_count >= 5
SQL
User.find_by_sql(sql)
```

### Window Functions

```ruby
# Running totals and rankings
scope :with_running_balance, -> {
  select(<<~SQL)
    transactions.*,
    SUM(amount) OVER (
      PARTITION BY account_id
      ORDER BY created_at
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_balance,
    ROW_NUMBER() OVER (
      PARTITION BY account_id
      ORDER BY created_at DESC
    ) as recency_rank
  SQL
}

# Percentiles and rankings
scope :with_percentile, -> {
  select(<<~SQL)
    products.*,
    PERCENT_RANK() OVER (ORDER BY price) as price_percentile,
    NTILE(4) OVER (ORDER BY price) as price_quartile
  SQL
}
```

### Lateral Joins (PostgreSQL - Top N per Group)

```ruby
# Get last 3 orders per user efficiently
sql = <<~SQL
  SELECT users.*, recent_orders.*
  FROM users
  CROSS JOIN LATERAL (
    SELECT * FROM orders
    WHERE orders.user_id = users.id
    ORDER BY created_at DESC
    LIMIT 3
  ) AS recent_orders
  WHERE users.active = true
SQL
```

## PostgreSQL-Specific Optimization

### JSONB Query Optimization

```ruby
# Containment (uses GIN index)
Product.where("metadata @> ?", { category: "electronics" }.to_json)

# Key existence
Product.where("metadata ? 'discount'")

# Path queries
Product.where("metadata #>> '{specs,weight}' < ?", "500")

# Array contains
Product.where("tags @> ARRAY[?]::varchar[]", ["featured", "sale"])
```

### Array Operations

```ruby
# Array overlap (any match)
Product.where("tags && ARRAY[?]::varchar[]", ["electronics", "sale"])

# Array contains all
Product.where("tags @> ARRAY[?]::varchar[]", ["premium", "featured"])

# Unnest for joins
Product.joins(<<~SQL)
  JOIN LATERAL unnest(tag_ids) AS t(tag_id) ON true
SQL
```

### Upsert (INSERT ON CONFLICT)

```ruby
# Atomic upsert with returning
Product.upsert(
  { sku: "ABC123", name: "Widget", price: 29.99 },
  unique_by: :sku,
  on_duplicate: Arel.sql("price = EXCLUDED.price, updated_at = NOW()"),
  returning: %w[id created_at updated_at]
)

# Bulk upsert
Product.upsert_all(products, unique_by: :sku)
```

## Pagination Strategies

### Offset Pagination Problems

```ruby
# Page 500 of results
User.order(:created_at).offset(10000).limit(20)

# PostgreSQL must:
# 1. Scan 10,020 rows
# 2. Discard 10,000 rows
# 3. Return 20 rows
# Performance degrades linearly with page number
```

Additional issues:
- Row insertions/deletions between pages cause duplicates or skipped items
- No way to "bookmark" position

### Keyset (Cursor) Pagination

```ruby
# First page
User.order(:created_at, :id).limit(20)

# Next pages - use last item as cursor
User.where("(created_at, id) > (?, ?)", last_created_at, last_id)
    .order(:created_at, :id)
    .limit(20)

# Simplified for single column (if unique)
User.where("id > ?", last_id).order(:id).limit(20)
```

Benefits:
- Constant performance regardless of "page" number
- Stable results (no duplicates/skips)
- Uses index efficiently

### pagy gem (Recommended)

```ruby
# Gemfile
gem "pagy"

# Controller - standard offset pagination
@pagy, @users = pagy(User.order(:created_at))

# Keyset pagination (pagy-keyset)
@pagy, @users = pagy_keyset(User.order(:id), limit: 20)

# In view
<%== pagy_nav(@pagy) %>
```

Why pagy:
- 40x faster than Kaminari/will_paginate for large offsets
- Lower memory usage
- Keyset pagination support via pagy-keyset

## Query Rewriting Patterns

### Subquery to JOIN

```ruby
# SLOW: Correlated subquery
User.where("EXISTS (SELECT 1 FROM orders WHERE orders.user_id = users.id AND orders.total > 100)")

# FASTER: JOIN with DISTINCT
User.joins(:orders).where("orders.total > 100").distinct
```

### OR to UNION

```ruby
# SLOW: OR prevents index use
User.where("email = ? OR phone = ?", email, phone)

# FASTER: UNION uses both indexes
User.where(email: email).or(User.where(phone: phone))
# Or explicit UNION for complex cases
User.from("(#{User.where(email: email).to_sql} UNION #{User.where(phone: phone).to_sql}) AS users")
```

### NOT IN to NOT EXISTS

```ruby
# SLOW: NOT IN with NULLs is problematic
User.where("id NOT IN (SELECT user_id FROM banned_users)")

# FASTER: NOT EXISTS handles NULLs correctly
User.where("NOT EXISTS (SELECT 1 FROM banned_users WHERE banned_users.user_id = users.id)")
```

## SQLite Optimization

### SQLite-Specific Considerations

```ruby
# Use WAL mode for concurrent reads
ActiveRecord::Base.connection.execute("PRAGMA journal_mode=WAL")

# Optimize for read-heavy workloads
ActiveRecord::Base.connection.execute("PRAGMA synchronous=NORMAL")
ActiveRecord::Base.connection.execute("PRAGMA cache_size=-64000") # 64MB

# Analyze tables for query planner
ActiveRecord::Base.connection.execute("ANALYZE")
```

### SQLite Index Strategies

```ruby
# Covering index (SQLite 3.31+)
execute "CREATE INDEX idx_orders_user_date ON orders(user_id, created_at) INCLUDE (total)"

# Expression index
execute "CREATE INDEX idx_users_email_lower ON users(LOWER(email))"
```
