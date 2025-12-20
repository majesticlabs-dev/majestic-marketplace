---
name: content-atomizer
description: Transform long-form content into platform-ready assets. One article becomes Twitter threads, LinkedIn carousels, email excerpts, video scripts, and Instagram posts.
triggers:
  - atomize content
  - repurpose content
  - content atomizer
  - turn article into
  - repurpose article
  - content repurposing
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, AskUserQuestion
---

# Content Atomizer

Transform one piece of long-form content into 5-10 platform-ready distribution assets.

## The Multiplier Effect

```
┌─────────────────────────────────────────────────────┐
│           LONG-FORM CONTENT                         │
│  (Article, Newsletter, Podcast Transcript, Video)   │
└─────────────────────────────────────────────────────┘
                        │
                   ATOMIZER
                        │
    ┌───────┬───────┬───────┬───────┬───────┐
    ↓       ↓       ↓       ↓       ↓       ↓
 Twitter  LinkedIn  Email   Video  Instagram  Short
 Thread   Carousel  Excerpt Script  Carousel   Post
```

## Input

Ask the user to provide:
1. **Source content** - URL, file path, or paste the content directly
2. **Target platforms** - Which outputs they want (default: all)
3. **Audience context** - Who is this for? (optional but helpful)

If the user just pastes content, proceed immediately. Don't over-ask.

## Output Formats

### 1. Twitter/X Thread

**Structure:**
```
Tweet 1 (Hook - MOST IMPORTANT):
[Scroll-stopping opener. Pattern interrupt or curiosity gap.]
[Max 280 chars. No hashtags in hook.]

🧵 Thread:

Tweet 2-8 (Body):
[One key insight per tweet]
[Use line breaks for readability]
[Keep each tweet standalone but connected]

Tweet 9 (Summary + CTA):
TL;DR:
• [Key point 1]
• [Key point 2]
• [Key point 3]

[CTA: Follow, retweet, or comment prompt]
```

**Rules:**
- 7-10 tweets ideal (not too long)
- First tweet = 90% of success
- Each tweet should work if read alone
- Use "1/" numbering if >5 tweets
- No hashtags except maybe 1-2 in final tweet

### 2. LinkedIn Carousel

**Structure:**
```
SLIDE 1: Cover
[Bold statement or question]
[Curiosity hook]
[Your name/handle small]

SLIDE 2: The Problem/Hook
[Relatable pain point or insight]

SLIDES 3-9: Core Content
[One idea per slide]
[Large text, minimal words]
[Max 30 words per slide]

SLIDE 10: Summary
[Key takeaways as bullets]

SLIDE 11: CTA
[Follow for more]
[Comment your take]
[Save for later]
```

**Rules:**
- 8-12 slides optimal
- Max 30 words per slide
- Use contrast (dark/light)
- Each slide = one screenshot-able idea
- Include your handle on every slide

### 3. Email Excerpt

**Structure:**
```
SUBJECT LINE OPTIONS:
1. [Curiosity-driven - 6-10 words]
2. [Benefit-driven - 6-10 words]
3. [Pattern interrupt - 6-10 words]

PREVIEW TEXT:
[First 40-90 chars that appear in inbox]

---

EMAIL BODY:

[Personal opener - 1 sentence]

[Key insight from content - 2-3 paragraphs]

[Transition to full piece]

Read the full article: [LINK]

[Sign-off]

P.S. [Bonus hook or question]
```

**Rules:**
- Subject line < 50 chars (mobile)
- Open with value, not "Hi [Name]"
- Pull the most interesting insight
- Create open loop to full content
- P.S. always gets read

### 4. Video Script (Short-Form)

**Structure:**
```
HOOK (0-3 seconds):
[Pattern interrupt. Stop the scroll.]
"[Exact words to say]"

SETUP (3-10 seconds):
[Context. Why this matters.]
"[Exact words]"

BODY (10-45 seconds):
[Core insight in 2-3 beats]

Beat 1: "[Words]"
Beat 2: "[Words]"
Beat 3: "[Words]"

PAYOFF (45-55 seconds):
[The "aha" moment]
"[Exact words]"

CTA (55-60 seconds):
[What to do next]
"[Exact words]"

---
PRODUCTION NOTES:
- B-roll suggestions: [list]
- Text overlays: [key phrases]
- Pacing: [fast/medium/slow sections]
```

**Rules:**
- Write for speaking, not reading
- Hook must work with sound OFF (text overlay)
- 60 seconds max (45-60 ideal)
- One clear takeaway

### 5. Instagram Carousel

