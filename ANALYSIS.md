# Spec Kit Repository Analysis

## Executive Summary

**Spec Kit** is a comprehensive toolkit for **Spec-Driven Development (SDD)** - a methodology that inverts traditional software development by making specifications the primary artifact that generates code, rather than code being the source of truth. The repository contains:

1. **Specify CLI** - A Python-based command-line tool that bootstraps projects with SDD structure
2. **Templates** - Structured markdown templates that guide AI agents through specification → planning → implementation
3. **Scripts** - Bash and PowerShell automation scripts for feature creation and agent context management
4. **Documentation** - Comprehensive guides for SDD methodology and agent integration

---

## 1. Context & Purpose

### Core Philosophy

Spec-Driven Development represents a fundamental shift:
- **Traditional**: Code is king → Specifications guide code → Gap between intent and implementation
- **SDD**: Specifications are executable → Code serves specifications → No gap, only transformation

### Key Principles

1. **Specifications as Lingua Franca**: Specs are the primary artifact; code is expression
2. **Executable Specifications**: Precise, complete, unambiguous enough to generate working systems
3. **Continuous Refinement**: Validation happens continuously, not as a one-time gate
4. **Research-Driven Context**: Research agents gather technical context throughout
5. **Bidirectional Feedback**: Production reality informs specification evolution
6. **Constitutional Foundation**: Immutable principles govern how specs become code

### Target Users

- Development teams using AI coding assistants (Claude, Cursor, Gemini, Copilot, etc.)
- Teams practicing iterative, specification-first development
- Organizations wanting to maintain architectural consistency across AI-generated code

---

## 2. Architecture & Structure

### Repository Organization

```
spec-kit/
├── src/specify_cli/          # Main CLI application (Python)
│   └── __init__.py           # Single-file CLI implementation (~1210 lines)
├── templates/                # Template files for AI agents
│   ├── commands/             # Command definitions (Markdown)
│   ├── spec-template.md      # Feature specification template
│   ├── plan-template.md      # Implementation plan template
│   └── tasks-template.md     # Task breakdown template
├── scripts/                  # Automation scripts
│   ├── bash/                 # Bash scripts (POSIX-compatible)
│   └── powershell/           # PowerShell scripts (Windows)
├── docs/                     # Documentation (GitHub Pages)
├── memory/                   # Constitutional principles
└── .github/                  # CI/CD workflows and release automation
```

### CLI Architecture

**Single-File Design**: The entire CLI (`src/specify_cli/__init__.py`) is a monolithic Python file using:
- **Typer** - CLI framework (built on Click)
- **Rich** - Terminal UI library (colors, tables, progress, panels)
- **httpx** - HTTP client with SSL/TLS support
- **truststore** - Cross-platform SSL certificate handling

**Key Design Patterns**:

1. **Agent Configuration Dictionary** (`AGENT_CONFIG`):
   - Single source of truth for all AI agent metadata
   - Keys match actual CLI tool names (no mapping needed)
   - Fields: `name`, `folder`, `install_url`, `requires_cli`

2. **Step Tracker Pattern**:
   - Hierarchical progress tracking with live UI updates
   - Status states: `pending`, `running`, `done`, `error`, `skipped`
   - Auto-refresh via callback mechanism

3. **Template Download & Extraction**:
   - Downloads pre-built ZIP templates from GitHub releases
   - Handles both new directory and `--here` (current directory) modes
   - Smart merging for `.vscode/settings.json`

---

## 3. Patterns & Conventions

### File Naming Conventions

1. **Command Files**: `speckit.{command}.md` (e.g., `speckit.specify.md`)
   - Prefixed with `speckit.` for discoverability
   - Stored in agent-specific directories (`.claude/commands/`, `.gemini/commands/`, etc.)

2. **Feature Branches**: `{NNN}-{short-name}`
   - Format: `001-feature-name`, `002-another-feature`
   - Auto-numbered based on existing branches
   - GitHub 244-byte limit enforced

3. **Specification Files**: `specs/{branch-name}/spec.md`
   - One spec per feature branch
   - Organized by feature number and name

### Template Structure Pattern

All templates follow a consistent pattern:

