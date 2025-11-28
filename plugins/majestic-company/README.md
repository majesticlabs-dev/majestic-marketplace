# Majestic Company

Business operations tools. Includes 2 specialized agents and 13 skills.

## Installation

```bash
claude /plugin install majestic-company
```

## Agents

Invoke with: `agent majestic-company:<name>`

| Agent | Description |
|-------|-------------|
| `first-principles` | Strategic thinking using Elon Musk's first-principles methodology - problem-solving, decision-making, breakthrough thinking |
| `people-ops` | People operations - hiring, onboarding, PTO policies, performance management, employee relations |

## Skills

### CEO Skills

Invoke with: `skill majestic-company:ceo:<name>`

| Skill | Description |
|-------|-------------|
| `founder-mode` | Help founders run companies using contrarian principles that break conventional management wisdom |
| `strategic-planning` | Build one-page strategic briefs with core objective, milestones, leverage points, and risks |
| `decision-framework` | Walk through decisions with first-principles, cost/benefit, and second-order effects analysis |
| `industry-pulse` | Real-time pulse check on any industry: trending tech, recent events, key shifts for operators/investors |
| `growth-audit` | 360-degree business audit with evidence-backed blueprint to 5-10X growth trajectory |
| `industry-research` | Research market, identify underserved pain, design venture to capture opportunity in 12 months |
| `ai-advantage` | Develop research-backed AI competitive strategies combining academic research, market trends, and social sentiment |
| `pareto` | Identify the vital 20% of activities that produce 80% of results using Pareto Principle analysis |
| `future-back` | Envision ideal future state, then reverse-engineer the pathway from vision to reality |
| `decisions` | Tree of Thoughts business decisions with expert consultants exploring multiple approaches |
| `market-expansion` | Strategic market expansion analysis with quantified entry strategies and financial projections |

### Research Skills

Invoke with: `skill majestic-company:<name>`

| Skill | Description |
|-------|-------------|
| `problem-research` | Research competitor pain points from review platforms (G2, Capterra, Reddit) to find wedge opportunities. SaaS/B2B focus. Brutally honest viability assessment. |

### Legal Skills

Invoke with: `skill majestic-company:legal:<name>`

| Skill | Description |
|-------|-------------|
| `document-review` | Review legal documents as an experienced attorney. Analyzes contracts, ToS, privacy policies, NDAs section-by-section with specific replacement text for problematic clauses. |

### Founder Mode Usage

```bash
# Strategic decision with conventional advice conflict
skill majestic-company:ceo:founder-mode

# Then provide:
# - Company stage
# - Specific challenge
# - Current approach
# - Conventional advice received
# - Your founder instinct
```

The skill challenges "manager mode" thinking and helps founders leverage their unique capabilities: authority, vision, deep company knowledge, risk tolerance, and cultural connection.

### Strategic Planning Usage

```bash
# Build a strategic plan for a goal
skill majestic-company:ceo:strategic-planning

# Then provide:
# - Goal: What you want to achieve
# - Context: Current situation, constraints, resources
# - Timeline: Desired timeframe (optional)
# - Audience: Who will read/approve (optional)
```

The skill produces one-page briefs with: core objective, 3 key milestones, 5 leverage points, risk assessment, and next action.

### Decision Framework Usage

```bash
# Walk through a decision
skill majestic-company:ceo:decision-framework

# Then provide:
# - Option A: First choice
# - Option B: Second choice
# - Context: Situation and constraints (optional)
```

The skill applies a 3-part framework: first-principles analysis, cost/benefit breakdown, and second-order effects. Includes examples from similar situations.

### Industry Pulse Usage

```bash
# Get pulse check on an industry
skill majestic-company:ceo:industry-pulse

# Then provide:
# - Industry or niche (e.g., "AI infrastructure", "fintech payments")
```

The skill uses WebSearch to provide: trending technologies, notable events from the last 2 weeks, and 3 key shifts impacting operators and investors.

### Growth Audit Usage

```bash
# Comprehensive business growth audit
skill majestic-company:ceo:growth-audit

# Then provide:
# - Business Name/Description
# - Unique Selling Point
# - Current Monthly Revenue
# - Annual Growth Rate
# - Number of Customers
# - Churn Rate
# - Customer Acquisition Cost
# - Team Size
# - Growth Timeline Goal (months)
# - Risk Tolerance (conservative/moderate/aggressive/ultra-aggressive)
```

The skill performs a 360-degree analysis across six dimensions: market dynamics, product positioning, growth engine, retention mechanics, operational excellence, and competitive moat. Output includes a growth scorecard, critical growth limiters, 90-day acceleration plan with 5-7 quick wins, 3-5 strategic growth initiatives with execution roadmaps, and a measurement system with quarterly milestones.

### Industry Research Usage

```bash
# Research a market and design a venture
skill majestic-company:ceo:industry-research

# Then provide:
# - Industry to research (e.g., "healthcare SaaS", "fintech for SMBs")
```

The skill executes a 10-step workflow: map macro landscape, identify pain points, select best opportunity via weighted scorecard, draft business thesis, design product, plan go-to-market, assess moat, build financial model, identify risks, and create 90-day action roadmap. Output is investor-ready with reasoning and executive summary.

### AI Advantage Usage

```bash
# Develop AI competitive strategy
skill majestic-company:ceo:ai-advantage

# Then provide:
# - Industry
# - Priority business functions for AI enhancement
# - Current AI maturity level
```

The skill combines academic research, market trends, and social sentiment analysis to deliver actionable AI competitive strategies with implementation roadmaps and a competitive positioning matrix.

### Pareto Analysis Usage

```bash
# Identify your vital 20%
skill majestic-company:ceo:pareto

# Then provide:
# - Area to optimize (learning, productivity, business, personal)
# - Specific goals in that area
# - Current activities involved
```

