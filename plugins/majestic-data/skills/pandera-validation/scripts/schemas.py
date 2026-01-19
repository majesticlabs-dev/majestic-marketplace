"""
Pandera schema patterns for DataFrame validation.

Includes schema definitions, custom checks, and decorator patterns.
"""

import pandas as pd
import pandera as pa
from pandera import Column, Check, DataFrameSchema
from pandera import SchemaModel, Field
from pandera.typing import Series


# =============================================================================
# Basic Schemas
# =============================================================================

def create_user_schema() -> DataFrameSchema:
    """Create example user DataFrame schema."""
    return DataFrameSchema({
        "id": Column(int, Check.gt(0), unique=True),
        "email": Column(str, Check.str_matches(r'^[\w\.-]+@[\w\.-]+\.\w+$')),
        "revenue": Column(float, Check.ge(0)),
        "date": Column("datetime64[ns]"),
        "category": Column(str, Check.isin(['A', 'B', 'C'])),
    })


def create_nullable_schema() -> DataFrameSchema:
    """Schema with nullable and optional columns."""
    return DataFrameSchema({
        "id": Column(int, nullable=False),
        "email": Column(str, nullable=False),
        "phone": Column(str, nullable=True),  # Can be null
        "notes": Column(str, required=False),  # Column may not exist
    })


def create_date_range_schema() -> DataFrameSchema:
    """Schema with multi-column validation."""
    return DataFrameSchema({
        "start_date": Column("datetime64[ns]"),
        "end_date": Column("datetime64[ns]"),
    }, checks=[
        Check(lambda df: (df['end_date'] > df['start_date']).all(),
              error="end_date must be after start_date")
    ])


# =============================================================================
# Class-Based Schema (SchemaModel)
# =============================================================================

class UserSchema(SchemaModel):
    """Type-hinted DataFrame schema using SchemaModel."""
    id: Series[int] = Field(gt=0, unique=True)
    email: Series[str] = Field(str_matches=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    age: Series[int] = Field(ge=0, le=150)
    status: Series[str] = Field(isin=['active', 'inactive'])

    class Config:
        strict = True  # Fail if extra columns exist
        coerce = True  # Attempt type coercion


# =============================================================================
# Validation Helpers
# =============================================================================

def validate_with_errors(
    df: pd.DataFrame,
    schema: DataFrameSchema
) -> tuple[pd.DataFrame | None, list[dict]]:
    """Validate DataFrame and collect all errors.

    Args:
        df: DataFrame to validate
        schema: Pandera schema

    Returns:
        Tuple of (validated_df or None, list of error dicts)
    """
    try:
        validated = schema.validate(df, lazy=True)
        return validated, []
    except pa.errors.SchemaErrors as err:
        errors = []
        for failure in err.failure_cases.itertuples():
            errors.append({
                'column': failure.column,
                'check': failure.check,
                'failure_case': failure.failure_case
            })
        return None, errors


def infer_and_export_schema(df: pd.DataFrame) -> dict:
    """Infer schema from DataFrame and return as dict.

    Args:
        df: DataFrame to infer schema from

    Returns:
        Dict with 'python_code' and 'yaml' representations
    """
    inferred = pa.infer_schema(df)
    return {
        'python_code': inferred.to_script(),
        'yaml': inferred.to_yaml()
    }
