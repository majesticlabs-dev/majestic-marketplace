"""
Great Expectations patterns for data pipeline validation.

Includes context setup, expectation suite creation, and validation.
"""

import great_expectations as gx
from great_expectations.checkpoint import Checkpoint


# =============================================================================
# Context Setup
# =============================================================================

def get_pandas_context(datasource_name: str = "pandas_datasource"):
    """Get GX context with pandas datasource configured.

    Args:
        datasource_name: Name for the pandas datasource

    Returns:
        Tuple of (context, datasource)
    """
    context = gx.get_context()
    datasource = context.sources.add_pandas(datasource_name)
    return context, datasource


def add_dataframe_asset(datasource, asset_name: str, df):
    """Add DataFrame as data asset and build batch request.

    Args:
        datasource: GX datasource
        asset_name: Name for the data asset
        df: pandas DataFrame

    Returns:
        Batch request for the DataFrame
    """
    asset = datasource.add_dataframe_asset(name=asset_name)
    return asset.build_batch_request(dataframe=df)


# =============================================================================
# Expectation Suite Builder
# =============================================================================

def create_basic_suite(context, suite_name: str, columns_config: dict):
    """Create expectation suite from column configuration.

    Args:
        context: GX context
        suite_name: Name for the expectation suite
        columns_config: Dict mapping column names to expectation configs
            Example:
            {
                'user_id': {'not_null': True, 'unique': True, 'type': 'int'},
                'age': {'min': 0, 'max': 150},
                'status': {'values': ['active', 'inactive']},
                'email': {'regex': r'^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$'}
            }

    Returns:
        Expectation suite
    """
    suite = context.add_expectation_suite(suite_name)

    for column, config in columns_config.items():
        # Column existence
        suite.add_expectation(
            gx.expectations.ExpectColumnToExist(column=column)
        )

        # Null check
        if config.get('not_null', False):
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToNotBeNull(column=column)
            )

        # Uniqueness
        if config.get('unique', False):
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToBeUnique(column=column)
            )

        # Type check
        if 'type' in config:
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToBeOfType(
                    column=column,
                    type_=config['type']
                )
            )

        # Range check
        if 'min' in config or 'max' in config:
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToBeBetween(
                    column=column,
                    min_value=config.get('min'),
                    max_value=config.get('max')
                )
            )

        # Categorical values
        if 'values' in config:
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToBeInSet(
                    column=column,
                    value_set=config['values']
                )
            )

        # Regex pattern
        if 'regex' in config:
            suite.add_expectation(
                gx.expectations.ExpectColumnValuesToMatchRegex(
                    column=column,
                    regex=config['regex']
                )
            )

    return suite


# =============================================================================
# Validation Runner
# =============================================================================

def run_validation(
    context,
    checkpoint_name: str,
    batch_request,
    suite_name: str
) -> dict:
    """Run validation checkpoint and return results summary.

    Args:
        context: GX context
        checkpoint_name: Name for the checkpoint
        batch_request: Batch request for data
        suite_name: Name of expectation suite to use

    Returns:
        Dict with 'success' bool and 'failures' list
    """
    checkpoint = context.add_or_update_checkpoint(
        name=checkpoint_name,
        validations=[{
            "batch_request": batch_request,
            "expectation_suite_name": suite_name
        }]
    )

    results = checkpoint.run()

    summary = {
        'success': results.success,
        'failures': []
    }

    if not results.success:
        for result in results.run_results.values():
            for exp_result in result.results:
                if not exp_result.success:
                    summary['failures'].append({
                        'expectation': exp_result.expectation_config.expectation_type,
                        'column': exp_result.expectation_config.kwargs.get('column'),
                    })

    return summary
