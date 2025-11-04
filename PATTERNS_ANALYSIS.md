# Spec Kit Patterns & Structure Analysis

## Overview

This document analyzes the patterns across `.github/`, `scripts/`, and `templates/` directories to understand how commands are created, scripts work, and releases are built.

---

## 1. `.github/workflows/` - CI/CD & Release Automation

### Structure

```
.github/workflows/
├── release.yml              # Main release workflow
├── lint.yml                 # Code quality checks
├── docs.yml                 # Documentation generation
└── scripts/
    ├── get-next-version.sh          # Calculate next semantic version
    ├── check-release-exists.sh      # Check if release already exists
    ├── create-release-packages.sh   # Build ZIP archives for each agent+script combo
    ├── generate-release-notes.sh   # Generate changelog
    ├── create-github-release.sh    # Create GitHub release with assets
    └── update-version.sh           # Update pyproject.toml version
```

### Release Workflow Pattern

1. **Trigger**: On push to `main` when `memory/`, `scripts/`, `templates/`, or `.github/workflows/` change
2. **Version Calculation**: Auto-increment patch version (v0.0.0 → v0.0.1)
3. **Package Creation**: For each agent × script combination:
   - Creates directory structure: `.specify/`, agent-specific folder (`.claude/commands/`, etc.)
   - Copies templates, scripts, memory files
   - Generates command files from templates (replacing placeholders)
   - Creates ZIP archive: `spec-kit-template-{agent}-{script}-{version}.zip`
4. **Release Creation**: Uploads all ZIPs to GitHub release

### Key Patterns

**Agent Configuration** (in `create-release-packages.sh`):
```bash
ALL_AGENTS=(claude gemini copilot cursor-agent qwen opencode windsurf codex kilocode auggie roo codebuddy amp q)
ALL_SCRIPTS=(sh ps)
```

**Command Generation**:
- Reads templates from `templates/commands/*.md`
- Extracts YAML frontmatter (description, script paths)
- Replaces placeholders:
  - `{SCRIPT}` → actual script path
  - `{AGENT_SCRIPT}` → agent context update script
  - `$ARGUMENTS` (Markdown) or `{{args}}` (TOML) → user input placeholder
  - `__AGENT__` → agent name
- Outputs to agent-specific directory with appropriate extension (`.md`, `.toml`, `.prompt.md`)

**Path Rewriting**:
```bash
# Templates reference: memory/, scripts/, templates/
# Runtime structure: .specify/memory/, .specify/scripts/, .specify/templates/
rewrite_paths() {
  sed -E \
    -e 's@(/?)memory/@.specify/memory/@g' \
    -e 's@(/?)scripts/@.specify/scripts/@g' \
    -e 's@(/?)templates/@.specify/templates/@g'
}
```

---

## 2. `scripts/` - Automation Scripts

### Structure

```
scripts/
├── bash/
│   ├── common.sh              # Shared utilities (repo root, branch detection, feature paths)
│   ├── create-new-feature.sh  # Create feature branch and spec directory
│   ├── setup-plan.sh          # Setup implementation plan directory
│   ├── check-prerequisites.sh # Validate prerequisites for commands
│   └── update-agent-context.sh # Update AI agent context files
└── powershell/
    ├── common.ps1              # PowerShell equivalents
    ├── create-new-feature.ps1
    ├── setup-plan.ps1
    ├── check-prerequisites.ps1
    └── update-agent-context.ps1
```

### Script Patterns

#### 1. **Common Functions** (`common.sh` / `common.ps1`)

**Purpose**: Shared utilities for all scripts

**Key Functions**:
- `get_repo_root()`: Find repository root (git or `.specify` directory)
- `get_current_branch()`: Get current feature branch (git, `SPECIFY_FEATURE` env var, or latest spec dir)
- `get_feature_paths()`: Output all feature-related paths as environment variables
- `check_feature_branch()`: Validate branch naming (must match `^[0-9]{3}-`)

**Output Format**:
```bash
REPO_ROOT='/path/to/repo'
CURRENT_BRANCH='001-feature-name'
HAS_GIT='true'
FEATURE_DIR='/path/to/repo/specs/001-feature-name'
FEATURE_SPEC='/path/to/repo/specs/001-feature-name/spec.md'
IMPL_PLAN='/path/to/repo/specs/001-feature-name/plan.md'
TASKS='/path/to/repo/specs/001-feature-name/tasks.md'
# ... more paths
```

