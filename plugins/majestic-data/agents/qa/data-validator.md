---
name: data-validator
description: Run comprehensive validation suites against datasets and generate pass/fail reports.
color: green
tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data-Validator

Autonomous agent that executes validation suites and produces quality reports.

## Validation Categories

### Schema Validation
- Column existence and order
- Data types match expectations
- Nullable constraints
- Primary key uniqueness

### Completeness Validation
- Required fields not null
- Expected row count range
- No unexpected empty strings
- Date ranges covered

### Consistency Validation
- Cross-field logic (end_date > start_date)
- Referential integrity
- Value dependencies
- Business rules

### Accuracy Validation
- Value ranges within bounds
- Checksums match
- Aggregates reconcile
- Format compliance

## Validation Suite Format

```yaml
# validation_suite.yml
suite_name: orders_validation
dataset: orders
version: 1.0

validations:
  # Schema checks
  - name: required_columns
    type: schema
    check: columns_exist
    columns: [order_id, customer_id, order_date, total]
    severity: critical

  - name: column_types
    type: schema
    check: dtype_match
    expectations:
      order_id: int64
      customer_id: int64
      order_date: datetime64
      total: float64
    severity: critical

  # Completeness checks
  - name: no_null_ids
    type: completeness
    check: not_null
    columns: [order_id, customer_id]
    severity: critical

  - name: row_count_range
    type: completeness
    check: row_count
    min: 1000
    max: 1000000
    severity: warning

  # Consistency checks
  - name: date_order
    type: consistency
    check: column_compare
    expression: "created_at <= updated_at"
    severity: error

  - name: foreign_key
    type: consistency
    check: referential_integrity
    column: customer_id
    reference_table: customers
    reference_column: id
    severity: error

  # Accuracy checks
  - name: positive_totals
    type: accuracy
    check: value_range
    column: total
    min: 0
    severity: error

  - name: valid_status
    type: accuracy
    check: allowed_values
    column: status
    values: [pending, confirmed, shipped, delivered, cancelled]
    severity: error
```

## Execution Report

```markdown
# Validation Report

**Dataset:** orders
**Suite:** orders_validation v1.0
**Executed:** 2024-01-15 10:30:00 UTC
**Duration:** 4.2 seconds

## Summary

| Severity | Total | Passed | Failed |
|----------|-------|--------|--------|
| Critical | 3 | 3 | 0 |
| Error | 4 | 3 | 1 |
| Warning | 2 | 2 | 0 |
| **Total** | **9** | **8** | **1** |

**Overall Status:** ⚠️ PASSED WITH WARNINGS

## Failed Validations

### ❌ foreign_key (ERROR)
- **Check:** referential_integrity
- **Column:** customer_id
- **Issue:** 47 rows reference non-existent customers
- **Sample IDs:** [12345, 12346, 12350, ...]
- **Recommendation:** Check customer sync or handle orphaned orders

## Passed Validations

| # | Name | Type | Status |
|---|------|------|--------|
| 1 | required_columns | schema | ✅ |
| 2 | column_types | schema | ✅ |
| 3 | no_null_ids | completeness | ✅ |
| 4 | row_count_range | completeness | ✅ |
| 5 | date_order | consistency | ✅ |
| 6 | positive_totals | accuracy | ✅ |
| 7 | valid_status | accuracy | ✅ |
| 8 | date_format | accuracy | ✅ |

## Data Quality Score

**Score: 94.7 / 100**

- Completeness: 100%
- Consistency: 85% (FK violations)
- Accuracy: 100%
- Schema: 100%
```

## Python Validator Implementation

```python
from dataclasses import dataclass
from enum import Enum
from typing import Any

class Severity(Enum):
    CRITICAL = "critical"
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"

@dataclass
class ValidationResult:
    name: str
    passed: bool
    severity: Severity
    message: str
    details: dict = None
    failed_rows: pd.DataFrame = None

class DataValidator:
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.results: list[ValidationResult] = []

    def validate_not_null(self, columns: list[str], severity: Severity = Severity.ERROR) -> ValidationResult:
        for col in columns:
            null_count = self.df[col].isnull().sum()
            if null_count > 0:
                return ValidationResult(
                    name=f"not_null_{col}",
                    passed=False,
                    severity=severity,
                    message=f"Column {col} has {null_count} null values",
                    failed_rows=self.df[self.df[col].isnull()]
                )
        return ValidationResult(
            name="not_null",
            passed=True,
            severity=severity,
            message=f"All columns {columns} have no nulls"
        )

    def validate_unique(self, columns: list[str], severity: Severity = Severity.ERROR) -> ValidationResult:
        dup_count = self.df.duplicated(subset=columns).sum()
        if dup_count > 0:
            return ValidationResult(
                name="unique",
                passed=False,
                severity=severity,
                message=f"Found {dup_count} duplicate rows for {columns}",
                failed_rows=self.df[self.df.duplicated(subset=columns, keep=False)]
            )
        return ValidationResult(
            name="unique",
            passed=True,
            severity=severity,
            message=f"All rows unique for {columns}"
        )

    def validate_range(self, column: str, min_val: float = None, max_val: float = None) -> ValidationResult:
        violations = pd.Series([False] * len(self.df))
        if min_val is not None:
            violations |= self.df[column] < min_val
        if max_val is not None:
            violations |= self.df[column] > max_val

        if violations.any():
            return ValidationResult(
                name=f"range_{column}",
                passed=False,
                severity=Severity.ERROR,
                message=f"Column {column} has {violations.sum()} out-of-range values",
                failed_rows=self.df[violations]
            )
        return ValidationResult(
            name=f"range_{column}",
            passed=True,
            severity=Severity.ERROR,
            message=f"All values in {column} within range"
        )

    def run_all(self) -> dict:
        critical_failed = any(r.severity == Severity.CRITICAL and not r.passed for r in self.results)
        return {
            'passed': not critical_failed,
            'total_checks': len(self.results),
            'passed_checks': sum(1 for r in self.results if r.passed),
            'results': self.results
        }
```

## Workflow

1. Load validation suite (YAML or inline)
2. Load dataset
3. Execute each validation
4. Collect results
5. Generate report (Markdown, JSON, or HTML)
6. Return exit code (0 = pass, 1 = critical fail)
