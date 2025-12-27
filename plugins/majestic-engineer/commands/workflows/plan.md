---
name: majestic:plan
description: Transform feature descriptions into well-structured project plans following conventions
argument-hint: "[feature description, bug report, or improvement idea]"
---

# Create a plan for a new feature or bug fix

## Introduction

Transform feature descriptions, bug reports, or improvement ideas into well-structured markdown files that follow project conventions and best practices. This command provides flexible detail levels to match your needs.

## Feature Description

<feature_description> $ARGUMENTS </feature_description>

**If the feature description above is empty, ask the user:** "What would you like to plan? Please describe the feature, bug fix, or improvement you have in mind."

Do not proceed until you have a clear feature description from the user.

## Main Tasks

### 0. Feature Classification & Design System Check

<thinking>
Determine if this feature involves UI work that should reference a design system.
</thinking>

**UI Detection Keywords:**

Check if the feature description contains any of these keywords:
- **Components**: page, component, widget, view, screen, modal, dialog, form, layout
- **Elements**: button, input, field, dropdown, menu, select, card, table, nav, header, footer
- **Visual**: design, UI, UX, interface, theme, style, responsive, mobile, dark mode
- **Actions**: display, show, render, present, animate

**If feature contains UI keywords:**

1. **Check for design system:**
   ```bash
   # Check toolbox config
   grep "design_system_path:" .agents.yml 2>/dev/null

   # Or default location
   ls docs/design/design-system.md 2>/dev/null
   ```

2. **If design system exists:**
   - Read the design system file
   - Note the aesthetic direction and component patterns
   - Include in research context for agents
   - Mark `HAS_DESIGN_SYSTEM=true` for plan output

3. **If NO design system and this is a NEW UI feature:**
   - Suggest running `/majestic:ux-brief` first to establish design direction
   - Ask user if they want to proceed without a design system

**Store for later:**
- `IS_UI_FEATURE: true/false`
- `HAS_DESIGN_SYSTEM: true/false`
- `DESIGN_SYSTEM_PATH: <path or empty>`

---

### 0b. DevOps/Infrastructure Feature Detection

<thinking>
DevOps detection is ADDITIVE - it supplements the primary tech stack, not replaces it.
A Rails app with Terraform infra should run BOTH Rails + DevOps agents.
</thinking>

**DevOps Detection Keywords:**

Check if the feature description contains any of these keywords:
- **IaC Tools**: terraform, opentofu, tofu, infrastructure, iac, hcl, .tf
- **Cloud Providers**: aws, gcp, azure, digitalocean, hetzner, cloudflare, backblaze
- **Resources**: server, droplet, instance, vpc, firewall, load-balancer, dns, bucket, volume
- **Provisioning**: cloud-init, user-data, provision, deploy, vm, container, kubernetes, k8s
- **Edge/Serverless**: workers, pages, wrangler, d1, r2, kv, edge, lambda, function
- **Config Management**: ansible, playbook, inventory, role, task, handler, play
- **Secrets**: 1password, op://, vault, secrets, credentials, ssm

**If feature contains DevOps keywords:**

1. **Check for IaC files:**
   ```bash
   # Check for Terraform/OpenTofu
   ls *.tf infra/*.tf terraform/*.tf 2>/dev/null

   # Check for cloud-init
   ls cloud-init*.yml user-data*.yml 2>/dev/null

   # Check for Ansible
   ls ansible/*.yml playbooks/*.yml roles/ inventory/ ansible.cfg 2>/dev/null
   ```

2. **Set detection flags:**
   - `IS_DEVOPS_FEATURE: true`
   - `HAS_IAC_FILES: true/false`
   - `HAS_ANSIBLE_FILES: true/false`
   - `DEVOPS_PROVIDERS: [list detected providers]`

3. **Load DevOps skills context:**
   - If Terraform/OpenTofu detected → reference `majestic-devops:opentofu-coder`
   - If specific provider detected → reference provider-specific skill (e.g., `majestic-devops:hetzner-coder`)
   - If cloud-init detected → reference `majestic-devops:cloud-init-coder`
   - If Ansible detected → reference `majestic-devops:ansible-coder`
   - If secrets management keywords detected → reference `majestic-devops:onepassword-cli-coder`

4. **Ask about secrets management (if not already detected):**

   If `IS_DEVOPS_FEATURE: true` but NO secrets keywords were found in the feature description, use `AskUserQuestion` to ask:

   > "Will this infrastructure work involve secrets or credentials (API keys, database passwords, tokens)?"

   | Option | Description |
   |--------|-------------|
   | Yes, use 1Password CLI | Reference `majestic-devops:onepassword-cli-coder` for secrets management |
   | Yes, other method | Note the secrets requirement without 1Password skill |
   | No secrets needed | Skip secrets management context |

