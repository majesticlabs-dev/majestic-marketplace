---
name: brand-positioning
description: Define your brand's core identity - purpose, values, personality, and positioning statement. Creates the strategic foundation that informs voice, design, and all brand decisions.
triggers:
  - brand positioning
  - brand strategy
  - brand identity
  - brand purpose
  - brand values
  - positioning statement
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, AskUserQuestion
---

# Brand Positioning Architect

Define your brand's strategic foundation - the internal identity that drives every external expression.

## What This Creates

| Asset | Purpose |
|-------|---------|
| **Brand Purpose** | Why you exist beyond profit |
| **Brand Values** | Principles that guide decisions |
| **Brand Personality** | Human traits that shape voice |
| **Target Audience** | Who you serve (psychographic depth) |
| **Brand Promise** | Core commitment to customers |
| **Positioning Statement** | Classic strategic framework |

## Relationship to Other Tools

| Tool | Focus | Relationship |
|------|-------|--------------|
| `brand-positioning` | WHO you are (identity) | **This tool** - foundation |
| `competitive-positioning` | HOW you differ (comparison) | Uses this as input |
| `brand-voice` | HOW you sound (expression) | Derives from personality |
| `ux-brief` | HOW you look (visual) | References values/personality |

## Conversation Starter

Use `AskUserQuestion` to gather context:

"I'll help you define your brand's strategic foundation - the identity that drives all your marketing and design decisions.

**What stage are you at?**

**Option A - Starting Fresh**
Answer discovery questions to build your positioning from scratch.

**Option B - Have Existing Materials**
Share what you have (mission statement, about page, pitch deck) and I'll extract and refine.

**Option C - Repositioning**
Describe current positioning and what's not working."

## Discovery Process

### Phase 1: Purpose & Values

**Question 1: Origin Story**
"Why did you start this company? What problem made you say 'someone needs to fix this'?"

**Question 2: Impact Vision**
"If you succeed wildly, what changes in the world? What do customers become?"

**Question 3: Non-Negotiables**
"What would you never do, even if profitable? What lines won't you cross?"

**Question 4: Decision Lens**
"When you face a hard choice, what principles guide you?"

### Phase 2: Audience Definition

**Question 5: Ideal Customer**
"Describe your best customer - not demographics, but their mindset, frustrations, and aspirations."

**Question 6: Emotional State**
"When someone finds you, what state are they in?"
- Frustrated (seeking relief)
- Ambitious (seeking growth)
- Confused (seeking clarity)
- Skeptical (seeking proof)
- Overwhelmed (seeking simplicity)

**Question 7: Alternatives**
"If you didn't exist, what would they do instead? (Competitor, DIY, nothing)"

### Phase 3: Personality & Tone

**Question 8: Human Traits**
"If your brand were a person at a dinner party, how would others describe them?"
- Pick 3-5: Bold, Friendly, Professional, Playful, Sophisticated, Rebellious, Trustworthy, Innovative, Warm, Direct, Quirky, Authoritative, Approachable, Provocative

**Question 9: Not This**
"What personality would be WRONG for your brand? What should you never sound like?"

**Question 10: Reference Brands**
"Name 2-3 brands whose personality you admire (any industry)."

### Phase 4: Differentiation

**Question 11: Unique Value**
"What can you honestly claim that competitors cannot?"

**Question 12: Proof**
"What evidence supports your unique claim? (Results, approach, team, technology)"

## Framework Application

### Brand Purpose Framework

**Format:** We exist to [impact] by [approach] for [audience].

**Test:** Does it pass the "so what" test 3 times?
- "We make software" → So what?
- "So teams collaborate better" → So what?
- "So companies ship faster" → So what?
- "So innovation accelerates" ← Purpose level

### Values Framework

Each value needs:

| Component | What It Answers |
|-----------|-----------------|
| **Name** | What we call this value (1-2 words) |
| **Meaning** | What it actually means to us |
| **Behavior** | How it shows up in decisions |
| **Anti-pattern** | What violating this looks like |

**Example:**
- **Value:** Radical Transparency
- **Meaning:** We share context, not just conclusions
- **Behavior:** Public roadmaps, open pricing, honest limitations
- **Anti-pattern:** Hidden fees, vague messaging, overselling

### Personality Framework

Map each trait to communication implications:

| Trait | Meaning | Voice Implication | Design Implication |
|-------|---------|-------------------|-------------------|
| Bold | We take stands | Declarative statements | High contrast, strong type |
| Warm | We care personally | Conversational tone | Soft colors, friendly imagery |
| Direct | We don't waste time | Short sentences | Clean layouts, clear CTAs |

### Positioning Statement

**Classic Format:**
> For [target audience] who [situation/need], [Brand] is the [category] that [key benefit]. Unlike [alternatives], we [differentiator] because [reason to believe].

**Parts Explained:**

| Part | Purpose | Example |
|------|---------|---------|
| Target audience | Specificity signals fit | "For early-stage founders" |
| Situation/need | Context triggers relevance | "who need to ship fast without a dev team" |
| Category | Mental filing cabinet | "a no-code platform" |
| Key benefit | Primary value delivered | "that turns ideas into products in days" |
| Alternatives | Competitive frame | "Unlike agencies or hiring developers" |
| Differentiator | Unique advantage | "we combine templates with expert guidance" |
| Reason to believe | Proof/credibility | "backed by 500+ successful launches" |

