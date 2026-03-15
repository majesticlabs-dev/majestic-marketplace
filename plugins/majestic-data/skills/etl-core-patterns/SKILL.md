---
name: etl-core-patterns
description: Core ETL reliability patterns including idempotency, checkpointing, error handling, chunking, retry logic, and logging.
allowed-tools: Read Write Edit Grep Glob Bash
---

# ETL Core Patterns

Reliability patterns for production data pipelines.

## Idempotency Patterns

```python
# Pattern 1: Delete-then-insert (simple, works for small datasets)
def load_daily_data(date: str, df: pd.DataFrame) -> None:
    with engine.begin() as conn:
        conn.execute(
            text("DELETE FROM daily_metrics WHERE date = :date"),
            {"date": date}
        )
        df.to_sql('daily_metrics', conn, if_exists='append', index=False)

# Pattern 2: UPSERT (better for large datasets)
def upsert_records(df: pd.DataFrame) -> None:
    for batch in chunked(df.to_dict('records'), 1000):
        stmt = insert(MyTable).values(batch)
        stmt = stmt.on_conflict_do_update(
            index_elements=['id'],
            set_={col: stmt.excluded[col] for col in update_cols}
        )
        session.execute(stmt)

# Pattern 3: Source hash for change detection
def extract_with_hash(df: pd.DataFrame) -> pd.DataFrame:
    hash_cols = ['id', 'name', 'value', 'updated_at']
    df['_row_hash'] = pd.util.hash_pandas_object(df[hash_cols])
    return df
```

## Checkpointing

```python
import json
from pathlib import Path

class Checkpoint:
    def __init__(self, path: str):
        self.path = Path(path)
        self.state = self._load()

    def _load(self) -> dict:
        if self.path.exists():
            return json.loads(self.path.read_text())
        return {}

    def save(self) -> None:
        self.path.write_text(json.dumps(self.state, default=str))

    def get_last_processed(self, key: str) -> str | None:
        return self.state.get(key)

    def set_last_processed(self, key: str, value: str) -> None:
        self.state[key] = value
        self.save()

# Usage
checkpoint = Checkpoint('.etl_checkpoint.json')
last_id = checkpoint.get_last_processed('users_sync')

for batch in fetch_users_since(last_id):
    process(batch)
    checkpoint.set_last_processed('users_sync', batch[-1]['id'])
```

## Error Handling

```python
from dataclasses import dataclass

@dataclass
class FailedRecord:
    source_id: str
    error: str
    raw_data: dict
    timestamp: datetime

class ETLProcessor:
    def __init__(self):
        self.failed_records: list[FailedRecord] = []

    def process_batch(self, records: list[dict]) -> list[dict]:
        processed = []
        for record in records:
            try:
                processed.append(self.transform(record))
            except Exception as e:
                self.failed_records.append(FailedRecord(
                    source_id=record.get('id', 'unknown'),
                    error=str(e),
                    raw_data=record,
                    timestamp=datetime.now()
                ))
        return processed

    def save_failures(self, path: str) -> None:
        if self.failed_records:
            df = pd.DataFrame([vars(r) for r in self.failed_records])
            df.to_parquet(f"{path}/failures_{datetime.now():%Y%m%d_%H%M%S}.parquet")

# Dead letter queue pattern
def process_with_dlq(records: list[dict], dlq_table: str) -> None:
    for record in records:
        try:
            process(record)
        except Exception as e:
            save_to_dlq(dlq_table, record, str(e))
```

## Chunked Processing

```python
from typing import Iterator, TypeVar

T = TypeVar('T')

def chunked(iterable: Iterator[T], size: int) -> Iterator[list[T]]:
    """Yield successive chunks from iterable."""
    batch = []
    for item in iterable:
        batch.append(item)
        if len(batch) >= size:
            yield batch
            batch = []
    if batch:
        yield batch

# Memory-efficient file processing
def process_large_csv(path: str, chunk_size: int = 50_000) -> None:
    for i, chunk in enumerate(pd.read_csv(path, chunksize=chunk_size)):
        print(f"Processing chunk {i}: {len(chunk)} rows")
        transformed = transform(chunk)
        load(transformed, mode='append')
        del chunk, transformed  # Explicit memory cleanup
        gc.collect()
```

## Retry Logic

```python
import time
from functools import wraps

def retry(max_attempts: int = 3, delay: float = 1.0, backoff: float = 2.0):
    """Decorator for retrying failed operations."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            current_delay = delay

            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_attempts - 1:
                        print(f"Attempt {attempt + 1} failed: {e}. Retrying in {current_delay}s")
                        time.sleep(current_delay)
                        current_delay *= backoff

            raise last_exception
        return wrapper
    return decorator

@retry(max_attempts=3, delay=1.0, backoff=2.0)
def fetch_from_api(url: str) -> dict:
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()
```

## Logging Best Practices