The skill guides you through identifying all factors, determining impact through comparisons, isolating the vital few activities, and minimizing low-value work. Output includes a prioritized action plan with immediate, weekly, and ongoing actions.

### Future Back Planning Usage

```bash
# Create a future back plan
skill majestic-company:ceo:future-back

# Then provide:
# - Future timeframe (3, 5, or 10 years)
# - Personal, professional, or organizational scope
# - Current situation and aspirations
```

The skill guides you through future visualization (outcome and experience dimensions), then maps backward from vision to present with prerequisite chains, critical path identification, resource requirements, and a horizon-based implementation blueprint with immediate actions.

### Business Decisions Usage

```bash
# Get structured decision analysis
skill majestic-company:ceo:decisions

# Then provide your business challenge, such as:
# - Market entry strategies
# - Product feature prioritization
# - Hiring decisions
# - Pricing optimization
# - Investment allocation
```

The skill assembles 4 expert consultants (Growth Strategist, Operations Expert, Financial Analyst, Skeptic Risk Analyst) who each explore 3 approaches with potential outcomes, debate disagreements, and deliver a unified recommendation with confidence level. For complex decisions, adds implementation milestones with contingency plans.

### Market Expansion Usage

```bash
# Analyze market expansion opportunity
skill majestic-company:ceo:market-expansion

# Then provide:
# - Company name
# - Target market (region, segment, or vertical)
# - Current market position
```

The skill evaluates 3 entry strategies (direct, partnership, acquisition, etc.) through decision trees with quantified scoring (profitability, scalability, risk). Output includes 3-year financial projections, competitive positioning, resource requirements, and risk mitigation strategies.

### Problem Research Usage

```bash
# Start interactive research session
skill majestic-company:problem-research

# With initial context
skill majestic-company:problem-research "Project management software for marketing teams"

# Specific competitor focus
skill majestic-company:problem-research "CRM alternatives to Salesforce for SMBs"
```

The skill will ask you to select:
- **Research scope**: Light (3-5 competitors), Medium (5-10), or Deep (10+)
- **Execution mode**: Semi-automated (WebSearch) or Agentic browsing (Browser MCP)

**Output includes:**
- Pain Points Table (ranked with quotes and scores)
- Must-Haves Table (table stakes features)
- Hidden Gems (underserved opportunities)
- Opportunity Map (wedge strategies)
- Viability Assessment (GO/PROCEED WITH CAUTION/RECONSIDER/NO-GO)

Every report concludes with brutally honest answers to: "What would make this fail?" and "Is this a vitamin or painkiller?"

### Document Review Usage

```bash
# Review a legal document
skill majestic-company:legal:document-review

# Then provide:
# - Document type (Contract, NDA, ToS, Privacy Policy, Employment Agreement, etc.)
# - Your role (which party you represent)
# - Attach or paste the document
```

The skill analyzes each section for: scope, payment terms, timelines, IP rights, termination clauses, liability, confidentiality, and governing law. Output includes section-by-section analysis, risk assessment (high/medium/low), and specific replacement text for problematic clauses.

**Note:** This is for informational purposes only and does not constitute legal advice. Consult qualified counsel before signing.

## Usage Examples

### First-Principles Thinking

```bash
# Strategic problem analysis
agent majestic-company:first-principles "My business is plateauing at $1M ARR"

# Decision making
agent majestic-company:first-principles "Should I pivot from B2C to B2B?"

# Product prioritization
agent majestic-company:first-principles "My product roadmap has 50 items - help me cut 90%"

# Clean slate thinking
agent majestic-company:first-principles "My SaaS evolved randomly over 3 years - if I restarted today, what would I build?"
```

### People Operations

```bash
# Create a structured interview kit
agent majestic-company:people-ops "Create interview kit for Senior Engineer in California"

# Draft a PTO policy
agent majestic-company:people-ops "Draft accrual-based PTO policy for 50-person company"

# Generate onboarding plan
agent majestic-company:people-ops "Create 30/60/90 onboarding plan for remote Product Manager"

# Performance improvement plan
agent majestic-company:people-ops "Create PIP template with coaching steps"
```

## First-Principles Capabilities

The first-principles agent uses 15 strategic prompts organized into 6 categories:

### Foundation
- Strip problems to objective reality ("physics")
- Challenge existing assumptions
- Break problems into fundamental components

### Ideal State
- Envision optimal solutions without cost constraints
- Apply brutal prioritization (cut 90%)

### Risk Analysis
- Pre-mortem failure analysis
- Challenge industry norms
- Separate "actually impossible" from "feels impossible"

### Breakthrough
- Find minimum viable breakthrough (not MVP)
- Clean slate thinking

### Constraints & Politics
- Identify hidden constraints
- Remove social friction from problem-solving

### Scale & Leverage
- 10x acceleration thinking
- Design for millions
- Identify highest-leverage actions

## People-Ops Capabilities

### Hiring & Recruiting
- Job descriptions with competencies and EOE statements
- Structured interview kits with rubrics and scorecards
- Candidate communication templates

### Onboarding & Offboarding
- 30/60/90 day plans
- IT access and compliance checklists
- Exit interview guides

### PTO & Leave
- Accrual-based and grant-based policies
- Pro-rating rules and coverage plans
- Jurisdiction-aware templates

### Performance Management
- Competency matrices by level
- SMART goal setting frameworks
- PIP templates with objective measures

### Employee Relations
- Issue intake and investigation templates
- Documentation standards
- Conflict resolution frameworks

## Important Notes

- **Not legal advice** - Consult qualified counsel before implementing policies
- **Jurisdiction-aware** - Agent will ask for location to provide appropriate guidance
- **Compliance-focused** - Templates follow labor law best practices
