---
name: data-validation
description: Data validation patterns and pipeline helpers. Custom validation functions, schema evolution, and test assertions.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data Validation

Custom validation patterns and pipeline helpers.

**Framework-specific skills:**
- `pydantic-validation` - Record-level validation with Pydantic
- `pandera-validation` - DataFrame schema validation
- `great-expectations` - Pipeline expectations and monitoring

## Framework Selection

| Use Case | Framework |
|----------|-----------|
| API request/response | Pydantic |
| Record-by-record ETL | Pydantic |
| DataFrame validation | Pandera |
| Type hints for DataFrames | Pandera |
| Pipeline monitoring | Great Expectations |
| Data warehouse checks | Great Expectations |
| Custom business rules | Custom functions (below) |

## Custom Validation Functions

```python
from dataclasses import dataclass
import pandas as pd

@dataclass
class ValidationResult:
    passed: bool
    message: str
    failed_rows: pd.DataFrame | None = None

def validate_no_duplicates(df: pd.DataFrame, cols: list[str]) -> ValidationResult:
    """Check for duplicate rows based on columns."""
    duplicates = df[df.duplicated(subset=cols, keep=False)]
    if len(duplicates) > 0:
        return ValidationResult(
            passed=False,
            message=f"Found {len(duplicates)} duplicate rows",
            failed_rows=duplicates
        )
    return ValidationResult(passed=True, message="No duplicates found")

def validate_referential_integrity(
    df: pd.DataFrame,
    column: str,
    reference_df: pd.DataFrame,
    reference_column: str
) -> ValidationResult:
    """Check foreign key references exist."""
    valid_values = set(reference_df[reference_column])
    invalid = df[~df[column].isin(valid_values)]
    if len(invalid) > 0:
        return ValidationResult(
            passed=False,
            message=f"Found {len(invalid)} rows with invalid references",
            failed_rows=invalid
        )
    return ValidationResult(passed=True, message="All references valid")

def validate_date_range(
    df: pd.DataFrame,
    column: str,
    min_date,
    max_date
) -> ValidationResult:
    """Check dates within expected range."""
    out_of_range = df[(df[column] < min_date) | (df[column] > max_date)]
    if len(out_of_range) > 0:
        return ValidationResult(
            passed=False,
            message=f"Found {len(out_of_range)} rows outside date range",
            failed_rows=out_of_range
        )
    return ValidationResult(passed=True, message="All dates in range")
```

## Validation Pipeline

```python
from typing import Callable

class DataValidator:
    def __init__(self):
        self.checks: list[Callable[[pd.DataFrame], ValidationResult]] = []

    def add_check(self, check: Callable[[pd.DataFrame], ValidationResult]):
        self.checks.append(check)
        return self

    def validate(self, df: pd.DataFrame) -> dict:
        results = {'passed': True, 'checks': []}
        for check in self.checks:
            result = check(df)
            results['checks'].append({
                'name': check.__name__,
                'passed': result.passed,
                'message': result.message
            })
            if not result.passed:
                results['passed'] = False
        return results

# Usage
validator = DataValidator()
validator.add_check(lambda df: validate_no_duplicates(df, ['id']))
validator.add_check(lambda df: validate_referential_integrity(df, 'user_id', users_df, 'id'))

results = validator.validate(df)
if not results['passed']:
    raise ValueError(f"Validation failed: {results}")
```

## Schema Evolution

```python
def validate_with_schema_version(data: dict, schema_version: int) -> dict:
    """Handle multiple schema versions during migration."""
    if schema_version == 1:
        # Old schema: name was single field
        if 'name' in data and 'first_name' not in data:
            parts = data['name'].split(' ', 1)
            data['first_name'] = parts[0]
            data['last_name'] = parts[1] if len(parts) > 1 else ''
            del data['name']

    if schema_version < 3:
        # Schema v3 added 'metadata' field
        if 'metadata' not in data:
            data['metadata'] = {}

    return data
```

## Test Assertions

```python
def assert_schema_match(df: pd.DataFrame, expected: dict) -> None:
    """Assert DataFrame matches expected schema."""
    for col, dtype in expected.items():
        assert col in df.columns, f"Missing column: {col}"
        assert df[col].dtype == dtype, f"Column {col}: expected {dtype}, got {df[col].dtype}"

def assert_no_nulls(df: pd.DataFrame, columns: list[str]) -> None:
    """Assert no null values in specified columns."""
    for col in columns:
        null_count = df[col].isnull().sum()
        assert null_count == 0, f"Column {col} has {null_count} null values"

def assert_unique(df: pd.DataFrame, columns: list[str]) -> None:
    """Assert no duplicate values in column combination."""
    dup_count = df.duplicated(subset=columns).sum()
    assert dup_count == 0, f"Found {dup_count} duplicate rows for columns {columns}"

def assert_values_in_set(df: pd.DataFrame, column: str, valid_values: set) -> None:
    """Assert all values in column are from valid set."""
    invalid = set(df[column].unique()) - valid_values
    assert not invalid, f"Column {column} has invalid values: {invalid}"
```

## Pipeline Integration

```python
def run_validation_pipeline(
    df: pd.DataFrame,
    config: dict
) -> tuple[pd.DataFrame, dict]:
    """Run validation and return clean data + report."""
    validator = DataValidator()

    # Add checks from config
    if 'unique_columns' in config:
        validator.add_check(lambda df: validate_no_duplicates(df, config['unique_columns']))

    if 'date_ranges' in config:
        for col, (min_d, max_d) in config['date_ranges'].items():
            validator.add_check(lambda df, c=col, mn=min_d, mx=max_d:
                              validate_date_range(df, c, mn, mx))

    results = validator.validate(df)

    if not results['passed']:
        # Optionally filter to only valid rows
        # df = df[~df['_invalid']]
        pass

    return df, results
```
