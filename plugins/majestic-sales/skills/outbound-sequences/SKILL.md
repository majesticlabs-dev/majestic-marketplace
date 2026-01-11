---
name: outbound-sequences
description: Templates and frameworks for cold outreach sequences. Email templates, cold call scripts, LinkedIn messages, subject lines, and response handling.
allowed-tools: Read, Write, Edit, WebSearch
---

# Outbound Sequences

Design high-response cold outreach sequences for email, phone, and LinkedIn.

## Input Context

Expect structured context from orchestrator:

```yaml
current_metrics:
  open_rate: percent
  reply_rate: percent
  meeting_rate: percent
diagnosed_problem: subject_lines | copy | targeting | CTA
target_persona:
  title: string
  industry: string
  company_size: string
channels: [email, phone, linkedin]
value_prop: string
social_proof: string
current_best: string  # sample copy
tool: Apollo | Outreach | Lemlist | etc.
```

## Sequence Architecture

### Multi-Channel Sequence (7 touches)

```
Day 1:  Email #1 (Initial) ──→ Day 3: LinkedIn Connect
Day 4:  Email #2 (Value-add) ──→ Day 6: LinkedIn Message
Day 7:  Phone Call ──→ Day 8: Email #3 (Insight)
Day 10: LinkedIn Engage ──→ Day 12: Email #4 (Case Study)
Day 15: Email #5 (Breakup)

RESPONSE BRANCHES:
Positive → Discovery call booking sequence
Objection → Objection handler sequence
"Not Now" → Nurture sequence (30-day follow-up)
```

### Email-Only Sequence (5 touches)

```
Day 1:  Initial outreach (50-75 words)
Day 4:  Follow-up + new angle (40-60 words)
Day 8:  Value add / insight (60-80 words)
Day 12: Social proof / case study (70-90 words)
Day 15: Breakup (30-50 words)
```

## Email Templates

### Template 1: Problem-Agitate-Solve

```
Subject: [Pain point] at {{company}}?

{{first_name}},

{{companies_like_yours}} often tell us {{specific_pain}}.

The cost? {{quantified_impact}}.

{{one_sentence_solution_with_result}}.

Open to a quick call to see if this applies to {{company}}?

{{sender_name}}
```

### Template 2: Trigger Event

```
Subject: Congrats on {{trigger_event}}

{{first_name}},

Saw that {{company}} just {{trigger: funding, expansion, hire}}.

Usually when companies {{trigger}}, they run into {{related_pain}}.

We helped {{similar_company}} navigate this and {{specific_result}}.

Worth 15 minutes to share what worked for them?

{{sender_name}}
```

### Template 3: Mutual Connection

```
Subject: {{connection_name}} suggested I reach out

{{first_name}},

{{connection_name}} mentioned you're working on {{initiative}}.

We've helped {{2-3_similar_companies}} with similar goals and {{specific_results}}.

Would love to share what's working for them if useful.

Open to a brief call this week?

{{sender_name}}
```

### Template 4: Breakup Email

```
Subject: Should I close your file?

{{first_name}},

I've reached out a few times but haven't heard back.

I'll assume {{their_pain}} isn't a priority right now and close your file.

If anything changes, feel free to reach back out.

{{sender_name}}

PS: {{final_value_piece}}
```

### Email Body Framework (AIDA)

```
Subject: [Personalized hook]

Hey {{first_name}},

[ATTENTION: Personal observation about them/their company]
Saw that {{specific_detail_showing_research}}.

[INTEREST: Problem statement they likely have]
Most {{their_role}} at {{company_type}} struggle with {{specific_pain}}.

[DESIRE: Quick value/proof]
We helped {{similar_company}} solve this by {{specific_result}}.

[ACTION: Clear, low-friction CTA]
Worth a 15-min call to see if we can help with {{specific_goal}}?

{{sender_name}}
```

## Subject Line Library

### Pattern Interrupt (Highest Opens)

- "Quick question about {{topic}}"
- "{{Mutual_connection}} suggested I reach out"
- "Thought of you when I saw {{trigger}}"
- "{{first_name}} - quick thought"

### Trigger-Based

- "Congrats on {{trigger_event}}"
- "Saw your post on {{topic}}"
- "{{company}}'s {{news}} caught my eye"

### Value-Focused

- "How {{competitor}} increased X by 30%"
- "{{result}} for {{similar_company}}"
- "Cut {{pain}} in half?"

### Curiosity

- "{{first_name}}?"
- "Bad idea?"
- "Thought about this..."

### Avoid These

- "Touching base" / "Following up"
- "EXCLUSIVE OFFER" / "Don't miss out"
- "Quick chat" / "Partnership opportunity"
- "Hope you're well"

## Cold Call Script

### Opening (15 seconds)

```
"Hi {{name}}, this is {{your_name}} from {{company}}.

Did I catch you at a bad time?

[If yes: When's better?]
[If no: Continue]

I'm reaching out because {{trigger_or_reason}}.

{{one_sentence_value}}.

Is {{their_pain}} something you're focused on right now?"
```

### Call Structure