```markdown
# [Document Title]: [FEATURE NAME]

**Metadata**: Branch, Date, Status, Input
**Mandatory Sections**: [Section names]
**Optional Sections**: [Section names]
<!-- Template instructions as HTML comments -->
```

**Key Template Sections**:

1. **User Scenarios & Testing**: Prioritized user stories (P1, P2, P3)
2. **Requirements**: Functional requirements (FR-001, FR-002...)
3. **Success Criteria**: Measurable, technology-agnostic outcomes
4. **Technical Context**: Language, dependencies, platform, constraints
5. **Constitution Check**: Phase gates enforcing architectural principles
6. **Project Structure**: Source code layout (single/web/mobile)

### Script Execution Pattern

**Bash Scripts** (`scripts/bash/`):
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -e`
- JSON output mode: `--json` flag
- Cross-platform: Works on Linux, macOS, Windows (Git Bash/WSL)

**PowerShell Scripts** (`scripts/powershell/`):
- Parameter-based: `-Json`, `-ShortName`, `-Number`
- Error handling: `$ErrorActionPreference = "Stop"`
- Parallel structure to bash scripts

### Command Definition Pattern

Command files (in `templates/commands/`) use YAML frontmatter:

```markdown
---
description: "Command description"
scripts:
  sh: scripts/bash/script.sh --json "{ARGS}"
  ps: scripts/powershell/script.ps1 -Json "{ARGS}"
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input
$ARGUMENTS

