---
name: session:pickup
description: Resume work from a previous handoff session stored in .agents/handoffs
allowed-tools: Bash, Read, AskUserQuestion, Glob, Grep
model: haiku
argument-hint: "[optional: handoff-file]"
---

Resumes work from a previous handoff session which are stored in `.agents/handoffs`.

**IMPORTANT**: This command must be run from within a project directory, not from `~/.claude`. It looks for handoffs in the project's `.agents/handoffs/` directory.

The handoff folder might not exist if there are none.

Requested handoff file: `$ARGUMENTS`

## Process

### 0. Verify Project Directory

Before listing or reading handoffs:
1. Check if we're in a project directory (look for a git repository or verify current working directory is not `~/.claude`)
2. If in `~/.claude`, inform the user they need to run this command from their project directory
3. If in a project, proceed with the pickup process

### 1. Check for Handoff File Argument

If no handoff file was provided in `$ARGUMENTS`, list all available handoffs and use `AskUserQuestion` to let user select which handoff to resume.

To list handoffs, use this bash command:

```bash
if [ -d ".agents/handoffs" ]; then
  echo "## Available Handoffs"
  echo ""
  for file in .agents/handoffs/*.md; do
    if [ -f "$file" ]; then
      title=$(grep -m 1 "^# " "$file" | sed 's/^# //')
      basename=$(basename "$file")
      echo "* \`$basename\`: $title"
    fi
  done
  echo ""
  echo "To pickup a handoff, use: /pickup <filename>"
else
  echo "No handoffs directory found at .agents/handoffs"
  echo "Create a handoff first using: /handoff <purpose>"
fi
```

### 2. Locate and Read Handoff File

If a handoff file was provided in `$ARGUMENTS`:

1. **Search for matches**: Look in `.agents/handoffs/` for files matching the provided name. The user might have:
   - Provided the exact filename (e.g., `2025-11-04-implement-auth.md`)
   - Provided just the slug (e.g., `implement-auth`)
   - Provided a partial match (e.g., `auth`)
   - Misspelled the filename

2. **Handle matches**:
   - **No matches**: Inform the user that no handoff file was found and list available handoffs
   - **Single match**: Read the file and proceed
   - **Multiple matches**: List the matches and ask the user to specify which one to use

3. **Read the handoff**: Once the correct file is identified, read it using the Read tool to get the full handoff plan.

### 3. Verify State Before Resuming

After reading the handoff, verify the current codebase state matches what was documented:

1. **Check documented files exist**: For each file mentioned in "Files and Code Sections", verify it still exists using Glob
2. **Check for recent changes**: If handoff includes a date, check if relevant files changed since:
   ```bash
   git log --since="<handoff_date>" --oneline -- <file1> <file2> ...
   ```
3. **Validate key patterns**: Use Grep to confirm critical code patterns mentioned in the handoff are still present

**Present verification summary:**

```
## State Verification

✅ **Verified:**
- <files that exist and match>
- <patterns confirmed present>

⚠️ **Drift Detected:**
- <file> was modified on <date> (after handoff)
- <pattern> no longer found in <file>

❓ **Unable to Verify:**
- <items requiring manual confirmation>
```

**Skip verification if:**
- Handoff was created today
- Handoff contains no file references
- User explicitly requests to skip (`/pickup --skip-verify <file>`)

### 4. Resume Work

After verification:
   - Acknowledge what handoff you're resuming
   - Summarize the key context from the handoff (primary request, current state)
   - If drift was detected, ask: "Some files changed since this handoff. Address drift first or proceed with the documented next step?"
   - Otherwise, proceed with the "Next Step" outlined in the handoff plan
   - Ask the user for confirmation or additional direction if needed

## Example Workflow

### No argument provided:
```
User: /pickup
Assistant: [Lists all available handoffs]
```

### Exact filename provided:
```
User: /pickup 2025-11-04-implement-auth.md
Assistant: [Reads the handoff and resumes work on implementing authentication]
```

### Partial match provided:
```
User: /pickup auth
Assistant: Found multiple matches:
- 2025-11-04-implement-auth.md
- 2025-11-03-fix-auth-bug.md
Which handoff would you like to continue?
```

### With state verification:
```
User: /pickup implement-auth
Assistant: Resuming handoff: Implement Authentication (2025-11-04)

## State Verification

✅ Verified:
- app/models/user.rb exists
- app/controllers/sessions_controller.rb exists
- bcrypt gem in Gemfile

⚠️ Drift Detected:
- app/models/user.rb modified 2 days after handoff
- config/routes.rb has new routes not in handoff

The handoff's "Next Step" is: Add session management.
Some files changed since this handoff. Address drift first or proceed?
```

### Skip verification:
```
User: /pickup --skip-verify implement-auth
Assistant: [Skips verification, immediately resumes from "Next Step"]
```
