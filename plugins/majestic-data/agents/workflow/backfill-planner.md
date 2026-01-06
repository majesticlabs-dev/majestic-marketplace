---
name: backfill-planner
description: Design and execute historical data backfill strategies with progress tracking.
color: purple
tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

# Backfill-Planner

Autonomous agent that plans and coordinates historical data backfill operations.

## Backfill Scenarios

### Full Table Reload
- Replace entire table with fresh data
- Use when: Schema changed, data corruption, initial load

### Incremental Backfill
- Process historical data in chunks
- Use when: Adding new derived columns, reprocessing with new logic

### Gap Filling
- Fill missing time periods
- Use when: Pipeline failures left gaps

### Point-in-Time Correction
- Fix specific records
- Use when: Identified data quality issues

## Planning Workflow

1. **Assess scope**
   - Date range to backfill
   - Data volume estimation
   - Resource requirements

2. **Design strategy**
   - Chunk size and parallelism
   - Dependency handling
   - Rollback approach

3. **Generate execution plan**
   - Ordered steps with checkpoints
   - Validation gates
   - Progress tracking

4. **Monitor execution**
   - Track completion percentage
   - Handle failures
   - Report progress

## Backfill Plan Template

```yaml
backfill:
  name: orders_tier_backfill
  description: Backfill customer_tier column for historical orders
  created: 2024-01-15
  requested_by: data-team

  scope:
    table: orders
    date_range:
      start: 2023-01-01
      end: 2024-01-01
    estimated_rows: 5_200_000
    estimated_duration: 4h

  strategy:
    type: incremental
    chunk_by: month
    chunk_size: ~500_000 rows
    parallelism: 4
    preserve_existing: true  # Don't overwrite already-filled values

  execution:
    pre_checks:
      - verify_source_data_exists
      - verify_target_column_exists
      - capture_baseline_metrics

    chunks:
      - id: chunk_01
        date_range: [2023-01-01, 2023-02-01]
        estimated_rows: 420_000
        status: pending

      - id: chunk_02
        date_range: [2023-02-01, 2023-03-01]
        estimated_rows: 380_000
        status: pending

      # ... more chunks

    post_checks:
      - verify_no_nulls_in_tier
      - verify_row_count_unchanged
      - compare_distribution_to_recent

  rollback:
    strategy: restore_from_backup
    backup_location: s3://backups/orders_pre_backfill/

  monitoring:
    progress_webhook: https://slack.../webhook
    update_frequency: per_chunk
```

## Execution Script

