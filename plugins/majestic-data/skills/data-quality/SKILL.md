---
name: data-quality
description: Data profiling, distribution monitoring, anomaly detection, and quality metrics.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data-Quality

Patterns for data profiling, monitoring, and quality assurance.

## Quick Profiling

```python
def profile_dataframe(df: pd.DataFrame) -> dict:
    """Generate comprehensive profile of DataFrame."""
    profile = {
        'shape': df.shape,
        'memory_mb': df.memory_usage(deep=True).sum() / 1024**2,
        'columns': {}
    }

    for col in df.columns:
        col_profile = {
            'dtype': str(df[col].dtype),
            'null_count': int(df[col].isnull().sum()),
            'null_pct': round(df[col].isnull().mean() * 100, 2),
            'unique_count': int(df[col].nunique()),
            'unique_pct': round(df[col].nunique() / len(df) * 100, 2),
        }

        if df[col].dtype in ['int64', 'float64']:
            col_profile.update({
                'min': float(df[col].min()),
                'max': float(df[col].max()),
                'mean': float(df[col].mean()),
                'std': float(df[col].std()),
                'median': float(df[col].median()),
                'zeros': int((df[col] == 0).sum()),
                'negatives': int((df[col] < 0).sum()),
            })
        elif df[col].dtype == 'object':
            col_profile.update({
                'min_length': int(df[col].str.len().min()),
                'max_length': int(df[col].str.len().max()),
                'top_values': df[col].value_counts().head(5).to_dict(),
            })
        elif pd.api.types.is_datetime64_any_dtype(df[col]):
            col_profile.update({
                'min_date': str(df[col].min()),
                'max_date': str(df[col].max()),
                'date_range_days': int((df[col].max() - df[col].min()).days),
            })

        profile['columns'][col] = col_profile

    return profile
```

## Data Quality Dimensions

```python
from dataclasses import dataclass
from enum import Enum

class QualityDimension(Enum):
    COMPLETENESS = "completeness"    # Missing values
    UNIQUENESS = "uniqueness"        # Duplicates
    VALIDITY = "validity"            # Format/range
    ACCURACY = "accuracy"            # Correctness
    CONSISTENCY = "consistency"      # Cross-field logic
    TIMELINESS = "timeliness"        # Data freshness

@dataclass
class QualityMetric:
    dimension: QualityDimension
    name: str
    score: float  # 0-100
    passed: bool
    details: dict

def calculate_completeness(df: pd.DataFrame, required_cols: list[str]) -> QualityMetric:
    """Measure data completeness."""
    null_rates = df[required_cols].isnull().mean()
    avg_completeness = (1 - null_rates.mean()) * 100

    return QualityMetric(
        dimension=QualityDimension.COMPLETENESS,
        name="Required Fields Completeness",
        score=avg_completeness,
        passed=avg_completeness >= 95,
        details={
            'null_rates': null_rates.to_dict(),
            'threshold': 95
        }
    )

def calculate_uniqueness(df: pd.DataFrame, key_cols: list[str]) -> QualityMetric:
    """Measure uniqueness of key columns."""
    dup_count = df.duplicated(subset=key_cols).sum()
    uniqueness = (1 - dup_count / len(df)) * 100

    return QualityMetric(
        dimension=QualityDimension.UNIQUENESS,
        name="Key Column Uniqueness",
        score=uniqueness,
        passed=uniqueness == 100,
        details={
            'duplicate_count': dup_count,
            'key_columns': key_cols
        }
    )
```

## Distribution Monitoring

```python
import numpy as np
from scipy import stats

def detect_distribution_drift(
    baseline: pd.Series,
    current: pd.Series,
    threshold: float = 0.1
) -> dict:
    """Detect statistical drift between distributions."""

    if baseline.dtype in ['int64', 'float64']:
        # KS test for numeric
        statistic, p_value = stats.ks_2samp(baseline.dropna(), current.dropna())
        drifted = p_value < threshold

        return {
            'test': 'Kolmogorov-Smirnov',
            'statistic': statistic,
            'p_value': p_value,
            'drifted': drifted,
            'baseline_mean': baseline.mean(),
            'current_mean': current.mean(),
            'mean_change_pct': abs(current.mean() - baseline.mean()) / baseline.mean() * 100
        }
    else:
        # Chi-square for categorical
        baseline_dist = baseline.value_counts(normalize=True)
        current_dist = current.value_counts(normalize=True)

        # Align categories
        all_cats = set(baseline_dist.index) | set(current_dist.index)
        baseline_aligned = [baseline_dist.get(c, 0) for c in all_cats]
        current_aligned = [current_dist.get(c, 0) for c in all_cats]

        statistic, p_value = stats.chisquare(current_aligned, baseline_aligned)

        return {
            'test': 'Chi-Square',
            'statistic': statistic,
            'p_value': p_value,
            'drifted': p_value < threshold,
            'new_categories': list(set(current.unique()) - set(baseline.unique())),
            'missing_categories': list(set(baseline.unique()) - set(current.unique()))
        }

def monitor_all_columns(baseline_df: pd.DataFrame, current_df: pd.DataFrame) -> dict:
    """Monitor drift across all columns."""
    results = {}
    for col in baseline_df.columns:
        if col in current_df.columns:
            results[col] = detect_distribution_drift(baseline_df[col], current_df[col])
    return results
```

