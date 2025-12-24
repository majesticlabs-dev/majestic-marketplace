---
name: majestic:init
description: Initialize AGENTS.md with hierarchical structure and .agents.yml config
allowed-tools: Bash, Write, Read, Grep, Glob
---

# Initialize AGENTS.md

Set up AI agent documentation and machine-readable config for this project.

## Architecture

- **AGENTS.md** - Human-readable guidance (WHAT/WHY/HOW)
- **.agents.yml** - Machine-readable config for commands
- **CLAUDE.md** - Symlink to AGENTS.md

## Helper Scripts

This command uses helper scripts in `init/` directory:

| Script | Purpose |
|--------|---------|
| `detect-versions.sh` | Auto-detect Ruby, Rails, Python, Node versions |
| `detect-branch.sh` | Detect default git branch |
| `detect-tech-stack.sh` | Detect tech stack from project files |
| `gitignore-add.sh` | Add entries to .gitignore idempotently |
| `check-existing.sh` | Check for existing AGENTS.md/CLAUDE.md |
| `verify-setup.sh` | Verify setup completion |

## AGENTS.md Best Practices

### Constraints

| Constraint | Reason |
|------------|--------|
| **Under 300 lines** | Ideally 60-100 for simple projects |
| **~100 usable instructions** | Claude's ~150 limit minus ~50 system prompt |
| **Universal rules only** | Claude is told context "may or may not be relevant" - non-universal = ignored |
| **No config data** | Config belongs in `.agents.yml` |
| **Manual > auto-generated** | Hand-crafted instructions get more leverage |

### The WHAT/WHY/HOW Framework

```markdown
# Project Name

Load config: @.agents.yml

Ask more questions until you have enough context to give an accurate & confident answer.

## WHAT (Architecture)
- Tech stack, project structure
- Major directories and their purpose

## WHY (Purpose)
- What this project does
- Where to find relevant code

## HOW (Workflows)
- Essential commands (build, test, lint)
- Verification procedures
```

## Step 1: Generate Hierarchical AGENTS.md Structure

**CRITICAL:** This step generates the entire hierarchical AGENTS.md structure. Do NOT proceed to Step 2 until this is complete.

### 1.0 Check Existing State (For Existing Codebases)

First, check what already exists:

```bash
./init/check-existing.sh
```

**If AGENTS.md already exists**, use `AskUserQuestion`:
- **Regenerate** - Create fresh hierarchical structure (backs up existing)
- **Enhance** - Keep existing root, add sub-folder AGENTS.md files
- **Skip** - Keep existing, move to .agents.yml configuration only

If user chooses **Regenerate**, backup first:
```bash
mv AGENTS.md AGENTS.md.backup
```

If user chooses **Enhance** or **Regenerate**, continue with 1.1. If **Skip**, jump to Step 2.

### 1.1 Invoke the Hierarchical Agents Skill

```
skill hierarchical-agents
```

### 1.2 Complete ALL Skill Phases

The skill has 4 phases that MUST all be completed:

1. **Phase 1: Repository Analysis** - Analyze codebase structure, identify major directories
2. **Phase 2: Generate Root AGENTS.md** - Create lightweight root file (under 200 lines)
3. **Phase 3: Generate Sub-Folder AGENTS.md files** - Create detailed files for each major package/directory
4. **Phase 4: Apply Special Considerations** - Adapt for specific package types

**Do NOT skip any phase.** The skill provides templates and guidelines - you must actually write the files.

### 1.3 Verify Hierarchical Structure Created

After completing the skill, verify files were created:

```bash
./init/check-existing.sh agents
```

### 1.4 Checkpoint: Confirm Before Proceeding

Before moving to Step 2, confirm:
- [ ] Root AGENTS.md exists (under 200 lines)
- [ ] Sub-folder AGENTS.md files exist for major directories
- [ ] Root contains JIT Index linking to sub-files

**If no sub-folder AGENTS.md files were created**, go back and complete Phase 3 of the skill. Simple projects may only need root AGENTS.md, but most projects benefit from at least one sub-folder file.

## Step 2: Gather Configuration

**IMPORTANT:** You MUST use `AskUserQuestion` to interactively gather configuration from the user. Do NOT assume values or skip questions.

### Flow

