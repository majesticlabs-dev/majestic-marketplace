# STANDARD Plan Template

**Best for:** Most features, complex bugs, team collaboration

```markdown
## Overview

[Comprehensive description]

## Problem Statement / Motivation

[Why this matters]

## Proposed Solution

[High-level approach]

## Technical Considerations

- Architecture impacts
- Performance implications
- Security considerations

## Acceptance Criteria

- [ ] Detailed requirement 1
- [ ] Detailed requirement 2
- [ ] Testing requirements

## Definition of Done

Feature behaviors that must work (code quality handled by other agents):

| Item | Verification |
|------|--------------|
| [Feature behavior 1] | [Command or manual check] |
| [Feature behavior 2] | [Command or manual check] |

## Success Metrics

[How we measure success]

## Dependencies & Risks

[What could block or complicate this]

## Design System Reference (if IS_UI_FEATURE)

- **Design System:** `[DESIGN_SYSTEM_PATH]`
- **Components to use:** [list from design system: buttons, inputs, cards, etc.]
- **Color tokens:** [relevant semantic colors from design system]
- **Typography:** [relevant type scale entries]
- **Patterns to follow:** [specific component patterns and states]

## Infrastructure Context (if IS_DEVOPS_FEATURE)

- **IaC Tool:** [OpenTofu/Terraform version]
- **Providers:** [DEVOPS_PROVIDERS list]
- **Skills to apply:** [DEVOPS_SKILLS list]
- **State backend:** [local/remote - describe current setup]
- **Security findings:** [summary from infra-security-review if run]

## References & Research

- Similar implementations: [file_path:line_number]
- Best practices: [documentation_url]
- Related PRs: #[pr_number]
```
