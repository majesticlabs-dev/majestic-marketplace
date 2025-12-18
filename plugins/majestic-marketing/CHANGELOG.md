# Changelog

All notable changes to majestic-marketing will be documented in this file.

## [3.4.0] - 2025-12-18

### Enhanced

**GEO (Generative Engine Optimization) Enhancements**

Added AI trust signal strategies based on research showing framing matters more than domain authority:

- **`llm-optimizer`** - New "Content Framing for AI Trust" section:
  - High-trust content format ranking (research report > comparative analysis > listicle)
  - Reframing strategy with before/after examples
  - Research-style content elements checklist
  - Speed advantage insight (hours vs months for AI visibility)

- **`entity-builder`** - New "Analyst & Expert Positioning" section:
  - Expert entity types with AI trust signals
  - Building analyst credibility (research arm, bio elements)
  - Research output patterns (quarterly reports, benchmarks)
  - Analyst triplets to establish
  - Cross-reference strategy for consistent expert entity

- **`authority-builder`** - New "Press Release Strategy for AEO" section:
  - High-trust PR framing table (research framing vs promotional)
  - Press release structure optimized for AI extraction
  - Distribution channel comparison with cost tiers
  - Speed factor for AI indexing

## [3.3.0] - 2025-12-14

### Enhanced

**`google-ads-strategy` - 2026 Match Type Updates**

Updated with current Google Ads best practices based on 2026 match type evolution:

- **Match type guidance**: Skip phrase match in new campaigns—now redundant due to AI-driven overlaps with exact and broad
- **Recommended mix**: 70% exact match (control) + 30% broad match (discovery)
- **Ad group structure**: One theme per ad group, max 20 keywords
- **Keyword discovery process**: Google Keyword Planner workflow with validation checklist
- **Head term priority**: Prefer high-volume head terms—match types capture long-tail variants automatically
- **Optimization roadmap**: Week-by-week cadence (Weeks 1-2, 3-4, Month 2, Month 3+)
- **Expanded negatives**: Added "repair", "rental", "used" to standard negative keyword list

