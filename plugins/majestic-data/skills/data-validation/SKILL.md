---
name: data-validation
description: Schema enforcement and data validation using Pydantic, pandera, and Great Expectations patterns.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data-Validation

Production patterns for data validation and schema enforcement.

## Pydantic for Record Validation

```python
from pydantic import BaseModel, Field, field_validator, model_validator
from datetime import date
from typing import Literal

class UserRecord(BaseModel):
    id: int = Field(gt=0)
    email: str = Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    status: Literal['active', 'inactive', 'pending']
    created_at: date
    age: int = Field(ge=0, le=150)

    @field_validator('email')
    @classmethod
    def lowercase_email(cls, v: str) -> str:
        return v.lower()

    @model_validator(mode='after')
    def check_consistency(self) -> 'UserRecord':
        if self.status == 'active' and self.age < 13:
            raise ValueError('Active users must be 13+')
        return self

# Batch validation
def validate_records(records: list[dict]) -> tuple[list[UserRecord], list[dict]]:
    valid, invalid = [], []
    for record in records:
        try:
            valid.append(UserRecord(**record))
        except ValidationError as e:
            invalid.append({'record': record, 'errors': e.errors()})
    return valid, invalid
```

## Pandera for DataFrame Validation

```python
import pandera as pa
from pandera import Column, Check, DataFrameSchema

# Define schema
schema = DataFrameSchema({
    "id": Column(int, Check.gt(0), unique=True),
    "email": Column(str, Check.str_matches(r'^[\w\.-]+@[\w\.-]+\.\w+$')),
    "revenue": Column(float, Check.ge(0)),
    "date": Column("datetime64[ns]"),
    "category": Column(str, Check.isin(['A', 'B', 'C'])),
})

# Validate DataFrame
@pa.check_output(schema)
def load_data(path: str) -> pd.DataFrame:
    return pd.read_csv(path)

# Schema with custom checks
schema_with_custom = DataFrameSchema({
    "start_date": Column("datetime64[ns]"),
    "end_date": Column("datetime64[ns]"),
}, checks=[
    Check(lambda df: df['end_date'] > df['start_date'],
          error="end_date must be after start_date")
])
```

## Great Expectations Patterns

```python
import great_expectations as gx

# Quick validation
context = gx.get_context()

# Define expectations
suite = context.add_expectation_suite("user_data_suite")

# Column existence
suite.add_expectation(
    gx.expectations.ExpectColumnToExist(column="user_id")
)

# Null checks
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToNotBeNull(column="user_id")
)

# Value ranges
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToBeBetween(
        column="age", min_value=0, max_value=150
    )
)

# Uniqueness
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToBeUnique(column="user_id")
)

# Categorical values
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToBeInSet(
        column="status",
        value_set=["active", "inactive", "pending"]
    )
)

# Run validation
results = context.run_checkpoint(
    checkpoint_name="user_data_checkpoint",
    batch_request={"datasource_name": "my_datasource", "data_asset_name": "users"}
)
```

## Custom Validation Functions

```python
from typing import Callable
from dataclasses import dataclass

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
    min_date: date,
    max_date: date
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

## Schema Evolution Handling

```python
from typing import Any

def validate_with_schema_version(
    data: dict,
    schema_version: int
) -> dict:
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

def infer_and_validate_schema(df: pd.DataFrame) -> dict:
    """Infer schema from DataFrame and return validation report."""
    report = {
        'columns': {},
        'row_count': len(df),
        'issues': []
    }

    for col in df.columns:
        col_info = {
            'dtype': str(df[col].dtype),
            'null_count': int(df[col].isnull().sum()),
            'null_pct': float(df[col].isnull().mean()),
            'unique_count': int(df[col].nunique())
        }

        if df[col].dtype in ['int64', 'float64']:
            col_info['min'] = float(df[col].min())
            col_info['max'] = float(df[col].max())
            col_info['mean'] = float(df[col].mean())

        report['columns'][col] = col_info

        # Flag potential issues
        if col_info['null_pct'] > 0.5:
            report['issues'].append(f"Column '{col}' has >50% nulls")
        if col_info['unique_count'] == 1:
            report['issues'].append(f"Column '{col}' has only one unique value")

    return report
```

## Validation Pipeline

```python
class DataValidator:
    def __init__(self):
        self.checks: list[Callable[[pd.DataFrame], ValidationResult]] = []

    def add_check(self, check: Callable[[pd.DataFrame], ValidationResult]):
        self.checks.append(check)
        return self

    def validate(self, df: pd.DataFrame) -> dict:
        results = {
            'passed': True,
            'checks': []
        }

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
validator.add_check(lambda df: validate_no_nulls(df, ['id', 'email']))
validator.add_check(lambda df: validate_email_format(df, 'email'))

results = validator.validate(df)
if not results['passed']:
    raise ValueError(f"Validation failed: {results}")
```

## Assertions for Tests

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
```