1. Ask **Core Questions** (4 questions) in a single AskUserQuestion call
2. Based on tech_stack answer:
   - If **Rails**: Ask Rails-specific questions (6 questions)
   - If **Python**: Ask Python-specific questions (3 questions)
   - If **Node**: Ask Node-specific questions (6 questions)
   - If **Generic**: Skip to Final Questions
3. Ask **Final Questions** (3 questions) in a single AskUserQuestion call

### Core Questions (Ask First)

Use a single `AskUserQuestion` call with these 4 questions:

#### Question 1: Tech Stack
**Question:** "What is the primary tech stack?"
**Options:**
1. **Rails** - Ruby on Rails
2. **Python** - Python (FastAPI, Django, etc.)
3. **Node** - JavaScript/TypeScript (React, Next.js, Express, etc.)
4. **Generic** - Other or auto-detect

#### Question 2: App Status
**Question:** "What is the application's current status?"
**Options:**
1. **Development** - Pre-production, breaking changes OK
2. **Production** - Live users, backward compatibility required

#### Question 3: Task Management
**Question:** "What task management system do you use?"
**Options:**
1. **GitHub Issues**
2. **Linear**
3. **Beads**
4. **File-based** (docs/backlog/)

#### Question 4: Workflow
**Question:** "How do you prefer to work on features?"
**Options:**
1. **Worktrees** - Isolated directories per feature
2. **Branches** - Traditional feature branches

### Rails-Specific Questions (If Rails Selected)

Auto-detect versions first, then ask remaining questions in two `AskUserQuestion` calls (max 4 questions each):

```bash
./init/detect-versions.sh ruby
./init/detect-versions.sh rails
```

**First AskUserQuestion call (4 questions):**

#### Question R1: Database
**Question:** "What database are you using?"
**Options:**
1. **SQLite** - Default Rails 8 database
2. **PostgreSQL** - Production-ready relational DB
3. **MySQL** - Alternative relational DB

#### Question R2: Frontend
**Question:** "What frontend approach?"
**Options:**
1. **Hotwire** - Turbo + Stimulus (Rails default)
2. **Inertia** - React/Vue/Svelte with Rails backend
3. **API-only** - JSON API, separate frontend

#### Question R3: CSS Framework
**Question:** "What CSS framework?"
**Options:**
1. **Tailwind** - Utility-first CSS
2. **Bootstrap** - Component framework
3. **None** - Custom CSS only

#### Question R4: JavaScript Strategy
**Question:** "How do you manage JavaScript?"
**Options:**
1. **Importmap** - Rails 8 default, no bundler
2. **esbuild** - Fast JS bundler
3. **Vite** - Modern dev server + bundler

**Second AskUserQuestion call (2 questions):**

#### Question R5: Deployment (multiSelect: true)
**Question:** "What deployment tools do you use?"
**Options:**
1. **Kamal** - Docker-based deployment
2. **Fly.io** - Platform-as-a-service
3. **Heroku** - Classic PaaS
4. **Render** - Modern PaaS

#### Question R6: Rails 8 Extras (multiSelect: true)
**Question:** "Which Solid gems are you using?"
**Options:**
1. **Solid Cache** - Database-backed caching
2. **Solid Queue** - Database-backed job queue
3. **Solid Cable** - Database-backed Action Cable

### Python-Specific Questions (If Python Selected)

Auto-detect framework first, then ask all 3 questions in a single `AskUserQuestion` call:

```bash
./init/detect-versions.sh python
./init/detect-tech-stack.sh python-fw
```

**Single AskUserQuestion call (3 questions):**

#### Question P1: Framework
**Question:** "What Python framework?"
**Options:**
1. **FastAPI** - Modern async API framework
2. **Django** - Full-stack web framework
3. **Flask** - Lightweight microframework
4. **None** - Library or CLI tool

#### Question P2: Package Manager
**Question:** "What package manager?"
**Options:**
1. **uv** - Fast modern package manager
2. **Poetry** - Dependency management
3. **pip** - Standard pip + requirements.txt

#### Question P3: Database
**Question:** "What database?"
**Options:**
1. **PostgreSQL** - Production relational DB
2. **SQLite** - Lightweight local DB
3. **None** - No database

### Node-Specific Questions (If Node Selected)

Auto-detect first:

