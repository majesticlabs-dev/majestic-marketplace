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

### 1. Repository Research & Context Gathering

<thinking>
First, I need to understand the project's conventions and existing patterns, leveraging all available resources and use parallel subagents to do this.
</thinking>

Run these agents in parallel at the same time:

- `agent git-researcher "[feature_description]"` - analyze repository patterns and history
- `agent docs-researcher "[feature_description]"` - fetch library/framework documentation
- `agent best-practices-researcher "[feature_description]"` - research external best practices

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

Write the plan to `docs/plans/<issue_title>.md`

## Post-Generation Options

After writing the plan file:

### 1. Auto-Preview Check (REQUIRED)

**BEFORE presenting options, you MUST:**

1. Invoke `config-reader` agent to get merged config (base + local overrides)
2. Check the returned config for `auto_preview: true`
3. **If auto_preview is true:**
   - Execute: `open docs/plans/<issue_title>.md`
   - Tell user: "Opened plan in your editor."
   - Use the "auto-previewed" options below
4. **If false or not found:** Use the "not auto-previewed" options below

### 2. Present Options

Use **AskUserQuestion tool** to present options:

**Question:** "Plan ready at `docs/plans/<issue_title>.md`. What would you like to do next?"

**Options (if NOT auto-previewed):**
1. **Preview in editor** - Open the plan file (`open <path>`)
2. **Start building (Recommended)** - Begin implementing this plan
3. **Get review** - Get feedback from reviewers
4. **Create backlog item** - Add to your configured task system

**Options (if auto-previewed):**
1. **Start building (Recommended)** - Begin implementing this plan
2. **Get review** - Get feedback from reviewers
3. **Create backlog item** - Add to your configured task system
4. **Revise** - Change approach or request specific changes

Based on selection:
- **Preview in editor** → Run `open docs/plans/<issue_title>.md`, then re-present options
- **Start building** → Begin implementation using the plan
- **Get review** → Run plan-review agent on the plan file
- **Create backlog item** → Invoke `backlog-manager` skill (see Backlog Integration below)
- **Revise** → Ask "What would you like changed?" then regenerate with changes
- **Other** (automatically provided) → Accept free text, act on it

Loop back to options after Revise until user selects to build or review.

## Backlog Integration

When user selects "Create backlog item":

1. **Check for configuration** in project's CLAUDE.md for `backend:` setting
2. **If configured** → Invoke `skill backlog-manager` to create the item using their preferred backend
3. **If not configured** → Ask user which system they use and recommend adding to CLAUDE.md:

   ```markdown
   ## Task Management
   backend: github  # Options: files, github, linear, beads
   ```

   Then proceed with their selection.

## Reasoning Approaches

- **Analytical:** Break down complex features into manageable components
- **User-Centric:** Consider end-user impact and experience
- **Technical:** Evaluate implementation complexity and architecture fit
- **Strategic:** Align with project goals and roadmap

This is a planning-only command. Don't write implementation code - just research and write the plan.
