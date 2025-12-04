# Changelog

All notable changes to this project will be documented in this file.

## [1.24.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simplified simple naming without prefixes (Claude Code auto-namespaces) prefix for easier invocation
  - Old: `agent majestic-company:first-principles`
  - New: `agent first-principles`
- Updated all documentation with new agent names

## [1.23.0] - 2025-11-30

### Enhanced

- `ceo:pricing-strategy` skill with new Expansion Revenue Strategy section
  - Expansion model options table (usage-based, seat expansion, feature upsell, add-on)
  - Recommended expansion play template with trigger, timing, and messaging fields
  - Key questions for identifying value metrics that scale with customer success

## [1.22.0] - 2025-11-30

### Added

- `blind-spot-analyzer` agent for strategic self-awareness
  - Identifies the single most critical blind spot limiting founder/business growth
  - 7 structured intake questions to gather context (replacing memory requirement)
  - 10 blind spot archetypes: 5 founder psychology + 5 strategic gaps
  - Three-part output: Diagnosis with evidence, Consequences, Prescription
  - Evidence-based analysis citing founder's own words
  - Brutally honest, single-focus approach

## [1.21.0] - 2025-11-30

### Added

- `idea-validator` agent for evidence-based startup idea validation
  - Orchestrates existing research tools: `problem-research`, `customer-discovery`, `market-research`, `competitive-positioning`, `tam-calculator`
  - Three validation depths: Quick (10-15 min), Standard (20-30 min), Full (45-60 min)
  - Structured validation phases: Problem Validation, Customer Discovery, Market Sizing, Competitive Positioning, Synthesis
  - Delivers GO / PROCEED WITH CAUTION / PIVOT / NO-GO verdict with evidence
  - Includes kill criteria and next steps for each verdict
  - Brutally honest assessment framework with blind spot identification
  - Does NOT simulate or fabricate data - uses real market research

## [1.19.0] - 2025-11-28

### Added

- `fundraising:tam-calculator` skill for market sizing
  - Three calculation methodologies: top-down, bottom-up, and value-theory
  - TAM/SAM/SOM funnel with visual representation
  - Data source credibility assessment matrix
  - Sensitivity analysis with scenario modeling (bear/base/bull)
  - VC presentation package with slide-ready summary
  - Investor Q&A preparation with anticipated questions
  - Common pitfalls checklist

### Enhanced

- `fundraising:elevator-pitch` skill significantly expanded
  - Villain-Hero storytelling framework as primary methodology
  - Three investor-customized pitch versions (technical, market-focused, customer-obsessed)
  - Word-for-word scripts with timing markers for 30s/60s/90s durations
  - Pitch variations: emotional, success story, urgency, competitor comparison, one-liner
  - Psychological hooks library
  - Delivery coaching with body language and voice modulation
  - A/B testing and iteration framework

## [1.18.0] - 2025-11-28

### Added

- New `fundraising/` skill category with 3 skills:

- `fundraising:elevator-pitch` - Create compelling 30/60/90-second elevator pitches using Villain-Hero storytelling framework (previously undocumented, now organized)

- `fundraising:funding-ask-optimizer` - Craft compelling investment asks
  - Multi-perspective justification (growth acceleration, historical comparables, risk mitigation)
  - Month-by-month milestone roadmap with funding allocation breakdown
  - Investment narrative script for verbal delivery

- `fundraising:objection-destroyer` - Create powerful pitch closings
  - 4-element framework: market insight, proprietary advantage, founder mission, FOMO trigger
  - 45-second primary script with pacing guidance
  - Variants for skeptical, excited, and analytical investors

## [1.17.0] - 2025-11-28

### Added

- `ceo:pricing-strategy` skill for competitor pricing analysis and optimization
  - Comprehensive pricing analysis of 5-7 competitors
  - Value-to-price ratio comparison
  - Customer willingness-to-pay assessment by segment
  - Recommended pricing tiers with profit margin analysis
  - Pricing psychology insights specific to industry
  - Promotional discount strategies and timing
  - Implementation roadmap with KPIs

