# AI Writing Tells

Signs and patterns that indicate AI-generated text. Use this reference to identify and eliminate AI "slop" from prose.

> **Source:** Compiled from Wikipedia's "Signs of AI writing" page, WikiProject AI Cleanup, and community observations. These patterns appear far more frequently in LLM output than in pre-2022 human writing.

## Quick Detection

**Cluster rule:** Any single pattern is weak evidence. Look for **clusters of 3+ patterns** in the same text for strong indication of AI involvement.

---

## 1. AI Vocabulary

Words that AI models overuse. Not banned, but flag when they appear in clusters.

### Importance Amplifiers

| AI Word | Human Alternative |
|---------|-------------------|
| pivotal | key, important, central |
| crucial | important, essential |
| significant | important, notable |
| notable | worth noting, interesting |
| remarkable | interesting, unusual |
| profound | deep, serious, major |
| transformative | changing, improving |

### Praise Escalators

| AI Word | Human Alternative |
|---------|-------------------|
| prominent | well-known, leading |
| renowned | famous, respected |
| acclaimed | praised, celebrated |
| celebrated | famous, honored |
| distinguished | respected, notable |
| prestigious | respected, elite |

### Action Verbs (Overused)

| AI Word | Human Alternative |
|---------|-------------------|
| underscores | shows, highlights |
| highlights | shows, points out |
| showcases | shows, displays |
| demonstrates | shows, proves |
| emphasizes | stresses, shows |
| illuminates | shows, explains |
| elucidates | explains, clarifies |

### Abstract Nouns

| AI Word | Human Alternative |
|---------|-------------------|
| landscape | field, area, space, market |
| ecosystem | system, environment, community |
| framework | system, structure, approach |
| paradigm | model, approach, way of thinking |
| realm | area, field, domain |
| domain | area, field |
| sphere | area, field |
| tapestry | mix, combination, blend |

### Quality Descriptors

| AI Word | Human Alternative |
|---------|-------------------|
| holistic | complete, whole, integrated |
| multifaceted | complex, varied |
| comprehensive | complete, full, thorough |
| robust | strong, solid, reliable |
| nuanced | subtle, detailed |
| intricate | complex, detailed |
| seamless | smooth, easy |

### Milestone Words

| AI Word | Human Alternative |
|---------|-------------------|
| landmark | major, historic, important |
| milestone | achievement, step |
| cornerstone | foundation, basis |
| groundbreaking | new, innovative |
| cutting-edge | modern, advanced, latest |
| state-of-the-art | modern, advanced |

### Connector Words (Overused)

| AI Word | Human Alternative |
|---------|-------------------|
| moreover | also, and, plus |
| furthermore | also, and |
| additionally | also, and |
| consequently | so, as a result |
| nevertheless | but, however, still |
| notwithstanding | despite, although |

### Other AI Favorites

| AI Word | Human Alternative |
|---------|-------------------|
| delve | explore, look at, examine |
| embark | start, begin |
| leverage | use |
| utilize | use |
| facilitate | help, enable, allow |
| optimize | improve |
| streamline | simplify, speed up |
| synergy | cooperation, combined effect |
| paradigm shift | change, major change |

---

## 2. AI Phrases

Phrases that signal AI-generated content.

### Opening Phrases

Never start sentences with:
- "In today's [landscape/world/era]..."
- "In the realm of..."
- "It's important to note that..."
- "It's worth mentioning that..."
- "Let's delve into..."
- "Let's explore..."
- "Dive into..."

### Transition Phrases (Overused)

Limit or avoid:
- "On the other hand..."
- "By contrast..."
- "Not only... but also..."
- "While some... others..."
- "That being said..."

### Future/Speculation Phrases

Flag these:
- "...is poised to..."
- "...is set to..."
- "...continues to [play a vital role]..."
- "...shaping the future of..."
- "Looking ahead..."
- "Going forward..."
- "In the future..."
- "...will likely play a key role..."
- "...is expected to continue growing..."

### Importance-Selling Phrases

Flag these:
- "...has had a profound impact on..."
- "...plays a vital role in..."
- "...marks a pivotal moment in..."
- "...has significantly shaped the landscape of..."
- "...in the broader context of..."
- "...in the wider landscape of..."

### Closing Phrases

Never use:
- "In conclusion..."
- "In summary..."
- "To summarize..."
- "Overall, [subject] continues to be..."
- "...remains an important part of..."

