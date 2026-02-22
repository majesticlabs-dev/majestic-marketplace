# Increment Decomposition Patterns

## General Strategy

Order increments from simplest to most complex:

1. **Degenerate cases** — empty input, nil, zero, no-op
2. **Happy path** — core behavior with valid input
3. **Variations** — different valid inputs, alternate paths
4. **Edge cases** — boundaries, limits, unusual but valid input
5. **Error cases** — invalid input, failures, exceptions
6. **Integration** — interaction with external systems or components

## Pattern: Data Transformation

| # | Increment | Test Description |
|---|-----------|-----------------|
| 1 | Empty/nil input | Returns default when given empty input |
| 2 | Single item | Transforms one item correctly |
| 3 | Multiple items | Transforms collection correctly |
| 4 | Filtering | Excludes items matching criteria |
| 5 | Edge values | Handles boundary values (max, min, empty string) |
| 6 | Invalid input | Raises error for malformed data |

## Pattern: CRUD

| # | Increment | Test Description |
|---|-----------|-----------------|
| 1 | Create (valid) | Creates record with valid attributes |
| 2 | Create (invalid) | Rejects record with missing/invalid attributes |
| 3 | Read (exists) | Retrieves existing record |
| 4 | Read (missing) | Returns error/nil for nonexistent record |
| 5 | Update (valid) | Modifies record with valid changes |
| 6 | Update (invalid) | Rejects invalid modifications |
| 7 | Delete | Removes record and confirms absence |
| 8 | List/filter | Lists records with optional filtering |

## Pattern: State Machine

| # | Increment | Test Description |
|---|-----------|-----------------|
| 1 | Initial state | Object starts in correct initial state |
| 2 | Valid transition | Transitions to next state with valid trigger |
| 3 | Invalid transition | Rejects transition from wrong state |
| 4 | Guard conditions | Blocks transition when guard fails |
| 5 | Side effects | Triggers callbacks on transition |
| 6 | Terminal state | Cannot transition from final state |

## Pattern: Calculation

| # | Increment | Test Description |
|---|-----------|-----------------|
| 1 | Zero/identity | Returns identity value for trivial input |
| 2 | Simple case | Calculates correctly for basic input |
| 3 | Multiple inputs | Handles compound calculations |
| 4 | Rounding/precision | Produces correct precision |
| 5 | Overflow/limits | Handles extreme values |
| 6 | Error cases | Rejects invalid inputs (division by zero, negative where not allowed) |

## Pattern: Integration / Adapter

| # | Increment | Test Description |
|---|-----------|-----------------|
| 1 | Successful call | Returns expected data from external service |
| 2 | Empty response | Handles empty/null response gracefully |
| 3 | Error response | Handles HTTP error / exception |
| 4 | Timeout | Handles timeout with appropriate error |
| 5 | Retry | Retries on transient failure |
| 6 | Data mapping | Maps external format to internal model |