**Store for later:**
- `IS_DEVOPS_FEATURE: true/false`
- `HAS_IAC_FILES: true/false`
- `HAS_ANSIBLE_FILES: true/false`
- `USES_SECRETS_MANAGEMENT: true/false`
- `DEVOPS_PROVIDERS: [list or empty]`
- `DEVOPS_SKILLS: [list of relevant skills]`

---

### 1. Repository Research & Context Gathering

**Set terminal title:** !`echo -ne "\033]0;<short_feature_summary>\007"`

<thinking>
First, I need to understand the project's conventions and existing patterns, leveraging all available resources and use parallel subagents to do this.
</thinking>

Run these agents in parallel at the same time:

- `agent git-researcher "[feature_description]"` - analyze repository patterns and history
- `agent docs-researcher "[feature_description]"` - fetch library/framework documentation
- `agent best-practices-researcher "[feature_description]"` - research external best practices
- **IF IS_DEVOPS_FEATURE AND HAS_IAC_FILES:** `agent infra-security-review` - audit existing IaC for security issues

**Reference Collection:**

- [ ] Document all research findings with specific file paths (e.g., `src/services/example_service.ts:42`)
- [ ] Include URLs to external documentation and best practices guides
- [ ] Create a reference list of similar issues or PRs (e.g., `#123`, `#456`)
- [ ] Note any team conventions discovered in `CLAUDE.md` or team documentation

### 2. Issue Planning & Structure

<thinking>
Consider this like a product manager - what would make this issue clear and actionable? Evaluate multiple perspectives
</thinking>

**Title & Categorization:**

- [ ] Draft clear, searchable issue title using conventional format (e.g., `feat:`, `fix:`, `docs:`)
- [ ] Determine issue type: enhancement, bug, refactor

**Stakeholder Analysis:**

- [ ] Identify who will be affected by this issue (end users, developers, operations)
- [ ] Consider implementation complexity and required expertise

**Content Planning:**

- [ ] Choose appropriate detail level based on issue complexity and audience
- [ ] List all necessary sections for the chosen template
- [ ] Gather supporting materials (error logs, screenshots, design mockups)
- [ ] Prepare code examples or reproduction steps if applicable, name the mock filenames in the lists

### 3. Spec Review Analysis

After planning the issue structure, run the spec reviewer to validate and refine the feature specification:

- `agent spec-reviewer "[feature_description and research_findings]"`

**Spec Reviewer Output:**

- [ ] Review spec-reviewer analysis results
- [ ] Incorporate any identified gaps or edge cases into the issue
- [ ] Update acceptance criteria based on spec-reviewer findings

### 4. Choose Implementation Detail Level

Select how comprehensive you want the issue to be, simpler is mostly better.

#### MINIMAL (Quick Issue)

**Best for:** Simple bugs, small improvements, clear features

**Includes:**

- Problem statement or feature description
- Basic acceptance criteria
- Essential context only

**Structure:**

```markdown
[Brief problem/feature description]

## Acceptance Criteria

- [ ] Core requirement 1
- [ ] Core requirement 2

## Context

[Any critical information]

## MVP

### example_file.ts

[Code example with appropriate language syntax highlighting]

## Design System Reference (if IS_UI_FEATURE)

- **Design System:** `[DESIGN_SYSTEM_PATH]`
- **Components to use:** [list relevant components from design system]
- **Patterns to follow:** [specific patterns relevant to this feature]

## Infrastructure Context (if IS_DEVOPS_FEATURE)

- **IaC Tool:** [OpenTofu/Terraform version]
- **Providers:** [DEVOPS_PROVIDERS list]
- **Skills:** [DEVOPS_SKILLS list]

## References

- Related issue: #[issue_number]
- Documentation: [relevant_docs_url]
```

#### MORE (Standard Issue)

**Best for:** Most features, complex bugs, team collaboration

**Includes everything from MINIMAL plus:**

- Detailed background and motivation
- Technical considerations
- Success metrics
- Dependencies and risks
- Basic implementation suggestions

**Structure:**

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

#### A LOT (Comprehensive Issue)

**Best for:** Major features, architectural changes, complex integrations

**Includes everything from MORE plus:**

- Detailed implementation plan with phases
- Alternative approaches considered
- Extensive technical specifications
- Resource requirements and timeline
- Future considerations and extensibility
- Risk mitigation strategies
- Documentation requirements

**Structure:**