```
1. Permission opener (10 sec)
2. Reason for call (15 sec)
3. Qualifying question (listen)
4. Bridge to pain (based on answer)
5. Share relevant insight/case study
6. Ask for meeting
7. Handle objection (if needed)
8. Confirm next steps
```

### Objection Responses

| Objection | Response |
|-----------|----------|
| "Not interested" | "Totally understand. Quick question - is that because {{pain}} isn't a priority, or you're handling it differently?" |
| "Send me an email" | "Happy to. What specifically would be most helpful to include?" |
| "We have a solution" | "Makes sense. How's that working? Any gaps you're looking to address?" |
| "No budget" | "Understood. When do budgets get reviewed? Happy to reconnect then." |
| "Who is this?" | "{{name}} from {{company}}. We help {{their_title}} with {{specific_pain}}. Worth 2 minutes?" |

## LinkedIn Templates

### Connection Request (300 char max, no pitch)

```
{{first_name}}, I came across your {{post/profile/company}} and noticed {{specific_observation}}.

I work with {{similar_role/company_type}} on {{relevant_topic}}.

Would love to connect and learn more about {{their_focus_area}}.

{{your_name}}
```

### First Message After Connect

```
Thanks for connecting, {{first_name}}.

I noticed {{company}} is focused on {{initiative_from_research}}.

We've been helping {{similar_companies}} with {{related_challenge}} and thought you might find {{specific_resource}} useful.

Happy to share if interested.
```

### Direct Message (Clear Ask)

```
{{first_name}},

I've been following {{company}}'s work on {{initiative}} - impressive results.

We helped {{similar_company}} achieve {{specific_result}} with a similar challenge.

Would a 15-minute call to share what worked for them be useful?

Either way, keep up the great work.
```

### Engage Before Outreach

Before InMail:
1. Like 2-3 of their posts
2. Leave thoughtful comment
3. Share their content (if relevant)
4. Then send connection/message

## Response Handling

### Positive Response

```
{{first_name}}, great to hear from you!

I have {{day}} at {{time}} or {{day}} at {{time}} available.

Here's my calendar if easier: {{link}}

Looking forward to it.

{{sender_name}}
```

### Objection Response

```
{{first_name}}, appreciate the candid response.

Totally understand {{their_objection}}.

Quick question: {{question_uncovering_real_concern}}

Either way, happy to {{lower_commitment_offer}}.

{{sender_name}}
```

### "Not Now" Response

```
{{first_name}}, completely understand - timing is everything.

When would be a better time to revisit this?

Happy to reach back out in {{timeframe}} if that works.

{{sender_name}}
```

### "Send More Info" Response

```
{{first_name}}, happy to share more.

Here's {{one_specific_asset}}: {{link}}

Quick question: What specifically prompted the interest?

That'll help me tailor what I send next.

{{sender_name}}
```

## Personalization Framework

| Tier | Time/Prospect | What to Include |
|------|---------------|-----------------|
| Tier 1 (Basic) | 30 sec | Name, company, industry |
| Tier 2 (Researched) | 2-3 min | News, LinkedIn content, job postings |
| Tier 3 (Deep) | 10-15 min | Podcast quotes, custom video, mutual connections |

### Research Sources

- LinkedIn posts and activity
- Company news/press releases
- Job postings (indicate priorities)
- Podcast appearances
- Conference presentations
- Mutual connections

## Timing Optimization

### Best Send Times

| Day | Email | Calls | LinkedIn |
|-----|-------|-------|----------|
| Tuesday | 7-8am, 10-11am | 10-11am, 2-3pm | Afternoon |
| Wednesday | 7-8am, 10-11am | 10-11am, 2-3pm | Afternoon |
| Thursday | 7-8am, 10-11am | 10-11am, 2-3pm | Afternoon |
| Friday | 7-8am only | Avoid | Morning |

### Sequence Spacing

- Email to email: 3-4 days
- Email to LinkedIn: 1-2 days
- LinkedIn to phone: 1 day
- After no response: wait 3 days
- Breakup email: day 14-15

## Output Format

```markdown
# OUTBOUND SEQUENCE: {{Company Name}}

## Target Persona
{{title}}, {{industry}}, {{company_size}}

## Sequence Architecture
[Visual flow diagram]

## Email Sequence
### Email 1: Initial (Day 1)
**Subject:** [3 options]
**Preview:** [preview text]
**Copy:** [full email]
**Personalization:** [variables used]

### Email 2: Follow-up (Day 4)
...

## LinkedIn Sequence
### Touch 1: Connection (Day 3)
...

## Cold Call Script
[Opening + structure + objection handling]

## Response Playbook
[Templates for each response type]

## A/B Test Variants
[Specific tests for diagnosed problem area]
```

## Anti-Patterns

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| Generic opener | "Hope you're well" ignored | Specific observation |
| Feature dump | They don't care yet | Lead with their pain |
| Multiple CTAs | Confusion, lower response | Single clear ask |
| Long emails | Won't be read on mobile | Under 75 words |
| Same angle each email | No reason to reply | New value per touch |
| No personalization | Feels like spam | Add {{variables}} |