## [1.16.0] - 2025-11-28

### Added

- `ceo:30-day-launch` skill for tactical 30-day business execution
  - 4-question intake: business type, budget, time commitment, target market
  - Business Model Blueprint with proven models and real examples
  - "Do This, Not That" prioritized checklist for essential tasks only
  - Copy-paste customer outreach templates (emails, LinkedIn, call scripts)
  - Legal compliance shortcuts for minimum viable setup
  - First-90-days revenue forecast with realistic milestones
  - Common rookie mistakes and industry-specific pitfalls
  - Hour-by-hour first week schedule for execution

- Added differentiation guide in README between `startup-blueprint` and `30-day-launch`

### Changed

- Enhanced `ceo:startup-blueprint` Phase 2 (Product-Market Fit) with deeper validation framework
  - Assumption mapping by risk level (high/medium/low)
  - Validation methodology matrix with success criteria and timelines
  - Decision framework (green/yellow/red light indicators for pivot vs proceed)
  - Validation milestones connecting PMF to growth scaling

## [1.15.0] - 2025-11-28

### Added

- `ceo:startup-blueprint` skill for interactive 10-phase startup planning
  - 7-question initial assessment: skills, budget, interests, time, goals, risk tolerance, experience
  - Phase 1: Deep research and interactive idea generation with validation
  - Phase 2: Product-market fit strategy with personas and MVP planning
  - Phase 3: Business model development with unit economics
  - Phase 4: Competitive landscape analysis with SWOT and positioning
  - Phase 5: Budget-optimized marketing strategy with guerrilla tactics
  - Phase 6: Operational execution roadmap with launch strategy
  - Phase 7: Conversion funnel and customer journey design
  - Phase 8: Growth scaling framework with expansion strategy
  - Phase 9: Financial model and funding strategy
  - Phase 10: Comprehensive implementation masterplan with 30-60-90 day plan
  - Maintains continuity across phases with personalized recommendations

## [1.14.0] - 2025-11-28

### Added

- `ceo:market-expansion` skill for strategic market expansion analysis
  - Tree of Thoughts methodology with 3 entry strategies
  - 3 decision branches per strategy with 2-3 outcomes each
  - Scoring on profitability, scalability, and risk (1-10)
  - Financial projections for Years 1-3
  - Competitive positioning and resource allocation
  - Top 3 risks with mitigation strategies

## [1.13.0] - 2025-11-28

### Added

- `ceo:decisions` skill for Tree of Thoughts business decision-making
  - 4 expert consultants: Growth Strategist, Operations Expert, Financial Analyst, Skeptic Risk Analyst
  - Each consultant explores 3 approaches with 2-3 potential outcomes
  - Pros/cons evaluation and consultant debate before recommendation
  - Multi-level ToT for complex problems: 5 milestones, 3 strategies per milestone, contingency plans
  - Decision confidence levels (High/Medium/Low)

## [1.12.0] - 2025-11-28

### Added

- `legal:document-review` skill for legal document analysis
  - New `legal/` skill category
  - 8-point analysis framework: scope, payment, timelines, IP, termination, liability, confidentiality, governing law
  - Document type support: contracts, ToS, privacy policies, NDAs, employment agreements
  - Section-by-section analysis with risk levels (high/medium/low)
  - Specific replacement text for problematic clauses
  - Questions to ask before signing

## [1.11.0] - 2025-11-28

### Added

- `ceo:future-back` skill for vision-to-reality planning
  - Future visualization framework with outcome and experience dimensions
  - Backward mapping methodology with prerequisite chains and critical path
  - Resource and capability roadmap with barrier/enabler analysis
  - Horizon-based implementation blueprint (3 horizons)
  - Immediate action blueprint with quick wins and review cadence

## [1.10.0] - 2025-11-28

### Added