**Structure:**
```
SLIDE 1: Hook
[Big bold text - max 8 words]
[Swipe prompt or emoji →]

SLIDES 2-8: Content
[One insight per slide]
[Large text, high contrast]
[Max 20 words per slide]

SLIDE 9: Summary
[Recap as checklist or bullets]

SLIDE 10: CTA
[Save this post]
[Share with someone who needs it]
[Follow @handle for more]
```

**Rules:**
- 1:1 ratio (1080x1080)
- Less text than LinkedIn carousels
- Visual-first, text-support
- Save + Share focus (algorithm loves these)
- Use slide numbers subtly

### 6. Short-Form Post (Universal)

For quick single posts across platforms:

```
HOOK:
[First line that stops scroll - under 100 chars]

BODY:
[Core message - 2-3 short sentences]
[Use line breaks liberally]

TAKEAWAY:
[One clear insight or action]

CTA:
[Engagement prompt OR link]
```

## Atomization Process

### Step 1: Extract Core Elements

From the source content, identify:
- **Central thesis** - The one big idea (1 sentence)
- **Key insights** - 3-7 supporting points
- **Stories/examples** - Concrete illustrations
- **Data/stats** - Quotable numbers
- **Contrarian angles** - What goes against common belief
- **Actionable takeaways** - What reader can DO

### Step 2: Platform Mapping

| Element | Best Platform | Why |
|---------|---------------|-----|
| Central thesis | LinkedIn post, Video hook | Authority |
| Key insights | Thread, Carousel | Educational |
| Stories | Video, Long-form post | Emotional |
| Data/stats | Carousel slide, Tweet | Shareable |
| Contrarian take | Tweet, LinkedIn | Engagement |
| Takeaways | Email, Carousel end | Value |

### Step 3: Generate Assets

Create each format using the templates above. Customize hooks for each platform's audience.

## Quick Mode vs. Deep Mode

### Quick Mode (Default)
Just atomize the content using the templates. Fast, reliable, good enough.

### Deep Mode
When user asks for "optimized" or "researched" versions:
1. Use WebSearch to find top-performing content in their niche
2. Analyze current platform algorithm priorities
3. Customize hooks based on what's working NOW
4. Add platform-specific hashtag/timing recommendations

## Output Format

```markdown
# CONTENT ATOMIZATION: [Title]

## Source Summary
[1-2 sentence summary of original content]

## Central Thesis
[The one big idea]

## Key Insights Extracted
1. [Insight]
2. [Insight]
3. [Insight]
(etc.)

---

## TWITTER/X THREAD

[Full thread with numbering]

---

## LINKEDIN CAROUSEL

[Slide-by-slide content]

---

## EMAIL EXCERPT

[Complete email with subject options]

---

## VIDEO SCRIPT (60s)

[Full script with timing]

---

## INSTAGRAM CAROUSEL

[Slide-by-slide content]

---

## SHORT-FORM POST

[Universal single post]

---

## DISTRIBUTION CHECKLIST

- [ ] Twitter thread scheduled for [optimal time]
- [ ] LinkedIn carousel designed and queued
- [ ] Email drafted with link to full content
- [ ] Video script ready for recording
- [ ] Instagram carousel slides created
- [ ] Short post ready for [platform]

## REPURPOSING CALENDAR

| Day | Platform | Asset | Notes |
|-----|----------|-------|-------|
| Day 1 | [Primary] | [Asset] | Launch |
| Day 2 | [Secondary] | [Asset] | Cross-post |
| Day 3 | [Tertiary] | [Asset] | Extend reach |
| Day 7 | Email | Excerpt | Newsletter |
```

## Quality Checklist

Before delivering, verify:
- [ ] Each format uses platform-native conventions
- [ ] Hooks are different across platforms (not copy-paste)
- [ ] Video script is speakable (read it aloud)
- [ ] Carousels work as standalone (no context needed)
- [ ] Email creates genuine curiosity for full content
- [ ] No AI-slop phrases ("In today's landscape", "Let's dive in")

## What This Skill Does NOT Do

- **Design visuals** - Provides text/copy only, not graphics
- **Schedule posts** - Provides content, not automation
- **Write the original** - Atomizes existing content only

## When to Use This vs. Other Skills

| Use `content-atomizer` when... | Use other skills when... |
|-------------------------------|--------------------------|
| You have finished long-form content | Creating original content (`content-writer`) |
| Need multi-platform distribution | Single platform strategy (`linkedin-content`) |
| Want to maximize one piece's reach | Building content calendar (`content-calendar`) |
| Repurposing newsletters, articles | Writing from scratch (`viral-content`) |