```bash
./init/detect-versions.sh node
./init/detect-tech-stack.sh typescript
./init/detect-tech-stack.sh node-fw
```

**First AskUserQuestion call (4 questions):**

#### Question N1: Framework
**Question:** "What framework are you using?"
**Options:**
1. **Next.js** - React framework with SSR/SSG
2. **React** - React SPA (Vite, CRA)
3. **Vue/Nuxt** - Vue ecosystem
4. **Express/Fastify** - Node.js backend

#### Question N2: Package Manager
**Question:** "What package manager?"
**Options:**
1. **pnpm** - Fast, disk-efficient
2. **npm** - Node default
3. **yarn** - Classic alternative
4. **bun** - All-in-one toolkit

#### Question N3: TypeScript
**Question:** "Are you using TypeScript?"
**Options:**
1. **Yes** - TypeScript enabled
2. **No** - JavaScript only

#### Question N4: Styling
**Question:** "What styling approach?"
**Options:**
1. **Tailwind** - Utility-first CSS
2. **CSS Modules** - Scoped CSS files
3. **Styled Components** - CSS-in-JS
4. **Sass** - CSS preprocessor

**Second AskUserQuestion call (2 questions):**

#### Question N5: Testing
**Question:** "What testing tools?"
**Options:**
1. **Vitest** - Vite-native testing
2. **Jest** - Classic test runner
3. **Playwright** - E2E testing
4. **Cypress** - E2E testing

#### Question N6: Deployment
**Question:** "What deployment platform?"
**Options:**
1. **Vercel** - Next.js optimized
2. **Cloudflare** - Edge workers/pages
3. **Netlify** - JAMstack hosting
4. **Railway** - Container platform

### Final Questions (Ask All Users)

Use a single `AskUserQuestion` call with these 3 questions:

#### Question F1: Branch Naming
**Question:** "What branch naming convention?"
**Options:**
1. **feature/desc** - e.g., `feature/add-auth`
2. **issue-desc** - e.g., `42-add-auth`
3. **type/issue-desc** - e.g., `feat/42-add-auth`
4. **user/desc** - e.g., `david/add-auth`

#### Question F2: Review Topics
**Question:** "Where should code review topics be stored?"
**Options:**
1. **Default** - `docs/agents/review-topics.md`
2. **Skip** - Don't configure now

#### Question F3: Track in Git?
**Question:** "Should `.agents.yml` be tracked in git?"
**Options:**
1. **Yes** - Shared config for team
2. **No** - Local-only (add to .gitignore)

#### Question F4: Local Overrides (Conditional)
**Condition:** Only ask if F3 answer was "Yes" (tracked in git)
**Question:** "Do you want personal config overrides?"
**Options:**
1. **Yes** - Create `.agents.local.yml` with examples (auto-added to .gitignore)
2. **No** - Skip, use team config only

#### Question F5: Browser Preference
**Question:** "What browser do you use for development? (for web-browser skill)"
**Options:**
1. **Chrome** - Google Chrome (default, no config needed)
2. **Brave** - Brave browser
3. **Edge** - Microsoft Edge
4. **Skip** - Don't configure now

## Step 3: Auto-Detect Values

### Default Branch

```bash
./init/detect-branch.sh
```

### Tech Stack (if Generic selected)

```bash
./init/detect-tech-stack.sh stack
```

### Design System (Auto-Detect)

Search for existing design system files (e.g., `design-system.md` in `docs/` or project root).

- **If found:** Record path in `.agents.yml` under `toolbox.build_task.design_system_path`
- **If not found:** Omit the `toolbox.build_task` section, suggest `/majestic:ux-brief`

## Step 4: Write .agents.yml

Create the config file with ALL gathered values. Use the appropriate template based on tech stack.

### Rails Template