Based on [Jackson Blackledge's Google Ads Keyword Research Playbook](https://x.com/blvckledge) for DTC brands.

## [3.2.0] - 2025-12-13

### Added

**Commands (1)**
- `/aeo-workflow` - Complete AEO (Answer Engine Optimization) workflow command. Guides through all 7 phases:
  1. Strategy - Build buyer persona × journey grid
  2. Research - Three-pronged query sourcing
  3. Gaps - Identify AI visibility gaps
  4. Fan-out - Analyze query sub-questions
  5. Content - Apply 7-step AEO checklist
  6. Authority - Off-site mentions strategy
  7. Measure - Track 4 AEO metrics

### Documentation

- Added comprehensive [AEO Strategy Guide](https://github.com/majesticlabs-dev/majestic-marketplace/wiki/AEO-Strategy-Guide) to wiki

## [3.1.0] - 2025-12-13

### Added

**Skills (1)**
- `aeo-scorecard` - AEO measurement framework with the four key metrics: AI Visibility, AI Share of Voice, AI Citations, and Referral Demand. Includes scorecard template, tool recommendations, and monthly review cadence.

### Enhanced

**AEO (Answer Engine Optimization) Enhancements**

Based on actionable AEO presentation recommendations:

- **`llm-optimizer`** - Added 7-step AEO on-page checklist:
  1. Put the Answer First - Direct answer in first sentence
  2. Go One Click Deeper - Context/definitions for credibility
  3. Reference Original Data - Proprietary stats and case studies
  4. Include FAQ Section - 3+ fan-out sub-questions answered
  5. Add Structure - Bullets, tables, explicit headers
  6. "Taco Bell Test" (Chunking) - Each section stands alone
  7. Tie Back to Product - Connect educational content to brand
  - Also added query fan-out tools (Kuforia) and examples

- **`entity-builder`** - Added AI citation source strategy:
  - "Mentions > Backlinks" principle for AEO
  - How to identify currently-cited sources (XFunnel)
  - Outreach for contextual mentions (not just links)
  - Human-first channel seeding (YouTube, newsletters, LinkedIn)
  - Feature-specific review guidance for UGC

- **`content-planner`** - Added buyer persona × journey grid:
  - 3×4 Content Grid template (Personas × Journey Stages)
  - Three-pronged query sourcing (keyword data, social listening, internal data)
  - Funnel-stage query tagging system

## [3.0.0] - 2025-12-12

### Changed

- **Refactored** - `google-ads-strategy` skill trimmed to ≤500 lines
- **Refactored** - `linkedin-content` skill trimmed to ≤500 lines
- **Refactored** - `retention-system` skill trimmed to ≤500 lines
- **Version unified** - All majestic plugins now at v3.0.0

## [2.27.0] - 2025-12-08

### Added

**Resources (1)**
- `AI_WRITING_TELLS.md` - Comprehensive reference for detecting and eliminating AI-generated prose patterns. Based on Wikipedia's "Signs of AI writing" page. Includes 50+ AI vocabulary words with replacements, phrase patterns, structural tells, attribution red flags, detection checklist with severity levels, and before/after examples.

### Enhanced

- `copy-editor` - Added AI Writing Tells detection to Phase 3 review, report template, and compliance checklist
- `content-writer` - Simplified "Words to Avoid" to "Avoiding AI Slop" with reference to new resource
- `DEFAULT_STYLE_GUIDE.md` - Added section 4.3 "AI Writing Tells" with quick rules

## [2.26.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simplified simple naming without prefixes (Claude Code auto-namespaces) prefix for easier invocation
  - Old: `agent majestic-marketing:seo:llm-optimizer`
  - New: `agent llm-optimizer`
- Updated all documentation with new agent names

## [2.23.0] - 2025-11-30

### Added

**Skills (1)**
- `competitive-positioning` - Analyze competitors, identify positioning weaknesses, and craft sharp differentiators with taglines and tweet-length pitches. Includes competitor snapshot analysis, gap identification, differentiation strategies, and buyer-facing messaging assets.

## [2.22.0] - 2024-11-30

### Changed

**Skills Migrated to majestic-sales (6)**

The following sales-focused skills have been moved to the new `majestic-sales` plugin for better organization:

- `sales-playbook` - Now at `majestic-sales:sales-playbook`
- `outbound-sequences` - Now at `majestic-sales:outbound-sequences`
- `proposal-writer` - Now at `majestic-sales:proposal-writer`
- `icp-discovery` - Now at `majestic-sales:icp-discovery`
- `referral-program` - Now at `majestic-sales:referral-program`
- `win-back` - Now at `majestic-sales:win-back`

## [2.19.0] - 2025-11-28

### Added

**Agents (1)**
- `branding:namer` - Generate category-defining brand, company, and product names using Igor naming methodology. Includes competitive taxonomy analysis, four name types (functional, invented, experiential, evocative), A.S.S. test (Associations + Slogans Score), NFX guidelines, and "Happy Idiot" anti-patterns to avoid.

**Skills (1)**
- `power-words` - Enhance copy with emotional trigger words from 18 psychological categories. Includes 401+ power words organized by emotional impact (impatience, beauty, lust, novelty, authority, exclusivity, etc.), strategic replacement methodology, and before/after enhancement workflow.

## [2.18.0] - 2025-11-28

### Added

**Skills (1)**
- `content-writer` - Write well-structured articles using outline-first workflow. Includes two modes (outline/write), Gary Provost sentence variation technique, Flesch-Kincaid 8th grade readability, max 300 words/section, and words-to-avoid list for cleaner prose.

## [2.17.0] - 2025-11-28

### Added

**Skills (1)**
- `content-calendar` - Generate a complete 30-day content calendar with viral content ideas, format variety, hooks, and CTAs tailored to your niche and platform. Includes content pillars (5 types with mix ratios), hook/CTA libraries by content type, batch creation workflow, and performance tracking templates.

## [2.16.0] - 2025-11-28

### Added

**Skills (1)**
- `slogan-generator` - Generate and evaluate marketing slogans for any product or service. Creates 10-15 options across 6 categories (benefit-focused, emotional, wordplay, aspirational, problem-solution, brand promise), scores against 6 criteria, and recommends top 3 with rationale.

## [2.15.0] - 2025-11-28

### Added

**Skills (1)**
- `linkedin-content` - Create high-performing LinkedIn content with algorithm-optimized hooks, content pillar strategy, posting cadence, and performance tracking. Includes 5 hook formula categories, post format templates (text, carousel, poll), weekly posting schedules, engagement optimization tactics, A/B testing framework, and performance benchmarks by follower count.

## [2.14.0] - 2025-11-28

### Added

**Skills (1)**
- `case-study-writer` - Create compelling customer case studies for marketing and sales enablement. Guides through information gathering (customer details, challenge, solution, results) and produces polished case study documents in multiple formats (full, summary, social proof snippet).

## [2.13.0] - 2025-11-28

### Added

**Skills (1)**
- `bofu-keywords` - Find bottom-of-funnel keywords with high purchase intent for any product. Generates transactional, comparative, evaluative, and problem-solution keywords with content recommendations. Uses Perplexity MCP for real-time validation.

## [2.12.0] - 2025-11-28

### Added

**Skills (4)** - Retention Marketing Suite
- `email-nurture` - Design automated email nurture sequences and drip campaigns with segmentation strategies, behavioral triggers, and conversion-optimized copy for welcome, educational, re-engagement, and sales sequences
- `retention-system` - Design comprehensive customer retention systems with health scoring, churn prediction, proactive engagement workflows, and customer success frameworks to maximize lifetime value
- `referral-program` - Design viral referral programs with incentive structures, sharing mechanics, tracking systems, and optimization strategies to turn customers into advocates who drive new customer acquisition
- `win-back` - Design win-back campaigns to re-engage dormant customers and recover churned users with targeted messaging, special offers, and feedback collection to understand and address churn reasons

## [2.11.0] - 2025-11-28

### Added

**Skills (1)**
- `landing-page-builder` - Generate structured landing page copy with hero, problem, solution, benefits, proof, objections, offer, and CTA sections. Framework-agnostic approach that adapts based on audience awareness level. Simpler/faster alternative to `sales-page` when you already know your messaging.

### Enhanced

- `landing-page-builder` - Added Conversation Starter section for interactive input gathering and Audience Psychology Checklist for deeper emotional mapping.

## [2.10.0] - 2025-11-28

### Added

**Skills (1)**
- `customer-discovery` - Find where potential customers discuss problems online and extract their language patterns. Honest about web search limitations; provides starting points for manual community research.

## [2.9.0] - 2025-11-28

### Added

**Skills (1)**
- `hook-writer` - Generate attention-grabbing hooks from 5 investor archetype perspectives (Numbers Shark, Consumer-Insight Expert, Tech Visionary, Founder-Story Investor, Scalability Strategist)

## [2.8.0] - 2025-11-28

### Added

**Skills (1)**
- `value-prop-sharpener` - Refine value propositions from emotional, logical, and status angles into 15-word statements with evolution process

## [2.7.0] - 2025-11-28

### Added

**Skills (1)**
- `sales-page` - High-converting sales page templates with headline formulas, bullet frameworks, and CTA psychology

## [2.6.0] - 2025-11-28

### Added

**Skills (3)**
- `irresistible-offer` - Craft irresistible offers using direct response marketing principles with 7-part formula
- `free-tool-arsenal` - Build complete business tech stack with 100% free tools and automation workflows
- `viral-content` - Create viral content frameworks with platform-specific patterns and psychological hooks

### Changed

- Enhanced `traffic-magnet` with guerrilla marketing elements: cold outreach scripts, social post templates, and zero-cost success stories

## [2.3.0] - 2025-11-28

### Added

**Skills (1)**
- `traffic-magnet` - Research and compile organic traffic methods for new websites with zero ad spend, including 30-day action plans

## [2.2.0] - 2025-11-28

### Added

**Skills (1)**
- `marketing-strategy` - Interactive interview to build a custom marketing strategy with JSON export

## [2.1.0] - 2025-11-28

### Added

**Skills (1)**
- `market-research` - Comprehensive market research with web data, competitive analysis, and structured synthesis

## [2.0.0] - 2025-11-27

### Added

**SEO Agents (10)**
- `seo:authority-builder` - E-E-A-T analysis and authority signal optimization
- `seo:cannibalization-detector` - Keyword overlap and conflict detection
- `seo:content-auditor` - Content quality and SEO best practices audit
- `seo:content-planner` - Topic clusters and content calendar planning
- `seo:content-refresher` - Identify outdated content and suggest updates
- `seo:content-writer` - SEO-optimized content creation
- `seo:keyword-strategist` - Keyword density, LSI, semantic optimization
- `seo:meta-optimizer` - Meta titles, descriptions, URL optimization
- `seo:snippet-hunter` - Featured snippet and SERP feature optimization
- `seo:structure-architect` - Header hierarchy, schema, internal linking

**GEO Agents (3)**
- `seo:llm-optimizer` - Optimize content for AI citation (ChatGPT, Perplexity, Gemini)
- `seo:entity-builder` - Brand entity and triplet optimization for LLM presence
- `seo:schema-architect` - Schema.org and llms.txt implementation for AI extraction

**Skills (2)**
- `seo-audit` - Comprehensive SEO and GEO audit methodology
- `content-optimizer` - Content optimization workflow for search and AI

**Commands (2)**
- `/seo-audit` - Quick SEO audit with actionable recommendations
- `/content-check` - Comprehensive content check for SEO and AI readability

## [1.0.0] - 2024-11-26

### Added
- Initial release with 1 skill
- copy-editor skill for marketing and content editing
