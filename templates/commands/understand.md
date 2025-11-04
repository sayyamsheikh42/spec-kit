---
description: Examine the whole codebase and update the existing agent context file to document the project's current state, technology stack, and structure for existing projects that weren't developed using spec-kit.
scripts:
  sh: scripts/bash/analyze-codebase.sh --json
  ps: scripts/powershell/analyze-codebase.ps1 -Json
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

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON output. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

   The script will analyze the codebase and return:
   - `TECH_STACK`: Detected languages, frameworks, and dependencies
   - `PROJECT_STRUCTURE`: Directory structure and organization
   - `BUILD_TOOLS`: Build systems, package managers, test frameworks
   - `DEPENDENCIES`: Key dependencies and versions
   - `PATTERNS`: Architectural patterns detected
   - `REPO_ROOT`: Repository root path

2. **Load existing context**: Read the current agent context file (if it exists):
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

3. **Analyze codebase structure**:
   - Examine project root directory structure
   - Identify source code directories (`src/`, `lib/`, `app/`, `backend/`, `frontend/`, etc.)
   - Identify configuration files (package.json, requirements.txt, Cargo.toml, etc.)
   - Identify test directories and test frameworks
   - Document the overall project organization

4. **Extract technology information**:
   - **Primary Language**: Detect from file extensions and configuration files
   - **Frameworks**: Identify web frameworks, UI libraries, backend frameworks
   - **Build Tools**: Package managers (npm, pip, cargo, maven, etc.), build systems
   - **Testing**: Test frameworks and testing patterns
   - **Database**: Database systems in use (if any)
   - **Dependencies**: Key dependencies from package files
   - **Deployment**: Docker, Kubernetes, CI/CD configurations (if present)

5. **Detect architectural patterns**:
   - Project type: Single application, monorepo, microservices, web app (frontend+backend), mobile app
   - Code organization: MVC, layered architecture, component-based, etc.
   - API patterns: REST, GraphQL, RPC (if applicable)
   - State management: Redux, Zustand, Context API, etc. (if applicable)

6. **Create or update project understanding document**:
   Create or update `.specify/project-understanding.md` with:
   - **Project Overview**: Brief description of what the project does
   - **Technology Stack**: Complete list of technologies detected
   - **Project Structure**: Directory tree and organization
   - **Build & Test**: How to build and test the project
   - **Key Patterns**: Architectural and code patterns identified
   - **Dependencies**: Major dependencies and their purposes
   - **Development Workflow**: Inferred workflow from structure and configs

7. **Update agent context file**:
   - Run `{AGENT_SCRIPT}` to update the agent-specific context file
   - The script will add the detected technology stack to "Active Technologies"
   - Add a "Recent Changes" entry: "Initial spec-kit integration: Documented existing codebase"
   - Preserve any existing manual additions between markers

8. **Generate summary report**:
   Output a summary including:
   - Technologies detected
   - Project structure identified
   - Agent context file location and status
   - Project understanding document location
   - Next steps: Suggest running `/speckit.constitution` to establish project principles

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

