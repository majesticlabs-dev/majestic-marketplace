---
name: majestic-data:validate
description: Run data validation suite against a dataset.
argument-hint: "<file-path> [--suite <suite-file>]"
disable-model-invocation: true
---

# Data Validate Command

Run comprehensive data validation checks against a dataset.

## Arguments

**Target:** `$ARGUMENTS`

Parse arguments:
- File path (required): The data file to validate
- `--suite <path>`: Optional validation suite YAML file
- `--strict`: Fail on any warning (default: fail on errors only)

## Execution

### Step 1: Load Dataset

```python
# Detect format and load
if path.endswith('.csv'):
    df = pd.read_csv(path)
elif path.endswith('.parquet'):
    df = pd.read_parquet(path)
elif path.endswith('.json'):
    df = pd.read_json(path, lines=True)
```

### Step 2: Load or Generate Validation Suite

**If suite provided:**
```python
with open(suite_path) as f:
    suite = yaml.safe_load(f)
```

**If no suite:** Generate default checks based on data profiling:
- Not null for columns with 0% nulls
- Unique for columns with 100% unique
- Type consistency
- Value range checks for numerics

### Step 3: Run Validations

Invoke the data-validator agent:

```
Task(subagent_type="majestic-data:qa:data-validator",
     prompt="Run validation suite against the loaded dataset and report results")
```

### Step 4: Output Results

## Output Format

```markdown
# Validation Report

**File:** orders.csv
**Suite:** orders_validation.yml
**Executed:** 2024-01-15 10:30:00 UTC

## Summary

| Severity | Checks | Passed | Failed |
|----------|--------|--------|--------|
| 🔴 Critical | 3 | 3 | 0 |
| 🟠 Error | 5 | 4 | 1 |
| 🟡 Warning | 4 | 4 | 0 |
| **Total** | **12** | **11** | **1** |

**Status:** ⚠️ PASSED WITH ERRORS

## Failed Checks

### ❌ valid_status (ERROR)
- **Check:** Column `status` values in allowed set
- **Expected:** pending, confirmed, shipped, delivered, cancelled
- **Found:** 47 rows with value "processing"
- **Action:** Add "processing" to allowed values or fix source data

## Passed Checks

✅ unique_order_id (Critical)
✅ not_null_customer_id (Critical)
✅ not_null_order_date (Critical)
✅ positive_total (Error)
✅ valid_date_range (Error)
✅ foreign_key_customer (Error)
✅ row_count_range (Warning)
✅ freshness_check (Warning)
✅ no_future_dates (Warning)
✅ valid_email_format (Warning)

## Quality Score: 91.7 / 100
```

## Exit Codes

- `0`: All checks passed
- `1`: Critical or error checks failed
- `2`: Only warnings (with --strict: exits 1)

## Default Validation Suite

When no suite is provided, these checks run automatically:

```yaml
auto_validations:
  # For all columns
  - type: schema
    check: column_types_consistent

  # For columns with 0% nulls in profile
  - type: completeness
    check: not_null
    auto_detect: true

  # For columns with 100% unique
  - type: uniqueness
    check: unique
    auto_detect: true

  # For numeric columns
  - type: accuracy
    check: no_negatives_if_positive_mean
    auto_detect: true

  # For date columns
  - type: accuracy
    check: no_future_dates
    auto_detect: true

  # For string columns matching patterns
  - type: accuracy
    check: format_validation
    patterns:
      email: '^[\w\.-]+@[\w\.-]+\.\w+$'
      phone: '^\+?[\d\s\-\(\)]{10,}$'
      url: '^https?://'
```