## Output Format

```markdown
# BRAND POSITIONING: [Brand Name]

*Strategic foundation document v1.0*

---

## Brand Essence

**One-liner:** [10 words capturing the brand]

**Purpose:** [Why we exist]

**Promise:** [What we guarantee]

---

## Brand Values

| Value | Meaning | How It Shows Up |
|-------|---------|-----------------|
| [Value 1] | [What it means to us] | [Behavioral example] |
| [Value 2] | [What it means to us] | [Behavioral example] |
| [Value 3] | [What it means to us] | [Behavioral example] |

### Values in Action

**Hiring:** We look for [traits aligned with values]
**Product:** We prioritize [features/experiences aligned with values]
**Support:** We respond with [approach aligned with values]

---

## Target Audience

### Primary ICP

**Who:** [Specific description]
**Pain:** [What frustrates them]
**Desire:** [What they want to become]
**Trigger:** [What makes them seek solutions]
**Emotional State:** [How they feel when they find us]

### What They Believe

- [Belief 1 - something they already think that makes them receptive]
- [Belief 2]
- [Belief 3]

### What They're Tired Of

- [Frustration 1 with alternatives]
- [Frustration 2]
- [Frustration 3]

---

## Brand Personality

### Traits

| Trait | Description | Voice Implication |
|-------|-------------|-------------------|
| [Trait 1] | [What this means] | [How it sounds] |
| [Trait 2] | [What this means] | [How it sounds] |
| [Trait 3] | [What this means] | [How it sounds] |

### We Are / We Are Not

| We Are | We Are Not |
|--------|------------|
| [Positive trait] | [Opposite/extreme] |
| [Positive trait] | [Opposite/extreme] |
| [Positive trait] | [Opposite/extreme] |

### If We Were...

- **A person:** [Description - age, profession, how they'd act at a party]
- **A celebrity:** [Name and why]
- **A car:** [Brand/model and why]

---

## Competitive Position

### Market Context

**Category:** [What we are]
**Alternatives:** [What customers use instead]
**Our Lane:** [Where we uniquely fit]

### Differentiation

**What we do differently:** [Key differentiator]
**Why it matters:** [Customer benefit]
**Why believable:** [Proof points]

---

## Positioning Statement

> For [target audience] who [situation/need],
> [Brand] is the [category] that [key benefit].
> Unlike [alternatives], we [differentiator]
> because [reason to believe].

### Variations

**Elevator Pitch (30 sec):**
"[Audience] struggle with [problem]. Most [alternatives] try [their approach], but [weakness]. We're different—we [unique approach] so you [outcome]."

**Tweet-Length:**
"[Hook] + [benefit] + [differentiator]" (140 chars)

**Tagline:**
"[3-5 words that capture essence]"

---

## Strategic Guardrails

### Always

- [Behavior/approach we commit to]
- [Behavior/approach we commit to]
- [Behavior/approach we commit to]

### Never

- [Line we won't cross]
- [Line we won't cross]
- [Line we won't cross]

---

## Using This Document

| When Creating | Reference |
|---------------|-----------|
| Marketing copy | Purpose, personality, positioning statement |
| Product decisions | Values, target audience beliefs |
| Visual design | Personality traits, "If we were..." |
| Voice guide | Personality, We Are/We Are Not |
| Sales messaging | Positioning variations, differentiation |
| Hiring | Values, guardrails |

---

## Next Steps

1. [ ] Share with team for alignment
2. [ ] Create brand-voice.md using personality section
3. [ ] Run competitive-positioning to sharpen differentiation
4. [ ] Update homepage to reflect positioning
5. [ ] Review quarterly - positioning evolves
```

## File Output

Save to: `docs/brand-positioning.md` or `.claude/brand-positioning.md`

Offer to create related documents:
- `brand-voice.md` - Invoke `brand-voice` skill with personality as input
- Run `competitive-positioning` - Sharpen differentiation with research

## Quality Standards

- **Specific over generic** - "We're customer-focused" is worthless
- **Honest** - Don't manufacture differentiation that doesn't exist
- **Testable** - Values must guide actual decisions
- **Memorable** - Positioning should be repeatable without notes
- **Connected** - Each section should reinforce others

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| "We value excellence" | Every company claims this | What specific behavior does this require? |
| "For everyone who..." | No positioning power | Narrow to specific audience segment |
| "We're the best" | Unverifiable claim | What specific advantage makes you better? |
| "Innovative solutions" | Meaningless buzzword | What specifically do you do differently? |
| 7+ values | Unactionable | Prioritize to 3-5 that actually guide decisions |

## Integration with Other Skills

After creating positioning:

1. **`brand-voice`** - Feed personality traits to create voice guide
2. **`competitive-positioning`** - Research competitors against your differentiation
3. **`ux-brief`** - Reference personality for visual design direction
4. **`style-guide/new`** - Use brand context for writing style decisions
5. **`landing-page-builder`** - Apply positioning to page copy
