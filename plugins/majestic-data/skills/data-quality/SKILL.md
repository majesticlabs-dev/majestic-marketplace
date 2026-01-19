---
name: data-quality
description: Quality dimensions, scorecards, distribution monitoring, and freshness checks. Use for data validation pipelines and quality gates.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Data Quality

Quality dimensions, scorecarding, and monitoring for data pipelines.

**Related skills:**
- `data-profiler` - For comprehensive data profiling
- `anomaly-detector` - For outlier detection

## Quality Dimensions

```python
from dataclasses import dataclass
from enum import Enum
from datetime import datetime

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
```

## Quality Checks

### Completeness

```python
def calculate_completeness(df: pd.DataFrame, required_cols: list[str]) -> QualityMetric:
    """Measure data completeness."""
    null_rates = df[required_cols].isnull().mean()
    avg_completeness = (1 - null_rates.mean()) * 100

    return QualityMetric(
        dimension=QualityDimension.COMPLETENESS,
        name="Required Fields Completeness",
        score=avg_completeness,
        passed=avg_completeness >= 95,
        details={'null_rates': null_rates.to_dict(), 'threshold': 95}
    )
```

### Uniqueness

```python
def calculate_uniqueness(df: pd.DataFrame, key_cols: list[str]) -> QualityMetric:
    """Measure uniqueness of key columns."""
    dup_count = df.duplicated(subset=key_cols).sum()
    uniqueness = (1 - dup_count / len(df)) * 100

    return QualityMetric(
        dimension=QualityDimension.UNIQUENESS,
        name="Key Column Uniqueness",
        score=uniqueness,
        passed=uniqueness == 100,
        details={'duplicate_count': dup_count, 'key_columns': key_cols}
    )
```

### Freshness

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
        details={'latest_timestamp': str(latest), 'age_hours': round(age_hours, 2)}
    )
```

### Volume

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
        details={'current': current_count, 'expected': expected_count, 'deviation_pct': round(deviation, 2)}
    )
```

## Distribution Monitoring

```python
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
        return {
            'test': 'Kolmogorov-Smirnov',
            'statistic': statistic,
            'p_value': p_value,
            'drifted': p_value < threshold,
            'mean_change_pct': abs(current.mean() - baseline.mean()) / baseline.mean() * 100
        }
    else:
        # Chi-square for categorical
        baseline_dist = baseline.value_counts(normalize=True)
        current_dist = current.value_counts(normalize=True)
        all_cats = set(baseline_dist.index) | set(current_dist.index)
        baseline_aligned = [baseline_dist.get(c, 0) for c in all_cats]
        current_aligned = [current_dist.get(c, 0) for c in all_cats]
        statistic, p_value = stats.chisquare(current_aligned, baseline_aligned)
        return {
            'test': 'Chi-Square',
            'statistic': statistic,
            'p_value': p_value,
            'drifted': p_value < threshold,
            'new_categories': list(set(current.unique()) - set(baseline.unique()))
        }
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
        return sum(m.score for m in self.metrics) / len(self.metrics) if self.metrics else 0.0

    @property
    def passed(self) -> bool:
        return all(m.passed for m in self.metrics)

    def to_dict(self) -> dict:
        return {
            'dataset': self.dataset_name,
            'timestamp': self.timestamp.isoformat(),
            'rows': self.row_count,
            'columns': self.column_count,
            'overall_score': self.overall_score,
            'passed': self.passed,
            'metrics': [{'dimension': m.dimension.value, 'name': m.name, 'score': m.score, 'passed': m.passed} for m in self.metrics]
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
    ]

    return QualityScorecard(
        dataset_name=name,
        timestamp=datetime.now(),
        row_count=len(df),
        column_count=len(df.columns),
        metrics=metrics
    )
```

## Report Generation

```python
def generate_html_report(scorecard: QualityScorecard) -> str:
    """Generate HTML quality report."""
    status_color = "green" if scorecard.passed else "red"
    metrics_html = "".join([
        f"<tr><td>{m.dimension.value}</td><td>{m.name}</td>"
        f"<td style='color: {'green' if m.passed else 'red'}'>{m.score:.1f}%</td>"
        f"<td>{'✓' if m.passed else '✗'}</td></tr>"
        for m in scorecard.metrics
    ])

    return f"""
    <html><body>
        <h1>Data Quality Report: {scorecard.dataset_name}</h1>
        <p>Generated: {scorecard.timestamp} | Rows: {scorecard.row_count:,}</p>
        <h2 style="color: {status_color}">Overall: {scorecard.overall_score:.1f}%</h2>
        <table border="1">
            <tr><th>Dimension</th><th>Check</th><th>Score</th><th>Status</th></tr>
            {metrics_html}
        </table>
    </body></html>
    """
```
