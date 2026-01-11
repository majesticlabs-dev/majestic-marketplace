# Segmentation & Automation Triggers

## Segmentation Framework

### Entry-Based Segments

| Segment | Trigger | Sequence Path |
|---------|---------|---------------|
| Lead Magnet A | Downloaded [specific lead magnet] | Welcome → Nurture A → Sales |
| Lead Magnet B | Downloaded [different lead magnet] | Welcome → Nurture B → Sales |
| Webinar | Registered for webinar | Webinar → Sales |
| Purchase | Made purchase | Customer onboarding |

### Behavior-Based Segments

| Segment | Trigger | Action |
|---------|---------|--------|
| Engaged | Opened 3+ emails in 7 days | Fast-track to sales |
| Clicker | Clicked but no purchase | Objection sequence |
| Ghost | No opens in 14 days | Re-engagement |
| Buyer | Made purchase | Exit nurture, enter customer |

### Interest-Based Segments

| Segment | Identification Method | Content Focus |
|---------|----------------------|---------------|
| [Interest A] | Clicked links about [topic] | [Relevant content] |
| [Interest B] | Downloaded [specific resource] | [Relevant content] |
| [Interest C] | Visited [specific page] | [Relevant content] |

## Automation Triggers

### Action-Based Triggers

| Action | Trigger | Result |
|--------|---------|--------|
| Email opened | Opens email [X] | Tag as "engaged" |
| Link clicked | Clicks pricing link | Enter sales sequence |
| Page visited | Visits checkout page | Abandoned cart sequence |
| Form submitted | Submits application | Qualification sequence |

### Time-Based Triggers

| Trigger | Timing | Result |
|---------|--------|--------|
| Sequence complete | After last welcome email | Move to nurture |
| No purchase | 14 days after sales sequence | Re-nurture |
| Anniversary | 365 days since signup | Anniversary offer |
| Birthday | On birthday (if collected) | Birthday discount |

### Conditional Logic

| Condition | If True | If False |
|-----------|---------|----------|
| Opened welcome email 1 | Send email 2 | Wait 24h, resend with new subject |
| Clicked sales email CTA | Exit sequence, tag "prospect" | Continue sequence |
| Made purchase | Exit all sales sequences | Continue |

## Platform-Specific Implementation Notes

### ConvertKit
- Use Tags for segments
- Visual Automations for sequences
- Link Triggers for behavior tracking

### ActiveCampaign
- Use Automations with Goals
- Contact Scoring for engagement
- Site Tracking for page visits

### HubSpot
- Workflows with branching logic
- Lead Scoring integration
- Lifecycle Stage automation

### Klaviyo
- Flows with conditional splits
- Predictive analytics for timing
- Event-based triggers
