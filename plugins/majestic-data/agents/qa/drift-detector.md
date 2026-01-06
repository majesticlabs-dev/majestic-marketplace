---
name: drift-detector
description: Compare schema and data distributions across dataset versions to detect drift.
color: green
tools: Read, Grep, Glob, Bash
---

# Drift-Detector

Autonomous agent that monitors data drift between dataset versions or time periods.

## Drift Types

### Schema Drift
- New columns added
- Columns removed
- Type changes
- Constraint changes

### Data Drift
- Value distribution shifts
- New categorical values
- Range changes
- Null rate changes

### Volume Drift
- Row count changes
- Growth rate anomalies
- Seasonal pattern breaks

## Comparison Workflow

1. **Load baseline and current datasets**
2. **Compare schemas**
3. **Compare distributions** (numeric and categorical)
4. **Calculate drift scores**
5. **Generate alerts and report**

## Schema Comparison

```python
def compare_schemas(
    baseline: pd.DataFrame,
    current: pd.DataFrame
) -> dict:
    """Compare schemas between two DataFrames."""
    baseline_cols = set(baseline.columns)
    current_cols = set(current.columns)

    return {
        'added_columns': list(current_cols - baseline_cols),
        'removed_columns': list(baseline_cols - current_cols),
        'type_changes': [
            {
                'column': col,
                'baseline_type': str(baseline[col].dtype),
                'current_type': str(current[col].dtype)
            }
            for col in baseline_cols & current_cols
            if baseline[col].dtype != current[col].dtype
        ],
        'common_columns': list(baseline_cols & current_cols)
    }
```

## Statistical Drift Detection

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

    # Kolmogorov-Smirnov test
    ks_stat, ks_pvalue = stats.ks_2samp(baseline_clean, current_clean)

    # Population Stability Index
    psi = calculate_psi(baseline_clean, current_clean)

    return {
        'ks_statistic': ks_stat,
        'ks_pvalue': ks_pvalue,
        'drifted': ks_pvalue < significance,
        'psi': psi,
        'psi_alert': psi > 0.25,  # >0.25 indicates significant shift
        'baseline_stats': {
            'mean': baseline_clean.mean(),
            'std': baseline_clean.std(),
            'median': baseline_clean.median()
        },
        'current_stats': {
            'mean': current_clean.mean(),
            'std': current_clean.std(),
            'median': current_clean.median()
        }
    }

def calculate_psi(baseline: pd.Series, current: pd.Series, bins: int = 10) -> float:
    """Calculate Population Stability Index."""
    # Create bins from baseline
    _, bin_edges = np.histogram(baseline, bins=bins)

    # Calculate proportions
    baseline_counts = np.histogram(baseline, bins=bin_edges)[0]
    current_counts = np.histogram(current, bins=bin_edges)[0]

    baseline_pct = baseline_counts / len(baseline)
    current_pct = current_counts / len(current)

    # Avoid division by zero
    baseline_pct = np.where(baseline_pct == 0, 0.0001, baseline_pct)
    current_pct = np.where(current_pct == 0, 0.0001, current_pct)

    psi = np.sum((current_pct - baseline_pct) * np.log(current_pct / baseline_pct))
    return psi

def detect_categorical_drift(
    baseline: pd.Series,
    current: pd.Series,
    significance: float = 0.05
) -> dict:
    """Detect drift in categorical column using chi-square."""
    baseline_dist = baseline.value_counts(normalize=True)
    current_dist = current.value_counts(normalize=True)

    # Align categories
    all_categories = set(baseline_dist.index) | set(current_dist.index)
    baseline_aligned = [baseline_dist.get(c, 0) for c in all_categories]
    current_aligned = [current_dist.get(c, 0) for c in all_categories]

    # Chi-square test
    chi2, pvalue = stats.chisquare(current_aligned, baseline_aligned)

    return {
        'chi2_statistic': chi2,
        'chi2_pvalue': pvalue,
        'drifted': pvalue < significance,
        'new_categories': list(set(current.unique()) - set(baseline.unique())),
        'missing_categories': list(set(baseline.unique()) - set(current.unique())),
        'distribution_change': {
            cat: {
                'baseline': baseline_dist.get(cat, 0),
                'current': current_dist.get(cat, 0),
                'change': current_dist.get(cat, 0) - baseline_dist.get(cat, 0)
            }
            for cat in all_categories
        }
    }
```

## Drift Report

```markdown
# Data Drift Report

**Baseline:** orders_2024_01.parquet (Jan 2024)
**Current:** orders_2024_02.parquet (Feb 2024)
**Analysis Date:** 2024-02-15

## Summary

| Metric | Value | Status |
|--------|-------|--------|
| Schema Changes | 1 | ⚠️ |
| Columns with Drift | 3 of 12 | ⚠️ |
| Overall PSI | 0.18 | ✅ |
| Volume Change | +15% | ✅ |

## Schema Changes

### Added Columns
- `promo_code` (VARCHAR) - New promotional tracking

### Type Changes
None detected

## Distribution Drift

### 🔴 status (CRITICAL DRIFT)
- **PSI:** 0.42 (threshold: 0.25)
- **Chi-square p-value:** 0.0001

| Value | Baseline | Current | Change |
|-------|----------|---------|--------|
| pending | 15% | 8% | -7% |
| confirmed | 25% | 35% | +10% |
| shipped | 40% | 42% | +2% |
| cancelled | 20% | 15% | -5% |

**Interpretation:** Significant shift toward confirmed orders, fewer pending/cancelled.

### 🟡 total_amount (MODERATE DRIFT)
- **PSI:** 0.19 (threshold: 0.25)
- **KS p-value:** 0.02

| Stat | Baseline | Current | Change |
|------|----------|---------|--------|
| Mean | $85.50 | $92.30 | +8% |
| Median | $72.00 | $78.00 | +8% |
| Std | $45.20 | $52.10 | +15% |

**Interpretation:** Average order value increased, more variance.

### ✅ customer_id (NO DRIFT)
- **PSI:** 0.03
- Stable distribution

## Volume Analysis

| Metric | Baseline | Current | Change |
|--------|----------|---------|--------|
| Row Count | 45,230 | 52,015 | +15% |
| Daily Avg | 1,459 | 1,857 | +27% |

**Trend:** Growth consistent with seasonal patterns.

## Recommendations

1. **Investigate status shift** - Confirm this reflects actual business change
2. **Update monitoring thresholds** for total_amount if new mean is expected
3. **Add promo_code to validation suite**
```

## Alerting Thresholds

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

  alerts:
    - type: schema_change
      severity: warning
      channels: [slack, email]

    - type: psi_red
      severity: critical
      channels: [pagerduty, slack]

    - type: new_category
      severity: info
      channels: [slack]
```

## Execution

1. Load baseline and current datasets
2. Run schema comparison
3. For each common column:
   - Detect numeric or categorical drift
   - Calculate drift score
4. Analyze volume patterns
5. Generate report with severity levels
6. Trigger alerts for critical drift
