---
name: data-profiler
description: Generate data profiles with column stats, correlations, and missing patterns for DataFrames. Use for EDA and data discovery.
allowed-tools: Read Write Edit Bash
---

# Data Profiler

**Audience:** Data engineers and analysts exploring new datasets.

**Goal:** Generate comprehensive profiles including statistics, correlations, and missing patterns.

## Scripts

Execute profiling functions from `scripts/profiling.py`:

```python
from scripts.profiling import (
    profile_dataframe,
    print_profile_summary,
    profile_correlations,
    profile_missing_patterns
)
```

## Usage Examples

### Basic Profiling

```python
import pandas as pd
from scripts.profiling import profile_dataframe, print_profile_summary

df = pd.read_csv('data.csv')
profile = profile_dataframe(df)
print_profile_summary(profile)
```

**Output:**
```
Shape: 10,000 rows x 15 columns
Memory: 1.23 MB

Column Summary:
  id (int64): 10,000 unique, no nulls
  email (object): 9,847 unique, 1.53% null
  revenue (float64): 3,421 unique, no nulls
  created_at (datetime64[ns]): 365 unique, no nulls
```

### Correlation Analysis

```python
from scripts.profiling import profile_correlations

corr = profile_correlations(df, threshold=0.7)

if corr['high_correlations']:
    print("Highly correlated columns:")
    for c in corr['high_correlations']:
        print(f"  {c['col1']} <-> {c['col2']}: {c['correlation']}")
```

### Missing Data Patterns

```python
from scripts.profiling import profile_missing_patterns

missing = profile_missing_patterns(df)

for col, stats in missing.items():
    if col != 'co_missing_columns':
        print(f"{col}: {stats['percent']}% missing, max {stats['consecutive_max']} consecutive")

# Check for columns missing together
if 'co_missing_columns' in missing:
    for col1, col2, pct in missing['co_missing_columns']:
        print(f"{col1} and {col2} both missing {pct}% of time")
```

## Profile Output Schema

```yaml
shape: [rows, columns]
memory_mb: float
columns:
  column_name:
    dtype: string
    null_count: int
    null_pct: float
    unique_count: int
    unique_pct: float
    # Numeric columns add:
    min: float
    max: float
    mean: float
    std: float
    median: float
    zeros: int
    negatives: int
    # String columns add:
    min_length: int
    max_length: int
    top_values: {value: count}
    # Datetime columns add:
    min_date: string
    max_date: string
    date_range_days: int
```

## Analysis Dimensions

### Numeric Columns
- Min, max, range, mean, median, mode
- Standard deviation, variance, skewness, kurtosis
- Percentiles (5, 25, 50, 75, 95)
- Zero count, negative count
- Outlier detection (IQR method)

### String Columns
- Min/max/avg length
- Pattern analysis (emails, phones, URLs)
- Top N frequent values
- Whitespace issues (leading/trailing)
- Case distribution (upper/lower/mixed)
- Empty string count

### DateTime Columns
- Min/max dates, date range span
- Missing dates in sequence
- Day of week distribution
- Hour distribution (if timestamp)

### Categorical Columns
- Cardinality, value distribution
- Imbalance ratio
- Rare categories (< 1%)

## Correlation Analysis

```python
correlation_matrix = df.select_dtypes(include=[np.number]).corr()

# Highly correlated pairs (> 0.8)
high_corr = []
for i in range(len(correlation_matrix.columns)):
    for j in range(i+1, len(correlation_matrix.columns)):
        if abs(correlation_matrix.iloc[i, j]) > 0.8:
            high_corr.append((
                correlation_matrix.columns[i],
                correlation_matrix.columns[j],
                correlation_matrix.iloc[i, j]
            ))
```

## Quality Flags

Automatically flag:
- **High nulls:** > 50% missing values
- **Constant column:** Only 1 unique value
- **High cardinality:** Unique ratio > 95% (possible ID)
- **Suspected duplicates:** Based on key columns
- **Data type mismatch:** Numeric stored as string
- **Future dates:** Dates beyond today
- **Negative values:** In typically positive columns

## Report Sections

### Executive Summary
- Dataset shape (rows x columns), memory footprint
- Overall quality score, critical issues count

### Column-by-Column Analysis
- Statistics table, distribution histogram (ASCII for terminal)
- Top values (for categorical), quality warnings

### Relationships
- Correlation heatmap summary
- Potential foreign key relationships, column dependencies

### Recommendations
- Suggested data type optimizations
- Columns to investigate, potential data quality rules

## Output Formats

- **Markdown Report:** Full detailed report with tables
- **JSON Summary:** Machine-readable profile for programmatic use
- **HTML Dashboard:** Interactive report with charts (if ydata-profiling available)

## Dependencies

```
pandas
numpy
```
