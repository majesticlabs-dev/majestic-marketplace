---
name: etl-patterns
description: Production ETL patterns including idempotency, checkpointing, error handling, and backfill strategies.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# ETL-Patterns

Production-grade Extract-Transform-Load patterns for reliable data pipelines.

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
from typing import Any

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
            # Send to dead letter queue for later inspection
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

## Backfill Strategy

```python
from datetime import date, timedelta
from concurrent.futures import ThreadPoolExecutor

def backfill_date_range(
    start: date,
    end: date,
    process_fn: callable,
    parallel: int = 4
) -> None:
    """Backfill data for a date range."""
    dates = []
    current = start
    while current <= end:
        dates.append(current)
        current += timedelta(days=1)

    # Process in parallel with controlled concurrency
    with ThreadPoolExecutor(max_workers=parallel) as executor:
        futures = {executor.submit(process_fn, d): d for d in dates}
        for future in as_completed(futures):
            d = futures[future]
            try:
                future.result()
                print(f"Completed: {d}")
            except Exception as e:
                print(f"Failed: {d} - {e}")

# Usage
backfill_date_range(
    start=date(2024, 1, 1),
    end=date(2024, 3, 31),
    process_fn=process_daily_data,
    parallel=4
)
```

## Incremental Load Patterns

```python
# Pattern 1: Timestamp-based incremental
def incremental_by_timestamp(table: str, timestamp_col: str) -> pd.DataFrame:
    last_run = get_last_run_timestamp(table)
    query = f"""
        SELECT * FROM {table}
        WHERE {timestamp_col} > :last_run
        ORDER BY {timestamp_col}
    """
    df = pd.read_sql(query, engine, params={'last_run': last_run})
    if not df.empty:
        set_last_run_timestamp(table, df[timestamp_col].max())
    return df

# Pattern 2: Change Data Capture (CDC) style
def process_cdc_events(events: list[dict]) -> None:
    for event in events:
        op = event['operation']  # INSERT, UPDATE, DELETE
        data = event['data']

        if op == 'DELETE':
            soft_delete(data['id'])
        else:
            upsert(data)

# Pattern 3: Full refresh with swap
def full_refresh_with_swap(df: pd.DataFrame, table: str) -> None:
    temp_table = f"{table}_temp"
    df.to_sql(temp_table, engine, if_exists='replace', index=False)

    with engine.begin() as conn:
        conn.execute(text(f"DROP TABLE IF EXISTS {table}_old"))
        conn.execute(text(f"ALTER TABLE {table} RENAME TO {table}_old"))
        conn.execute(text(f"ALTER TABLE {temp_table} RENAME TO {table}"))
        conn.execute(text(f"DROP TABLE {table}_old"))
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

## Pipeline Orchestration

```python
from enum import Enum
from dataclasses import dataclass, field

class StepStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    SUCCESS = "success"
    FAILED = "failed"
    SKIPPED = "skipped"

@dataclass
class PipelineStep:
    name: str
    func: callable
    dependencies: list[str] = field(default_factory=list)
    status: StepStatus = StepStatus.PENDING
    error: str | None = None

class Pipeline:
    def __init__(self, name: str):
        self.name = name
        self.steps: dict[str, PipelineStep] = {}

    def add_step(self, name: str, func: callable, depends_on: list[str] = None):
        self.steps[name] = PipelineStep(name, func, depends_on or [])

    def run(self) -> bool:
        for step in self._topological_sort():
            # Skip if dependencies failed
            if any(self.steps[d].status == StepStatus.FAILED for d in step.dependencies):
                step.status = StepStatus.SKIPPED
                continue

            step.status = StepStatus.RUNNING
            try:
                step.func()
                step.status = StepStatus.SUCCESS
            except Exception as e:
                step.status = StepStatus.FAILED
                step.error = str(e)

        return all(s.status == StepStatus.SUCCESS for s in self.steps.values())
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