## Outline
[Step-by-step execution instructions]
```

**Placeholder Patterns**:
- `$ARGUMENTS` - User-provided arguments (Markdown/prompt-based agents)
- `{{args}}` - User-provided arguments (TOML-based agents: Gemini, Qwen)
- `{SCRIPT}` - Replaced with actual script path
- `__AGENT__` - Replaced with agent name (e.g., "claude", "gemini")

---

## 4. File Organization

### Template Files

**`templates/spec-template.md`**:
- Structure for feature specifications
- Sections: User Scenarios, Requirements, Success Criteria, Key Entities
- Guidelines: Focus on WHAT/WHY, avoid HOW/tech stack
- Maximum 3 `[NEEDS CLARIFICATION]` markers

**`templates/plan-template.md`**:
- Structure for implementation plans
- Phases: Technical Context → Constitution Check → Research → Design → Contracts
- Enforces architectural gates (Simplicity, Anti-Abstraction, Integration-First)

**`templates/tasks-template.md`**:
- Task breakdown organized by user story
- Format: `[ID] [P?] [Story] Description`
- Phases: Setup → Foundational → User Stories → Polish
- Parallel execution markers `[P]` for independent tasks

### Command Files

**`templates/commands/specify.md`**:
- Creates feature specification from natural language
- Calls `create-new-feature.sh/ps1` to setup branch and directory
- Generates quality checklist
- Handles clarification questions (max 3)

**`templates/commands/plan.md`**:
- Creates implementation plan from spec
- Phases: Research → Design → Contracts
- Updates agent context files
- Enforces constitution gates

**`templates/commands/tasks.md`**:
- Generates task list from plan
- Organizes by user story priority
- Marks parallel execution opportunities

**`templates/commands/implement.md`**:
- Executes tasks from `tasks.md`
- Validates prerequisites (constitution, spec, plan, tasks)
- Follows TDD approach (tests before implementation)

**`templates/commands/clarify.md`**:
- Structured clarification workflow
- Sequential, coverage-based questioning
- Records answers in Clarifications section

**`templates/commands/analyze.md`**:
- Cross-artifact consistency analysis
- Runs after `/speckit.tasks`, before `/speckit.implement`
- Non-destructive discrepancy report

**`templates/commands/checklist.md`**:
- Generates custom quality checklists
- Validates requirements completeness, clarity, consistency

**`templates/commands/constitution.md`**:
- Creates/updates project governing principles
- Stores in `.specify/memory/constitution.md`

### Script Files

**`scripts/bash/create-new-feature.sh`**:
- Creates feature branch and spec directory
- Auto-numbers branches (001, 002, 003...)
- Generates semantic branch names from descriptions
- Filters stop words, enforces GitHub 244-byte limit
- Sets `SPECIFY_FEATURE` environment variable

**`scripts/bash/setup-plan.sh`**:
- Sets up implementation plan directory structure
- Returns JSON with paths: `FEATURE_SPEC`, `IMPL_PLAN`, `SPECS_DIR`, `BRANCH`

**`scripts/bash/update-agent-context.sh`**:
- Updates agent-specific context files
- Detects agent type from directory structure
- Adds new technology from plan to context
- Preserves manual additions between markers

**`scripts/bash/check-prerequisites.sh`**:
- Validates required tools are installed
- Checks for git, AI agent CLIs, etc.

**`scripts/bash/common.sh`**:
- Shared utility functions for bash scripts
- Common error handling, path resolution

**PowerShell equivalents** (`scripts/powershell/`):
- Parallel structure to bash scripts
- Same functionality, PowerShell syntax

---

## 5. Key Components & How They Work

### CLI Initialization (`specify init`)

**Workflow**:

1. **Banner Display**: ASCII art with colored styling
2. **Project Path Resolution**: 
   - New directory: `specify init my-project`
   - Current directory: `specify init .` or `specify init --here`
3. **AI Agent Selection**:
   - Interactive arrow-key selection if not provided
   - Validates agent exists in `AGENT_CONFIG`
   - Checks CLI tool availability (if `requires_cli: true`)
4. **Script Type Selection**:
   - Auto-detects: PowerShell on Windows, Bash on Unix
   - Interactive selection in TTY mode
5. **Template Download**:
   - Fetches latest release from GitHub API
   - Downloads ZIP matching pattern: `spec-kit-template-{agent}-{script}.zip`
   - Extracts to project directory
6. **Git Initialization**:
   - Creates git repo (unless `--no-git`)
   - Initial commit: "Initial commit from Specify template"
7. **Script Permissions**:
   - Sets execute bits on `.sh` files (Unix only)

**Error Handling**:
- Network failures: Retry with detailed error messages
- Extraction failures: Cleanup and exit with diagnostics
- Git failures: Continue without git, show warning

### Agent Configuration System

**`AGENT_CONFIG` Dictionary**:

```python
AGENT_CONFIG = {
    "claude": {
        "name": "Claude Code",
        "folder": ".claude/",
        "install_url": "https://docs.anthropic.com/...",
        "requires_cli": True,
    },
    # ... 13 total agents
}
```

**Key Design Decision**: Dictionary keys match actual CLI tool names
- ✅ `"cursor-agent"` (actual tool name)
- ❌ `"cursor"` (would require mapping)

**Benefits**:
- No special-case mappings needed
- Direct tool checking: `shutil.which(agent_key)`
- Simpler code, fewer bugs

**Agent Categories**:
- **CLI-Based**: Require CLI tool (`claude`, `gemini`, `cursor-agent`, etc.)
- **IDE-Based**: Built into IDE (`copilot`, `windsurf`, `kilocode`, etc.)

### Template Generation System

**Release Package Creation** (`.github/workflows/scripts/create-release-packages.sh`):

1. For each agent in `ALL_AGENTS` array:
   - Create base directory structure
   - Generate command files from templates
   - Replace placeholders: `{SCRIPT}`, `$ARGUMENTS`, `{{args}}`
   - Create ZIP archive: `spec-kit-template-{agent}-{script}.zip`

2. **Command File Generation**:
   - Markdown agents: Copy `.md` files, replace `$ARGUMENTS`
   - TOML agents: Convert to TOML format, replace `{{args}}`
   - Script paths: Resolve to actual script locations

3. **Directory Structure**:
   - Each agent has specific folder: `.claude/commands/`, `.gemini/commands/`, etc.
   - Templates copied to `.specify/templates/`
   - Scripts copied to `.specify/scripts/`

### Command Execution Flow

**AI Agent Invocation**:

1. User types: `/speckit.specify Build a photo organizer`
2. Agent loads command file: `.claude/commands/speckit.specify.md`
3. Agent reads YAML frontmatter, finds script paths
4. Agent executes script: `scripts/bash/create-new-feature.sh --json "Build a photo organizer"`
5. Script returns JSON: `{"BRANCH_NAME": "001-photo-organizer", "SPEC_FILE": "...", ...}`
6. Agent reads template: `templates/spec-template.md`
7. Agent fills template with user input and script output
8. Agent writes: `specs/001-photo-organizer/spec.md`

**Script Execution Pattern**:

```bash
# Script receives arguments
create-new-feature.sh --json --short-name "photo-organizer" "Build a photo organizer"

