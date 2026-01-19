---
name: pandera-validation
description: DataFrame schema validation using pandera. Schema definitions, column checks, and decorator-based validation.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Pandera Validation

DataFrame schema validation and type checking for pandas.

## Basic Schema

```python
import pandera as pa
from pandera import Column, Check, DataFrameSchema

schema = DataFrameSchema({
    "id": Column(int, Check.gt(0), unique=True),
    "email": Column(str, Check.str_matches(r'^[\w\.-]+@[\w\.-]+\.\w+$')),
    "revenue": Column(float, Check.ge(0)),
    "date": Column("datetime64[ns]"),
    "category": Column(str, Check.isin(['A', 'B', 'C'])),
})

# Validate DataFrame
validated_df = schema.validate(df)
```

## Schema with Nullable and Optional

```python
schema = DataFrameSchema({
    "id": Column(int, nullable=False),
    "email": Column(str, nullable=False),
    "phone": Column(str, nullable=True),  # Can be null
    "notes": Column(str, required=False),  # Column may not exist
})
```

## Built-in Checks

```python
# Numeric checks
Column(int, Check.gt(0))           # Greater than
Column(int, Check.ge(0))           # Greater than or equal
Column(int, Check.lt(100))         # Less than
Column(int, Check.le(100))         # Less than or equal
Column(int, Check.in_range(0, 100))  # Between inclusive
Column(int, Check.isin([1, 2, 3]))   # In set

# String checks
Column(str, Check.str_matches(r'^\d{3}-\d{4}$'))  # Regex
Column(str, Check.str_length(min_value=1, max_value=100))
Column(str, Check.str_startswith('ID-'))
Column(str, Check.str_contains('@'))

# General checks
Column(pa.Int, unique=True)        # No duplicates
Column(str, Check.isin(['A', 'B', 'C']))
```

## Custom Checks

```python
# Single column check
schema = DataFrameSchema({
    "age": Column(int, Check(lambda s: s.between(0, 120).all(),
                             element_wise=False,
                             error="Age must be 0-120")),
})

# Multi-column check (DataFrame-level)
schema = DataFrameSchema({
    "start_date": Column("datetime64[ns]"),
    "end_date": Column("datetime64[ns]"),
}, checks=[
    Check(lambda df: (df['end_date'] > df['start_date']).all(),
          error="end_date must be after start_date")
])
```

## Decorator-Based Validation

```python
@pa.check_output(schema)
def load_data(path: str) -> pd.DataFrame:
    """Validate output matches schema."""
    return pd.read_csv(path)

@pa.check_input(schema, "df")
def process_data(df: pd.DataFrame) -> pd.DataFrame:
    """Validate input matches schema."""
    return df.assign(processed=True)

@pa.check_io(df=schema, out=output_schema)
def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    """Validate both input and output."""
    return df.transform(...)
```

## Class-Based Schemas (SchemaModel)

```python
from pandera import SchemaModel, Field
from pandera.typing import Series

class UserSchema(SchemaModel):
    id: Series[int] = Field(gt=0, unique=True)
    email: Series[str] = Field(str_matches=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    age: Series[int] = Field(ge=0, le=150)
    status: Series[str] = Field(isin=['active', 'inactive'])

    class Config:
        strict = True  # Fail if extra columns exist
        coerce = True  # Attempt type coercion

# Validate
UserSchema.validate(df)

# Use as type hint
def process_users(df: pa.typing.DataFrame[UserSchema]) -> pd.DataFrame:
    return df.query("status == 'active'")
```

## Lazy Validation (Collect All Errors)

```python
try:
    schema.validate(df, lazy=True)
except pa.errors.SchemaErrors as err:
    print("Schema errors:")
    for failure in err.failure_cases.itertuples():
        print(f"  {failure.column}: {failure.check} - {failure.failure_case}")
```

## Schema from DataFrame (Inference)

```python
# Infer schema from existing DataFrame
inferred_schema = pa.infer_schema(df)

# Export as Python code
print(inferred_schema.to_script())

# Export as YAML
print(inferred_schema.to_yaml())
```

## When to Use Pandera

| Use Case | Pandera | Alternative |
|----------|---------|-------------|
| DataFrame validation | ✓ | - |
| Type hints for DataFrames | ✓ | - |
| ETL pipeline checks | ✓ | Great Expectations |
| Record-level validation | - | Pydantic |
| Data warehouse expectations | - | Great Expectations |
