---
name: majestic-data:transform
description: Transform data files between formats or apply transformations.
argument-hint: "<source> --to <target> [--flatten] [--schema]"
disable-model-invocation: true
---

# Data Transform Command

Transform data files between formats or apply structural transformations.

## Arguments

**Input:** `$ARGUMENTS`

Parse arguments:
- Source file (required): Input file path
- `--to <path>`: Output file path (format inferred from extension)
- `--flatten`: Flatten nested JSON structures
- `--schema <path>`: Apply schema/type casting
- `--columns <list>`: Select specific columns
- `--filter <expr>`: Filter rows by expression

## Supported Conversions

| From | To | Notes |
|------|-----|-------|
| CSV | Parquet | Recommended for analytics |
| CSV | JSON | Lines format |
| JSON | CSV | Flattens if needed |
| JSON | Parquet | With optional flatten |
| Parquet | CSV | For compatibility |
| Excel | CSV/Parquet | Specify sheet with --sheet |

## Execution

### Step 1: Analyze Source

Determine source format and structure:

```python
source_ext = Path(source).suffix.lower()
target_ext = Path(target).suffix.lower()

if source_ext == '.json':
    # Check if nested
    sample = json.loads(Path(source).read_text()[:10000])
    is_nested = any(isinstance(v, (dict, list)) for v in sample[0].values())
```

### Step 2: Apply Transformation

**Simple format conversion:**
```python
if source_ext == '.csv' and target_ext == '.parquet':
    df = pd.read_csv(source)
    df.to_parquet(target, compression='snappy', index=False)
```

**With flattening (JSON):**
```
Task(subagent_type="majestic-data:transform:json-flattener",
     prompt="Flatten nested JSON and convert to target format")
```

**With schema application:**
```
Task(subagent_type="majestic-data:research:schema-discoverer",
     prompt="Infer and apply schema, then convert")
```

### Step 3: Validate Output

Run basic validation on output:
- Row count matches (or documented why it differs)
- Required columns present
- No data corruption

## Output

```markdown
# Transform Complete

**Source:** events.json (1.2 GB, 5.2M rows)
**Target:** events.parquet

## Transformation Applied

- Format: JSON → Parquet
- Flattening: Yes (depth 3 → flat)
- Compression: Snappy

## Column Mapping

| Original Path | Output Column | Type |
|---------------|---------------|------|
| id | id | int64 |
| user.id | user_id | int64 |
| user.email | user_email | string |
| event.type | event_type | string |
| event.properties | properties_json | string |
| timestamp | timestamp | datetime64 |

## Metrics

| Metric | Value |
|--------|-------|
| Source size | 1.2 GB |
| Output size | 245 MB |
| Compression ratio | 4.9x |
| Source rows | 5,200,000 |
| Output rows | 5,200,000 |
| Duration | 45 seconds |

## Notes

- Nested `event.properties` kept as JSON string (too varied to flatten)
- Timestamps converted from Unix epoch to datetime
- 3 columns with >99% nulls dropped: legacy_field_1, legacy_field_2, debug_info
```

## Examples

```bash
# Simple CSV to Parquet
/data:transform orders.csv --to orders.parquet

# Flatten nested JSON
/data:transform events.json --to events.parquet --flatten

# Select specific columns
/data:transform data.csv --to subset.parquet --columns "id,name,value"

# Filter rows
/data:transform orders.csv --to active.parquet --filter "status == 'active'"

# Excel to CSV (specific sheet)
/data:transform report.xlsx --to data.csv --sheet "Q4 Data"
```
