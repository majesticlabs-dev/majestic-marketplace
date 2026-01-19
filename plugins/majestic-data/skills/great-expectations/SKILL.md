---
name: great-expectations
description: Data validation using Great Expectations. Expectation suites, checkpoints, and data docs for pipeline monitoring.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Great Expectations

Expectation-based data validation for data pipelines.

## Quick Start

```python
import great_expectations as gx

# Get or create context
context = gx.get_context()

# Add data source
datasource = context.sources.add_pandas("my_datasource")

# Add data asset
asset = datasource.add_dataframe_asset(name="users")

# Build batch request
batch_request = asset.build_batch_request(dataframe=df)
```

## Define Expectations

```python
# Create expectation suite
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
        column="age",
        min_value=0,
        max_value=150
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

# Regex patterns
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToMatchRegex(
        column="email",
        regex=r"^[\w\.-]+@[\w\.-]+\.\w+$"
    )
)
```

## Common Expectations

```python
# Table-level
ExpectTableRowCountToBeBetween(min_value=1000, max_value=10000)
ExpectTableColumnCountToEqual(value=10)

# Column existence and types
ExpectColumnToExist(column="id")
ExpectColumnValuesToBeOfType(column="id", type_="int")

# Null handling
ExpectColumnValuesToNotBeNull(column="id")
ExpectColumnValuesToBeNull(column="deprecated_field")

# Numeric ranges
ExpectColumnValuesToBeBetween(column="age", min_value=0, max_value=150)
ExpectColumnMeanToBeBetween(column="revenue", min_value=100, max_value=1000)
ExpectColumnSumToBeBetween(column="quantity", min_value=0)

# String patterns
ExpectColumnValuesToMatchRegex(column="phone", regex=r"^\d{3}-\d{4}$")
ExpectColumnValueLengthsToBeBetween(column="name", min_value=1, max_value=100)

# Categorical
ExpectColumnValuesToBeInSet(column="status", value_set=["A", "B", "C"])
ExpectColumnDistinctValuesToBeInSet(column="country", value_set=["US", "CA", "UK"])

# Uniqueness
ExpectColumnValuesToBeUnique(column="id")
ExpectCompoundColumnsToBeUnique(column_list=["user_id", "date"])
```

## Run Validation

```python
# Create checkpoint
checkpoint = context.add_or_update_checkpoint(
    name="user_data_checkpoint",
    validations=[{
        "batch_request": batch_request,
        "expectation_suite_name": "user_data_suite"
    }]
)

# Run checkpoint
results = checkpoint.run()

# Check if passed
if results.success:
    print("All expectations passed!")
else:
    print("Validation failed")
    for result in results.run_results.values():
        for expectation_result in result.results:
            if not expectation_result.success:
                print(f"  Failed: {expectation_result.expectation_config.expectation_type}")
```

## Data Docs

```python
# Build and open data docs (HTML reports)
context.build_data_docs()
context.open_data_docs()
```

## Profiler (Auto-generate Expectations)

```python
# Create profiler
profiler = gx.RuleBasedProfiler(
    name="user_profiler",
    config_version=1.0,
    rules={
        "rule_for_columns": {
            "domain_builder": {
                "class_name": "ColumnDomainBuilder",
            },
            "expectation_configuration_builders": [
                {"class_name": "DefaultExpectationConfigurationBuilder"}
            ]
        }
    }
)

# Run profiler
suite = profiler.run(batch_request=batch_request)
```

## When to Use Great Expectations

| Use Case | GX | Alternative |
|----------|-----|-------------|
| Pipeline monitoring | ✓ | - |
| Data warehouse validation | ✓ | - |
| Automated data docs | ✓ | - |
| Simple DataFrame checks | - | Pandera |
| Record-level API validation | - | Pydantic |
| Real-time streaming | - | Custom |

## Directory Structure

```
great_expectations/
├── great_expectations.yml     # Config
├── expectations/              # Expectation suites (JSON)
├── checkpoints/               # Checkpoint definitions
├── plugins/                   # Custom expectations
├── uncommitted/
│   ├── data_docs/            # Generated HTML docs
│   └── validations/          # Validation results
```
