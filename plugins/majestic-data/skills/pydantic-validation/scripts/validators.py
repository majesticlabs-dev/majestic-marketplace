"""
Pydantic validation patterns for record-level data validation.

Includes model examples, batch validation, and common patterns.
"""

from pydantic import BaseModel, Field, ValidationError, field_validator, model_validator
from datetime import date
from typing import Literal, Annotated


# =============================================================================
# Type Aliases
# =============================================================================

PositiveInt = Annotated[int, Field(gt=0)]
Email = Annotated[str, Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')]


# =============================================================================
# Example Models
# =============================================================================

class UserRecord(BaseModel):
    """Example user record with common validations."""
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


class Address(BaseModel):
    """Nested model example."""
    street: str
    city: str
    country: str = Field(default='US')
    postal_code: str


class Customer(BaseModel):
    """Model with nested models and default logic."""
    id: int
    name: str
    billing_address: Address
    shipping_address: Address | None = None

    @model_validator(mode='after')
    def default_shipping(self) -> 'Customer':
        if self.shipping_address is None:
            self.shipping_address = self.billing_address
        return self


class Order(BaseModel):
    """Model with multiple validators."""
    items: list[str]
    total: float
    discount_pct: float = 0

    @field_validator('items')
    @classmethod
    def items_not_empty(cls, v: list) -> list:
        if not v:
            raise ValueError('Order must have at least one item')
        return v

    @field_validator('discount_pct')
    @classmethod
    def valid_discount(cls, v: float) -> float:
        if v < 0 or v > 100:
            raise ValueError('Discount must be between 0 and 100')
        return v

    @model_validator(mode='after')
    def check_total(self) -> 'Order':
        if self.total <= 0:
            raise ValueError('Total must be positive')
        return self


# =============================================================================
# Batch Validation
# =============================================================================

def validate_records(
    records: list[dict],
    model: type[BaseModel] = UserRecord
) -> tuple[list[BaseModel], list[dict]]:
    """Validate batch of records, separating valid from invalid.

    Args:
        records: List of dicts to validate
        model: Pydantic model class to validate against

    Returns:
        Tuple of (valid_records, invalid_records_with_errors)
    """
    valid, invalid = [], []
    for record in records:
        try:
            valid.append(model(**record))
        except ValidationError as e:
            invalid.append({'record': record, 'errors': e.errors()})
    return valid, invalid


def print_validation_errors(invalid: list[dict], max_show: int = 5) -> None:
    """Print validation errors in readable format."""
    print(f"Found {len(invalid)} invalid records")
    for item in invalid[:max_show]:
        print(f"  Record: {item['record']}")
        for err in item['errors']:
            print(f"    - {err['loc']}: {err['msg']}")