# Script:
1. Finds repo root (git or .specify directory)
2. Checks existing branches (remote + local + specs dirs)
3. Determines next number (001, 002, etc.)
4. Creates branch: 001-photo-organizer
5. Creates directory: specs/001-photo-organizer/
6. Copies template: spec-template.md → spec.md
7. Outputs JSON: {"BRANCH_NAME": "...", "SPEC_FILE": "...", ...}
```

### Constitutional Enforcement

**Constitution File**: `.specify/memory/constitution.md`

**Nine Articles**:

1. **Article I**: Library-First Principle (every feature starts as standalone library)
2. **Article II**: CLI Interface Mandate (all libraries expose CLI)
3. **Article III**: Test-First Imperative (tests before code, non-negotiable)
4. **Article IV-IX**: Additional principles (modularity, simplicity, integration-first, etc.)

**Enforcement Mechanism**:

1. Plan template includes "Constitution Check" section
2. Phase gates before implementation:
   - Simplicity Gate: ≤3 projects?
   - Anti-Abstraction Gate: Using framework directly?
   - Integration-First Gate: Contracts defined?
3. Violations must be justified in "Complexity Tracking" table
4. AI agent validates gates before proceeding

---

## 6. Design Principles

### 1. Single Source of Truth

- **Agent metadata**: `AGENT_CONFIG` dictionary only
- **Templates**: One template per artifact type
- **Constitution**: One file, immutable principles

### 2. Convention Over Configuration

- Branch naming: `{NNN}-{short-name}` (auto-numbered)
- Directory structure: `specs/{branch-name}/`
- File names: `spec.md`, `plan.md`, `tasks.md`

### 3. Progressive Disclosure

- Templates start with mandatory sections
- Optional sections only when relevant
- Checklists guide quality without overwhelming

### 4. Technology Agnostic

- Specs avoid implementation details
- Success criteria measurable without tech stack
- Templates work for any language/framework

### 5. AI Agent Agnostic

- Same templates work for all agents
- Agent-specific only in:
  - Command file format (Markdown vs TOML)
  - Directory location (`.claude/` vs `.gemini/`)
  - Argument placeholder (`$ARGUMENTS` vs `{{args}}`)

### 6. Error Prevention Through Structure

- Templates constrain LLM output
- Checklists prevent missing requirements
- Constitution gates prevent over-engineering
- Maximum 3 clarification markers (prevents analysis paralysis)

### 7. Cross-Platform Compatibility

- Bash scripts: POSIX-compatible (Linux, macOS, Windows WSL/Git Bash)
- PowerShell scripts: Windows-native
- Python CLI: Cross-platform (typer, rich, httpx)

### 8. Observability & Debugging

- JSON output mode for scripts (parseable by AI)
- Rich terminal UI with progress tracking
- Detailed error messages with context
- Debug mode: `--debug` flag for verbose output

---

## 7. Workflow Patterns

### Feature Development Workflow

```
1. /speckit.constitution
   → Creates .specify/memory/constitution.md
   → Establishes project principles

2. /speckit.specify "Build photo organizer"
   → Creates branch: 001-photo-organizer
   → Creates specs/001-photo-organizer/spec.md
   → Generates quality checklist

3. /speckit.clarify (optional)
   → Asks up to 3 clarification questions
   → Updates spec with answers

4. /speckit.plan "Use React + PostgreSQL"
   → Creates plan.md, research.md, data-model.md
   → Creates contracts/ (API specs)
   → Updates agent context file

5. /speckit.tasks
   → Reads plan.md, data-model.md, contracts/
   → Generates tasks.md organized by user story
   → Marks parallel execution opportunities

6. /speckit.analyze (optional)
   → Cross-artifact consistency check
   → Reports discrepancies

7. /speckit.implement
   → Reads tasks.md
   → Executes tasks in order (respects dependencies)
   → Follows TDD (tests before implementation)
