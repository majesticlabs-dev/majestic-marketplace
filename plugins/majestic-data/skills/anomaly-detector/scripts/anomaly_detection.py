"""
Anomaly detection methods for pandas DataFrames and Series.

Statistical methods (Z-score, IQR, Modified Z-score) and ML-based methods
(Isolation Forest, LOF) for outlier detection.
"""

import pandas as pd
import numpy as np


# =============================================================================
# Statistical Methods
# =============================================================================

def detect_anomalies_zscore(series: pd.Series, threshold: float = 3.0) -> pd.Series:
    """Detect anomalies using Z-score.

    Args:
        series: Numeric pandas Series
        threshold: Number of standard deviations (default 3.0)

    Returns:
        Boolean Series where True indicates anomaly
    """
    mean = series.mean()
    std = series.std()
    z_scores = (series - mean) / std
    return abs(z_scores) > threshold


def detect_anomalies_iqr(series: pd.Series, multiplier: float = 1.5) -> pd.Series:
    """Detect anomalies using IQR method.

    Args:
        series: Numeric pandas Series
        multiplier: IQR multiplier (1.5 for outliers, 3.0 for extreme outliers)

    Returns:
        Boolean Series where True indicates anomaly
    """
    Q1 = series.quantile(0.25)
    Q3 = series.quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - multiplier * IQR
    upper = Q3 + multiplier * IQR
    return (series < lower) | (series > upper)


def detect_anomalies_modified_zscore(series: pd.Series, threshold: float = 3.5) -> pd.Series:
    """Detect anomalies using Modified Z-score (robust to outliers).

    Uses median and MAD instead of mean and std.
    """
    median = series.median()
    mad = (series - median).abs().median()
    modified_z = 0.6745 * (series - median) / mad
    return abs(modified_z) > threshold


# =============================================================================
# ML-Based Methods
# =============================================================================

def detect_anomalies_isolation_forest(
    df: pd.DataFrame,
    columns: list[str],
    contamination: float = 0.01
) -> pd.Series:
    """Detect anomalies using Isolation Forest.

    Args:
        df: DataFrame with data
        columns: Columns to use for detection
        contamination: Expected proportion of outliers (0.01 = 1%)

    Returns:
        Boolean Series where True indicates anomaly
    """
    from sklearn.ensemble import IsolationForest

    model = IsolationForest(contamination=contamination, random_state=42)
    predictions = model.fit_predict(df[columns].fillna(0))
    return pd.Series(predictions == -1, index=df.index)


def detect_anomalies_lof(
    df: pd.DataFrame,
    columns: list[str],
    n_neighbors: int = 20,
    contamination: float = 0.01
) -> pd.Series:
    """Detect anomalies using Local Outlier Factor.

    Good for detecting local density-based anomalies.
    """
    from sklearn.neighbors import LocalOutlierFactor

    model = LocalOutlierFactor(n_neighbors=n_neighbors, contamination=contamination)
    predictions = model.fit_predict(df[columns].fillna(0))
    return pd.Series(predictions == -1, index=df.index)


# =============================================================================
# Time-Series Methods
# =============================================================================

def detect_anomalies_rolling(
    series: pd.Series,
    window: int = 7,
    n_std: float = 2.0
) -> pd.Series:
    """Detect anomalies using rolling mean/std.

    Good for time-series with trends or seasonality.
    """
    rolling_mean = series.rolling(window=window, center=True).mean()
    rolling_std = series.rolling(window=window, center=True).std()

    lower = rolling_mean - n_std * rolling_std
    upper = rolling_mean + n_std * rolling_std

    return (series < lower) | (series > upper)


def detect_anomalies_stl(
    series: pd.Series,
    period: int,
    threshold: float = 3.0
) -> pd.Series:
    """Detect anomalies using STL decomposition residuals.

    Separates trend, seasonality, and residuals.
    """
    from statsmodels.tsa.seasonal import STL

    stl = STL(series, period=period)
    result = stl.fit()
    residuals = result.resid

    mean = residuals.mean()
    std = residuals.std()
    z_scores = (residuals - mean) / std

    return abs(z_scores) > threshold


# =============================================================================
# Ensemble Approach
# =============================================================================

def detect_anomalies_ensemble(
    df: pd.DataFrame,
    columns: list[str],
    methods: list[str] = ['zscore', 'iqr', 'isolation_forest'],
    min_agreement: int = 2
) -> pd.DataFrame:
    """Combine multiple anomaly detection methods.

    Args:
        df: DataFrame with data
        columns: Columns to analyze
        methods: List of methods to use
        min_agreement: Minimum methods that must agree for flagging

    Returns:
        DataFrame with anomaly flags per method and combined
    """
    results = pd.DataFrame(index=df.index)

    for col in columns:
        series = df[col]

        if 'zscore' in methods:
            results[f'{col}_zscore'] = detect_anomalies_zscore(series)
        if 'iqr' in methods:
            results[f'{col}_iqr'] = detect_anomalies_iqr(series)
        if 'modified_zscore' in methods:
            results[f'{col}_mzscore'] = detect_anomalies_modified_zscore(series)

    if 'isolation_forest' in methods:
        results['isolation_forest'] = detect_anomalies_isolation_forest(df, columns)

    # Combined flag: anomaly if min_agreement methods agree
    method_cols = list(results.columns)
    results['is_anomaly'] = results[method_cols].sum(axis=1) >= min_agreement

    return results
