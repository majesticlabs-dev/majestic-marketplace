# Interview Command

> `/majestic-tools:interview` - Domain-aware discovery through conversational probing

## Overview

The interview command helps you discover requirements, uncover assumptions, and surface blind spots through structured conversation. It automatically detects the domain from your input and loads domain-specific questions.

## Quick Start

```bash
/majestic-tools:interview "brand voice"       # Brand discovery
/majestic-tools:interview "new campaign"      # Marketing discovery
/majestic-tools:interview "sales pitch"       # Sales discovery
/majestic-tools:interview "user needs"        # Product discovery
/majestic-tools:interview "new feature"       # Engineering discovery (default)
```

## Domain Detection

| Domain | Trigger Keywords | Best For |
|--------|-----------------|----------|
| **brand** | brand voice, tone, writing style, voice guide | Codifying how you sound |
| **product** | product, user research, discovery, jobs to be done | Exploring problem space |
| **marketing** | campaign, content strategy, audience, messaging | Planning campaigns |
| **sales** | sales process, objections, pitch, deal, pricing | Preparing for deals |
| **engineering** | feature, bug, system, architecture (default) | Planning implementation |

## How It Works

1. **Input Analysis** - Detects domain from keywords in your input
2. **Domain Loading** - Loads domain-specific question bank (YAML resource)
3. **Conversational Interview** - Asks ONE question at a time, digs deep on uncertainty
4. **Reflection** - Always asks "What did I forget to ask?"
5. **Synthesis** - Produces domain-specific summary with quotable moments and next steps

## Interview Methodology

### Core Principles

- **One question at a time** - No overwhelming batches
- **Go deep on uncertainty** - When they say "I think..." or "probably...", probe further
- **Skip the obvious** - Push on things they haven't fully thought through
- **Capture quotable moments** - Verbatim quotes often beat formal requirements

### Dig Deeper Triggers

Each domain has "dig deeper when they say..." patterns:

```yaml
# Example from brand.yaml
dig_deeper_when:
  - pattern: "We want to sound professional..."
    probe: what does professional mean to YOU?
  - pattern: "We're friendly but..."
    probe: where's the line?
```

## Domain Details

### Brand Discovery

Explores voice identity and messaging:

| Area | Questions Probe For |
|------|-------------------|
| Voice Identity | Brand as a person, personality traits, differentiation |
| Audience Connection | Who you're talking to, their language, their context |
| Tone Boundaries | What to NEVER sound like, cringe words, when tone shifts |
| Existing Patterns | Content that feels "you", customer quotes, feedback |
| Practical Rules | Contractions, pronouns, emoji, humor levels |

**Output feeds into:** `brand-voice` skill for full voice guide generation

### Product Discovery

Explores problem space and user needs:

| Area | Questions Probe For |
|------|-------------------|
| Problem Space | The pain (not solution), triggers, cost of status quo |
| User Context | Day in their life, what they're trying to do, expertise |
| Current Alternatives | What they do today, what's good/broken, switching triggers |
| Success Signals | How users know it works, aha moment, metrics |
| Scope Boundaries | Smallest valuable version, explicit exclusions, v2 candidates |

**Output feeds into:** `/prd` command for product requirements

### Marketing Discovery

Explores campaign goals and messaging:

| Area | Questions Probe For |
|------|-------------------|
| Campaign Goal | Desired action, success metric, timeline |
| Audience | Who specifically, where they are, what they believe |
| Message | One thing to remember, emotional response, proof |
| Differentiation | Competition, unique claims, unfair advantages |
| Constraints | Budget, channels, existing assets, approvals |

**Output feeds into:** `content-calendar` skill for planning

### Sales Discovery

Explores deal context and buyer dynamics:

| Area | Questions Probe For |
|------|-------------------|
| Deal Context | What you're selling, buyer, stakes |
| Buyer Journey | Decision stage, alternatives evaluated, timeline |
| Decision Makers | Champion, skeptic, budget holder, process |
| Objections | Stated concerns, unstated worries, hesitation |
| Competition | Who else, their advantages, your advantages |
| Pricing & Value | Budget reality, ROI story, "worth it" factors |

**Output feeds into:** `proposal-writer` skill for proposals

### Engineering Discovery

Explores implementation and scope:

| Area | Questions Probe For |
|------|-------------------|
| Technical | Approach, tradeoffs, system fit, edge cases |
| Human & Workflow | Who's affected, fallbacks, success criteria |
| Strategic | Why now, MVP scope, explicit exclusions |

**Output feeds into:** `/blueprint` command for implementation planning

## Output Format

Each domain produces a structured synthesis:

```markdown
## Interview Summary: [Topic]

### [Domain Area 1]
[Key findings]

### [Domain Area 2]
[Key findings]

### Quotable Moments
> "[Verbatim insight]"

### Open Questions
- [ ] [Thing to resolve]

### Next Steps
- [Domain-appropriate action]
```

## Integration with Other Tools

| After Interview | Use This | Purpose |
|----------------|----------|---------|
| Brand interview | `brand-voice` skill | Generate full voice guide |
| Product interview | `/prd` | Create product requirements |
| Marketing interview | `content-calendar` | Plan content execution |
| Sales interview | `proposal-writer` | Generate proposal |
| Engineering interview | `/blueprint` | Create implementation plan |

## Examples

### Brand Voice Discovery

```
User: /majestic-tools:interview "brand voice"

Claude: Let's explore your brand voice. If your brand walked into a party,
how would they introduce themselves?

User: Probably like a smart friend who knows a lot but doesn't show off.
Helpful but not condescending.

Claude: I notice you said "probably" - are you uncertain about that, or is
that definitely how you want to come across?

... [continues with deep probing] ...

Claude: What did I forget to ask about?

User: Maybe how formal we should be in different contexts - like emails vs docs.

... [addresses gap] ...

Claude: Here's your interview summary:
[Synthesis with voice identity, personality traits, quotable moments]

Would you like me to create a full voice guide from this?
```

### Product Discovery

```
User: /majestic-tools:interview "user research for task management"

Claude: What problem are you solving? Try to describe the pain without
jumping to the solution.

User: People lose track of what they committed to doing.

Claude: How do they deal with this today?

User: Sticky notes, emails to themselves, random apps...

Claude: What triggers someone to seek a better solution?

User: Usually after they drop something important - missed deadline,
forgotten promise.

... [continues exploring problem space] ...
```

## Configuration

Domain resources are stored as YAML files:

```
plugins/majestic-tools/commands/workflows/resources/interview/domains/
├── brand.yaml
├── engineering.yaml
├── marketing.yaml
├── product.yaml
└── sales.yaml
```

Each YAML defines:
- `triggers` - Keywords that activate this domain
- `discovery_domains` - Question areas with dig-deeper patterns
- `question_style_examples` - "Instead of... Ask..." examples
- `synthesis` - Output template structure
- `next_steps` - Follow-up actions

## Related Commands & Skills

- `/majestic-guide` - Find the right tool for any task
- `brand-voice` skill - Generate voice guides from interview output
- `/prd` - Create product requirements documents
- `/blueprint` - Create implementation plans
- `proposal-writer` skill - Generate sales proposals
