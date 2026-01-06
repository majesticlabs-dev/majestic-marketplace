---
name: csv-to-sql
description: Generate CREATE TABLE and COPY/INSERT statements from CSV files with type inference.
color: yellow
tools: Read, Write, Edit, Grep, Glob, Bash
---

# CSV-to-SQL

Autonomous agent that converts CSV files to SQL table definitions and load scripts.

## Workflow

1. **Analyze the CSV**
   - Detect delimiter, encoding, header row
   - Sample data for type inference
   - Identify constraints (NOT NULL, UNIQUE)

2. **Generate schema**
   - CREATE TABLE statement
   - Appropriate column types
   - Constraints and indexes

3. **Generate load script**
   - COPY command (PostgreSQL) or equivalent
   - INSERT statements as fallback
   - Error handling options

## Type Mapping

| Detected Pattern | PostgreSQL | MySQL | SQLite |
|-----------------|------------|-------|--------|
| Integer | INTEGER / BIGINT | INT / BIGINT | INTEGER |
| Decimal | NUMERIC(p,s) | DECIMAL(p,s) | REAL |
| Boolean | BOOLEAN | TINYINT(1) | INTEGER |
| Date | DATE | DATE | TEXT |
| Timestamp | TIMESTAMP | DATETIME | TEXT |
| UUID | UUID | CHAR(36) | TEXT |
| Short text | VARCHAR(n) | VARCHAR(n) | TEXT |
| Long text | TEXT | TEXT | TEXT |
| JSON | JSONB | JSON | TEXT |

## Output Templates

### PostgreSQL

```sql
-- Generated from: orders.csv
-- Rows: 50,000 | Columns: 8

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'shipped', 'delivered')),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for common query patterns
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

-- Load data
\COPY orders FROM 'orders.csv' WITH (FORMAT csv, HEADER true, NULL '');

-- Verify
SELECT COUNT(*) as loaded_rows FROM orders;
```

### MySQL

```sql
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('pending', 'shipped', 'delivered') NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer (customer_id),
    INDEX idx_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA INFILE '/path/to/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

### SQLite

```sql
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'shipped', 'delivered')),
    total_amount REAL NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

.mode csv
.import --skip 1 orders.csv orders
```

## Python Load Script

```python
import pandas as pd
from sqlalchemy import create_engine

def load_csv_to_db(
    csv_path: str,
    table_name: str,
    connection_string: str,
    if_exists: str = 'replace',
    chunksize: int = 10000
) -> int:
    """Load CSV to database with progress."""
    engine = create_engine(connection_string)

    total_rows = 0
    for chunk in pd.read_csv(csv_path, chunksize=chunksize):
        chunk.to_sql(
            table_name,
            engine,
            if_exists=if_exists if total_rows == 0 else 'append',
            index=False
        )
        total_rows += len(chunk)
        print(f"Loaded {total_rows:,} rows")

    return total_rows

# Usage
load_csv_to_db(
    'orders.csv',
    'orders',
    'postgresql://user:pass@localhost/db'
)
```

## Constraints Detection

Automatically detect and suggest:

1. **Primary Key**
   - Column named 'id', '*_id', 'pk'
   - 100% unique, no nulls

2. **Foreign Keys**
   - Columns ending in '_id'
   - Reference table inferred from prefix

3. **NOT NULL**
   - Columns with 0% null rate

4. **UNIQUE**
   - Columns with 100% unique values
   - Email, username patterns

5. **CHECK Constraints**
   - Categorical columns → IN list
   - Numeric ranges → >= / <=
   - Positive values → >= 0

## Execution

1. User provides: CSV path, target database type
2. Agent analyzes CSV structure
3. Generates CREATE TABLE with appropriate types
4. Generates COPY/INSERT statements
5. Optionally generates Python load script
6. Provides verification queries
