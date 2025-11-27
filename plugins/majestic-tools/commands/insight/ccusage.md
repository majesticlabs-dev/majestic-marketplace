---
allowed-tools: Bash(npx ccusage@latest *)
description: Analyze Claude Code token usage and costs
model: haiku
---

## Context
- Daily usage: !`npx ccusage@latest daily --json`
- Current billing block: !`npx ccusage@latest blocks --json`
- Monthly summary: !`npx ccusage@latest monthly --json`

## Your task
Analyze Claude Code token usage and provide insights on costs and patterns. Follow these steps:

1. **Parse usage data**:
   - Extract token counts and costs from the JSON outputs
   - Identify usage patterns across different models (Opus, Sonnet)
   - Calculate current billing block utilization

2. **Analyze patterns**:
   - Identify peak usage times
   - Compare daily vs monthly trends
   - Highlight any unusual spikes or patterns
   - Calculate average tokens per session

3. **Provide cost insights**:
   - Total costs for current period
   - Cost breakdown by model
   - Projected monthly costs based on current usage
   - Comparison to previous periods if available

4. **Generate recommendations**:
   - Suggest optimizations for reducing token usage
   - Identify opportunities for using more cost-effective models
   - Recommend best times for intensive work based on billing blocks

## Arguments
`$ARGUMENTS` can specify:
- Date ranges: `2024-01-15 to 2024-01-20`
- Specific analysis: `blocks`, `daily`, `monthly`, `live`
- Custom filters: `--model opus`, `--breakdown`

If no arguments provided, show comprehensive analysis of last week's usage.

## Expected Output
```markdown
## Claude Code Usage Analysis

### Current Billing Block
- **Block Started**: [timestamp]
- **Tokens Used**: [X] / [block limit]
- **Time Remaining**: [hours:minutes]
- **Utilization**: [percentage]%

### Today's Usage
- **Total Tokens**: [count]
- **Total Cost**: $[amount]
- **Sessions**: [count]
- **Average per Session**: [tokens]

### Model Breakdown
| Model | Tokens | Cost | % of Total |
|-------|--------|------|------------|
| Opus  | [X]    | $[Y] | [Z]%       |
| Sonnet| [X]    | $[Y] | [Z]%       |

### Monthly Summary
- **Total Cost**: $[amount]
- **Daily Average**: $[amount]
- **Projected Monthly**: $[amount]

### Recommendations
1. [Specific optimization suggestions]
2. [Model usage recommendations]
3. [Billing block optimization tips]

### Usage Trends
[Visual representation or description of usage patterns]
```

## Example Usage
```bash
# Comprehensive recent usage analysis
/ccusage

# Analyze specific date range
/ccusage 2024-01-15 to 2024-01-20

# Focus on current billing block
/ccusage blocks

# Get live monitoring view
/ccusage live
```

## Additional Commands
For more detailed analysis, you can also run:
- `npx ccusage@latest daily --breakdown` - Per-model daily breakdown
- `npx ccusage@latest blocks --live` - Real-time monitoring dashboard
- `npx ccusage@latest monthly --from 2024-01` - Historical monthly data