## Anomaly Detection

```python
def detect_anomalies_zscore(series: pd.Series, threshold: float = 3.0) -> pd.Series:
    """Detect anomalies using Z-score."""
    mean = series.mean()
    std = series.std()
    z_scores = (series - mean) / std
    return abs(z_scores) > threshold

def detect_anomalies_iqr(series: pd.Series, multiplier: float = 1.5) -> pd.Series:
    """Detect anomalies using IQR method."""
    Q1 = series.quantile(0.25)
    Q3 = series.quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - multiplier * IQR
    upper = Q3 + multiplier * IQR
    return (series < lower) | (series > upper)

def detect_anomalies_isolation_forest(df: pd.DataFrame, columns: list[str]) -> pd.Series:
    """Detect anomalies using Isolation Forest."""
    from sklearn.ensemble import IsolationForest

    model = IsolationForest(contamination=0.01, random_state=42)
    predictions = model.fit_predict(df[columns].fillna(0))
    return pd.Series(predictions == -1, index=df.index)
```

## Quality Scorecard

```python
@dataclass
class QualityScorecard:
    dataset_name: str
    timestamp: datetime
    row_count: int
    column_count: int
    metrics: list[QualityMetric]

    @property
    def overall_score(self) -> float:
        """Weighted average of all metrics."""
        if not self.metrics:
            return 0.0
        return sum(m.score for m in self.metrics) / len(self.metrics)

    @property
    def passed(self) -> bool:
        """All critical checks passed."""
        return all(m.passed for m in self.metrics)

    def to_dict(self) -> dict:
        return {
            'dataset': self.dataset_name,
            'timestamp': self.timestamp.isoformat(),
            'rows': self.row_count,
            'columns': self.column_count,
            'overall_score': self.overall_score,
            'passed': self.passed,
            'metrics': [
                {
                    'dimension': m.dimension.value,
                    'name': m.name,
                    'score': m.score,
                    'passed': m.passed
                }
                for m in self.metrics
            ]
        }

def generate_scorecard(
    df: pd.DataFrame,
    name: str,
    required_cols: list[str],
    key_cols: list[str]
) -> QualityScorecard:
    """Generate complete quality scorecard."""
    metrics = [
        calculate_completeness(df, required_cols),
        calculate_uniqueness(df, key_cols),
        # Add more metrics as needed
    ]

    return QualityScorecard(
        dataset_name=name,
        timestamp=datetime.now(),
        row_count=len(df),
        column_count=len(df.columns),
        metrics=metrics
    )
```

## Freshness Monitoring

```python
def check_freshness(
    df: pd.DataFrame,
    timestamp_col: str,
    max_age_hours: int = 24
) -> QualityMetric:
    """Check if data is fresh enough."""
    latest = df[timestamp_col].max()
    age_hours = (datetime.now() - latest).total_seconds() / 3600

    return QualityMetric(
        dimension=QualityDimension.TIMELINESS,
        name="Data Freshness",
        score=max(0, 100 - (age_hours / max_age_hours * 100)),
        passed=age_hours <= max_age_hours,
        details={
            'latest_timestamp': str(latest),
            'age_hours': round(age_hours, 2),
            'threshold_hours': max_age_hours
        }
    )
```

## Volume Monitoring

```python
def check_volume(
    current_count: int,
    expected_count: int,
    tolerance_pct: float = 20
) -> QualityMetric:
    """Check if row count is within expected range."""
    deviation = abs(current_count - expected_count) / expected_count * 100

    return QualityMetric(
        dimension=QualityDimension.COMPLETENESS,
        name="Volume Check",
        score=max(0, 100 - deviation),
        passed=deviation <= tolerance_pct,
        details={
            'current_count': current_count,
            'expected_count': expected_count,
            'deviation_pct': round(deviation, 2),
            'tolerance_pct': tolerance_pct
        }
    )
```

## Report Generation

```python
def generate_html_report(scorecard: QualityScorecard) -> str:
    """Generate HTML quality report."""
    status_color = "green" if scorecard.passed else "red"

    metrics_html = ""
    for m in scorecard.metrics:
        color = "green" if m.passed else "red"
        metrics_html += f"""
        <tr>
            <td>{m.dimension.value}</td>
            <td>{m.name}</td>
            <td style="color: {color}">{m.score:.1f}%</td>
            <td>{"✓" if m.passed else "✗"}</td>
        </tr>
        """

    return f"""
    <html>
    <body>
        <h1>Data Quality Report: {scorecard.dataset_name}</h1>
        <p>Generated: {scorecard.timestamp}</p>
        <p>Rows: {scorecard.row_count:,} | Columns: {scorecard.column_count}</p>
        <h2 style="color: {status_color}">
            Overall Score: {scorecard.overall_score:.1f}%
            {"✓ PASSED" if scorecard.passed else "✗ FAILED"}
        </h2>
        <table border="1">
            <tr><th>Dimension</th><th>Check</th><th>Score</th><th>Status</th></tr>
            {metrics_html}
        </table>
    </body>
    </html>
    """
```