### Sycophantic Phrases

Remove entirely:
- "I hope this helps!"
- "Let me know if you need more information."
- "Thank you for your question."
- "Great question!"
- "That's an interesting point."

### Knowledge Cutoff Disclaimers

Remove chatbot leakage:
- "As of my last update..."
- "Based on my training data..."
- "I don't have access to real-time information..."
- "My knowledge cutoff is..."
- "I cannot browse the internet..."

### False Range Constructions

AI creates artificial scope with "from X to Y" patterns:

| AI Pattern | Problem |
|------------|---------|
| "from beginners to experts" | Vague, adds no information |
| "from small startups to large enterprises" | Generic scope-padding |
| "from theory to practice" | Filler phrase |
| "from planning to execution" | Obvious lifecycle, no insight |

**Fix:** Be specific about the actual audience or scope, or remove entirely.

---

## 3. Structural Patterns

### The "Challenges and Future" Formula

AI often adds sections near the end with this structure:

**Pattern:**
```
Despite its [strengths/benefits/potential], [subject] faces several challenges:
- [Generic challenge 1]
- [Generic challenge 2]
- [Generic challenge 3]

Nevertheless, ongoing initiatives aim to address these issues. With continued
support and collaboration, [subject] is poised to play an increasingly
important role.
```

**Fix:** Remove or rewrite with specific, sourced challenges and concrete solutions.

### The Balanced Hedge

AI mechanically presents both sides:

**Pattern:**
```
While some critics have raised concerns about [X], supporters argue that [Y].
Although [issue], proponents maintain that [benefit].
```

**Fix:** Take a position or present specific named sources for each view.

### The Essay Structure

AI defaults to academic essay format:

**Pattern:**
- Broad thematic opening: "[Subject] has long played an important role in..."
- Body with mechanical transitions
- Summative conclusion restating everything
- Positive closing note

**Fix:** Start with the most important information. Cut the summary conclusion.

### The "-ing" Phrase Analysis

AI uses superficial present participle phrases to add false depth:

**Pattern:**
```
[Subject], combining [aspect] with [aspect], represents...
Showcasing [quality] while maintaining [quality], the [subject]...
Drawing from [influence] and incorporating [element]...
```

**Fix:** Replace with concrete statements. "The app combines X with Y" → "The app does X. It also does Y."

### The Rule of Three

AI mechanically groups things in threes:

**Pattern:**
```
...brings together innovation, creativity, and excellence.
...marked by dedication, perseverance, and passion.
...offers quality, reliability, and value.
```

**Fix:** Use the actual number of items. If there are 2 things, list 2. If 4, list 4. Forced triples feel artificial.

---

## 4. Style & Formatting Patterns

Visual and formatting choices that signal AI generation.

### Punctuation Overuse

| Pattern | Problem | Fix |
|---------|---------|-----|
| Excessive em dashes (—) | AI loves em dashes for interjections | Use commas, parentheses, or restructure |
| Multiple em dashes per paragraph | Looks mechanical | Limit to 1 per paragraph max |
| Curly quotes in plain text | AI defaults to typographic quotes | Match document conventions |

### Text Decoration

| Pattern | Problem | Fix |
|---------|---------|-----|
| Mechanical boldface emphasis | Bolding obvious keywords | Bold only truly important terms |
| **Bolded inline headers:** with colons | Formulaic structure | Use proper headings or remove |
| Emoji decoration 🎯 | Unprofessional in most business writing | Remove unless brand-appropriate |
| Excessive bullet points | Everything becomes a list | Use prose where appropriate |

### Heading Conventions

| Pattern | Problem | Fix |
|---------|---------|-----|
| Title Case In Every Heading | AI defaults to title case | Match document style guide |
| Generic heading names | "Overview", "Key Features", "Conclusion" | Use specific, descriptive headings |
| Perfectly balanced sections | Each section suspiciously similar length | Vary section length naturally |

---

## 5. Attribution Red Flags

### Vague Expert Attribution

AI invents consensus without sources:

| AI Pattern | Problem |
|------------|---------|
| "Some experts believe..." | Which experts? |
| "Many scholars argue..." | Name them |
| "Critics point out..." | Who specifically? |
| "Observers note..." | Vague |
| "Commentators suggest..." | Unsourced |
| "The academic community agrees..." | Overgeneralization |
| "Society at large recognizes..." | Unsourced claim |