- `ceo:pareto` skill for Pareto Principle analysis
  - 4-step method: identify factors, determine impact, isolate vital few, address trivial many
  - Domain knowledge for learning, productivity, business, and personal contexts
  - Structured output with vital 20%, minimize list, action plan, and success indicators
  - Follow-up options for deeper exploration or additional areas

## [1.9.0] - 2025-11-28

### Added

- `ceo:ai-advantage` skill for AI competitive intelligence research
  - Multi-source research: academic, industry, market, social, media
  - Verification protocol with cross-referencing and source credibility evaluation
  - Implementation roadmap in three phases (0-6, 6-18, 18+ months)
  - Competitive positioning matrix with research base and market validation
  - References table with source types and key findings

## [1.8.0] - 2025-11-28

### Added

- `ceo:industry-research` skill for comprehensive venture design
  - 10-step workflow from market mapping to 90-day action plan
  - Weighted opportunity scorecard (TAM × urgency × ease × pricing power)
  - Business thesis, product design, GTM plan, financials, risks
  - Investor-ready output with reasoning and executive summary
  - Requires triangulation of 3+ sources for key claims

## [1.7.0] - 2025-11-28

### Added

- `ceo:growth-audit` skill for comprehensive business growth audits
  - 360-degree analysis across market, product, growth engine, retention, operations, and moat
  - Evidence-backed growth acceleration blueprint
  - 90-day quick wins with implementation steps
  - Strategic growth initiatives with execution roadmaps
  - Growth trajectory with quarterly milestones and measurement systems

## [1.6.0] - 2025-11-28

### Added

- `ceo:industry-pulse` skill for real-time industry pulse checks
  - Trending technologies with adoption signals
  - Notable events from the last 2 weeks
  - 3 key shifts impacting operators and investors
  - Uses WebSearch for current data

## [1.5.0] - 2025-11-28

### Added

- `problem-research` skill for researching competitor pain points and market opportunities
  - Analyzes reviews from G2, Capterra, TrustRadius, Reddit, and other platforms
  - Pain Point Score (PPS) formula for ranking issues by opportunity potential
  - Hidden Gem Score for finding underserved needs competitors ignore
  - Viability Scorecard (30-point scale) for go/no-go decisions
  - Brutally honest business viability assessment framework
  - Supports both semi-automated (WebSearch) and agentic browsing (Browser MCP) execution modes
  - Includes reference files: scoring-rubrics.md, output-template.md

## [1.4.0] - 2025-11-28

### Added

- `ceo:decision-framework` skill for structured decision-making
  - 3-part framework: first-principles, cost/benefit, second-order effects
  - Includes examples from similar situations
  - Structured output with recommendation and caveats

## [1.3.0] - 2025-11-28

### Added

- `ceo:strategic-planning` skill for building actionable strategic plans
  - Creates one-page briefs with core objective, 3 key milestones, 5 leverage points, and risks
  - Structured output format ready for pitching or execution
  - Includes guiding questions and risk assessment framework

## [1.2.0] - 2025-11-28

### Added

- `ceo:founder-mode` skill for running companies using contrarian principles
  - Challenges conventional management wisdom designed for professional managers
  - Response framework: Contrarian Analysis, Founder Capabilities, Direct Engagement, Implementation, Scaling
  - Output structure: Situation reframe, Conventional trap, Founder advantage, Action plan, Red flags, Metrics

## [1.1.0] - 2025-11-28

### Added

- `first-principles` agent for strategic thinking using Elon Musk's first-principles methodology
  - 15 core prompts organized into 6 categories
  - Foundation, Ideal State, Risk Analysis, Breakthrough, Constraints & Politics, Scale & Leverage
  - Meta-prompts for stacking multiple analysis approaches

## [1.0.0] - 2025-11-27

### Added

- Initial release of majestic-company plugin
- `people-ops` agent for people operations: hiring, onboarding, PTO policies, performance management, and employee relations