#### 2. **Feature Creation** (`create-new-feature.sh`)

**Purpose**: Create feature branch and spec directory

**Workflow**:
1. Parse arguments: `--json`, `--short-name`, `--number`, feature description
2. Find repo root (git or `.specify` directory)
3. Generate branch name:
   - Filter stop words ("I", "want", "to", "the", etc.)
   - Extract 3-4 meaningful words
   - Format: `{NNN}-{short-name}`
4. Determine branch number:
   - Check remote branches (git fetch)
   - Check local branches
   - Check specs directories
   - Use highest number + 1
5. Create branch (if git repo)
6. Create directory: `specs/{branch-name}/`
7. Copy template: `spec-template.md` → `spec.md`
8. Set `SPECIFY_FEATURE` environment variable
9. Output JSON or text

**Output Format**:
```json
{
  "BRANCH_NAME": "001-photo-organizer",
  "SPEC_FILE": "/path/to/repo/specs/001-photo-organizer/spec.md",
  "FEATURE_NUM": "001"
}
```

#### 3. **Plan Setup** (`setup-plan.sh`)

**Purpose**: Setup implementation plan directory

**Workflow**:
1. Load common functions
2. Get feature paths
3. Validate feature branch
4. Ensure feature directory exists
5. Copy `plan-template.md` → `plan.md`
6. Output paths in JSON or text format

#### 4. **Prerequisites Check** (`check-prerequisites.sh`)

**Purpose**: Validate prerequisites for commands

**Options**:
- `--json`: JSON output
- `--require-tasks`: Require `tasks.md` to exist
- `--include-tasks`: Include `tasks.md` in available docs
- `--paths-only`: Only output paths (no validation)

**Output Format**:
```json
{
  "FEATURE_DIR": "/path/to/repo/specs/001-feature-name",
  "AVAILABLE_DOCS": ["research.md", "data-model.md", "contracts/", "quickstart.md"]
}
```

#### 5. **Agent Context Update** (`update-agent-context.sh`)

**Purpose**: Update AI agent context files with tech stack info

**Workflow**:
1. Parse `plan.md` to extract:
   - Language/Version
   - Primary Dependencies
   - Storage/Database
   - Project Type
2. For each agent file (or all if none specified):
   - If file doesn't exist: Create from template
   - If file exists: Update "Active Technologies" and "Recent Changes" sections
   - Preserve manual additions between `<!-- MANUAL ADDITIONS START -->` markers

**Agent File Locations**:
- Claude: `CLAUDE.md`
- Gemini: `GEMINI.md`
- Copilot: `.github/copilot-instructions.md`
- Cursor: `.cursor/rules/specify-rules.mdc`
- Qwen: `QWEN.md`
- opencode/Codex/Amp/Q: `AGENTS.md`
- Windsurf: `.windsurf/rules/specify-rules.md`
- Kilo Code: `.kilocode/rules/specify-rules.md`
- Auggie: `.augment/rules/specify-rules.md`
- Roo: `.roo/rules/specify-rules.md`
- CodeBuddy: `CODEBUDDY.md`

### Script Execution Pattern

All scripts follow this pattern:

```bash
#!/usr/bin/env bash
set -e  # Exit on error

# Parse arguments (--json, --help, etc.)
# Source common functions
source "$SCRIPT_DIR/common.sh"

# Get feature paths
eval $(get_feature_paths)

# Validate environment
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Perform operation
# ...

# Output results (JSON or text)
if $JSON_MODE; then
    printf '{"KEY":"value"}\n'
else
    echo "KEY: value"
fi
```

---

## 3. `templates/commands/` - Command Definitions

### Structure

```
templates/commands/
├── specify.md      # Create feature specification
├── plan.md         # Create implementation plan
├── tasks.md        # Generate task breakdown
├── implement.md    # Execute implementation
├── clarify.md      # Structured clarification questions
├── analyze.md      # Cross-artifact consistency analysis
├── checklist.md    # Generate quality checklists
└── constitution.md # Create/update project constitution
```

