---
description: Examine the whole codebase and update the existing agent context file to document the project's current state, technology stack, and structure for existing projects that weren't developed using spec-kit.
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

## Outline

This command is designed for **existing projects** that were not originally developed using spec-kit. It analyzes the current codebase to understand the project's structure, technology stack, and patterns, then updates the agent context file so the AI understands how the project was previously built.

**IMPORTANT**: This command does NOT create a feature specification or plan. It only analyzes and documents the existing state of the project.

## OUTPUT STRUCTURE

Execute this workflow in 6 sequential steps:

## Step 1: Setup Context

Run `{SCRIPT}` from repo root and parse JSON output for REPO_ROOT and environment context. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

## Step 2: Analyze Codebase

Run the analysis script to gather facts about the codebase:

```bash
scripts/bash/analyze-codebase.sh --json
```

Parse the JSON output to extract:
- `TECH_STACK`: Detected languages, frameworks, and dependencies
- `PROJECT_STRUCTURE`: Directory structure and organization
- `BUILD_TOOLS`: Build systems, package managers, test frameworks
- `TEST_FRAMEWORKS`: Testing frameworks detected
- `DIRECTORY_STRUCTURE`: Top-level directory tree
- `REPO_ROOT`: Repository root path

## Step 3: Load Existing Context

Read the current agent context file (if it exists) based on the agent type:
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

If no agent file exists, note that a new one will be created.

## Step 4: Create Project Understanding Document

Call the creation script:

```bash
scripts/bash/create-project-understanding.sh --json
```

Parse JSON to get `path` and `template` name.

Read the created file and fill ALL {{PLACEHOLDERS}} using the analysis data from Step 2:

- `{{PROJECT_NAME}}` → Extract from README.md or repo name
- `{{DATE}}` → Today's date (YYYY-MM-DD)
- `{{PROJECT_OVERVIEW}}` → Brief description from README.md or inferred
- `{{PROJECT_TYPE}}` → From PROJECT_STRUCTURE analysis
- `{{PRIMARY_LANGUAGE}}` → From TECH_STACK.LANGUAGE
- `{{LANGUAGE_VERSION}}` → If detectable from config files
- `{{FRONTEND_FRAMEWORKS}}` → From TECH_STACK.FRAMEWORKS (filter frontend)
- `{{BACKEND_FRAMEWORKS}}` → From TECH_STACK.FRAMEWORKS (filter backend)
- `{{OTHER_FRAMEWORKS}}` → Other frameworks detected
- `{{DATABASE}}` → From TECH_STACK.DATABASE
- `{{BUILD_TOOLS}}` → From BUILD_TOOLS
- `{{TEST_FRAMEWORKS}}` → From TEST_FRAMEWORKS
- `{{DIRECTORY_STRUCTURE}}` → From DIRECTORY_STRUCTURE (formatted)
- `{{SOURCE_DIRECTORY}}` → Detected source directory (src/, lib/, app/, etc.)
- `{{TEST_DIRECTORY}}` → Detected test directory
- `{{CONFIG_DIRECTORY}}` → Location of config files
- `{{DOCS_DIRECTORY}}` → Location of documentation
- `{{LAYOUT_PATTERN}}` → Inferred architectural pattern
- `{{BUILD_COMMANDS}}` → Extracted from package.json scripts or Makefile
- `{{TEST_COMMANDS}}` → Extracted from package.json scripts
- `{{DEV_SETUP}}` → From README.md setup instructions
- `{{CODE_ORGANIZATION}}` → Inferred pattern (MVC, layered, component-based, etc.)
- `{{API_PATTERNS}}` → REST, GraphQL, RPC if detected
- `{{STATE_MANAGEMENT}}` → Redux, Zustand, Context API if detected
- `{{DATA_ACCESS_PATTERNS}}` → ORM, direct DB access, repository pattern
- `{{RUNTIME_DEPENDENCIES}}` → Major dependencies from package files
- `{{DEV_DEPENDENCIES}}` → Key dev dependencies
- `{{CONFIG_FILES_LIST}}` → List of important config files
- `{{VCS_WORKFLOW}}` → Git workflow patterns if detectable
- `{{CODE_STYLE}}` → Linting/formatting tools detected
- `{{DEPLOYMENT}}` → Docker, Kubernetes, CI/CD if present
- `{{STRENGTHS}}` → Notable patterns that work well
- `{{AREAS_FOR_IMPROVEMENT}}` → Potential issues or technical debt
- `{{SPECIAL_CONSIDERATIONS}}` → Unique aspects of codebase