```yaml
# .agents.yml - Project configuration for Claude Code commands
# Generated by /majestic:init

config_version: 1.1
default_branch: main
app_status: development

# Tech Stack
tech_stack: rails
ruby_version: "3.4.1"      # Auto-detected from Gemfile
rails_version: "8.0"        # Auto-detected from Gemfile
database: sqlite            # sqlite | postgres | mysql
frontend: hotwire           # hotwire | inertia | api-only
css: tailwind               # tailwind | bootstrap | none
assets: propshaft           # propshaft | sprockets
js: importmap               # importmap | esbuild | vite
deployment: kamal           # kamal | fly | heroku | render
extras:                     # Rails 8 Solid gems in use
  - solid_cache
  - solid_queue
  - solid_cable

# Workflow
task_management: github
workflow_labels:                  # Issue workflow states
  - backlog                     # New issues (removed when claiming)
  - in-progress                 # Being worked on
  - ready-for-review            # PR opened
  - done                        # Completed
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md

# Auto-actions - Automatic behaviors after command completion
auto_preview: true              # Auto-open plans, PRDs, briefs in editor
auto_create_task: true          # Auto-create task when /majestic:plan completes

# Browser - Configuration for web-browser skill (browser-cdp)
# Uncomment and set if not using Chrome (default)
# browser:
#   type: brave       # chrome | brave | edge
#   debug_port: 9222  # CDP port (default: 9222)

# Toolbox - Build task configuration
# design_system_path: Auto-detected or generated by /majestic:ux-brief
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md  # Remove if no design system

# Quality Gate - Reviewers run during quality checks
# Override: This list replaces defaults. Remove section to use defaults.
quality_gate:
  reviewers:
    - security-review           # OWASP security scanning
    - pragmatic-rails-reviewer  # Rails conventions and patterns
    - performance-reviewer      # N+1 queries, slow operations
    - test-reviewer            # Test coverage and quality
    - project-topics-reviewer  # Custom rules (if review_topics_path set)
    # Optional - uncomment to enable:
    # - dhh-code-reviewer       # Strict DHH/37signals Rails style
    # - data-integrity-reviewer # Migration safety (recommended for production)
    # - codex-reviewer          # External LLM (requires Codex CLI)
    # - gemini-reviewer         # External LLM (requires Gemini API)
```

### Python Template

```yaml
# .agents.yml - Project configuration for Claude Code commands
# Generated by /majestic:init

config_version: 1.1
default_branch: main
app_status: development

# Tech Stack
tech_stack: python
python_version: "3.12"      # Auto-detected from pyproject.toml
framework: fastapi          # fastapi | django | flask | none
package_manager: uv         # uv | poetry | pip
database: postgres          # postgres | sqlite | none

# Workflow
task_management: github
workflow_labels:                  # Issue workflow states
  - backlog                     # New issues (removed when claiming)
  - in-progress                 # Being worked on
  - ready-for-review            # PR opened
  - done                        # Completed
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md

# Auto-actions - Automatic behaviors after command completion
auto_preview: true              # Auto-open plans, PRDs, briefs in editor
auto_create_task: true          # Auto-create task when /majestic:plan completes

# Browser - Configuration for web-browser skill (browser-cdp)
# Uncomment and set if not using Chrome (default)
# browser:
#   type: brave       # chrome | brave | edge
#   debug_port: 9222  # CDP port (default: 9222)

# Toolbox - Build task configuration
# design_system_path: Auto-detected or generated by /majestic:ux-brief
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md  # Remove if no design system

# Quality Gate - Reviewers run during quality checks
# Override: This list replaces defaults. Remove section to use defaults.
quality_gate:
  reviewers:
    - security-review           # OWASP security scanning
    - python-reviewer           # Python conventions and idioms
    - test-reviewer            # Test coverage and quality
    - project-topics-reviewer  # Custom rules (if review_topics_path set)
    # Optional - uncomment to enable:
    # - codex-reviewer          # External LLM (requires Codex CLI)
    # - gemini-reviewer         # External LLM (requires Gemini API)
```

### Node Template

