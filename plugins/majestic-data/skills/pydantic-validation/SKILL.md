---
name: pydantic-validation
description: Record-level data validation using Pydantic models. Field validators, model validators, and batch validation patterns.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Pydantic Validation

Record-level data validation using Pydantic BaseModel.

## Basic Model

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
```

## Batch Validation

```python
from pydantic import ValidationError

def validate_records(records: list[dict]) -> tuple[list[UserRecord], list[dict]]:
    """Validate batch of records, separating valid from invalid."""
    valid, invalid = [], []
    for record in records:
        try:
            valid.append(UserRecord(**record))
        except ValidationError as e:
            invalid.append({'record': record, 'errors': e.errors()})
    return valid, invalid

# Usage
valid, invalid = validate_records(raw_data)
if invalid:
    print(f"Found {len(invalid)} invalid records")
    for item in invalid[:5]:  # Show first 5 errors
        print(f"  Record: {item['record']}")
        for err in item['errors']:
            print(f"    - {err['loc']}: {err['msg']}")
```

## Field Constraints

```python
from pydantic import Field
from typing import Annotated

# Numeric constraints
age: int = Field(ge=0, le=150)  # 0 <= age <= 150
price: float = Field(gt=0)       # price > 0
quantity: int = Field(default=1, ge=1)

# String constraints
email: str = Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
name: str = Field(min_length=1, max_length=100)
code: str = Field(default=None, pattern=r'^[A-Z]{3}$')

# Using Annotated (Pydantic v2)
PositiveInt = Annotated[int, Field(gt=0)]
Email = Annotated[str, Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')]
```

## Custom Validators

```python
from pydantic import field_validator, model_validator

class Order(BaseModel):
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
```

## Nested Models

```python
class Address(BaseModel):
    street: str
    city: str
    country: str = Field(default='US')
    postal_code: str

class Customer(BaseModel):
    id: int
    name: str
    billing_address: Address
    shipping_address: Address | None = None

    @model_validator(mode='after')
    def default_shipping(self) -> 'Customer':
        if self.shipping_address is None:
            self.shipping_address = self.billing_address
        return self
```

## JSON/Dict Conversion

```python
# Parse from dict
customer = Customer(**data_dict)

# Parse from JSON string
customer = Customer.model_validate_json(json_string)

# Convert to dict
data = customer.model_dump()
data_excl = customer.model_dump(exclude={'id'})

# Convert to JSON
json_str = customer.model_dump_json()
```

## Settings/Config Validation

```python
from pydantic_settings import BaseSettings

class DatabaseSettings(BaseSettings):
    host: str = 'localhost'
    port: int = 5432
    user: str
    password: str
    database: str

    class Config:
        env_prefix = 'DB_'  # Reads DB_HOST, DB_PORT, etc.

# Usage: reads from environment variables
settings = DatabaseSettings()
```

## When to Use Pydantic

| Use Case | Pydantic | Alternative |
|----------|----------|-------------|
| API request/response | ✓ | FastAPI integration |
| Config validation | ✓ | pydantic-settings |
| Record-by-record ETL | ✓ | - |
| Full DataFrame validation | - | pandera |
| Pipeline expectations | - | Great Expectations |
