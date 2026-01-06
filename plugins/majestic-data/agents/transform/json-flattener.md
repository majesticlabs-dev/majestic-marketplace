---
name: json-flattener
description: Normalize nested JSON structures into tabular format with configurable flattening strategies.
color: yellow
tools: Read, Write, Edit, Grep, Glob, Bash
---

# JSON-Flattener

Autonomous agent that transforms nested JSON into flat tabular structures.

## Workflow

1. **Analyze JSON structure**
   - Detect nesting depth
   - Identify arrays vs objects
   - Map paths to potential columns

2. **Choose flattening strategy**
   - Full flatten (dot notation)
   - Selective flatten (keep some nested)
   - Array explosion (one row per array element)
   - JSON columns (keep complex nested as JSON)

3. **Generate transformation**
   - Python/pandas code
   - SQL/dbt model
   - Output schema

## Flattening Strategies

### 1. Dot Notation (Full Flatten)

```json
{
  "user": {
    "name": "John",
    "address": {
      "city": "NYC",
      "zip": "10001"
    }
  }
}
```

Becomes:
| user.name | user.address.city | user.address.zip |
|-----------|-------------------|------------------|
| John | NYC | 10001 |

### 2. Array Explosion

```json
{
  "order_id": 1,
  "items": [
    {"sku": "A", "qty": 2},
    {"sku": "B", "qty": 1}
  ]
}
```

Becomes:
| order_id | items.sku | items.qty |
|----------|-----------|-----------|
| 1 | A | 2 |
| 1 | B | 1 |

### 3. Selective Flatten

Keep some paths as JSON columns:
| order_id | customer_name | items_json |
|----------|---------------|------------|
| 1 | John | [{"sku": "A"}, ...] |

## Python Implementation

```python
import pandas as pd
from typing import Any

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
                items.update(flatten_json(
                    value, new_key, sep, max_depth, current_depth + 1
                ))
            else:
                items[new_key] = value  # Keep as dict
        elif isinstance(value, list):
            if value and isinstance(value[0], dict):
                items[new_key] = value  # Keep array of objects
            else:
                items[new_key] = value  # Keep simple array
        else:
            items[new_key] = value

    return items

def explode_arrays(df: pd.DataFrame, array_columns: list[str]) -> pd.DataFrame:
    """Explode array columns into separate rows."""
    for col in array_columns:
        df = df.explode(col).reset_index(drop=True)
        # Flatten the exploded dicts
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

## SQL Approach (PostgreSQL)

```sql
-- Flatten nested JSON in PostgreSQL
WITH raw_data AS (
    SELECT
        id,
        data::jsonb as json_data
    FROM source_table
)
SELECT
    id,
    json_data->>'name' as name,
    json_data->'address'->>'city' as city,
    json_data->'address'->>'zip' as zip,
    (json_data->>'created_at')::timestamp as created_at
FROM raw_data;

-- Explode JSON array
SELECT
    id,
    item->>'sku' as sku,
    (item->>'quantity')::int as quantity
FROM source_table,
LATERAL jsonb_array_elements(data->'items') as item;
```

## dbt Model

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
        json_data->>'timestamp' as event_timestamp,

        -- Nested object
        json_data->'user'->>'id' as user_id,
        json_data->'user'->>'email' as user_email,

        -- Keep complex nested as JSON
        json_data->'properties' as properties_json

    from source
)

select * from flattened
```

## Output Schema Generation

After flattening, generate:

```yaml
flattened_schema:
  source: events.json
  original_depth: 4
  flattening_strategy: dot_notation
  array_handling: explode

  columns:
    - path: id
      type: integer
      nullable: false

    - path: user.name
      original_path: ["user", "name"]
      type: string
      nullable: false

    - path: user.address.city
      original_path: ["user", "address", "city"]
      type: string
      nullable: true

    - path: items.sku
      original_path: ["items", "[*]", "sku"]
      type: string
      nullable: false
      note: "Exploded from array"

  row_multiplication:
    source_rows: 1000
    output_rows: 3500
    reason: "items array avg 3.5 elements"
```

## Execution

1. User provides: JSON file/sample, desired output format
2. Agent analyzes structure and nesting
3. Recommends flattening strategy
4. Generates transformation code
5. Shows sample output
6. Provides schema documentation