```markdown
## Overview

[Executive summary]

## Problem Statement

[Detailed problem analysis]

## Proposed Solution

[Comprehensive solution design]

## Technical Approach

### Architecture

[Detailed technical design]

### Implementation Phases

#### Phase 1: [Foundation]

- Tasks and deliverables
- Success criteria
- Estimated effort

#### Phase 2: [Core Implementation]

- Tasks and deliverables
- Success criteria
- Estimated effort

#### Phase 3: [Polish & Optimization]

- Tasks and deliverables
- Success criteria
- Estimated effort

## Alternative Approaches Considered

[Other solutions evaluated and why rejected]

## Acceptance Criteria

### Functional Requirements

- [ ] Detailed functional criteria

### Non-Functional Requirements

- [ ] Performance targets
- [ ] Security requirements
- [ ] Accessibility standards

### Quality Gates

- [ ] Test coverage requirements
- [ ] Documentation completeness
- [ ] Code review approval

## Success Metrics

[Detailed KPIs and measurement methods]

## Dependencies & Prerequisites

[Detailed dependency analysis]

## Risk Analysis & Mitigation

[Comprehensive risk assessment]

## Resource Requirements

[Team, time, infrastructure needs]

## Future Considerations

[Extensibility and long-term vision]

## Documentation Plan

[What docs need updating]

## Design System Reference (if IS_UI_FEATURE)

### Design System Location
- **Path:** `[DESIGN_SYSTEM_PATH]`
- **Generated by:** `/majestic:ux-brief`

### Components to Use
| Component | Design System Section | Notes |
|-----------|----------------------|-------|
| [Button variants] | Component Specifications → Buttons | Primary for CTAs, Secondary for cancel |
| [Form inputs] | Component Specifications → Form Inputs | Follow error/success states |
| [Cards] | Component Specifications → Cards | Use bordered variant for lists |
| [Alerts] | Component Specifications → Alerts | Match semantic colors |

### Design Tokens to Apply
- **Colors:** [relevant tokens from Color System section]
- **Typography:** [relevant entries from Type Scale]
- **Spacing:** [relevant values from Spacing System]
- **Border Radius:** [values from Border Radius Scale]

### States to Implement
For each interactive component, implement these states per design system:
- Default, Hover, Focus, Active, Disabled, (Error/Success for forms)

### Do's and Don'ts
[Copy relevant entries from design system Do's and Don'ts section]

## Infrastructure Context (if IS_DEVOPS_FEATURE)

### IaC Overview
- **Tool:** [OpenTofu/Terraform version]
- **Providers:** [DEVOPS_PROVIDERS with versions]
- **State Backend:** [configuration details]
- **Modules:** [existing module structure]

### DevOps Skills to Apply
| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `majestic-devops:opentofu-coder` | HCL patterns, state management | All IaC work |
| `majestic-devops:[provider]-coder` | Provider-specific patterns | Provider resources |
| `majestic-devops:cloud-init-coder` | VM provisioning | New instances |

### Security Audit Results
[Summary from infra-security-review agent]

### Pre-Deploy Checklist
- [ ] Run `infra-security-review` before applying
- [ ] Verify state backend encryption
- [ ] Check for hardcoded secrets
- [ ] Review firewall/security group rules

## References & Research

### Internal References

- Architecture decisions: [file_path:line_number]
- Similar features: [file_path:line_number]
- Configuration: [file_path:line_number]

### External References

- Framework documentation: [url]
- Best practices guide: [url]
- Industry standards: [url]

### Related Work

- Previous PRs: #[pr_numbers]
- Related issues: #[issue_numbers]
- Design documents: [links]
```

### 5. Issue Creation & Formatting

<thinking>
Apply best practices for clarity and actionability, making the issue easy to scan and understand
</thinking>

**Content Formatting:**

