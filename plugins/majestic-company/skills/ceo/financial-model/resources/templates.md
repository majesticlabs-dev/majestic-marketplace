# Financial Model Templates

## Model Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ASSUMPTIONS (Inputs you control)                               │
│  ├── Pricing assumptions                                        │
│  ├── Growth rates                                               │
│  ├── Cost assumptions                                           │
│  └── Hiring plan                                                │
│         ↓                                                       │
│  DRIVERS (Key metrics)                                          │
│  ├── Customer acquisition                                       │
│  ├── Churn & expansion                                          │
│  ├── Unit economics                                             │
│  └── Headcount                                                  │
│         ↓                                                       │
│  OUTPUTS (Financial statements)                                 │
│  ├── Revenue schedule                                           │
│  ├── P&L statement                                              │
│  ├── Cash flow                                                  │
│  └── Key metrics dashboard                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Model Tabs Structure

1. **Assumptions** - All changeable inputs
2. **Revenue Model** - Bottoms-up revenue build
3. **Headcount Plan** - People costs
4. **Operating Expenses** - Non-people costs
5. **P&L** - Summary income statement
6. **Cash Flow** - Monthly cash position
7. **Unit Economics** - CAC, LTV, payback
8. **Scenarios** - Base, upside, downside
9. **Cap Table** - Ownership and dilution
10. **Dashboard** - Key metrics visualization

## Revenue Model Template

### Monthly Revenue Build

| Month | Starting Customers | New | Churned | Ending Customers | MRR | Growth |
|-------|-------------------|-----|---------|------------------|-----|--------|
| 1 | [X] | [X] | [X] | [X] | $[X] | - |
| 2 | [X] | [X] | [X] | [X] | $[X] | [X]% |
| ... | | | | | | |
| 12 | [X] | [X] | [X] | [X] | $[X] | [X]% |

### Revenue Formula

```
New MRR = New Customers × ACV ÷ 12
Churned MRR = Starting MRR × Churn Rate
Expansion MRR = Starting MRR × Expansion Rate
Ending MRR = Starting MRR + New MRR - Churned MRR + Expansion MRR
ARR = Ending MRR × 12
```

### Revenue Quality Metrics

| Metric | Year 1 | Year 2 | Year 3 | Benchmark |
|--------|--------|--------|--------|-----------|
| Net Revenue Retention | [X]% | [X]% | [X]% | >100% |
| Gross Revenue Retention | [X]% | [X]% | [X]% | >85% |
| Logo Retention | [X]% | [X]% | [X]% | >90% |
| Quick Ratio | [X] | [X] | [X] | >4 |

*Quick Ratio = (New MRR + Expansion MRR) / (Churned MRR + Contraction MRR)*

## Unit Economics Template

### CAC Calculation

| Channel | Monthly Spend | New Customers | CAC |
|---------|---------------|---------------|-----|
| Paid (Google/Meta) | $[X] | [X] | $[X] |
| Content/SEO | $[X] | [X] | $[X] |
| Outbound Sales | $[X] | [X] | $[X] |
| Referral | $[X] | [X] | $[X] |
| **Blended** | **$[X]** | **[X]** | **$[X]** |

### LTV Calculation

```
Average Revenue per Account (ARPA) = $[X]/month
Gross Margin = [X]%
Monthly Churn = [X]%
Customer Lifetime = 1 / Monthly Churn = [X] months

LTV = ARPA × Gross Margin × Customer Lifetime
LTV = $[X] × [X]% × [X] months = $[X]
```

### LTV/CAC Analysis

| Metric | Current | Target | Benchmark |
|--------|---------|--------|-----------|
| LTV | $[X] | $[X] | - |
| CAC | $[X] | $[X] | - |
| LTV/CAC | [X]x | [X]x | >3x |
| CAC Payback | [X] months | [X] months | <12 months |

## P&L Template

### Monthly P&L (First 12 Months)

| Line Item | M1 | M2 | M3 | ... | M12 |
|-----------|----|----|----|----|-----|
| **Revenue** | | | | | |
| MRR | $[X] | | | | |
| Services | $[X] | | | | |
| **Total Revenue** | $[X] | | | | |
| **COGS** | | | | | |
| Hosting | $[X] | | | | |
| Support | $[X] | | | | |
| **Gross Profit** | $[X] | | | | |
| **Gross Margin** | [X]% | | | | |
| **Operating Expenses** | | | | | |
| Sales & Marketing | $[X] | | | | |
| R&D | $[X] | | | | |
| G&A | $[X] | | | | |
| **Total OpEx** | $[X] | | | | |
| **EBITDA** | $[X] | | | | |
| **EBITDA Margin** | [X]% | | | | |

### Annual P&L Summary

