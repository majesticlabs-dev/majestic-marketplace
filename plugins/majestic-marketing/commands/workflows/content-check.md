---
name: majestic:content-check
allowed-tools: Read, Write, Edit, Grep, Glob
description: Comprehensive content check covering SEO, readability, and AI citation potential
---

# Content Check Command

Perform a quick content quality check covering SEO, readability, and AI citation potential.

## Input

$ARGUMENTS

## Instructions

1. **Read the Content**
   - If a file path is provided, read the file
   - If content is pasted, analyze directly

2. **Run Content Checks**

   **Readability Check:**
   - Calculate approximate reading level
   - Count average sentence length
   - Check paragraph lengths
   - Assess scannable formatting

   **SEO Check:**
   - Identify likely target keyword
   - Check keyword placement (title, H1, first 100 words)
   - Evaluate header structure
   - Count internal/external links

   **AI Extractability Check:**
   - TL;DR or summary present?
   - FAQ section present?
   - Paragraphs under 120 words?
   - Tables/lists for data?
   - Direct answers to questions?

   **Quality Check:**
   - Unique insights present?
   - Data/statistics included?
   - Expert perspective shown?
   - Actionable advice given?

3. **Generate Report**

   Output format:
   ```
   ## Content Check: [Title or First Line]

   **Word Count:** X words
   **Reading Level:** Grade X
   **AI Citation Ready:** Yes/Partial/No

   ### Quick Assessment

   | Check | Status | Notes |
   |-------|--------|-------|
   | Readability | [emoji] | [note] |
   | SEO Basics | [emoji] | [note] |
   | AI Extractable | [emoji] | [note] |
   | Content Quality | [emoji] | [note] |

   ### Key Findings

   **Strengths:**
   - [What's working]
   - [What's working]

   **Improvements Needed:**
   1. [Issue] → [Fix]
   2. [Issue] → [Fix]
   3. [Issue] → [Fix]

   ### AI Citation Checklist
   - [x/] TL;DR or summary
   - [x/] FAQ section
   - [x/] Short paragraphs (<120 words)
   - [x/] Tables or comparison data
   - [x/] Statistics with sources
   - [x/] Question-based headers

   ### Quick Fixes (Do Now)
   - [ ] [Action]
   - [ ] [Action]
   - [ ] [Action]
   ```

4. **Offer Assistance**
   - Offer to implement quick fixes
   - Suggest `skill content-optimizer` for full optimization
   - Recommend relevant agents for specific improvements

## Status Emojis

- Good: ✓
- Needs Work: ⚠
- Critical: ✗
- Not Checked: ○
