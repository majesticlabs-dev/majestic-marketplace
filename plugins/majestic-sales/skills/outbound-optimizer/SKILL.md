---
name: outbound-optimizer
description: Optimize outbound sales sequences by diagnosing metrics, identifying problems, invoking outbound-sequences skill, and validating improvements.
allowed-tools: Read Write Edit Grep Glob WebSearch WebFetch
---

# Outbound Optimizer

Diagnose current outbound performance, identify root causes, apply the `outbound-sequences` skill for improvements, validate output, and recommend A/B tests.

## Step 1: Gather Metrics

Collect current performance data:

1. **Metrics**: Open rate? Reply rate? Meeting book rate?
2. **Volume**: How many sequences/week? Total contacts?
3. **Target**: Who are you reaching? (Title, industry, company size)
4. **Channels**: Email only? Multi-channel? (Email, phone, LinkedIn)
5. **Sample**: Best-performing email or script
6. **Challenge**: Low opens? Low replies? No-shows? Wrong prospects?

## Step 2: Diagnose Against Benchmarks

| Metric | Benchmark | If Below → Problem |
|--------|-----------|-------------------|
| Open rate | 40-60% | Subject line / deliverability |
| Reply rate | 5-15% | Copy / relevance |
| Positive reply rate | 2-5% | Targeting / offer |
| Meeting book rate | 1-3% | CTA / friction |
| Show rate | 70-80% | Confirmation / timing |
| Connect rate (calls) | >5% | Timing / list quality |

## Step 3: Identify Root Cause

| Symptom | Likely Cause | Investigation |
|---------|--------------|---------------|
| Opens low, replies low | Subject line problem | Test new subject patterns |
| Opens high, replies low | Copy doesn't resonate | Review first line, value prop |
| Replies high, meetings low | CTA too aggressive | Lower friction ask |
| Meetings high, shows low | Weak confirmation | Add reminder sequence |
| All metrics low | Wrong ICP | Review targeting criteria |

## Step 4: Apply Outbound Sequences Skill

Apply `outbound-sequences` with structured context:

```yaml
context:
  current_metrics: [open rate, reply rate, meeting rate]
  diagnosed_problem: [subject lines | copy | targeting | CTA]
  target_persona: [title, industry, company size]
  channels: [email | multi-channel]
  value_prop: [what you solve]
  social_proof: [notable customers, results]
  current_best_performer: [paste sample]
  tool: [Apollo, Outreach, Lemlist, etc.]
request:
  - New sequence addressing diagnosed problem
  - Include A/B test variants for problem area
```

## Step 5: Validate Output

### Quality Checklist

- [ ] Subject lines are personalized and specific (not generic)
- [ ] First line shows research (references something specific)
- [ ] Emails are under 100 words
- [ ] CTA is clear and low-friction
- [ ] Sequence has 5-7 touches across channels
- [ ] Follow-up emails add new value (not just "checking in")
- [ ] Response handling covers all scenarios
- [ ] Templates are ready to load into tool

### Red Flags

| Issue | Problem | Fix |
|-------|---------|-----|
| Generic opener | "Hope you're well" | Specific observation |
| Long emails | Won't be read | Under 75 words |
| Multiple CTAs | Confusion | Single clear ask |
| No personalization vars | Can't scale | Add {{variables}} |
| Same value in each email | No reason to reply | New angle per email |

## Step 6: Recommend A/B Tests

Based on diagnosed problem, recommend:

| Problem Area | Test | Measure |
|--------------|------|---------|
| Subject lines | 2-3 variations | Open rate |
| First line | Personalized vs. direct | Reply rate |
| CTA | Meeting vs. question | Response rate |
| Send time | Morning vs. afternoon | Open rate |
| Sequence length | 5 vs. 7 touches | Total reply rate |

## Metrics Tracking Template

```
Weekly Review:
Sequences Sent: [X]
Open Rate: [X%] (benchmark: 50%)
Reply Rate: [X%] (benchmark: 10%)
Positive Rate: [X%] (benchmark: 3%)
Meetings Booked: [X]
Pipeline Generated: $[X]

Top Performer: [sequence/template name]
Underperformer: [sequence/template name]

This Week's Test: [what we're testing]
Result: [outcome]

Next Week Actions:
1. [specific optimization]
2. [specific optimization]
```

## Handling Edge Cases

| Situation | Action |
|-----------|--------|
| No metrics data | Ask for approximate open rate (estimate is fine) |
| No sample copy | Ask for current best email |
| Multiple problems | Focus on earliest funnel stage first (opens before replies) |
| Output too generic | Re-apply skill with more specific persona details |
| Tool constraints | Adjust templates for tool limitations |

## Deliverables

1. Diagnosis of current performance
2. Root cause analysis
3. Optimized sequence from `outbound-sequences` skill
4. A/B testing plan
5. Metrics tracking template
6. Weekly review cadence