```yaml
# .agents.yml - Project configuration for Claude Code commands
# Generated by /majestic:init

config_version: 1.1
default_branch: main
app_status: development

# Tech Stack
tech_stack: node
node_version: "22"          # Auto-detected from node -v
framework: nextjs           # nextjs | react | vue | nuxt | svelte | express | fastify | none
package_manager: pnpm       # pnpm | npm | yarn | bun
typescript: true            # true | false
styling: tailwind           # tailwind | css-modules | styled-components | sass | none
testing: vitest             # vitest | jest | playwright | cypress | none
deployment: vercel          # vercel | cloudflare | netlify | railway | none

# Workflow
task_management: github
workflow_labels:                  # Issue workflow states
  - backlog                     # New issues (removed when claiming)
  - in-progress                 # Being worked on
  - ready-for-review            # PR opened
  - done                        # Completed
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md

# Auto-actions - Automatic behaviors after command completion
auto_preview: true              # Auto-open plans, PRDs, briefs in editor
auto_create_task: true          # Auto-create task when /majestic:plan completes

# Browser - Configuration for web-browser skill (browser-cdp)
# Uncomment and set if not using Chrome (default)
# browser:
#   type: brave       # chrome | brave | edge
#   debug_port: 9222  # CDP port (default: 9222)

# Toolbox - Build task configuration
# design_system_path: Auto-detected or generated by /majestic:ux-brief
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md  # Remove if no design system

# Quality Gate - Reviewers run during quality checks
# Override: This list replaces defaults. Remove section to use defaults.
quality_gate:
  reviewers:
    - security-review           # OWASP security scanning
    - react-reviewer           # React best practices (if React/Next.js project)
    - test-reviewer            # Test coverage and quality
    - project-topics-reviewer  # Custom rules (if review_topics_path set)
    # Optional - uncomment to enable:
    # - codex-reviewer          # External LLM (requires Codex CLI)
    # - gemini-reviewer         # External LLM (requires Gemini API)
```

### Generic Template

```yaml
# .agents.yml - Project configuration for Claude Code commands
# Generated by /majestic:init

config_version: 1.1
default_branch: main
tech_stack: generic
app_status: development
task_management: github
workflow_labels:                  # Issue workflow states
  - backlog                     # New issues (removed when claiming)
  - in-progress                 # Being worked on
  - ready-for-review            # PR opened
  - done                        # Completed
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md

# Auto-actions - Automatic behaviors after command completion
auto_preview: true              # Auto-open plans, PRDs, briefs in editor
auto_create_task: true          # Auto-create task when /majestic:plan completes

# Browser - Configuration for web-browser skill (browser-cdp)
# Uncomment and set if not using Chrome (default)
# browser:
#   type: brave       # chrome | brave | edge
#   debug_port: 9222  # CDP port (default: 9222)

# Toolbox - Build task configuration
# design_system_path: Auto-detected or generated by /majestic:ux-brief
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md  # Remove if no design system

# Quality Gate - Reviewers run during quality checks
# Override: This list replaces defaults. Remove section to use defaults.
quality_gate:
  reviewers:
    - security-review           # OWASP security scanning
    - test-reviewer            # Test coverage and quality
    - project-topics-reviewer  # Custom rules (if review_topics_path set)
    # Optional - uncomment to enable:
    # - simplicity-reviewer     # Complexity and overengineering
    # - codex-reviewer          # External LLM (requires Codex CLI)
    # - gemini-reviewer         # External LLM (requires Gemini API)
```

### Notes

- Only include `review_topics_path` if user selected Default (not Skip)
- Only include `extras` list if user selected any Solid gems
- Only include `toolbox.build_task.design_system_path` if design system was auto-detected
- If no design system found, comment out or remove the `toolbox.build_task` section
- Auto-detect versions where possible, omit if not found
- If user selected Brave or Edge for browser (F5), uncomment and set `browser.type`; if Chrome or Skip, leave commented

### Gitignore Entries

```bash
# Always add runtime artifact
./init/gitignore-add.sh .claude/current_task.txt

# If user selected "No" for git tracking (F3)
./init/gitignore-add.sh .agents.yml

# If user selected "Yes" for local overrides (F4)
./init/gitignore-add.sh .agents.local.yml
```

Write `.agents.local.yml`:

```yaml
# .agents.local.yml - Personal overrides (not tracked in git)
# Uncomment and modify values you want to override from .agents.yml

# workflow: worktrees        # worktrees | branches
# branch_naming: user/desc   # Override team naming convention

# Auto-actions - Personal preferences for automatic behaviors
# auto_preview: true         # Auto-open plans, PRDs, briefs in editor
# auto_create_task: false    # Disable auto-task creation locally

# Browser - Personal browser preference (for web-browser skill)
# browser:
#   type: brave              # chrome | brave | edge
#   debug_port: 9222         # CDP port (default: 9222)

# Override quality gate reviewers (replaces team list entirely):
# quality_gate:
#   reviewers:
#     - security-review
#     - simplicity-reviewer
```

## Step 5: Update AGENTS.md

Add config reference at the top of AGENTS.md, right after the title:

