---
name: pipeline-analyzer
description: Analyze sales pipeline health, forecast accuracy, deal velocity, and conversion rates to identify bottlenecks and improve win rates.
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Pipeline Analyzer

Pipeline analytics guidance for high-growth B2B sales organizations.

## Initial Discovery

Gather pipeline data:

1. **Pipeline data**: Current pipeline by stage ($ value and deal count)?
2. **Win rate**: What % of opportunities do you close?
3. **Sales cycle**: Average days from qualified to closed?
4. **Target**: Revenue target this quarter?
5. **Historical**: What did you close last quarter? Coverage ratio?
6. **Concern**: Forecast accuracy? Slipped deals? Conversion rates?

## Routing

Based on primary concern, apply the appropriate skill:

| Concern | Skill | Deliverable |
|---------|-------|-------------|
| Pipeline health issues | `pipeline-diagnostics` | Coverage, velocity, problems |
| Forecast accuracy | `pipeline-forecasting` | Categories, weights, scoring |
| Report creation | `pipeline-reporting` | Weekly/monthly templates |

## Analysis Workflow

1. Gather pipeline data
2. Identify primary concern
3. If health/coverage issue:
   - Apply `pipeline-diagnostics`
   - Calculate coverage ratio
   - Analyze stage distribution
   - Diagnose problems and map to solutions
4. If forecasting issue:
   - Apply `pipeline-forecasting`
   - Apply deal scoring model
   - Calculate weighted pipeline
5. If reporting needed:
   - Apply `pipeline-reporting`
   - Generate appropriate template
6. Synthesize findings and recommendations

## Output Format

```markdown
# PIPELINE ANALYSIS: [Company/Date]

## Summary
[2-3 sentences on pipeline health]

## Key Metrics
- Coverage: [X]x quota
- Win Rate: [X%]
- Sales Cycle: [X] days
- Velocity: $[X]/day

## Findings
[Top 3 issues identified]

## Recommendations
1. [Action with expected impact]
2. [Action with expected impact]
3. [Action with expected impact]

## Next Steps
- [ ] [Immediate action]
- [ ] [This week action]
```