### Command File Pattern

**YAML Frontmatter**:
```yaml
---
description: "Command description"
scripts:
  sh: scripts/bash/script.sh --json "{ARGS}"
  ps: scripts/powershell/script.ps1 -Json "{ARGS}"
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---
```

**Body Structure**:
```markdown
## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `{SCRIPT}` from repo root and parse output
2. Load required files (spec.md, plan.md, etc.)
3. Perform operation (generate, validate, execute)
4. Write output files
5. Report completion
```

### Placeholder Patterns

**In Command Templates**:
- `$ARGUMENTS` - User-provided arguments (Markdown/prompt-based agents: Claude, Cursor, Copilot, etc.)
- `{{args}}` - User-provided arguments (TOML-based agents: Gemini, Qwen)
- `{SCRIPT}` - Replaced with actual script path from frontmatter
- `{AGENT_SCRIPT}` - Replaced with agent context update script path
- `__AGENT__` - Replaced with agent name (e.g., "claude", "gemini")

**In Scripts**:
- `{ARGS}` - Replaced with actual user arguments when script is called
- Single quotes: `'I'\''m Groot'` (bash escaping) or `"I'm Groot"` (double quotes)

### Command Execution Flow

1. **AI Agent Invocation**:
   - User types: `/speckit.command-name <arguments>`
   - Agent loads: `.claude/commands/speckit.command-name.md` (or agent-specific location)
   - Agent reads YAML frontmatter

2. **Script Execution**:
   - Agent extracts script path from frontmatter
   - Agent executes: `scripts/bash/script.sh --json "user arguments"`
   - Script outputs JSON: `{"KEY": "value", ...}`
   - Agent parses JSON output

3. **Template Processing**:
   - Agent reads template file (spec-template.md, plan-template.md, etc.)
   - Agent fills template with:
     - User input (`$ARGUMENTS`)
     - Script output (paths, branch names, etc.)
     - AI-generated content (specs, plans, tasks)

4. **File Writing**:
   - Agent writes filled template to appropriate location
   - Agent reports completion

### Command Types

#### 1. **Specification Commands** (`specify.md`)
- Creates feature specification from natural language
- Calls: `create-new-feature.sh`
- Generates: `specs/{branch}/spec.md`

#### 2. **Planning Commands** (`plan.md`)
- Creates implementation plan from spec
- Calls: `setup-plan.sh`, `update-agent-context.sh`
- Generates: `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

#### 3. **Task Commands** (`tasks.md`)
- Generates task breakdown from plan
- Calls: `check-prerequisites.sh`
- Generates: `tasks.md`

#### 4. **Implementation Commands** (`implement.md`)
- Executes tasks from tasks.md
- Calls: `check-prerequisites.sh --require-tasks`
- Validates checklists, creates ignore files, executes implementation

#### 5. **Quality Commands** (`clarify.md`, `analyze.md`, `checklist.md`)
- Structured clarification, consistency analysis, quality checklists
- Calls: `check-prerequisites.sh --paths-only`
- Generates: Clarification sections, analysis reports, checklist files

---

## 4. Creating a New Command

### Step-by-Step Guide

#### 1. **Create Command Template**

Create `templates/commands/speckit.{command-name}.md`:

```markdown
---
description: "Command description"
scripts:
  sh: scripts/bash/{script-name}.sh --json "{ARGS}"
  ps: scripts/powershell/{script-name}.ps1 -Json "{ARGS}"
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `{SCRIPT}` from repo root and parse output
2. Load required files
3. Perform operation
4. Write output files
5. Report completion
```

#### 2. **Create Bash Script** (if needed)

Create `scripts/bash/{script-name}.sh`:

```bash
#!/usr/bin/env bash
set -e

# Parse arguments
JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        *) ARGS+=("$arg") ;;
    esac
done

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get feature paths
eval $(get_feature_paths)

# Validate
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Perform operation
# ...

# Output
if $JSON_MODE; then
    printf '{"KEY":"value"}\n'
else
    echo "KEY: value"
fi
```

#### 3. **Create PowerShell Script** (if needed)

Create `scripts/powershell/{script-name}.ps1`:

```powershell
#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Load common functions
. "$PSScriptRoot/common.ps1"