```markdown
# Project Name

Load config: @.agents.yml
```

Remove any existing config sections from AGENTS.md (tech_stack, review_topics_path, etc.) - all config now lives in `.agents.yml`.

## Step 6: Create Review Topics File

If user selected Default for review topics, create the file:

```bash
mkdir -p docs/agents
```

Write `docs/agents/review-topics.md`:

```markdown
# Code Review Topics

Project-specific topics checked during every code review.

### Example Category
- Example topic to always check
- Another important convention

<!--
Tips:
- Be specific: "API calls need 30s timeout" not "handle errors"
- Focus on project-specific rules, not general best practices
-->
```

## Step 7: Create CLAUDE.md Symlink

```bash
ln -s AGENTS.md CLAUDE.md
```

**If CLAUDE.md exists**, ask:
1. **Replace** - Backup to CLAUDE.md.bak, then symlink
2. **Skip** - Leave as-is

## Step 8: Final Verification

```bash
./init/verify-setup.sh
```

The script checks:
- Root AGENTS.md exists and is under 200 lines
- Sub-folder AGENTS.md files (if any)
- `.agents.yml` exists
- CLAUDE.md symlink points to AGENTS.md
- `.claude/current_task.txt` is in .gitignore

## Output Summary

### Rails Project Example

```
✅ Hierarchical AGENTS.md structure created
   - Root AGENTS.md: X lines (under 200 ✓)
   - Sub-folder files: app/AGENTS.md, lib/AGENTS.md
   - JIT Index with links to sub-files
   - Config reference added

✅ .agents.yml created
   - default_branch: main
   - app_status: development
   - Tech Stack:
     - tech_stack: rails
     - ruby_version: 3.4.1
     - rails_version: 8.0
     - database: sqlite
     - frontend: hotwire
     - css: tailwind
     - js: importmap
     - deployment: kamal
     - extras: solid_cache, solid_queue, solid_cable
   - Toolbox:
     - design_system_path: docs/design/design-system.md (if detected)
   - Workflow:
     - task_management: github
     - workflow: worktrees
     - branch_naming: type/issue-desc
   - Quality Gate:
     - security-review, pragmatic-rails-reviewer, performance-reviewer
     - test-reviewer, project-topics-reviewer

✅ Design system detected (if applicable)
   - Path: docs/design/design-system.md
   - Or: ℹ No design system found. Run /majestic:ux-brief to create one.

✅ CLAUDE.md symlink created

✅ .agents.local.yml created (if requested)
   - Added to .gitignore
   - Contains commented override examples

⚠️  Remember: Review and refine AGENTS.md manually
```

### Python Project Example

```
✅ Hierarchical AGENTS.md structure created
   - Root AGENTS.md: X lines (under 200 ✓)
   - Sub-folder files: src/AGENTS.md
   - JIT Index with links to sub-files
   - Config reference added

✅ .agents.yml created
   - default_branch: main
   - app_status: development
   - Tech Stack:
     - tech_stack: python
     - python_version: 3.12
     - framework: fastapi
     - package_manager: uv
     - database: postgres
   - Workflow:
     - task_management: github
     - workflow: worktrees
     - branch_naming: type/issue-desc
   - Quality Gate:
     - security-review, python-reviewer, test-reviewer, project-topics-reviewer

✅ CLAUDE.md symlink created

⚠️  Remember: Review and refine AGENTS.md manually
```

### Node Project Example

```
✅ Hierarchical AGENTS.md structure created
   - Root AGENTS.md: X lines (under 200 ✓)
   - Sub-folder files: src/AGENTS.md, apps/web/AGENTS.md
   - JIT Index with links to sub-files
   - Config reference added

✅ .agents.yml created
   - default_branch: main
   - app_status: development
   - Tech Stack:
     - tech_stack: node
     - node_version: 22
     - framework: nextjs
     - package_manager: pnpm
     - typescript: true
     - styling: tailwind
     - testing: vitest
     - deployment: vercel
   - Workflow:
     - task_management: github
     - workflow: worktrees
     - branch_naming: type/issue-desc
   - Quality Gate:
     - security-review, react-reviewer, test-reviewer, project-topics-reviewer

✅ CLAUDE.md symlink created

⚠️  Remember: Review and refine AGENTS.md manually
```
