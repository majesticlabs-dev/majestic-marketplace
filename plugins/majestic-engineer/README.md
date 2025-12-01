# Majestic Engineer

Language-agnostic engineering workflows. Includes 18 specialized agents, 11 commands, and 13 skills.

## Installation

```bash
claude /plugin install majestic-engineer
```

## Recommended Workflow

```mermaid
graph LR
    A0(/guided-prd) --> A(/prd)
    A --> B{{architect}}
    B --> C{{plan-review}}
    C --> D[Build]
    D --> E{{test-create}}
    E --> F{{ship}}
```

| Step | Tool | Purpose |
|------|------|---------|
| 1 | `/majestic-engineer:workflows:prd` | Define requirements (WHAT & WHY) |
| 2 | `agent plan:architect` | Design implementation (HOW) |
| 3 | `agent plan:plan-review` | Validate before coding |
| 4 | Implementation | Write the code |
| 5 | `agent qa:test-create` | Write tests |
| 6 | `agent qa:security-review` | Security audit |
| 7 | `/majestic-engineer:git:commit` + `git:create-pr` | Ship it |

> **Note:** For Rails projects, use `/majestic-rails:workflows:build` for implementation.

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Analyze a spec for gaps | `agent plan:spec-reviewer` |
| Define what to build (requirements) | `/majestic-engineer:workflows:prd` |
| Design how to build it (architecture) | `agent plan:architect` |
| Plan a refactoring effort | `agent plan:refactor-plan` |
| Review a plan before implementing | `agent plan:plan-review` |

## Agents

Invoke with: `agent majestic-engineer:<category>:<name>`

### design

| Agent | Description |
|-------|-------------|
| `design:ui-ux-designer` | Iterative UI/UX refinement through screenshots and progressive improvements |

### plan

| Agent | Description |
|-------|-------------|
| `plan:architect` | Design non-trivial features, system architecture planning |
| `plan:plan-review` | Thorough review of development plans before implementation |
| `plan:refactor-plan` | Analyze code structure and create comprehensive refactoring plans |
| `plan:spec-reviewer` | Analyze specs and plans for user flows, gaps, and missing requirements |

### qa

| Agent | Description |
|-------|-------------|
| `qa:security-review` | OWASP Top 10 vulnerability scanning, secrets detection |
| `qa:test-create` | Automated test creation across frameworks (RSpec, Minitest, Jest) |
| `qa:test-reviewer` | Review test quality, coverage, edge cases, and assertion quality |
| `qa:visual-validator` | Verify UI changes achieved their goals through skeptical visual analysis |

### research

| Agent | Description |
|-------|-------------|
| `research:best-practices-researcher` | Research external best practices and documentation with structured citations |
| `research:docs-architect` | Create comprehensive technical documentation from codebases |
| `research:docs-researcher` | Fetch and summarize library documentation |
| `research:git-researcher` | Analyze git history, trace code evolution, and identify contributor expertise |
| `research:repo-analyst` | Repository onboarding - analyze structure, conventions, templates, and patterns |
| `research:web-research` | Internet research for debugging, finding solutions, and technical problems |

### workflow

| Agent | Description |
|-------|-------------|
| `workflow:always-works-verifier` | Verify implementations actually work before declaring completion |
| `workflow:github-resolver` | Resolve CI failures and PR review comments (auto-detects project type) |
| `workflow:ship` | Complete shipping workflow: lint, commit, PR |

## Commands

Invoke with: `/majestic-engineer:<category>:<name>`

### git

| Command | Description |
|---------|-------------|
| `git:changelog` | Create engaging changelogs from recent merges |
| `git:commit` | Create git commit with proper message formatting |
| `git:create-pr` | Create a pull request for the current feature branch |
| `git:pr-review` | Review and address Pull Request comments from GitHub |

### session

| Command | Description |
|---------|-------------|
| `session:handoff` | Create a detailed handoff plan for continuing work |
| `session:pickup` | Resume work from a previous handoff session |

### workflows

| Command | Description |
|---------|-------------|
| `workflows:debug` | Debug errors, test failures, or unexpected behavior (auto-detects project type) |
| `workflows:guided-prd` | Discover and refine a product idea through guided questioning, then generate a PRD |
| `workflows:prd` | Create a Product Requirements Document (PRD) for a new product or feature |
| `workflows:question` | Answer questions about project structure without coding |
| `workflows:ship-it` | Complete checkout workflow - runs linting, creates commit, and opens PR |

## Skills

Invoke with: `skill majestic-engineer:<name>`

| Skill | Description |
|-------|-------------|
| `ast-grep-searching` | Structural code search and AST-based pattern matching for safe refactoring |
| `backlog-manager` | Manage project backlogs and task prioritization |
| `check-ci` | Monitor PR CI checks by polling GitHub status |
| `create-adr` | Create Architecture Decision Records for significant technical decisions |
| `fix-reporter` | Capture solved problems as categorized documentation with YAML frontmatter |
| `frontend-design` | Create distinctive, production-grade frontend interfaces for Tailwind, React, Vue, and Rails/Hotwire |
| `git-worktree` | Manage git worktrees for parallel development |
| `hierarchical-agents` | Generate hierarchical AGENTS.md structure for codebases |
| `mermaid-builder` | Create syntactically correct Mermaid diagrams |
| `ripgrep-search` | Fast, intelligent code and text searching with ripgrep |
| `subagent-driven-development` | Execute plans with fresh subagent per task and code review between tasks |
| `tdd-workflow` | Test-driven development using red-green-refactor cycle |
| `web-browser` | Browser automation via Chrome DevTools Protocol |

## Configuration

### Task Management

The `backlog-manager` skill supports multiple backends:

| Backend | Choose When |
|---------|-------------|
| **Files** | Solo/small projects, want git-tracked todos, no external dependencies |
| **GitHub** | Already using GitHub Issues, team collaboration, want PR/issue linking |
| **Linear** | Already using Linear, sprint planning, need project management features |
| **Beads** | Dependency-aware workflows, AI agent coordination, need blocking/ready tracking |

Configure in your project's CLAUDE.md:

```markdown
## Task Management
backend: github  # Options: files, github, linear, beads
```

### External Dependencies

| Tool | Required For | Installation |
|------|--------------|--------------|
| [beads](https://github.com/steveyegge/beads) | `backlog-manager` beads backend | `curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh \| bash` |

## Usage Examples

```bash
# Create a PRD for a new feature
/majestic-engineer:workflows:prd "Mobile app for tracking fitness goals"

# Design implementation based on PRD
agent majestic-engineer:plan:architect "Design user authentication system"

# Create commit and PR
/majestic-engineer:git:commit
/majestic-engineer:git:create-pr

# Monitor CI (using skill)
skill majestic-engineer:check-ci

# Use git-worktree skill for parallel development
skill majestic-engineer:git-worktree
```