```

### Branch Management Pattern

- **Feature branches**: `001-feature-name`, `002-another-feature`
- **Auto-numbering**: Scans remote, local, and specs directory
- **Semantic naming**: Extracts meaningful words from description
- **Stop word filtering**: Removes "I", "want", "to", "the", etc.
- **Length enforcement**: Truncates to GitHub's 244-byte limit

### Template Filling Pattern

1. **Load template**: Read markdown template file
2. **Extract placeholders**: Find `[FEATURE NAME]`, `[DATE]`, etc.
3. **Run scripts**: Execute helper scripts for paths, branch names
4. **Fill sections**: Use AI to generate content per section guidelines
5. **Validate**: Check against quality checklist
6. **Write**: Save to appropriate location

---

## 8. Integration Points

### GitHub Integration

- **Releases**: Templates packaged as ZIP files in GitHub releases
- **API**: Uses GitHub API to fetch latest release
- **Authentication**: Supports `GH_TOKEN` / `GITHUB_TOKEN` for rate limits
- **Branch validation**: Checks remote branches for numbering

### AI Agent Integration

**Command File Loading**:
- Agents scan their directory (`.claude/commands/`, etc.)
- Load markdown/TOML files as commands
- Execute scripts specified in frontmatter

**Context Updates**:
- Agent context files updated by `update-agent-context.sh/ps1`
- Preserves manual additions between markers
- Adds new technology from implementation plans

### Git Integration

- **Repository detection**: Looks for `.git` or `.specify` directory
- **Branch creation**: Creates feature branches automatically
- **Initial commit**: Creates initial commit if `--no-git` not used
- **Branch numbering**: Checks git branches for next number

---

## 9. Error Handling Patterns

### Script Error Handling

**Bash**: `set -e` (exit on error), explicit error messages
**PowerShell**: `$ErrorActionPreference = "Stop"`, try/catch blocks

### CLI Error Handling

- **Network errors**: Retry with detailed diagnostics
- **File system errors**: Cleanup and exit gracefully
- **Validation errors**: Show helpful messages with suggestions
- **User errors**: Clear error messages, show usage examples

### Template Validation

- **Quality checklist**: Generated after spec creation
- **Constitution gates**: Block invalid plans
- **Clarification limits**: Maximum 3 markers (prevents paralysis)
- **Required sections**: Templates enforce mandatory sections

---

## 10. Extension Points

### Adding New AI Agents

1. Add to `AGENT_CONFIG` (use actual CLI tool name as key)
2. Update help text in `init()` command
3. Update README documentation
4. Update release package script
5. Update agent context scripts (bash + PowerShell)
6. Update GitHub release script
7. (Optional) Update devcontainer files

### Adding New Commands

1. Create command file: `templates/commands/speckit.{command}.md`
2. Add YAML frontmatter with script paths
3. Define execution outline
4. Create helper scripts if needed (bash + PowerShell)
5. Document in README

### Customizing Templates

- Templates are Markdown files with HTML comments for instructions
- Can be modified per-project after `specify init`
- Changes persist in project (not in CLI tool)

---

## 11. Key Strengths

1. **Consistency**: Single source of truth for agent metadata
2. **Flexibility**: Works with 13+ AI agents
3. **Structure**: Templates guide AI toward quality outputs
4. **Automation**: Scripts handle repetitive tasks
5. **Cross-platform**: Bash + PowerShell support
6. **Observability**: JSON output, progress tracking, detailed errors
7. **Documentation**: Comprehensive guides and examples
8. **Constitutional**: Enforces architectural principles

---

## 12. Potential Improvements

1. **Modular CLI**: Split `__init__.py` into multiple modules
2. **Template Validation**: Schema validation for template structure
3. **Plugin System**: Allow custom commands/scripts without modifying core
4. **Testing**: Add unit tests for CLI and scripts
5. **Configuration File**: Allow project-specific configuration
6. **Template Versioning**: Track template versions in projects
7. **Offline Mode**: Support offline template usage

---

## Conclusion

Spec Kit is a well-architected toolkit that successfully implements Spec-Driven Development principles. The codebase demonstrates:

- **Clear separation of concerns**: CLI, templates, scripts, documentation
- **Consistent patterns**: File naming, template structure, script execution
- **Extensibility**: Easy to add new agents, commands, templates
- **Cross-platform support**: Bash, PowerShell, Python
- **AI-friendly design**: JSON output, structured templates, clear instructions

The design philosophy of making specifications executable and code generated is consistently applied throughout the codebase, from the CLI tool to the templates to the scripts.

