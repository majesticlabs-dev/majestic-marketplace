# AI Writing Tells

Signs and patterns that indicate AI-generated text. Use this reference to identify and eliminate AI "slop" from prose.

> **Source:** Compiled from Wikipedia's "Signs of AI writing" page and community observations. These patterns appear far more frequently in LLM output than in pre-2022 human writing.

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

---

## 4. Attribution Red Flags

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

## 5. Detection Checklist

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

---

## 6. Severity Levels

### High Severity (Always Fix)
- Sycophantic phrases (chatbot leakage)
- "In conclusion..." / "In summary..."
- "In today's landscape..."
- Vague expert attribution without sources
- Formulaic challenges/future sections

### Medium Severity (Fix When Clustered)
- AI vocabulary words (3+ in same paragraph)
- Mechanical balance phrases
- Future speculation phrases
- Essay-style structure

### Low Severity (Context-Dependent)
- Individual AI vocabulary words
- Transition words like "moreover"
- Single instances of hedge phrases

---

## 7. Before/After Examples

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