| Line Item | Year 1 | Year 2 | Year 3 |
|-----------|--------|--------|--------|
| **Revenue** | $[X] | $[X] | $[X] |
| YoY Growth | - | [X]% | [X]% |
| **Gross Profit** | $[X] | $[X] | $[X] |
| Gross Margin | [X]% | [X]% | [X]% |
| **Sales & Marketing** | $[X] | $[X] | $[X] |
| % of Revenue | [X]% | [X]% | [X]% |
| **R&D** | $[X] | $[X] | $[X] |
| % of Revenue | [X]% | [X]% | [X]% |
| **G&A** | $[X] | $[X] | $[X] |
| % of Revenue | [X]% | [X]% | [X]% |
| **EBITDA** | $(X) | $(X) | $[X] |
| EBITDA Margin | [X]% | [X]% | [X]% |

## Cash Flow Template

### Monthly Cash Flow

| Month | Starting Cash | Revenue | Expenses | Net Burn | Ending Cash | Runway |
|-------|---------------|---------|----------|----------|-------------|--------|
| 1 | $[X] | $[X] | $[X] | $(X) | $[X] | [X] mo |
| 2 | $[X] | $[X] | $[X] | $(X) | $[X] | [X] mo |
| ... | | | | | | |
| 12 | $[X] | $[X] | $[X] | $(X) | $[X] | [X] mo |

### Cash Flow Formula

```
Cash In:
+ Revenue collected (adjust for payment terms)
+ Funding received
+ Other income

Cash Out:
- Payroll (monthly)
- Rent/facilities (monthly)
- Vendors (monthly)
- One-time costs (equipment, deposits)
- Debt payments

Net Cash Flow = Cash In - Cash Out
Ending Cash = Starting Cash + Net Cash Flow
Runway (months) = Ending Cash / Average Monthly Burn
```

## Scenario Analysis Template

### Scenario Definitions

| Scenario | Description | Key Assumptions |
|----------|-------------|-----------------|
| **Base** | Plan of record | [X]% growth, [X] hires |
| **Upside** | Things go well | [X]% growth, faster hiring |
| **Downside** | Conservative | [X]% growth, minimal hiring |
| **Survival** | Cash preservation | [X]% growth, cuts |

### Revenue by Scenario

| Period | Base | Upside | Downside | Survival |
|--------|------|--------|----------|----------|
| End Y1 ARR | $[X] | $[X] | $[X] | $[X] |
| End Y2 ARR | $[X] | $[X] | $[X] | $[X] |
| End Y3 ARR | $[X] | $[X] | $[X] | $[X] |

### Decision Triggers

| If This Happens | Then Do This |
|-----------------|--------------|
| MRR growth <[X]% for 3 months | Activate downside plan |
| Runway <6 months | Begin fundraise or cuts |
| Churn >[X]% | Pause S&M, focus on retention |
| LTV/CAC <2x | Reduce paid spend |

## Fundraising Template

### Current Capitalization

| Shareholder | Shares | % Ownership |
|-------------|--------|-------------|
| Founders | [X] | [X]% |
| Employees (ESOP) | [X] | [X]% |
| Seed Investors | [X] | [X]% |
| **Total** | [X] | 100% |

### Proposed Round

| Term | Value |
|------|-------|
| Round Size | $[X] |
| Pre-Money Valuation | $[X] |
| Post-Money Valuation | $[X] |
| New Investor Ownership | [X]% |
| ESOP Expansion | [X]% |

### Use of Funds

| Category | Amount | % of Round |
|----------|--------|------------|
| Hiring (Engineering) | $[X] | [X]% |
| Hiring (Sales/Marketing) | $[X] | [X]% |
| Marketing Spend | $[X] | [X]% |
| G&A / Buffer | $[X] | [X]% |
| **Total** | $[X] | 100% |

## Metrics Dashboard Template

### Growth Metrics

| Metric | Current | Target | Trend |
|--------|---------|--------|-------|
| MRR | $[X] | $[X] | ↑ |
| MRR Growth (MoM) | [X]% | [X]% | → |
| ARR | $[X] | $[X] | ↑ |
| New Customers/Month | [X] | [X] | → |

### Retention Metrics

| Metric | Current | Target | Benchmark |
|--------|---------|--------|-----------|
| Logo Churn | [X]% | [X]% | <5% |
| Revenue Churn | [X]% | [X]% | <3% |
| Net Revenue Retention | [X]% | [X]% | >100% |
| Expansion Revenue | [X]% | [X]% | >20% |

### Efficiency Metrics

| Metric | Current | Target | Benchmark |
|--------|---------|--------|-----------|
| LTV/CAC | [X]x | [X]x | >3x |
| CAC Payback | [X] mo | [X] mo | <12 mo |
| Gross Margin | [X]% | [X]% | >70% |
| Magic Number | [X] | [X] | >0.75 |

*Magic Number = Net New ARR / S&M Spend (prior quarter)*

### Financial Health

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Monthly Burn | $[X] | $[X] | ⚠️ |
| Runway | [X] mo | [X] mo | ✅ |
| Rule of 40 | [X]% | [X]% | ⚠️ |

*Rule of 40 = Revenue Growth % + EBITDA Margin %*
