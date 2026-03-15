---
name: pandas-coder
description: DataFrame manipulation with chunked processing, memory optimization, and vectorized operations.
allowed-tools: Read Write Edit Grep Glob Bash
---

# Pandas-Coder

Expert in pandas DataFrame manipulation with focus on production-ready patterns for large datasets.

## Memory-Efficient Reading

```python
# Chunked CSV reading - default for files > 100MB
chunks = pd.read_csv('large.csv', chunksize=50_000)
for chunk in chunks:
    process(chunk)

# Read only needed columns
df = pd.read_csv('data.csv', usecols=['id', 'name', 'value'])

# Optimize dtypes on load
df = pd.read_csv('data.csv', dtype={
    'id': 'int32',           # not int64
    'category': 'category',  # not object
    'flag': 'bool'
})
```

## Category Type for Repeated Strings

```python
# BEFORE: 800MB with object dtype
df['status'] = df['status'].astype('category')  # AFTER: 50MB

# Set categories explicitly for consistency across files
df['status'] = pd.Categorical(
    df['status'],
    categories=['pending', 'active', 'completed', 'cancelled']
)
```

## Vectorized Operations Over Loops

```python
# BAD - iterating rows
for idx, row in df.iterrows():
    df.loc[idx, 'total'] = row['price'] * row['qty']

# GOOD - vectorized
df['total'] = df['price'] * df['qty']

# BAD - apply with Python function
df['clean'] = df['name'].apply(lambda x: x.strip().lower())

# GOOD - vectorized string methods
df['clean'] = df['name'].str.strip().str.lower()
```

## Conditional Assignment

```python
# Use np.where for simple conditions
df['tier'] = np.where(df['revenue'] > 1000, 'premium', 'standard')

# Use np.select for multiple conditions
conditions = [
    df['score'] >= 90,
    df['score'] >= 70,
    df['score'] >= 50
]
choices = ['A', 'B', 'C']
df['grade'] = np.select(conditions, choices, default='F')
```

## GroupBy Optimizations

```python
# Named aggregations (pandas 2.0+)
result = df.groupby('category').agg(
    total_sales=('sales', 'sum'),
    avg_price=('price', 'mean'),
    count=('id', 'count')
)

# Transform for broadcasting back to original shape
df['pct_of_group'] = df.groupby('category')['value'].transform(
    lambda x: x / x.sum()
)
```

## Index Operations

```python
# Set index for frequent lookups
df = df.set_index('user_id')
user_data = df.loc[12345]  # O(1) lookup

# Reset before groupby if index not needed
df.reset_index(drop=True, inplace=True)

# Multi-index for hierarchical data
df = df.set_index(['region', 'date'])
df.loc[('US', '2024-01')]  # Hierarchical access
```

## Memory Reduction Recipe

```python
def reduce_memory(df: pd.DataFrame) -> pd.DataFrame:
    """Reduce DataFrame memory by 50-90%."""
    for col in df.columns:
        col_type = df[col].dtype

        if col_type == 'object':
            if df[col].nunique() / len(df) < 0.5:
                df[col] = df[col].astype('category')

        elif col_type == 'int64':
            if df[col].min() >= 0:
                if df[col].max() < 255:
                    df[col] = df[col].astype('uint8')
                elif df[col].max() < 65535:
                    df[col] = df[col].astype('uint16')
            else:
                if df[col].min() > -128 and df[col].max() < 127:
                    df[col] = df[col].astype('int8')
                elif df[col].min() > -32768 and df[col].max() < 32767:
                    df[col] = df[col].astype('int16')

        elif col_type == 'float64':
            df[col] = df[col].astype('float32')

    return df
```

## Parquet Over CSV

```python
# Save with compression
df.to_parquet('data.parquet', compression='snappy', index=False)

# Read specific columns (predicate pushdown)
df = pd.read_parquet('data.parquet', columns=['id', 'value'])

# Partitioned writes for large datasets
df.to_parquet(
    'data/',
    partition_cols=['year', 'month'],
    compression='snappy'
)
```

## DateTime Handling