**Fix:** Name specific people or remove the claim.

### Weasel Phrases

| AI Pattern | Problem |
|------------|---------|
| "...is widely regarded as..." | By whom? |
| "...is considered by many to be..." | How many? Who? |
| "Experts agree that..." | Citation needed |
| "It is generally accepted..." | By whom? |
| "Research shows..." | Which research? |

**Fix:** Cite specific sources or remove the hedge.

---

## 6. Detection Checklist

Use this checklist when reviewing content:

### Vocabulary Check
- [ ] No cluster of 3+ AI vocabulary words in same paragraph
- [ ] "Landscape", "realm", "paradigm" used 0-1 times total
- [ ] "Pivotal", "crucial", "profound" used sparingly
- [ ] "Delve", "embark", "leverage" replaced with simpler words

### Phrase Check
- [ ] No "In today's [X]..." openings
- [ ] No "In conclusion..." or "In summary..." closings
- [ ] No "poised to" or "shaping the future"
- [ ] No sycophantic phrases ("I hope this helps")

### Structure Check
- [ ] No formulaic "Challenges and Future Prospects" section
- [ ] No mechanical "on one hand / on the other hand" balance
- [ ] Opening leads with specific information, not broad theme
- [ ] No summative conclusion restating the article

### Attribution Check
- [ ] No "some experts" without names
- [ ] No "widely regarded as" without citation
- [ ] Claims supported by specific sources
- [ ] No overgeneralization to "the public" or "society"

### Style & Formatting Check
- [ ] Em dashes used sparingly (max 1 per paragraph)
- [ ] No mechanical boldface on obvious keywords
- [ ] No **Bolded Inline Headers:** pattern
- [ ] Heading case matches document style
- [ ] No emoji unless brand-appropriate
- [ ] No forced "rule of three" groupings
- [ ] No chatbot knowledge cutoff disclaimers

---

## 7. Severity Levels

### High Severity (Always Fix)
- Sycophantic phrases (chatbot leakage)
- Knowledge cutoff disclaimers
- "In conclusion..." / "In summary..."
- "In today's landscape..."
- Vague expert attribution without sources
- Formulaic challenges/future sections
- Emoji in professional writing

### Medium Severity (Fix When Clustered)
- AI vocabulary words (3+ in same paragraph)
- Mechanical balance phrases
- Future speculation phrases
- Essay-style structure
- Forced "rule of three" groupings
- Excessive em dashes
- **Bolded inline headers:** pattern
- False range constructions ("from X to Y")

### Low Severity (Context-Dependent)
- Individual AI vocabulary words
- Transition words like "moreover"
- Single instances of hedge phrases
- Title case in headings (may be house style)
- Curly quotes (may be document convention)

---

## 8. Before/After Examples

### Example 1: Opening Paragraph

**AI Version:**
> In today's rapidly evolving digital landscape, artificial intelligence has emerged as a pivotal force, fundamentally transforming how businesses operate. This comprehensive guide delves into the multifaceted realm of AI implementation, showcasing its profound impact on various industries.

**Human Version:**
> AI is changing how companies work. This guide covers practical ways to use AI in your business, with examples from retail, healthcare, and finance.

### Example 2: Expert Attribution

**AI Version:**
> Many experts believe that this approach represents a paradigm shift in the industry. Critics and supporters alike acknowledge its transformative potential, with some observers noting its significant implications for future development.

**Human Version:**
> MIT researcher Jane Smith calls this "the biggest change in manufacturing since robotics." Industry analyst Bob Chen disagrees, arguing the benefits are overstated.

### Example 3: Conclusion

**AI Version:**
> In conclusion, it is clear that [subject] plays a vital role in [field]. Despite facing several challenges, it continues to shape the landscape and is poised to become increasingly important in the years to come. With ongoing support and collaboration, the future looks bright.

**Human Version:**
> [Subject] works best for [specific use case]. Start with [concrete first step] and measure [specific metric] to know if it's working.

---

## Usage Notes

- **This is a reference, not a rulebook.** Context matters.
- **Clusters matter more than individual words.** One "landscape" is fine; "pivotal landscape that showcases the robust ecosystem" is AI slop.
- **Domain-specific writing may legitimately use some terms.** Academic papers use "paradigm"; that's appropriate there.
- **The goal is natural human prose,** not avoiding every word on this list.
