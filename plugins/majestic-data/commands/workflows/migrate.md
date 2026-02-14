---
name: majestic-data:migrate
description: Generate or execute data migration scripts with safety checks.
argument-hint: "<action> [options]"
disable-model-invocation: true
---

# Data Migrate Command

Generate safe data migration scripts or execute migrations with validation.

## Actions

### `generate` - Create migration script

```bash
/data:migrate generate --source data.csv --target postgres --table orders
```

Generates:
- CREATE TABLE statement
- COPY/INSERT statements
- Rollback script
- Validation queries

### `plan` - Preview migration without executing

```bash
/data:migrate plan --migration migrations/20240115_add_tier.sql
```

Shows:
- What will be changed
- Estimated duration
- Risk assessment
- Rollback procedure

### `run` - Execute migration

```bash
/data:migrate run --migration migrations/20240115_add_tier.sql
```

Executes with:
- Pre-flight checks
- Transaction safety
- Progress tracking
- Post-validation

### `backfill` - Historical data backfill

```bash
/data:migrate backfill --table orders --column tier --range "2023-01-01:2024-01-01"
```

## Execution Flow

### For `generate`:

```
Task(subagent_type="majestic-data:transform:csv-to-sql",
     prompt="Generate migration scripts for loading CSV to database table")
```

Or:

```
Task(subagent_type="majestic-data:transform:migration-builder",
     prompt="Generate schema migration with safety checks")
```

### For `backfill`:

```
Task(subagent_type="majestic-data:workflow:backfill-planner",
     prompt="Plan and execute backfill operation for specified range")
```

## Output: Generate

```markdown
# Migration Generated

**Source:** orders.csv
**Target:** PostgreSQL / public.orders

## Files Created

1. `migrations/20240115_create_orders.sql` - Forward migration
2. `migrations/20240115_create_orders_rollback.sql` - Rollback script
3. `migrations/20240115_create_orders_validate.sql` - Validation queries

## Schema

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    total NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL
);
```

## Load Command

```bash
psql -d mydb -f migrations/20240115_create_orders.sql
```

## Validation

After migration, run:
```bash
psql -d mydb -f migrations/20240115_create_orders_validate.sql
```

Expected results:
- Row count: 52,340
- No null order_ids
- All statuses in allowed set
```

## Output: Plan

```markdown
# Migration Plan: 20240115_add_tier

## Summary

- **Type:** Schema change + backfill
- **Table:** customers
- **Estimated Duration:** 15 minutes
- **Risk Level:** 🟡 Medium

## Changes

1. Add column `tier VARCHAR(20)`
2. Backfill from order history
3. Add NOT NULL constraint
4. Add CHECK constraint

## Impact Analysis

- **Rows affected:** 125,000
- **Table lock:** Brief (ALTER ADD COLUMN)
- **Backfill:** Batched, no lock
- **Constraint:** Requires validation

## Dependencies

- Requires: orders table populated
- Blocks: None

## Rollback

```sql
ALTER TABLE customers DROP COLUMN tier;
```

## Recommendation

✅ Safe to proceed
- Run during low-traffic window
- Monitor query latency during backfill
```

## Output: Run

```markdown
# Migration Execution: 20240115_add_tier

**Started:** 2024-01-15 14:00:00 UTC
**Status:** ✅ SUCCESS

## Execution Log

| Step | Duration | Status |
|------|----------|--------|
| Pre-check: table exists | 0.1s | ✅ |
| Pre-check: column not exists | 0.1s | ✅ |
| Capture baseline | 0.5s | ✅ |
| Add column | 0.3s | ✅ |
| Backfill batch 1/13 | 45s | ✅ |
| Backfill batch 2/13 | 42s | ✅ |
| ... | ... | ... |
| Backfill batch 13/13 | 38s | ✅ |
| Add constraint | 2.1s | ✅ |
| Post-validation | 1.2s | ✅ |

**Total Duration:** 12m 34s

## Validation Results

| Check | Result |
|-------|--------|
| Row count unchanged | ✅ 125,000 |
| No null tiers | ✅ |
| Distribution reasonable | ✅ |

## Tier Distribution

| Tier | Count | Percentage |
|------|-------|------------|
| bronze | 75,000 | 60% |
| silver | 31,250 | 25% |
| gold | 12,500 | 10% |
| platinum | 6,250 | 5% |
```

## Safety Features

1. **Always generates rollback** - Never run a migration without undo
2. **Pre-flight checks** - Validates state before making changes
3. **Batched operations** - Large changes done in chunks
4. **Progress tracking** - See status during long migrations
5. **Post-validation** - Automated verification after completion