```python
# Parse dates efficiently
df['date'] = pd.to_datetime(df['date_str'], format='%Y-%m-%d')

# Extract components without apply
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()

# Date arithmetic
df['days_ago'] = (pd.Timestamp.now() - df['date']).dt.days
```

## Merge Optimization

```python
# Sort before merge for performance
left = left.sort_values('key')
right = right.sort_values('key')
result = pd.merge(left, right, on='key')

# Use categorical keys for memory efficiency
for df in [left, right]:
    df['key'] = df['key'].astype('category')
```

## Query vs Boolean Indexing

```python
# Boolean indexing - standard
filtered = df[(df['status'] == 'active') & (df['value'] > 100)]

# query() - more readable for complex conditions
filtered = df.query('status == "active" and value > 100')

# query() with variables
min_val = 100
filtered = df.query('value > @min_val')
```

## JSON Flattening

Normalize nested JSON structures into tabular format.

### Flattening Strategies

1. **Dot Notation (Full Flatten)** - `user.address.city` column naming
2. **Array Explosion** - One row per array element, parent fields duplicated
3. **Selective Flatten** - Keep complex nested paths as JSON columns

### Core Implementation

```python
def flatten_json(
    data: dict,
    parent_key: str = '',
    sep: str = '.',
    max_depth: int = None,
    current_depth: int = 0
) -> dict:
    """Recursively flatten nested JSON."""
    items = {}
    for key, value in data.items():
        new_key = f"{parent_key}{sep}{key}" if parent_key else key
        if isinstance(value, dict):
            if max_depth is None or current_depth < max_depth:
                items.update(flatten_json(value, new_key, sep, max_depth, current_depth + 1))
            else:
                items[new_key] = value
        elif isinstance(value, list):
            items[new_key] = value
        else:
            items[new_key] = value
    return items

def explode_arrays(df: pd.DataFrame, array_columns: list[str]) -> pd.DataFrame:
    """Explode array columns into separate rows."""
    for col in array_columns:
        df = df.explode(col).reset_index(drop=True)
        if df[col].apply(lambda x: isinstance(x, dict)).any():
            expanded = pd.json_normalize(df[col])
            expanded.columns = [f"{col}.{c}" for c in expanded.columns]
            df = pd.concat([df.drop(col, axis=1), expanded], axis=1)
    return df

def json_to_dataframe(
    json_data: list[dict],
    array_columns: list[str] = None,
    max_depth: int = None
) -> pd.DataFrame:
    """Convert JSON array to flattened DataFrame."""
    flattened = [flatten_json(record, max_depth=max_depth) for record in json_data]
    df = pd.DataFrame(flattened)
    if array_columns:
        df = explode_arrays(df, array_columns)
    return df
```

### SQL JSON Flattening (PostgreSQL)

```sql
-- Flatten nested JSON
SELECT
    id,
    json_data->>'name' as name,
    json_data->'address'->>'city' as city,
    (json_data->>'created_at')::timestamp as created_at
FROM source_table;

-- Explode JSON array
SELECT
    id,
    item->>'sku' as sku,
    (item->>'quantity')::int as quantity
FROM source_table,
LATERAL jsonb_array_elements(data->'items') as item;
```

### dbt JSON Flattening

```sql
-- models/staging/stg_api_events.sql
{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'api_events') }}
),
flattened as (
    select
        id,
        json_data->>'event_type' as event_type,
        json_data->'user'->>'id' as user_id,
        json_data->'user'->>'email' as user_email,
        json_data->'properties' as properties_json
    from source
)
select * from flattened
```

### Output Schema Generation

```yaml
flattened_schema:
  source: events.json
  original_depth: 4
  flattening_strategy: dot_notation
  array_handling: explode
  columns:
    - path: user.name
      original_path: ["user", "name"]
      type: string
      nullable: false
    - path: items.sku
      original_path: ["items", "[*]", "sku"]
      type: string
      note: "Exploded from array"
  row_multiplication:
    source_rows: 1000
    output_rows: 3500
    reason: "items array avg 3.5 elements"
```
