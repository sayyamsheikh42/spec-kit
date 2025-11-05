# Complete Guide: Adding New Commands to Spec-Kit

This document provides a step-by-step guide for adding new commands to Spec-Kit. It explains how commands work, how they're processed, and how to create your own commands. This guide is designed to be accessible to everyone, regardless of technical background.

## Table of Contents

1. [What Are Commands?](#what-are-commands)
2. [How Commands Work](#how-commands-work)
3. [Understanding the System](#understanding-the-system)
4. [Step-by-Step: Adding a New Command](#step-by-step-adding-a-new-command)
5. [Common Patterns](#common-patterns)
6. [Troubleshooting](#troubleshooting)

---

## What Are Commands?

Commands are instructions that AI assistants can execute in your projects. When you use Spec-Kit, commands like `/speckit.specify` or `/speckit.plan` appear in your AI assistant's interface.

### Real-World Analogy

Think of commands like shortcuts on your phone:
- **Shortcuts** = Commands (like `/speckit.understand`)
- **What they do** = Execute specific tasks automatically
- **Where they live** = In your project's special folders

### How Commands Get to Your Project

When you initialize a new project with Spec-Kit, commands are automatically downloaded and placed in the correct location for your AI assistant. This happens behind the scenes, so you don't need to do anything manually.

---

## How Commands Work

### The Lifecycle of a Command

```
1. Command Template Created
   ↓
2. Release Process Converts It
   ↓
3. Included in Release Package
   ↓
4. Downloaded When You Initialize Project
   ↓
5. Available in Your AI Assistant
```

### What Happens When You Use a Command

When you type `/speckit.understand` in your AI assistant:

1. **AI reads the command file** - It finds the instructions
2. **AI follows the steps** - It executes scripts and processes data
3. **AI creates files** - It generates documents or updates files
4. **AI reports back** - It tells you what was done

---

## Understanding the System

### Key Concepts Explained Simply

#### 1. Command Templates

**What they are:** Markdown files that contain instructions for the AI.

**Location:** `templates/commands/your-command.md`

**What they contain:**
- Description of what the command does
- Step-by-step instructions for the AI
- Which scripts to run
- What output to create

**Think of it as:** A recipe that tells the AI exactly how to cook something.

#### 2. Template Files

**What they are:** Files with placeholders that get filled in by the AI.

**Example:**
```markdown
# Project: {{PROJECT_NAME}}

Created on: {{DATE}}

Description: {{PROJECT_OVERVIEW}}
```

The AI will replace `{{PROJECT_NAME}}` with your actual project name, `{{DATE}}` with today's date, etc.

**Why use placeholders:** It ensures consistency and makes it easy for the AI to fill in information automatically.

#### 3. Scripts

**What they are:** Small programs that do specific tasks.

**Two types:**

**Thin Scripts** (Infrastructure):
- Create folders
- Copy template files
- Return information about what was created
- **Do NOT** generate content

**Analysis Scripts** (Content):
- Analyze your codebase
- Gather information
- Process data
- **Generate** content or insights

**The separation:** Scripts handle the "mechanical" work (creating files, finding things), while the AI handles the "intelligent" work (analyzing, writing, making decisions).

#### 4. Placeholders

**What they are:** Special markers in templates that get replaced with actual content.

**Syntax:** `{{PLACEHOLDER_NAME}}` (all caps, double curly braces)

**Examples:**
- `{{PROJECT_NAME}}` → Gets replaced with your project's name
- `{{DATE}}` → Gets replaced with today's date
- `{{TECH_STACK}}` → Gets replaced with detected technologies

**Why this matters:** The AI knows exactly what information to fill in where.

#### 5. Release Process

**What it is:** The automated system that prepares commands for distribution.

**What it does:**
1. Takes command templates
2. Converts them to the right format for each AI assistant
3. Packages everything into ZIP files
4. Makes them available for download

**Why it matters:** This is how new commands become available to everyone automatically.

---

## Step-by-Step: Adding a New Command

This section walks you through creating a new command from start to finish.

### Step 1: Plan Your Command

**Ask yourself:**
- What should this command do?
- What files or documents should it create?
- What information does it need?
- What scripts will it use?

**Example:** A command that documents API endpoints
- **Purpose:** Create a document listing all API endpoints
- **Creates:** An `api-endpoints.md` file
- **Needs:** To scan code files for API definitions
- **Uses:** A script to find API routes, a template to format them

### Step 2: Create the Command Template

**File location:** `templates/commands/your-command-name.md`

**Basic structure:**
```markdown
---
description: What your command does in plain language
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## OUTPUT STRUCTURE

Execute this workflow in sequential steps:

## Step 1: Setup

Run `{SCRIPT}` from repo root and parse JSON output for environment context.

## Step 2: [Your First Action]

[Describe what should happen in this step]

## Step 3: [Your Second Action]

[Describe what should happen in this step]

## Step 4: Report Completion

Output summary with acceptance criteria.
```

**What each part means:**

- **`description`:** A clear explanation of what the command does
- **`scripts`:** Which script to run first (usually check-prerequisites)
- **`agent_scripts`:** Script to update the AI assistant's context file
- **`$ARGUMENTS`:** User-provided input (optional)
- **`{SCRIPT}`:** Gets replaced with the actual script command
- **`{AGENT_SCRIPT}`:** Gets replaced with the agent update command

### Step 3: Create Template Files (If Needed)

**When needed:** If your command creates a document or file with placeholders.

**File location:** `templates/your-document-template.md`

**Structure:**
```markdown
# {{TITLE}}

Created: {{DATE}}

## Overview

{{DESCRIPTION}}

## Details

{{CONTENT}}

## Additional Information

{{EXTRA_INFO}}
```

**Important:** Use `{{PLACEHOLDER}}` syntax (all caps, double braces)

**List all placeholders** in your command template so the AI knows what to fill:
- `{{TITLE}}` → Where to get this information
- `{{DATE}}` → Today's date
- `{{DESCRIPTION}}` → From analysis or user input
- etc.

### Step 4: Create Thin Scripts

**What they do:** Create the file structure and copy templates with placeholders intact.

**Files needed:**
- `scripts/bash/create-your-document.sh` (for Mac/Linux)
- `scripts/powershell/create-your-document.ps1` (for Windows)

**Basic script structure:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# create-your-document.sh - Create document file
#
# This script ONLY:
#   1. Creates the directory structure
#   2. Copies the template with {{PLACEHOLDERS}} intact
#   3. Returns JSON metadata for AI to use

JSON=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    *) shift ;;
  esac
done

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Create output directory
OUTPUT_DIR="$REPO_ROOT/.specify"
mkdir -p "$OUTPUT_DIR"

# Find template file (check multiple locations)
TEMPLATE=""
if [[ -f "$REPO_ROOT/.specify/templates/your-document-template.md" ]]; then
  TEMPLATE="$REPO_ROOT/.specify/templates/your-document-template.md"
elif [[ -f "$REPO_ROOT/templates/your-document-template.md" ]]; then
  TEMPLATE="$REPO_ROOT/templates/your-document-template.md"
else
  echo "Error: Template not found" >&2
  exit 1
fi

# Create output file
OUTPUT_FILE="$OUTPUT_DIR/your-document.md"
cp "$TEMPLATE" "$OUTPUT_FILE"

# Return JSON if requested
if $JSON; then
  ABS_PATH=$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")
  printf '{"path":"%s","template":"%s"}\n' "$ABS_PATH" "$(basename "$TEMPLATE")"
else
  echo "✅ Template copied → $OUTPUT_FILE"
  echo "Note: AI will fill in {{PLACEHOLDERS}}"
fi
```

**Key points:**
- Scripts should be executable (`chmod +x`)
- Scripts return JSON when `--json` flag is used
- Scripts never fill in placeholders - that's the AI's job
- Scripts check multiple locations for templates

### Step 5: Update Your Command Template

**Add instructions for the AI to:**
1. Call the thin script to create the file
2. Parse the JSON response to get the file path
3. Read the created file
4. Replace all `{{PLACEHOLDERS}}` with actual data
5. Save the file

**Example addition to your command template:**
```markdown
## Step 2: Create Document

Call the creation script:
```bash
scripts/bash/create-your-document.sh --json
```

Parse the JSON output to get the `path` field.

Read the created file and fill ALL {{PLACEHOLDERS}}:
- `{{TITLE}}` → Extract from [source]
- `{{DATE}}` → Today's date (YYYY-MM-DD)
- `{{DESCRIPTION}}` → From [analysis or input]
- `{{CONTENT}}` → From [wherever the data comes from]

Save the filled file.
```

### Step 6: Test Your Command Locally

**Before committing changes:**

1. **Test the script:**
   ```bash
   ./scripts/bash/create-your-document.sh --json
   ```
   Should return JSON with `path` and `template` fields.

2. **Check the template file:**
   - Verify it was created in the right location
   - Check that placeholders are intact (not filled in)

3. **Test command generation (optional):**
   - Manually test that your command template is valid
   - Check that all placeholders are documented

### Step 7: Commit and Release

**Once testing is complete:**

1. **Add files to git:**
   ```bash
   git add templates/commands/your-command-name.md
   git add templates/your-document-template.md
   git add scripts/bash/create-your-document.sh
   git add scripts/powershell/create-your-document.ps1
   ```

2. **Commit:**
   ```bash
   git commit -m "feat: Add your-command-name command"
   ```

3. **Push:**
   ```bash
   git push origin main
   ```

4. **Create release:**
   - The release process will automatically include your new command
   - It will be converted to the right format for each AI assistant
   - It will be packaged and made available

### Step 8: Verify in a New Project

**After release is created:**

1. **Initialize a test project:**
   ```bash
   specify init test-project --ai gemini
   ```

2. **Check that command exists:**
   ```bash
   ls test-project/.gemini/commands/speckit.your-command-name.toml
   ```

3. **Test the command:**
   - Open your AI assistant in the test project
   - Type `/speckit.your-command-name`
   - Verify it works correctly

---

## Common Patterns

Different commands follow different patterns depending on what they do.

### Pattern 1: Simple Command (No File Creation)

**When to use:** Commands that analyze or process but don't create new files.

**Example:** A command that checks code quality

**Structure:**
- Command template with instructions
- Analysis scripts that gather data
- AI processes and reports results
- No template files needed
- No thin scripts needed

**Workflow:**
1. Run analysis script
2. AI processes results
3. AI reports findings

### Pattern 2: Command with Document Creation

**When to use:** Commands that create formatted documents with placeholders.

**Example:** A command that creates project documentation

**Structure:**
- Command template
- Template file with `{{PLACEHOLDERS}}`
- Thin script to create file
- AI fills placeholders

**Workflow:**
1. Call thin script to create file
2. AI gathers data
3. AI fills all placeholders
4. Save completed file

### Pattern 3: Command with Analysis + Creation

**When to use:** Commands that analyze code and create documentation from findings.

**Example:** A command that analyzes codebase structure and documents it

**Structure:**
- Command template
- Analysis script to gather information
- Template file for output
- Thin script to create file
- AI processes analysis and fills template

**Workflow:**
1. Run analysis script
2. AI processes results
3. Call thin script to create file
4. AI fills template with analysis data
5. Save completed file

---

## Troubleshooting

### Command Not Appearing in New Projects

**Checklist:**
1. ✅ Is the command file in `templates/commands/` directory?
2. ✅ Does the command file have valid YAML frontmatter?
3. ✅ Was a release created after adding the command?
4. ✅ Is the release available in your repository?
5. ✅ Are you using the correct repository URL in your CLI configuration?

**Common issues:**
- **Command file in wrong location:** Must be in `templates/commands/`
- **Invalid YAML:** Check frontmatter syntax
- **No release created:** Commands only appear after a release
- **Wrong repository:** Check that CLI points to correct repo

### Script Not Working

**Checklist:**
1. ✅ Is the script executable? (Run `chmod +x script.sh`)
2. ✅ Is the script in the correct location? (`.specify/scripts/` in projects)
3. ✅ Does the script return valid JSON with `--json` flag?
4. ✅ Does the template file exist in the expected location?

**Common issues:**
- **Not executable:** Scripts need execute permissions
- **Wrong path:** Scripts are copied to `.specify/scripts/` in projects
- **Invalid JSON:** Check script output format
- **Template not found:** Verify template file exists

### Placeholders Not Being Filled

**Checklist:**
1. ✅ Are placeholders using correct syntax? (`{{PLACEHOLDER}}` not `{PLACEHOLDER}` or `{{placeholder}}`)
2. ✅ Does the AI have the data needed to fill placeholders?
3. ✅ Was the file created before trying to fill placeholders?
4. ✅ Do placeholder names match exactly (case-sensitive)?

**Common issues:**
- **Wrong syntax:** Must be `{{ALL_CAPS}}` with double braces
- **Missing data:** AI needs to gather information before filling
- **Timing:** File must be created first, then filled
- **Case mismatch:** `{{PROJECT_NAME}}` ≠ `{{project_name}}` ≠ `{{Project_Name}}`

### Release Process Issues

**If commands aren't included in release:**

1. **Check release script:** Verify it processes `templates/commands/*.md`
2. **Check file format:** Must be valid Markdown with YAML frontmatter
3. **Check logs:** Review release workflow logs for errors
4. **Check packaging:** Verify ZIP files contain your command files

---

## Key Principles to Remember

### 1. Separation of Concerns

**Scripts handle infrastructure:**
- Creating folders
- Copying files
- Returning metadata

**AI handles content:**
- Analyzing data
- Making decisions
- Filling in placeholders
- Writing content

### 2. Use Placeholders

**Always use placeholder syntax:**
- Format: `{{PLACEHOLDER_NAME}}`
- All caps
- Double curly braces
- Descriptive names

**Why:** Makes it clear what information goes where and ensures consistency.

### 3. Return JSON from Scripts

**When scripts need to communicate with AI:**
- Use `--json` flag
- Return structured data
- Include `path` and `template` fields at minimum

**Why:** Makes it easy for AI to programmatically process results.

### 4. Test Before Releasing

**Always test:**
- Scripts work correctly
- Templates are valid
- Placeholders are correct
- Command structure is valid

**Why:** Prevents issues from reaching users.

### 5. Document Everything

**In your command template, clearly document:**
- What each step does
- Where to get data for placeholders
- What scripts to call
- What output to expect

**Why:** Makes it easier for the AI to follow instructions correctly.

---

## File Structure Overview

When adding a command, you'll work with these directories:

```
spec-kit/
├── templates/
│   ├── commands/
│   │   └── your-command-name.md      ← Command template
│   └── your-document-template.md      ← Template file (if needed)
├── scripts/
│   ├── bash/
│   │   └── create-your-document.sh   ← Thin script (Mac/Linux)
│   └── powershell/
│       └── create-your-document.ps1   ← Thin script (Windows)
└── .github/
    └── workflows/
        └── release.yml                 ← Release process
```

---

## Quick Reference

### Command Template Checklist

- [ ] Has YAML frontmatter with `description`
- [ ] Includes `scripts` section
- [ ] Includes `agent_scripts` section
- [ ] Has `User Input` section with `$ARGUMENTS`
- [ ] Has clear step-by-step instructions
- [ ] Documents all placeholders if creating files
- [ ] Includes error handling guidance
- [ ] Includes output format specification

### Template File Checklist

- [ ] Uses `{{PLACEHOLDER}}` syntax (all caps, double braces)
- [ ] Has clear structure
- [ ] Documents what each placeholder should contain
- [ ] Located in `templates/` directory

### Script Checklist

- [ ] Creates directory structure
- [ ] Finds template file (checks multiple locations)
- [ ] Copies template with placeholders intact
- [ ] Returns JSON with `--json` flag
- [ ] Has error handling
- [ ] Is executable (`chmod +x`)
- [ ] Has both Bash and PowerShell versions

### Testing Checklist

- [ ] Script runs successfully
- [ ] Script returns valid JSON
- [ ] Template file is created correctly
- [ ] Placeholders are intact (not filled)
- [ ] Command template is valid
- [ ] All files committed
- [ ] Release created successfully
- [ ] Command appears in new projects
- [ ] Command works as expected

---

## Additional Resources

### Understanding the Release Process

The release process automatically:
1. Finds all command templates
2. Converts them to the right format for each AI assistant
3. Includes universal rules
4. Packages everything into ZIP files
5. Makes them available for download

**You don't need to do anything special** - just put your command in `templates/commands/` and create a release.

### Understanding AI Assistant Formats

Different AI assistants use different formats:
- **Gemini/Qwen:** TOML format (`.toml` files)
- **Claude/Cursor:** Markdown format (`.md` files)

**The release process handles this automatically** - you only need to create the Markdown template.

### Understanding Placeholder Replacement

When the AI processes a command:
1. It reads the template file
2. It finds all `{{PLACEHOLDER}}` markers
3. It gathers the necessary data
4. It replaces each placeholder with actual content
5. It saves the completed file

**Make sure placeholders are clearly documented** so the AI knows where to get the data.

---

## Getting Help

If you encounter issues:

1. **Check this guide** - Review the troubleshooting section
2. **Review existing commands** - Look at how similar commands are structured
3. **Check file locations** - Verify files are in the correct directories
4. **Test incrementally** - Test scripts before testing full command
5. **Review logs** - Check release workflow logs for errors

---

## Summary

Adding a new command involves:

1. **Planning** what the command should do
2. **Creating** the command template file
3. **Creating** template files with placeholders (if needed)
4. **Creating** thin scripts to handle file creation
5. **Testing** everything locally
6. **Committing** and creating a release
7. **Verifying** the command works in new projects

The system handles most of the complexity automatically - you just need to create the right files in the right places with the right structure.

Remember: **Scripts handle infrastructure, AI handles content.** Keep this separation clear, and your commands will work smoothly.

---

*This guide provides everything you need to add new commands to Spec-Kit. Follow the patterns, test thoroughly, and your commands will be available to everyone automatically.*