- [ ] Use clear, descriptive headings with proper hierarchy (##, ###)
- [ ] Include code examples in triple backticks with language syntax highlighting
- [ ] Add screenshots/mockups if UI-related (drag & drop or use image hosting)
- [ ] Use task lists (- [ ]) for trackable items that can be checked off
- [ ] Add collapsible sections for lengthy logs or optional details using `<details>` tags

**Cross-Referencing:**

- [ ] Link to related issues/PRs using #number format
- [ ] Reference specific commits with SHA hashes when relevant
- [ ] Link to code using GitHub's permalink feature (press 'y' for permanent link)
- [ ] Mention relevant team members with @username if needed
- [ ] Add links to external resources with descriptive text

**Code & Examples:**

```markdown
# Good example with syntax highlighting and line references

# Collapsible error logs

<details>
<summary>Full error stacktrace</summary>

Error details here...

</details>
```

**AI-Era Considerations:**

- [ ] Account for accelerated development with AI pair programming
- [ ] Include prompts or instructions that worked well during research
- [ ] Note which AI tools were used for initial exploration (Claude, Copilot, etc.)
- [ ] Emphasize comprehensive testing given rapid implementation
- [ ] Document any AI-generated code that needs human review

### 6. Final Review & Submission

**Pre-submission Checklist:**

- [ ] Title is searchable and descriptive
- [ ] Labels accurately categorize the issue
- [ ] All template sections are complete
- [ ] Links and references are working
- [ ] Acceptance criteria are measurable
- [ ] Add names of files in pseudo code examples and todo lists
- [ ] Add an ERD mermaid diagram if applicable for new model changes

## Output Format

Write the plan to `docs/plans/<plan_filename>.md` where:
- `<plan_filename>` = `[YYYYMMDDHHMMSS]_<issue_title>`
- Example: `docs/plans/20250115143022_feat-add-user-authentication.md`

## Post-Generation Options

After writing the plan file, execute these steps IN ORDER:

### Step 1: Read Config and Execute Auto-Actions

Read config values:
- Auto preview: !`claude -p "/majestic:config auto_preview false"`
- Auto create task: !`claude -p "/majestic:config auto_create_task false"`
- Task management: !`claude -p "/majestic:config task_management none"`

#### Auto-Preview Action

**IF auto_preview = "true":**
1. Execute: `open docs/plans/<plan_filename>.md`
2. Tell user: "✓ Opened plan in your editor."
3. Set: PREVIEWED = true

**ELSE:** Set PREVIEWED = false

#### Auto-Create Task Action

**IF auto_create_task = "true" AND task_management != "none":**

1. Create task:

   | Backend | Command |
   |---------|---------|
   | `github` | `gh issue create --title "<plan title>" --body-file "docs/plans/<plan_filename>.md"` |
   | `beads` | `bd create "<plan title>" --description "See docs/plans/<plan_filename>.md"` |
   | `linear` | `linear issue create --title "<plan title>" --description "$(cat docs/plans/<plan_filename>.md)"` |

2. Tell user: "✓ Task created: <link or reference>"
3. Set: TASK_CREATED = true, TASK_REF = <reference>

**ELSE:** Set TASK_CREATED = false

### Step 2: Present Options Based on State

Use **AskUserQuestion tool** with the option set matching your state:

**Question:** "Plan ready at `docs/plans/<plan_filename>.md`. What would you like to do next?"

---

**IF TASK_CREATED = true:** (task was auto-created)

| Option | Description |
|--------|-------------|
| Start building (Recommended) | Run `/majestic:build-task <TASK_REF>` |
| Get review | Get feedback from plan-review agent |
| Revise | Change approach or request specific changes |

---

**IF TASK_CREATED = false AND PREVIEWED = true:** (previewed but no task)

| Option | Description |
|--------|-------------|
| Start building (Recommended) | Run `/majestic:build-task` (uses plan file) |
| Create task | Add to your task system, then build from task |
| Get review | Get feedback from plan-review agent |
| Revise | Change approach or request specific changes |

---

**IF TASK_CREATED = false AND PREVIEWED = false:** (neither previewed nor task created)

| Option | Description |
|--------|-------------|
| Preview in editor | Open the plan file |
| Start building (Recommended) | Run `/majestic:build-task` (uses plan file) |
| Create task | Add to your task system, then build from task |
| Get review | Get feedback from plan-review agent |

---

### Step 3: Handle User Selection

| Selection | Action |
|-----------|--------|
| Preview | Execute `open docs/plans/<plan_filename>.md`, then re-present options with PREVIEWED = true |
| Start building | Run `/majestic:build-task docs/plans/<plan_filename>.md` or `/majestic:build-task <TASK_REF>` |
| Create task | Create task (see Task Creation), report link, re-present options with TASK_CREATED = true |
| Get review | Run plan-review agent on the plan file |
| Revise | Ask "What would you like changed?" then regenerate |

## Task Creation

When creating a task (manual or auto):

| Backend | Command | Returns |
|---------|---------|---------|
| `github` | `gh issue create --title "..." --body-file "..."` | `#123` + URL |
| `beads` | `bd create "..." --description "..."` | `PROJ-123` |
| `linear` | `linear issue create --title "..." --description "..."` | `LIN-123` + URL |
| `file` | Write to `docs/tasks/<slug>.md` | File path |

**If `task_management` not configured:** Ask user which system, recommend adding to `.agents.yml`:
```yaml
task_management: github  # Options: github, beads, linear, file
auto_create_task: true   # Optional: auto-create tasks from plans
```

## Reasoning Approaches

- **Analytical:** Break down complex features into manageable components
- **User-Centric:** Consider end-user impact and experience
- **Technical:** Evaluate implementation complexity and architecture fit
- **Strategic:** Align with project goals and roadmap

This is a planning-only command. Don't write implementation code - just research and write the plan.
