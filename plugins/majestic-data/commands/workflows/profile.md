---
name: majestic-data:profile
description: Generate comprehensive data profile for a file or table.
argument-hint: "<file-path-or-table>"
disable-model-invocation: true
---

# Data Profile Command

Generate a comprehensive statistical profile of a dataset.

## Arguments

**Target:** `$ARGUMENTS`

Parse the target:
- If file path (ends in .csv, .parquet, .json): Profile the file
- If table reference (schema.table or just table): Profile from database
- If empty: Ask user for target

## Execution

### Step 1: Load Data Sample

```python
# Determine file type and load
if target.endswith('.csv'):
    df = pd.read_csv(target, nrows=10000)  # Sample for large files
elif target.endswith('.parquet'):
    df = pd.read_parquet(target)
elif target.endswith('.json'):
    df = pd.read_json(target, lines=True, nrows=10000)
else:
    # Assume database table
    df = pd.read_sql(f"SELECT * FROM {target} LIMIT 10000", engine)
```

### Step 2: Generate Profile

Invoke the data-profiler agent:

```
Task(subagent_type="majestic-data:research:data-profiler",
     prompt="Profile this dataset and generate comprehensive statistics report")
```

### Step 3: Output Report

Generate report in Markdown format with:

1. **Summary Section**
   - Row count, column count
   - Memory usage
   - Data types breakdown

2. **Column Profiles**
   - For each column: type, nulls, unique values
   - Statistics (numeric) or top values (categorical)
   - Quality flags

3. **Recommendations**
   - Type optimization suggestions
   - Quality issues to investigate
   - Schema recommendations

## Output Format

```markdown
# Data Profile: orders.csv

## Summary
- **Rows:** 52,340
- **Columns:** 12
- **Memory:** 45.2 MB
- **Generated:** 2024-01-15 10:30 UTC

## Column Profiles

| Column | Type | Nulls | Unique | Notes |
|--------|------|-------|--------|-------|
| order_id | int64 | 0% | 100% | Primary key candidate |
| customer_id | int64 | 0% | 15% | Foreign key |
| order_date | datetime | 0% | 8% | Range: 2023-01-01 to 2024-01-14 |
| total | float64 | 0% | 42% | Min: 0.99, Max: 9,999.00 |
| status | object | 0.5% | <1% | 5 unique values |

## Detailed Statistics

### order_id (int64)
- Min: 1, Max: 52,340
- No gaps detected
- Recommended: INTEGER PRIMARY KEY

### total (float64)
- Mean: $127.45, Median: $89.50
- Std: $142.30
- Outliers: 23 values > $1,000

## Recommendations

1. ⚠️ `status` has 0.5% nulls - investigate or set default
2. 💡 `total` has 23 high outliers - verify these are valid
3. ✅ No duplicate order_ids detected
```

## Options

- `--format [markdown|json|html]` - Output format (default: markdown)
- `--sample N` - Sample size for large files (default: 10000)
- `--output FILE` - Write to file instead of stdout
