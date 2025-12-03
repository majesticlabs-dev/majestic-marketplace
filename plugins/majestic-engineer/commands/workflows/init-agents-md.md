---
name: majestic:init-agents-md
description: Initialize AGENTS.md with hierarchical structure and create CLAUDE.md symlink
allowed-tools: AskUserQuestion, Skill, Bash, Write, Read, Grep, Glob
---

# Initialize AGENTS.md

Set up hierarchical AI agent documentation for this project with task management configuration.

## AGENTS.md Best Practices

Before generating, understand these critical principles:

### The Stateless Reality

LLMs begin every session with zero codebase knowledge. AGENTS.md is the primary onboarding mechanism - it must be concise and high-signal.

### Root File Constraints

| Constraint | Reason |
|------------|--------|
| **Under 300 lines** | Ideally 60-100 for simple projects |
| **~150 instruction limit** | Claude Code's system prompt uses ~50, leaving ~100-150 for you |
| **Universal rules only** | Non-universal instructions get ignored ("only if highly relevant") |
| **No style policing** | Use linters/hooks, not agent instructions |

### The WHAT/WHY/HOW Framework

Structure the root AGENTS.md with these sections:

```markdown
# Project Name

## WHAT (Architecture)
- Tech stack, project structure
- Major directories and their purpose
- Especially important for monorepos

## WHY (Purpose)
- What this project does
- Functional divisions
- Where to find relevant code

## HOW (Workflows)
- Essential commands (build, test, lint)
- Verification procedures
- Task management system
```

### Progressive Disclosure

- **Root file**: Only universal, always-applicable guidance
- **Sub-folder AGENTS.md**: Detailed patterns, examples, technology-specific conventions
- **Nearest-wins**: Agents read the closest AGENTS.md to the file being edited

### Manual Refinement Required

The generated output is a **starting point**, not a final product. You must:
- Review and trim unnecessary content
- Verify line count stays under 300
- Remove any instructions that aren't universally applicable
- Move specific patterns to sub-folder AGENTS.md files

## Step 1: Generate Hierarchical AGENTS.md

Invoke the hierarchical-agents skill to analyze the codebase:

```
skill hierarchical-agents
```

Follow the skill's complete process:
1. Repository Analysis
2. Generate Root AGENTS.md (keep under 300 lines!)
3. Generate Sub-Folder AGENTS.md files (if applicable)
4. Quality verification

**After generation, verify line count:**
```bash
wc -l AGENTS.md
```

If over 300 lines, move detailed content to sub-folder files.

## Step 2: Choose Configuration Level

Use `AskUserQuestion` to ask:

**Question:** "What level of AGENTS.md configuration do you need?"

**Options:**
1. **Basic** - WHAT/WHY/HOW + Task Management only
2. **Advanced** - Add Tool Preferences, Thinking Triggers, Subagent Triggers
3. **Full** - Add Communication Style and custom sections

## Step 3: Task Management Configuration

Use `AskUserQuestion` to ask about task management:

**Question:** "What task management system do you use for this project?"

**Options:**
1. **GitHub Issues** - Track tasks directly in GitHub
2. **Linear** - Use Linear for issue tracking
3. **Beads** - Use Beads task management
4. **File-based** - Track tasks in local markdown files (docs/backlog/)
5. **None** - No task management integration needed

## Step 4: Application Status Configuration

Use `AskUserQuestion` to ask about the application's lifecycle stage:

**Question:** "What is the application's current status?"

**Options:**
1. **Development** - Pre-production, no users yet, breaking changes acceptable
2. **Production** - Live users, backward compatibility required

Add the Application Status section immediately after the project title in AGENTS.md:

#### Development:
```markdown
## Application Status: DEVELOPMENT

- **Stage**: Pre-production, active development
- **Users**: None yet (no existing data to migrate)
- **Backward Compatibility**: NOT required - breaking changes are acceptable
- **Data Migrations**: Keep simple - no need to handle existing records
```

#### Production:
```markdown
## Application Status: PRODUCTION

- **Stage**: Live application with real users
- **Users**: Existing data must be preserved
- **Backward Compatibility**: REQUIRED - no breaking changes
- **Data Migrations**: Must handle existing records gracefully
```

## Step 5: Add Sections Based on Configuration Level

### Basic Level - Task Management Only

Append to the **HOW** section:

#### GitHub Issues:
```markdown
### Task Management
- System: GitHub Issues
- Create: `backlog add "task"` or via GitHub UI
- Reference: `#issue-number` in commits
```

#### Linear:
```markdown
### Task Management
- System: Linear
- Create: `backlog add "task"` or via Linear UI
- Reference: Issue ID in commits
```

#### Beads:
```markdown
### Task Management
- System: Beads
- Create: `backlog add "task"`
```

#### File-based:
```markdown
### Task Management
- System: File-based (`docs/backlog/`)
- Create: `backlog add "task"`
```

#### None:
```markdown
### Task Management
- Not configured
```

### Advanced Level - Add These Sections

If user selected **Advanced** or **Full**, detect available skills and add:

**Skill Detection:** Check the `Skill` tool's `<available_skills>` section in the system prompt to see which skills are installed. Common skills to look for:
- `majestic-engineer:ripgrep-search` - Fast text/code search
- `majestic-engineer:ast-grep-searching` - Structural code search and refactoring

**Template (customize based on detected skills):**

```markdown
### Tool Preferences
1. **Read/Edit** over bash cat/sed for file operations
2. **`skill ripgrep-search`** for text/code search patterns (if available)
3. **`skill ast-grep-searching`** for structural code search and refactoring (if available)
4. **Task (subagent)** for complex exploration and multi-file analysis
5. **Bash** for git, running tests/builds, system commands

### Extended Thinking Triggers
Use for: architecture decisions, debugging after initial failures, multi-file refactors, complex PR reviews
Skip for: simple CRUD, obvious bug fixes, file reads, running commands

### Subagent Triggers
Spawn when: exploring unfamiliar codebases, parallel investigations, fully describable independent tasks, deep research with summary needed
Do yourself when: simple sequential work, loaded context, tight feedback loops, immediate file edit feedback
```

### Full Level - Add Communication Style

If user selected **Full**, also ask:

**Question:** "How should Claude communicate with you?"

**Options:**
1. **Direct** - Terse, no fluff, execute don't explain
2. **Balanced** - Clear explanations with concise execution
3. **Detailed** - Thorough explanations and reasoning
4. **Sparring Partner** - Challenge assumptions, disagree when warranted

Then add:

```markdown
### Communication Style
- Mode: [selected style]
- [Additional preferences based on selection]
```

## Step 6: Create CLAUDE.md Symlink

```bash
ln -s AGENTS.md CLAUDE.md
```

**If CLAUDE.md exists**, ask user:
1. **Merge** - Append existing content to AGENTS.md, then symlink
2. **Replace** - Backup to CLAUDE.md.bak, then symlink
3. **Skip** - Leave as-is (not recommended)

## Step 7: Final Verification

```bash
# Check line count (should be under 300)
wc -l AGENTS.md

# Verify symlink
ls -la CLAUDE.md
readlink CLAUDE.md
```

## Output Summary

Report to user:
- AGENTS.md created with WHAT/WHY/HOW structure
- Configuration level: [Basic/Advanced/Full]
- Application status: [Development/Production]
- Line count: X lines (warn if over 300)
- Task management: [selected system]
- CLAUDE.md symlink: created/merged/skipped
- Sub-folder files: list any created
- **Reminder:** Review and manually refine the generated content