# Get feature paths
$paths = Get-FeaturePathsEnv

# Validate
if (-not (Test-FeatureBranch -Branch $paths.CURRENT_BRANCH -HasGit $paths.HAS_GIT)) { 
    exit 1 
}

# Perform operation
# ...

# Output
if ($Json) {
    $result = [PSCustomObject]@{ KEY = "value" }
    $result | ConvertTo-Json -Compress
} else {
    Write-Output "KEY: value"
}
```

#### 4. **Update Release Script** (if needed)

If command requires special handling in release packages, update `.github/workflows/scripts/create-release-packages.sh`:

```bash
# Command generation happens automatically for all files in templates/commands/
# No changes needed unless special formatting required
```

#### 5. **Test Command**

1. Build release packages locally:
   ```bash
   .github/workflows/scripts/create-release-packages.sh v0.0.21
   ```

2. Extract package and test:
   ```bash
   unzip .genreleases/spec-kit-template-claude-sh-v0.0.21.zip
   cd sdd-claude-package-sh
   # Test command in agent
   ```

---

## 5. Key Design Patterns

### 1. **Single Source of Truth**
- Agent metadata: `AGENT_CONFIG` in `src/specify_cli/__init__.py`
- Command templates: `templates/commands/*.md`
- Scripts: `scripts/bash/` and `scripts/powershell/` mirror each other

### 2. **Path Resolution**
- All scripts use `common.sh`/`common.ps1` for paths
- Supports both git and non-git repositories
- Falls back to `SPECIFY_FEATURE` environment variable

### 3. **JSON Output Mode**
- All scripts support `--json` flag for AI parsing
- Consistent JSON structure across scripts
- Text output for human readability

### 4. **Error Handling**
- `set -e` in bash scripts (exit on error)
- `$ErrorActionPreference = 'Stop'` in PowerShell
- Clear error messages with actionable guidance

### 5. **Template Processing**
- YAML frontmatter extracted during release build
- Placeholders replaced with actual values
- Paths rewritten from template structure to runtime structure

### 6. **Agent Agnosticism**
- Same templates work for all agents
- Agent-specific only in:
  - Directory location (`.claude/commands/` vs `.gemini/commands/`)
  - File format (`.md` vs `.toml` vs `.prompt.md`)
  - Argument placeholder (`$ARGUMENTS` vs `{{args}}`)

---

## 6. Common Pitfalls to Avoid

1. **Forgetting PowerShell Script**: Always create both bash and PowerShell versions
2. **Hardcoding Paths**: Use `common.sh` functions for path resolution
3. **Missing JSON Mode**: Always support `--json` flag for AI parsing
4. **Incorrect Placeholders**: Use `$ARGUMENTS` for Markdown, `{{args}}` for TOML
5. **Not Testing Both Scripts**: Test bash and PowerShell scripts separately
6. **Forgetting Error Handling**: Validate inputs and provide clear error messages
7. **Not Updating Release Scripts**: If adding new agents, update `create-release-packages.sh` and `create-github-release.sh`

---

## 7. Testing Checklist

Before creating a new command:

- [ ] Command template created in `templates/commands/`
- [ ] Bash script created (if needed) in `scripts/bash/`
- [ ] PowerShell script created (if needed) in `scripts/powershell/`
- [ ] Scripts use `common.sh`/`common.ps1` for paths
- [ ] Scripts support `--json` flag
- [ ] Scripts validate prerequisites
- [ ] Scripts output consistent JSON format
- [ ] Command follows existing command patterns
- [ ] Placeholders correctly used (`$ARGUMENTS` vs `{{args}}`)
- [ ] Tested locally with release package
- [ ] Tested with actual AI agent

---

## Summary

The Spec Kit codebase follows consistent patterns:

1. **Templates** define commands with YAML frontmatter and Markdown instructions
2. **Scripts** provide automation (bash + PowerShell mirrors)
3. **Release workflow** packages templates and scripts into agent-specific ZIPs
4. **Common utilities** provide shared functionality (paths, validation, etc.)
5. **Agent-agnostic design** allows same templates to work across all AI agents

When creating a new command, follow these patterns for consistency and maintainability.

