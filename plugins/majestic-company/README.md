# Majestic Company

Business operations tools. Includes 2 specialized agents and 2 skills.

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

Invoke with: `skill majestic-company:ceo:<name>`

| Skill | Description |
|-------|-------------|
| `founder-mode` | Help founders run companies using contrarian principles that break conventional management wisdom |
| `strategic-planning` | Build one-page strategic briefs with core objective, milestones, leverage points, and risks |

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