Save the filled file.

## Step 5: Update Agent Context File

Run `{AGENT_SCRIPT}` to update the agent-specific context file:
- Add detected technology stack to "Active Technologies"
- Add "Recent Changes" entry: "Initial spec-kit integration: Documented existing codebase"
- Preserve any existing manual additions between markers

## Step 6: Report Completion

Output summary:

```
✅ Project Understanding Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Project Understanding: .specify/project-understanding.md
🤖 Agent Context: [agent-specific file path]

Technologies Detected:
- Primary Language: [language]
- Frameworks: [frameworks]
- Build Tools: [tools]
- Database: [database or "None"]

Project Structure: [structure type]

Next Steps:
→ Review .specify/project-understanding.md for accuracy
→ Run /speckit.constitution to establish project principles
→ Start using spec-kit for new features with /speckit.specify

Acceptance Criteria (PASS only if all true)
- All {{PLACEHOLDERS}} in project-understanding.md are filled
- Technology stack accurately reflects codebase
- Agent context file updated with detected technologies
- Project structure documented clearly
```

## Analysis Guidelines

### Language Detection

Look for these indicators:
- **JavaScript/TypeScript**: `package.json`, `.ts`/`.tsx` files, `tsconfig.json`
- **Python**: `requirements.txt`, `pyproject.toml`, `setup.py`, `.py` files
- **Rust**: `Cargo.toml`, `.rs` files
- **Go**: `go.mod`, `go.sum`, `.go` files
- **Java**: `pom.xml`, `build.gradle`, `.java` files
- **C#**: `.csproj`, `.sln`, `.cs` files
- **Ruby**: `Gemfile`, `.rb` files
- **PHP**: `composer.json`, `.php` files

### Framework Detection

Look for these indicators:
- **Web**: React (JSX, React imports), Vue (Vue components), Angular (Angular modules), Svelte (Svelte components)
- **Backend**: Express (express imports), FastAPI (FastAPI imports), Django (Django settings), Rails (Rails conventions)
- **Mobile**: React Native, Flutter, Swift/iOS, Kotlin/Android

### Project Structure Patterns

Common patterns:
- **Single project**: `src/`, `lib/`, `app/` at root
- **Web app**: `frontend/` + `backend/` or `client/` + `server/`
- **Monorepo**: Multiple packages/projects in root
- **Mobile**: `ios/` + `android/` or `app/` with platform-specific code

### Build Tools

Detect from configuration files:
- **npm/yarn/pnpm**: `package.json`, `yarn.lock`, `pnpm-lock.yaml`
- **pip/poetry**: `requirements.txt`, `pyproject.toml`, `poetry.lock`
- **cargo**: `Cargo.toml`, `Cargo.lock`
- **maven/gradle**: `pom.xml`, `build.gradle`
- **dotnet**: `.csproj`, `.sln`

## Output Files

1. **`.specify/project-understanding.md`**: Complete analysis of the existing codebase
2. **Agent context file**: Updated with detected technology stack (e.g., `CLAUDE.md`, `GEMINI.md`, etc.)

## Key Rules

- Use absolute paths for all file operations
- Do NOT modify existing source code - only analyze and document
- Preserve existing agent context file content (especially manual additions)
- If analysis is incomplete, mark sections with "NEEDS MANUAL REVIEW"
- Focus on high-level patterns and structure, not individual file details
- If the project is too large, focus on the main entry points and key directories

## Error Handling

- If no recognizable project structure found: Ask user to confirm this is a codebase directory
- If multiple languages detected: Document all, but identify the primary one
- If agent context file update fails: Report error but continue with project-understanding.md creation
- If script execution fails: Provide clear error message and suggest manual review

## Next Steps After Understanding

After running this command, users should:
1. Review `.specify/project-understanding.md` for accuracy
2. Run `/speckit.constitution` to establish project principles based on existing patterns
3. Optionally run `/speckit.specify` to start adding new features using spec-kit

