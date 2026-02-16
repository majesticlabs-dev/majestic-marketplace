# Proposal Input Schema

Expect structured context from orchestrator:

```yaml
prospect:
  company: string
  industry: string
  size: string
deal_size: <$10K | $10-50K | $50K+
stakeholders:
  - title: string
    concern: string
pain_points: [list from discovery]
solution: string
pricing: number | range
competition:
  - name: string
    weakness: string
objections: [list to address]
timeline:
  decision_date: date
  implementation_date: date
```
