---
name: data-profiler
description: Generate comprehensive data profiles for DataFrames. Use for EDA, data discovery, and understanding dataset characteristics.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data Profiler

Generate comprehensive profiles for pandas DataFrames covering shape, memory, and column-level statistics.

## Quick Profiling

```python
def profile_dataframe(df: pd.DataFrame) -> dict:
    """Generate comprehensive profile of DataFrame."""
    profile = {
        'shape': df.shape,
        'memory_mb': df.memory_usage(deep=True).sum() / 1024**2,
        'columns': {}
    }

    for col in df.columns:
        col_profile = {
            'dtype': str(df[col].dtype),
            'null_count': int(df[col].isnull().sum()),
            'null_pct': round(df[col].isnull().mean() * 100, 2),
            'unique_count': int(df[col].nunique()),
            'unique_pct': round(df[col].nunique() / len(df) * 100, 2),
        }

        if df[col].dtype in ['int64', 'float64']:
            col_profile.update({
                'min': float(df[col].min()),
                'max': float(df[col].max()),
                'mean': float(df[col].mean()),
                'std': float(df[col].std()),
                'median': float(df[col].median()),
                'zeros': int((df[col] == 0).sum()),
                'negatives': int((df[col] < 0).sum()),
            })
        elif df[col].dtype == 'object':
            col_profile.update({
                'min_length': int(df[col].str.len().min()),
                'max_length': int(df[col].str.len().max()),
                'top_values': df[col].value_counts().head(5).to_dict(),
            })
        elif pd.api.types.is_datetime64_any_dtype(df[col]):
            col_profile.update({
                'min_date': str(df[col].min()),
                'max_date': str(df[col].max()),
                'date_range_days': int((df[col].max() - df[col].min()).days),
            })

        profile['columns'][col] = col_profile

    return profile
```

## Profile Report

```python
def print_profile_summary(profile: dict) -> None:
    """Print human-readable profile summary."""
    print(f"Shape: {profile['shape'][0]:,} rows x {profile['shape'][1]} columns")
    print(f"Memory: {profile['memory_mb']:.2f} MB")
    print("\nColumn Summary:")

    for col, stats in profile['columns'].items():
        null_str = f"{stats['null_pct']}% null" if stats['null_pct'] > 0 else "no nulls"
        print(f"  {col} ({stats['dtype']}): {stats['unique_count']:,} unique, {null_str}")
```

## Correlation Analysis

```python
def profile_correlations(df: pd.DataFrame, threshold: float = 0.7) -> dict:
    """Find highly correlated numeric columns."""
    numeric_cols = df.select_dtypes(include=['int64', 'float64']).columns
    corr_matrix = df[numeric_cols].corr()

    high_correlations = []
    for i, col1 in enumerate(numeric_cols):
        for j, col2 in enumerate(numeric_cols):
            if i < j:  # Upper triangle only
                corr = corr_matrix.loc[col1, col2]
                if abs(corr) >= threshold:
                    high_correlations.append({
                        'col1': col1,
                        'col2': col2,
                        'correlation': round(corr, 3)
                    })

    return {
        'threshold': threshold,
        'high_correlations': sorted(high_correlations, key=lambda x: abs(x['correlation']), reverse=True)
    }
```

## Missing Patterns

```python
def profile_missing_patterns(df: pd.DataFrame) -> dict:
    """Analyze patterns in missing data."""
    missing_cols = df.columns[df.isnull().any()].tolist()

    patterns = {}
    for col in missing_cols:
        missing_mask = df[col].isnull()
        patterns[col] = {
            'count': int(missing_mask.sum()),
            'percent': round(missing_mask.mean() * 100, 2),
            'consecutive_max': int(missing_mask.groupby((~missing_mask).cumsum()).sum().max()) if missing_mask.any() else 0,
        }

    # Find columns that are always missing together
    if len(missing_cols) > 1:
        co_missing = []
        for i, col1 in enumerate(missing_cols):
            for j, col2 in enumerate(missing_cols):
                if i < j:
                    both_missing = (df[col1].isnull() & df[col2].isnull()).mean()
                    if both_missing > 0.5:
                        co_missing.append((col1, col2, round(both_missing * 100, 1)))
        patterns['co_missing_columns'] = co_missing

    return patterns
```

## Usage

```python
import pandas as pd

df = pd.read_csv('data.csv')
profile = profile_dataframe(df)
print_profile_summary(profile)

# Check correlations
corr = profile_correlations(df)
if corr['high_correlations']:
    print("\nHighly correlated columns:")
    for c in corr['high_correlations']:
        print(f"  {c['col1']} <-> {c['col2']}: {c['correlation']}")

# Check missing patterns
missing = profile_missing_patterns(df)
if missing:
    print("\nMissing data patterns:")
    for col, stats in missing.items():
        if col != 'co_missing_columns':
            print(f"  {col}: {stats['percent']}% missing")
```
