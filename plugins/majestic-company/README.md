# Majestic Company

Business operations tools. Includes 1 specialized agent.

## Installation

```bash
claude /plugin install majestic-company
```

## Agents

Invoke with: `agent majestic-company:<name>`

| Agent | Description |
|-------|-------------|
| `people-ops` | People operations - hiring, onboarding, PTO policies, performance management, employee relations |

## Usage Examples

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
