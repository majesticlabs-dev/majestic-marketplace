---
name: data-quality
description: Quality dimensions, scorecards, distribution monitoring, and freshness checks. Use for data validation pipelines and quality gates.
allowed-tools: Read Write Edit Bash
---

# Data Quality

**Audience:** Data engineers building quality gates for pipelines.

**Goal:** Measure, monitor, and report on data quality dimensions.

**Related skills:**
- `data-profiler` - For comprehensive data profiling
- `anomaly-detector` - For outlier detection

## Scripts

Execute quality functions from `scripts/quality_metrics.py`:

```python
from scripts.quality_metrics import (
    QualityDimension,
    QualityMetric,
    QualityScorecard,
    calculate_completeness,
    calculate_uniqueness,
    check_freshness,
    check_volume,
    detect_distribution_drift,
    generate_scorecard,
    generate_html_report
)
```

## Usage Examples

### Quality Checks

```python
from scripts.quality_metrics import calculate_completeness, calculate_uniqueness

# Completeness check
completeness = calculate_completeness(df, required_cols=['id', 'email', 'status'])
print(f"Completeness: {completeness.score}% - {'PASS' if completeness.passed else 'FAIL'}")

# Uniqueness check
uniqueness = calculate_uniqueness(df, key_cols=['id'])
print(f"Uniqueness: {uniqueness.score}%")
```

### Freshness Check

```python
from scripts.quality_metrics import check_freshness

freshness = check_freshness(df, timestamp_col='updated_at', max_age_hours=24)
if not freshness.passed:
    print(f"Data is stale: {freshness.details['age_hours']} hours old")
```

### Generate Scorecard

```python
from scripts.quality_metrics import generate_scorecard, generate_html_report

scorecard = generate_scorecard(
    df,
    name="users_table",
    required_cols=['id', 'email'],
    key_cols=['id']
)

print(f"Overall Score: {scorecard.overall_score:.1f}%")
print(f"Status: {'PASSED' if scorecard.passed else 'FAILED'}")

# Generate HTML report
html = generate_html_report(scorecard)
```

### Distribution Drift

```python
from scripts.quality_metrics import detect_distribution_drift

drift = detect_distribution_drift(baseline_df['revenue'], current_df['revenue'])
if drift['drifted']:
    print(f"Distribution drift detected: {drift['test']} p-value={drift['p_value']:.4f}")
```

## Quality Dimensions

| Dimension | What It Measures |
|-----------|-----------------|
| Completeness | Missing values, required fields |
| Uniqueness | Duplicates in key columns |
| Validity | Format, range, pattern compliance |
| Accuracy | Correctness vs source of truth |
| Consistency | Cross-field logical rules |
| Timeliness | Data freshness, staleness |

## Drift Detection

### Drift Types
- **Schema Drift:** New/removed columns, type changes, constraint changes
- **Data Drift:** Value distribution shifts, new categorical values, range changes, null rate changes
- **Volume Drift:** Row count changes, growth rate anomalies, seasonal pattern breaks

### Statistical Drift Methods

```python
from scipy import stats
import numpy as np

def detect_numeric_drift(
    baseline: pd.Series,
    current: pd.Series,
    significance: float = 0.05
) -> dict:
    """Detect drift in numeric column using KS test."""
    baseline_clean = baseline.dropna()
    current_clean = current.dropna()
    ks_stat, ks_pvalue = stats.ks_2samp(baseline_clean, current_clean)
    psi = calculate_psi(baseline_clean, current_clean)
    return {
        'ks_statistic': ks_stat,
        'ks_pvalue': ks_pvalue,
        'drifted': ks_pvalue < significance,
        'psi': psi,
        'psi_alert': psi > 0.25,
    }

def calculate_psi(baseline: pd.Series, current: pd.Series, bins: int = 10) -> float:
    """Calculate Population Stability Index."""
    _, bin_edges = np.histogram(baseline, bins=bins)
    baseline_counts = np.histogram(baseline, bins=bin_edges)[0]
    current_counts = np.histogram(current, bins=bin_edges)[0]
    baseline_pct = np.where(baseline_counts / len(baseline) == 0, 0.0001, baseline_counts / len(baseline))
    current_pct = np.where(current_counts / len(current) == 0, 0.0001, current_counts / len(current))
    return np.sum((current_pct - baseline_pct) * np.log(current_pct / baseline_pct))

def detect_categorical_drift(
    baseline: pd.Series,
    current: pd.Series,
    significance: float = 0.05
) -> dict:
    """Detect drift in categorical column using chi-square."""
    baseline_dist = baseline.value_counts(normalize=True)
    current_dist = current.value_counts(normalize=True)
    all_categories = set(baseline_dist.index) | set(current_dist.index)
    baseline_aligned = [baseline_dist.get(c, 0) for c in all_categories]
    current_aligned = [current_dist.get(c, 0) for c in all_categories]
    chi2, pvalue = stats.chisquare(current_aligned, baseline_aligned)
    return {
        'chi2_statistic': chi2,
        'chi2_pvalue': pvalue,
        'drifted': pvalue < significance,
        'new_categories': list(set(current.unique()) - set(baseline.unique())),
        'missing_categories': list(set(baseline.unique()) - set(current.unique())),
    }
```

### Schema Comparison

```python
def compare_schemas(baseline: pd.DataFrame, current: pd.DataFrame) -> dict:
    baseline_cols = set(baseline.columns)
    current_cols = set(current.columns)
    return {
        'added_columns': list(current_cols - baseline_cols),
        'removed_columns': list(baseline_cols - current_cols),
        'type_changes': [
            {'column': col, 'baseline_type': str(baseline[col].dtype), 'current_type': str(current[col].dtype)}
            for col in baseline_cols & current_cols
            if baseline[col].dtype != current[col].dtype
        ],
    }
```

### Drift Alerting Thresholds

```yaml
drift_config:
  psi_thresholds:
    green: 0.1
    yellow: 0.25
    red: 0.5
  volume_thresholds:
    max_daily_change_pct: 30
    max_weekly_change_pct: 50
  null_rate_thresholds:
    max_increase_pct: 5
```

## Dependencies

```
pandas
scipy  # For distribution drift detection
numpy  # For PSI calculation
```