```python
from dataclasses import dataclass
from datetime import date, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
import logging

@dataclass
class BackfillChunk:
    id: str
    start_date: date
    end_date: date
    status: str = "pending"
    rows_processed: int = 0
    error: str = None

class BackfillExecutor:
    def __init__(self, config: dict):
        self.config = config
        self.chunks = self._create_chunks()
        self.logger = logging.getLogger(__name__)

    def _create_chunks(self) -> list[BackfillChunk]:
        """Generate chunks based on date range and chunk size."""
        chunks = []
        start = self.config['scope']['date_range']['start']
        end = self.config['scope']['date_range']['end']
        chunk_by = self.config['strategy']['chunk_by']

        current = start
        chunk_num = 1
        while current < end:
            if chunk_by == 'month':
                next_date = min(current + timedelta(days=32), end)
                next_date = next_date.replace(day=1)
            elif chunk_by == 'week':
                next_date = min(current + timedelta(weeks=1), end)
            else:  # day
                next_date = min(current + timedelta(days=1), end)

            chunks.append(BackfillChunk(
                id=f"chunk_{chunk_num:02d}",
                start_date=current,
                end_date=next_date
            ))
            current = next_date
            chunk_num += 1

        return chunks

    def run(self, process_chunk_fn: callable) -> dict:
        """Execute backfill with parallel chunk processing."""
        self.logger.info(f"Starting backfill: {len(self.chunks)} chunks")

        parallelism = self.config['strategy']['parallelism']

        with ThreadPoolExecutor(max_workers=parallelism) as executor:
            futures = {
                executor.submit(self._process_with_retry, chunk, process_chunk_fn): chunk
                for chunk in self.chunks
            }

            for future in as_completed(futures):
                chunk = futures[future]
                try:
                    result = future.result()
                    chunk.status = "success"
                    chunk.rows_processed = result['rows']
                    self._report_progress(chunk)
                except Exception as e:
                    chunk.status = "failed"
                    chunk.error = str(e)
                    self.logger.error(f"Chunk {chunk.id} failed: {e}")

        return self._generate_report()

    def _process_with_retry(self, chunk: BackfillChunk, fn: callable, max_retries: int = 3):
        """Process chunk with retry logic."""
        for attempt in range(max_retries):
            try:
                return fn(chunk.start_date, chunk.end_date)
            except Exception as e:
                if attempt == max_retries - 1:
                    raise
                self.logger.warning(f"Chunk {chunk.id} attempt {attempt + 1} failed, retrying...")
                time.sleep(2 ** attempt)  # Exponential backoff

    def _report_progress(self, chunk: BackfillChunk):
        """Report progress after each chunk."""
        completed = sum(1 for c in self.chunks if c.status == "success")
        total = len(self.chunks)
        pct = completed / total * 100
        self.logger.info(f"Progress: {completed}/{total} ({pct:.1f}%) - Completed {chunk.id}")

    def _generate_report(self) -> dict:
        """Generate final backfill report."""
        return {
            'total_chunks': len(self.chunks),
            'successful': sum(1 for c in self.chunks if c.status == "success"),
            'failed': sum(1 for c in self.chunks if c.status == "failed"),
            'total_rows': sum(c.rows_processed for c in self.chunks),
            'chunks': [
                {
                    'id': c.id,
                    'date_range': f"{c.start_date} to {c.end_date}",
                    'status': c.status,
                    'rows': c.rows_processed,
                    'error': c.error
                }
                for c in self.chunks
            ]
        }
```

## Progress Report

```markdown
# Backfill Progress: orders_tier_backfill

**Started:** 2024-01-15 14:00:00 UTC
**Current Status:** 🔄 IN PROGRESS

## Progress

█████████████░░░░░░░░░░░░ 52% (7/12 chunks)

| Chunk | Date Range | Rows | Status | Duration |
|-------|------------|------|--------|----------|
| chunk_01 | Jan 2023 | 420,340 | ✅ | 18m |
| chunk_02 | Feb 2023 | 382,120 | ✅ | 16m |
| chunk_03 | Mar 2023 | 445,670 | ✅ | 19m |
| chunk_04 | Apr 2023 | 412,890 | ✅ | 17m |
| chunk_05 | May 2023 | 398,450 | ✅ | 17m |
| chunk_06 | Jun 2023 | 425,120 | ✅ | 18m |
| chunk_07 | Jul 2023 | 478,230 | ✅ | 20m |
| chunk_08 | Aug 2023 | - | 🔄 | - |
| chunk_09 | Sep 2023 | - | ⏳ | - |
| chunk_10 | Oct 2023 | - | ⏳ | - |
| chunk_11 | Nov 2023 | - | ⏳ | - |
| chunk_12 | Dec 2023 | - | ⏳ | - |

**Rows Processed:** 2,962,820 / ~5,200,000
**Elapsed Time:** 2h 5m
**Estimated Remaining:** 1h 55m
```

## Validation Gates

```python
def pre_backfill_checks(config: dict) -> bool:
    """Run checks before backfill starts."""
    checks = [
        ("Source data exists", check_source_exists),
        ("Target column exists", check_column_exists),
        ("Backup created", check_backup_exists),
        ("No concurrent backfills", check_no_locks),
    ]

    for name, check_fn in checks:
        if not check_fn(config):
            raise ValueError(f"Pre-check failed: {name}")

    return True

def post_backfill_checks(config: dict, result: dict) -> bool:
    """Run checks after backfill completes."""
    checks = [
        ("All chunks succeeded", lambda: result['failed'] == 0),
        ("Row count unchanged", check_row_count),
        ("No null values in tier", check_no_nulls),
        ("Distribution reasonable", check_distribution),
    ]

    for name, check_fn in checks:
        if not check_fn():
            raise ValueError(f"Post-check failed: {name}")

    return True
```
