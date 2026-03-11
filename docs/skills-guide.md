# The Complete Guide to Building Skills for Claude

Source: Anthropic official guide (2026). Reference for marketplace skill development.

## Chapter 1: Fundamentals

### What is a skill?

A folder containing:
- **SKILL.md** (required): Instructions in Markdown with YAML frontmatter
- **scripts/** (optional): Executable code (Python, Bash, etc.)
- **references/** (optional): Documentation loaded as needed
- **assets/** (optional): Templates, fonts, icons used in output

### Progressive Disclosure (3 levels)

1. **First level (YAML frontmatter):** Always loaded in Claude's system prompt. Provides just enough information for Claude to know when each skill should be used without loading all of it into context.
2. **Second level (SKILL.md body):** Loaded when Claude thinks the skill is relevant to the current task. Contains the full instructions and guidance.
3. **Third level (Linked files):** Additional files bundled within the skill directory that Claude can choose to navigate and discover only as needed.

This progressive disclosure minimizes token usage while maintaining specialized expertise.

### Core Design Principles

- **Composability:** Claude can load multiple skills simultaneously. Your skill should work well alongside others, not assume it's the only capability available.
- **Portability:** Skills work identically across Claude.ai, Claude Code, and API. Create a skill once and it works across all surfaces without modification, provided the environment supports any dependencies the skill requires.

### For MCP Builders: Skills + Connectors

| MCP (Connectivity) | Skills (Knowledge) |
|---|---|
| Connects Claude to your service (Notion, Asana, Linear, etc.) | Teaches Claude how to use your service effectively |
| Provides real-time data access and tool invocation | Captures workflows and best practices |
| What Claude can do | How Claude should do it |

**Without skills:** Users connect your MCP but don't know what to do next. Inconsistent results because users prompt differently each time.

**With skills:** Pre-built workflows activate automatically when needed. Consistent, reliable tool usage. Best practices embedded in every interaction.

## Chapter 2: Planning and Design

### Start with Use Cases

Before writing any code, identify 2-3 concrete use cases your skill should enable.

Good use case definition:
```
Use Case: Project Sprint Planning
Trigger: User says "help me plan this sprint" or "create sprint tasks"
Steps:
1. Fetch current project status from Linear (via MCP)
2. Analyze team velocity and capacity
3. Suggest task prioritization
4. Create tasks in Linear with proper labels and estimates
Result: Fully planned sprint with tasks created
```

Ask yourself:
- What does a user want to accomplish?
- What multi-step workflows does this require?
- Which tools are needed (built-in or MCP)?
- What domain knowledge or best practices should be embedded?

### Common Skill Use Case Categories

**Category 1: Document & Asset Creation**
- Creating consistent, high-quality output including documents, presentations, apps, designs, code, etc.
- Key techniques: Embedded style guides, template structures, quality checklists, no external tools required

**Category 2: Workflow Automation**
- Multi-step processes that benefit from consistent methodology, including coordination across multiple MCP servers.
- Key techniques: Step-by-step workflow with validation gates, templates for common structures, built-in review and improvement suggestions, iterative refinement loops

**Category 3: MCP Enhancement**
- Workflow guidance to enhance the tool access an MCP server provides.
- Key techniques: Coordinates multiple MCP calls in sequence, embeds domain expertise, provides context users would otherwise need to specify, error handling for common MCP issues

### Define Success Criteria

**Quantitative metrics:**
- Skill triggers on 90% of relevant queries
  - How to measure: Run 10-20 test queries. Track how many times it loads automatically vs. requires explicit invocation.
- Completes workflow in X tool calls
  - How to measure: Compare the same task with and without the skill enabled. Count tool calls and total tokens consumed.
- 0 failed API calls per workflow
  - How to measure: Monitor MCP server logs during test runs. Track retry rates and error codes.

**Qualitative metrics:**
- Users don't need to prompt Claude about next steps
- Workflows complete without user correction
- Consistent results across sessions

### Technical Requirements

#### File Structure

```
your-skill-name/
├── SKILL.md                  # Required - main skill file
├── scripts/                  # Optional - executable code
│   ├── process_data.py
│   └── validate.sh
├── references/               # Optional - documentation
│   ├── api-guide.md
│   └── examples/
└── assets/                   # Optional - templates, etc.
    └── report-template.md
```

#### Critical Rules

**SKILL.md naming:**
- Must be exactly `SKILL.md` (case-sensitive)
- No variations accepted (SKILL.MD, skill.md, etc.)

**Skill folder naming:**
- Use kebab-case: `notion-project-setup`
- No spaces: ~~`Notion Project Setup`~~
- No underscores: ~~`notion_project_setup`~~
- No capitals: ~~`NotionProjectSetup`~~

**No README.md:**
- Don't include README.md inside your skill folder
- All documentation goes in SKILL.md or references/
- Note: when distributing via GitHub, you'll still want a repo-level README for human users

### YAML Frontmatter

The YAML frontmatter is how Claude decides whether to load your skill. Get this right.

**Minimal required format:**
```yaml
---
name: your-skill-name
description: What it does. Use when user asks to [specific phrases].
---
```

#### Field Requirements

**name** (required):
- kebab-case only
- No spaces or capitals
- Should match folder name

**description** (required):
- MUST include BOTH: What the skill does + When to use it (trigger conditions)
- Under 1024 characters
- No XML tags (< or >)
- Include specific tasks users might say
- Mention file types if relevant

**license** (optional):
- Use if making skill open source
- Common: MIT, Apache-2.0

**compatibility** (optional):
- 1-500 characters
- Indicates environment requirements: e.g. intended product, required system packages, network access needs, etc.

**metadata** (optional):
- Any custom key-value pairs
- Suggested: author, version, mcp-server
- Example:
  ```yaml
  metadata:
      author: ProjectHub
      version: 1.0.0
      mcp-server: projecthub
  ```

#### Security Restrictions

**Forbidden in frontmatter:**
- XML angle brackets (< >)
- Skills with "claude" or "anthropic" in name (reserved)

Why: Frontmatter appears in Claude's system prompt. Malicious content could inject instructions.

### Writing Effective Descriptions

**Structure:** `[What it does] + [When to use it] + [Key capabilities]`

**Good examples:**
```yaml
# Good - specific and actionable
description: Analyzes Figma design files and generates developer handoff documentation. Use when user uploads .fig files, asks for "design specs", "component documentation", or "design-to-code handoff".

# Good - includes trigger phrases
description: Manages Linear project workflows including sprint planning, task creation, and status tracking. Use when user mentions "sprint", "Linear tasks", "project planning", or asks to "create tickets".

# Good - clear value proposition
description: End-to-end customer onboarding workflow for PayFlow. Handles account creation, payment setup, and subscription management. Use when user says "onboard new customer", "set up subscription", or "create PayFlow account".
```

**Bad examples:**
```yaml
# Too vague
description: Helps with projects.

# Missing triggers
description: Creates sophisticated multi-page documentation systems.

# Too technical, no user triggers
description: Implements the Project entity model with hierarchical relationships.
```

### Writing the Main Instructions

**Recommended structure:**
```markdown
---
name: your-skill
description: [...]
---

# Your Skill Name

## Instructions

### Step 1: [First Major Step]
Clear explanation of what happens.
```

**Best Practices for Instructions:**

Be Specific and Actionable:
```
# Good
Run `python scripts/validate.py --input {filename}` to check data format.
If validation fails, common issues include:
- Missing required fields (add them to the CSV)
- Invalid date formats (use YYYY-MM-DD)

# Bad
Validate the data before proceeding.
```

Include error handling:
```markdown
## Common Issues

### MCP Connection Failed
If you see "Connection refused":
1. Verify MCP server is running: Check Settings > Extensions
2. Confirm API key is valid
3. Try reconnecting: Settings > Extensions > [Your Service] > Reconnect
```

Reference bundled resources clearly:
```
Before writing queries, consult `references/api-patterns.md` for:
- Rate limiting guidance
- Pagination patterns
- Error codes and handling
```

Use progressive disclosure: Keep SKILL.md focused on core instructions. Move detailed documentation to `references/` and link to it.

### Examples Section

```markdown
## Example 1: [Common scenario]
User says: "Set up a new marketing campaign"

Actions:
1. Fetch existing campaigns via MCP
2. Create new campaign with provided parameters

Result: Campaign created with confirmation link
```

### Troubleshooting Section

```markdown
## Error: [Common error message]
Cause: [Why it happens]
Solution: [How to fix]
```

## Chapter 3: Testing and Iteration

### Testing Approaches

- **Manual testing in Claude.ai** - Run queries directly and observe behavior. Fast iteration, no setup required.
- **Scripted testing in Claude Code** - Automate test cases for repeatable validation across changes.
- **Programmatic testing via skills API** - Build evaluation suites that run systematically against defined test sets.

**Pro Tip:** Iterate on a single task before expanding. The most effective skill creators iterate on a single challenging task until Claude succeeds, then extract the winning approach into a skill.

### Recommended Testing Approach

#### 1. Triggering Tests

Goal: Ensure your skill loads at the right times.

Test cases:
- Triggers on obvious tasks
- Triggers on paraphrased requests
- Doesn't trigger on unrelated topics

Example test suite:
```
Should trigger:
- "Help me set up a new ProjectHub workspace"
- "I need to create a project in ProjectHub"
- "Initialize a ProjectHub project for Q4 planning"

Should NOT trigger:
- "What's the weather in San Francisco?"
- "Help me write Python code"
- "Create a spreadsheet" (unless ProjectHub skill handles sheets)
```

#### 2. Functional Tests

Goal: Verify the skill produces correct outputs.

Test cases:
- Valid outputs generated
- API calls succeed
- Error handling works
- Edge cases covered

Example:
```
Test: Create project with 5 tasks
Given: Project name "Q4 Planning", 5 task descriptions
When: Skill executes workflow
Then:
    - Project created in ProjectHub
    - 5 tasks created with correct properties
    - All tasks linked to project
    - No API errors
```

#### 3. Performance Comparison

Goal: Prove the skill improves results vs. baseline.

Baseline comparison:
```
Without skill:
- User provides instructions each time
- 15 back-and-forth messages
- 3 failed API calls requiring retry
- 12,000 tokens consumed

With skill:
- Automatic workflow execution
- 2 clarifying questions only
- 0 failed API calls
- 6,000 tokens consumed
```

### Using the skill-creator skill

The `skill-creator` skill - available in Claude.ai via plugin directory or download for Claude Code - can help you build and iterate on skills. If you have an MCP server and know your top 2-3 workflows, you can build and test a functional skill in a single sitting - often in 15-30 minutes.

**Creating skills:** Generate skills from natural language descriptions, produce properly formatted SKILL.md with frontmatter, suggest trigger phrases and structure.

**Reviewing skills:** Flag common issues (vague descriptions, missing triggers, structural problems), identify potential over/under-triggering risks, suggest test cases based on the skill's stated purpose.

**Iterative improvement:** After using your skill and encountering edge cases or failures, bring those examples back to skill-creator.

### Iteration Based on Feedback

**Undertriggering signals:**
- Skill doesn't load when it should
- Users manually enabling it
- Support questions about when to use it
- **Solution:** Add more detail and nuance to the description - this may include keywords particularly for technical terms

**Overtriggering signals:**
- Skill loads for irrelevant queries
- Users disabling it
- Confusion about purpose
- **Solution:** Add negative triggers, be more specific

**Execution issues:**
- Inconsistent results
- API call failures
- User corrections needed
- **Solution:** Improve instructions, add error handling

## Chapter 4: Distribution and Sharing

### Current Distribution Model (January 2026)

**How individual users get skills:**
1. Download the skill folder
2. Zip the folder (if needed)
3. Upload to Claude.ai via Settings > Capabilities > Skills
4. Or place in Claude Code skills directory

**Organization-level skills:**
- Admins can deploy skills workspace-wide (shipped December 18, 2025)
- Automatic updates
- Centralized management

### Agent Skills as Open Standard

Anthropic published Agent Skills as an open standard. Like MCP, skills should be portable across tools and platforms - the same skill should work whether you're using Claude or other AI platforms. Authors can note platform-specific capabilities in the `compatibility` field.

### Using Skills via API

For programmatic use cases - such as building applications, agents, or automated workflows that leverage skills - the API provides direct control over skill management and execution.

Key capabilities:
- `/v1/skills` endpoint for listing and managing skills
- Add skills to Messages API requests via the `container.skills` parameter
- Version control and management through the Claude Console
- Works with the Claude Agent SDK for building custom agents

**Note:** Skills in the API require the Code Execution Tool beta, which provides the secure environment skills need to run.

| Use Case | Best Surface |
|---|---|
| End users interacting with skills directly | Claude.ai / Claude Code |
| Manual testing and iteration during development | Claude.ai / Claude Code |
| Individual, ad-hoc workflows | Claude.ai / Claude Code |
| Applications using skills programmatically | API |
| Production deployments at scale | API |
| Automated pipelines and agent systems | API |

### Recommended Distribution Approach

1. **Host on GitHub** - Public repo for open-source skills, clear README with installation instructions, example usage and screenshots
2. **Document in Your MCP Repo** - Link to skills from MCP documentation, explain the value of using both together, provide quick-start guide
3. **Create an Installation Guide**

### Positioning Your Skill

**Focus on outcomes, not features:**

Good: "The ProjectHub skill enables teams to set up complete project workspaces in seconds - including pages, databases, and templates - instead of spending 30 minutes on manual setup."

Bad: "The ProjectHub skill is a folder containing YAML frontmatter and Markdown instructions that calls our MCP server tools."

**Highlight the MCP + skills story:**

"Our MCP server gives Claude access to your Linear projects. Our skills teach Claude your team's sprint planning workflow. Together, they enable AI-powered project management."

## Chapter 5: Patterns and Troubleshooting

### Choosing Your Approach: Problem-first vs. Tool-first

- **Problem-first:** "I need to set up a project workspace" -> Your skill orchestrates the right MCP calls in the right sequence. Users describe outcomes; the skill handles the tools.
- **Tool-first:** "I have Notion MCP connected" -> Your skill teaches Claude the optimal workflows and best practices. Users have access; the skill provides expertise.

### Pattern 1: Sequential Workflow Orchestration

**Use when:** Your users need multi-step processes in a specific order.

```markdown
## Workflow: Onboard New Customer

### Step 1: Create Account
Call MCP tool: `create_customer`
Parameters: name, email, company

### Step 2: Setup Payment
Call MCP tool: `setup_payment_method`
Wait for: payment method verification

### Step 3: Create Subscription
Call MCP tool: `create_subscription`
Parameters: plan_id, customer_id (from Step 1)

### Step 4: Send Welcome Email
Call MCP tool: `send_email`
Template: welcome_email_template
```

Key techniques: Explicit step ordering, dependencies between steps, validation at each stage, rollback instructions for failures.

### Pattern 2: Multi-MCP Coordination

**Use when:** Workflows span multiple services.

```markdown
### Phase 1: Design Export (Figma MCP)
1. Export design assets from Figma
2. Generate design specifications
3. Create asset manifest

### Phase 2: Asset Storage (Drive MCP)
1. Create project folder in Drive
2. Upload all assets
3. Generate shareable links

### Phase 3: Task Creation (Linear MCP)
1. Create development tasks
2. Attach asset links to tasks
3. Assign to engineering team

### Phase 4: Notification (Slack MCP)
1. Post handoff summary to #engineering
2. Include asset links and task references
```

Key techniques: Clear phase separation, data passing between MCPs, validation before moving to next phase, centralized error handling.

### Pattern 3: Iterative Refinement

**Use when:** Output quality improves with iteration.

```markdown
## Iterative Report Creation

### Initial Draft
1. Fetch data via MCP
2. Generate first draft report
3. Save to temporary file

### Quality Check
1. Run validation script: `scripts/check_report.py`
2. Identify issues:
    - Missing sections
    - Inconsistent formatting
    - Data validation errors

### Refinement Loop
1. Address each identified issue
2. Regenerate affected sections
3. Re-validate
4. Repeat until quality threshold met

### Finalization
1. Apply final formatting
2. Generate summary
3. Save final version
```

Key techniques: Explicit quality criteria, iterative improvement, validation scripts, know when to stop iterating.

### Pattern 4: Context-aware Tool Selection

**Use when:** Same outcome, different tools depending on context.

```markdown
## Smart File Storage

### Decision Tree
1. Check file type and size
2. Determine best storage location:
    - Large files (>10MB): Use cloud storage MCP
    - Collaborative docs: Use Notion/Docs MCP
    - Code files: Use GitHub MCP
    - Temporary files: Use local storage

### Execute Storage
Based on decision:
- Call appropriate MCP tool
- Apply service-specific metadata
- Generate access link

### Provide Context to User
Explain why that storage was chosen
```

Key techniques: Clear decision criteria, fallback options, transparency about choices.

### Pattern 5: Domain-specific Intelligence

**Use when:** Your skill adds specialized knowledge beyond tool access.

```markdown
## Payment Processing with Compliance

### Before Processing (Compliance Check)
1. Fetch transaction details via MCP
2. Apply compliance rules:
    - Check sanctions lists
    - Verify jurisdiction allowances
    - Assess risk level
3. Document compliance decision

### Processing
IF compliance passed:
    - Call payment processing MCP tool
    - Apply appropriate fraud checks
    - Process transaction
ELSE:
    - Flag for review
    - Create compliance case

### Audit Trail
- Log all compliance checks
- Record processing decisions
- Generate audit report
```

Key techniques: Domain expertise embedded in logic, compliance before action, comprehensive documentation, clear governance.

### Troubleshooting

#### Skill won't upload

**Error: "Could not find SKILL.md in uploaded folder"**
- Cause: File not named exactly SKILL.md
- Solution: Rename to SKILL.md (case-sensitive). Verify with: `ls -la` should show SKILL.md

**Error: "Invalid frontmatter"**
- Cause: YAML formatting issue
- Common mistakes:
  ```yaml
  # Wrong - missing delimiters
  name: my-skill
  description: Does things

  # Wrong - unclosed quotes
  name: my-skill
  description: "Does things

  # Correct
  ---
  name: my-skill
  description: Does things
  ---
  ```

**Error: "Invalid skill name"**
- Cause: Name has spaces or capitals
  ```yaml
  # Wrong
  name: My Cool Skill

  # Correct
  name: my-cool-skill
  ```

#### Skill doesn't trigger

**Symptom:** Skill never loads automatically.

**Fix:** Revise your description field.

Quick checklist:
- Is it too generic? ("Helps with projects" won't work)
- Does it include trigger phrases users would actually say?
- Does it mention relevant file types if applicable?

**Debugging approach:** Ask Claude: "When would you use the [skill name] skill?" Claude will quote the description back. Adjust based on what's missing.

#### Skill triggers too often

**Symptom:** Skill loads for unrelated queries.

**Solutions:**
1. Add negative triggers:
   ```yaml
   description: Advanced data analysis for CSV files. Use for statistical modeling, regression, clustering. Do NOT use for simple data exploration (use data-viz skill instead).
   ```
2. Be more specific:
   ```yaml
   # Too broad
   description: Processes documents

   # More specific
   description: Processes PDF legal documents for contract review
   ```
3. Clarify scope:
   ```yaml
   description: PayFlow payment processing for e-commerce. Use specifically for online payment workflows, not for general financial queries.
   ```

#### Instructions not followed

**Symptom:** Skill loads but Claude doesn't follow instructions.

**Common causes:**

1. **Instructions too verbose** - Keep instructions concise, use bullet points and numbered lists, move detailed reference to separate files
2. **Instructions buried** - Put critical instructions at the top, use ## Important or ## Critical headers, repeat key points if needed
3. **Ambiguous language:**
   ```
   # Bad
   Make sure to validate things properly

   # Good
   CRITICAL: Before calling create_project, verify:
   - Project name is non-empty
   - At least one team member assigned
   - Start date is not in the past
   ```
4. **Model "laziness"** - Add explicit encouragement:
   ```
   ## Performance Notes
   - Take your time to do this thoroughly
   - Quality is more important than speed
   - Do not skip validation steps
   ```
   Note: Adding this to user prompts is more effective than in SKILL.md

**Advanced technique:** For critical validations, consider bundling a script that performs the checks programmatically rather than relying on language instructions. Code is deterministic; language interpretation isn't.

#### MCP Connection Issues

**Symptom:** Skill loads but MCP calls fail.

**Checklist:**
1. Verify MCP server is connected (Settings > Extensions > [Your Service], should show "Connected" status)
2. Check authentication (API keys valid and not expired, proper permissions/scopes granted, OAuth tokens refreshed)
3. Test MCP independently (Ask Claude to call MCP directly without skill: "Use [Service] MCP to fetch my projects". If this fails, issue is MCP not skill)
4. Verify tool names (Skill references correct MCP tool names, check MCP server documentation, tool names are case-sensitive)

#### Large Context Issues

**Symptom:** Skill seems slow or responses degraded.

**Causes:** Skill content too large, too many skills enabled simultaneously, all content loaded instead of progressive disclosure.

**Solutions:**
1. Optimize SKILL.md size - Move detailed docs to references/, link to references instead of inline, keep SKILL.md under 5,000 words
2. Reduce enabled skills - Evaluate if you have more than 20-50 skills enabled simultaneously, recommend selective enablement, consider skill "packs" for related capabilities

## Chapter 6: Resources and References

### Official Documentation
- Best Practices Guide
- Skills Documentation
- API Reference
- MCP Documentation

### Tools and Utilities

**skill-creator skill:**
- Built into Claude.ai and available for Claude Code
- Can generate skills from descriptions
- Reviews and provides recommendations
- Use: "Help me build a skill using skill-creator"

**Validation:**
- skill-creator can assess your skills
- Ask: "Review this skill and suggest improvements"

### Example Skills

**Public skills repository:** GitHub: anthropic/skills - Contains Anthropic-created skills you can customize.

### Getting Support
- General questions: Community forums at the Claude Developers Discord
- Bug Reports: GitHub Issues: anthropic/skills/issues (include skill name, error message, steps to reproduce)

## Reference A: Quick Checklist

### Before you start
- [ ] Identified 2-3 concrete use cases
- [ ] Tools identified (built-in or MCP)
- [ ] Reviewed this guide and example skills
- [ ] Planned folder structure

### During development
- [ ] Folder named in kebab-case
- [ ] SKILL.md file exists (exact spelling)
- [ ] YAML frontmatter has --- delimiters
- [ ] name field: kebab-case, no spaces, no capitals
- [ ] description includes WHAT and WHEN
- [ ] No XML tags (< >) anywhere
- [ ] Instructions are clear and actionable
- [ ] Error handling included
- [ ] Examples provided
- [ ] References clearly linked

### Before upload
- [ ] Tested triggering on obvious tasks
- [ ] Tested triggering on paraphrased requests
- [ ] Verified doesn't trigger on unrelated topics
- [ ] Functional tests pass
- [ ] Tool integration works (if applicable)
- [ ] Compressed as .zip file

### After upload
- [ ] Test in real conversations
- [ ] Monitor for under/over-triggering
- [ ] Collect user feedback
- [ ] Iterate on description and instructions
- [ ] Update version in metadata