```python
import structlog

logger = structlog.get_logger()

def process_with_logging(batch_id: str, records: list[dict]) -> None:
    log = logger.bind(batch_id=batch_id, record_count=len(records))

    log.info("batch_started")

    try:
        result = process(records)
        log.info("batch_completed",
                 processed=result.processed_count,
                 failed=result.failed_count)
    except Exception as e:
        log.error("batch_failed", error=str(e))
        raise
```

## Data Migration Scripts

Create production-safe migration scripts with rollback and validation.

### Migration Template (PostgreSQL)

```sql
-- Migration: 20240115_add_customer_tier
-- Description: Add column and backfill from order history

-- PRE-MIGRATION CHECKS
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM customers) = 0 THEN
        RAISE EXCEPTION 'No customers found - aborting migration';
    END IF;
END $$;

CREATE TEMP TABLE migration_baseline AS
SELECT COUNT(*) as total_customers, NOW() as snapshot_time
FROM customers;

-- FORWARD MIGRATION
BEGIN;

ALTER TABLE customers ADD COLUMN IF NOT EXISTS tier VARCHAR(20);

-- Batch backfill
DO $$
DECLARE
    batch_size INT := 10000;
    affected INT;
BEGIN
    LOOP
        WITH batch AS (
            SELECT id FROM customers
            WHERE tier IS NULL
            LIMIT batch_size
            FOR UPDATE SKIP LOCKED
        )
        UPDATE customers c
        SET tier = CASE
            WHEN total_orders >= 100 THEN 'platinum'
            WHEN total_orders >= 50 THEN 'gold'
            WHEN total_orders >= 10 THEN 'silver'
            ELSE 'bronze'
        END
        FROM (
            SELECT customer_id, COUNT(*) as total_orders
            FROM orders GROUP BY customer_id
        ) o
        WHERE c.id = o.customer_id AND c.id IN (SELECT id FROM batch);

        GET DIAGNOSTICS affected = ROW_COUNT;
        EXIT WHEN affected = 0;
        COMMIT;
        BEGIN;
    END LOOP;
END $$;

ALTER TABLE customers ALTER COLUMN tier SET DEFAULT 'bronze';
ALTER TABLE customers ADD CONSTRAINT chk_tier
    CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum'));
COMMIT;

-- POST-MIGRATION VALIDATION
DO $$
DECLARE
    before_count INT;
    after_count INT;
BEGIN
    SELECT total_customers INTO before_count FROM migration_baseline;
    SELECT COUNT(*) INTO after_count FROM customers;
    IF before_count != after_count THEN
        RAISE EXCEPTION 'Row count mismatch: before=%, after=%', before_count, after_count;
    END IF;
END $$;
```

### Rollback Script

```sql
BEGIN;
ALTER TABLE customers DROP CONSTRAINT IF EXISTS chk_tier;
ALTER TABLE customers ALTER COLUMN tier DROP DEFAULT;
ALTER TABLE customers DROP COLUMN IF EXISTS tier;
COMMIT;
```

### Python Migration Framework

```python
@dataclass
class Migration:
    id: str
    description: str
    up: Callable
    down: Callable
    validate: Callable

class MigrationRunner:
    def __init__(self, engine):
        self.engine = engine

    def run(self, migration: Migration, dry_run: bool = False) -> bool:
        with self.engine.begin() as conn:
            baseline = self._capture_baseline(conn)
            if dry_run:
                return True
            try:
                migration.up(conn)
                if not migration.validate(conn, baseline):
                    raise ValueError("Validation failed")
                return True
            except Exception as e:
                migration.down(conn)
                raise
```

### Safe Migration Patterns

```sql
-- Adding a column: nullable first, backfill, then constraint
ALTER TABLE t ADD COLUMN new_col TYPE;
UPDATE t SET new_col = compute_value();
ALTER TABLE t ALTER COLUMN new_col SET NOT NULL;

-- Renaming a column: add new, copy, drop old
ALTER TABLE t ADD COLUMN new_name TYPE;
UPDATE t SET new_name = old_name;
ALTER TABLE t DROP COLUMN old_name;

-- Changing column type: add new, migrate, swap
ALTER TABLE t ADD COLUMN col_new NEWTYPE;
UPDATE t SET col_new = col::NEWTYPE;
ALTER TABLE t DROP COLUMN col;
ALTER TABLE t RENAME COLUMN col_new TO col;

-- Large table batch updates
DO $$
DECLARE
    batch_size INT := 10000;
    total_updated INT := 0;
BEGIN
    LOOP
        WITH batch AS (
            SELECT id FROM large_table
            WHERE needs_update = true
            LIMIT batch_size
        )
        UPDATE large_table SET ...
        WHERE id IN (SELECT id FROM batch);
        GET DIAGNOSTICS rows_affected = ROW_COUNT;
        total_updated := total_updated + rows_affected;
        EXIT WHEN rows_affected = 0;
        PERFORM pg_sleep(0.1);
    END LOOP;
END $$;
```

### Migration Safety Checklist

Before: tested on staging, rollback tested, backup taken, maintenance window scheduled.
After: validation queries passed, application health checked, performance normal.
