# Release v0.0.80 - Draft Release Notes

## New Features

### ✨ New `/speckit.understand` Command
- Analyze existing codebases and document project structure
- Automatically detect technology stack, frameworks, and patterns
- Generate comprehensive project understanding document
- Update agent context files with detected technologies
- Follows peer's "thin script" pattern for consistency

### 📋 Command Rules Injection
- Universal `command-rules.md` automatically injected into all commands
- Provides consistent behavior across all spec-kit commands
- Rules file excluded from final packages (build metadata only)

### 📜 Constitution Plus Support
- `constitutionplus.md` can override `constitution.md` in releases
- Allows maintaining enhanced constitution variants
- Excluded from final packages (build metadata only)

### 🤖 Protocol Templates
- New `protocol-templates/` directory for universal agent protocols
- `AGENTS.md` automatically generated for all agents
- Agent-specific files created (e.g., `.cursor/rules/guidelines.md`, `GEMINI.md`)
- Separates universal protocols from project-specific memory files

### 📦 PyPI Publishing Workflow
- New `.github/workflows/pypi.yml` for PyPI publishing
- Supports manual and tag-based triggers
- Configurable for trusted publishing or API token

### 📝 Pull Request Template
- Comprehensive PR template for better code reviews
- Includes testing checklist, impact assessment, and documentation checks

## Technical Improvements

### Script Architecture
- Refactored `understand` command to follow peer's pattern:
  - Thin scripts create files with placeholders
  - AI fills in placeholders after creation
  - Consistent with ADR/PHR command patterns

### Release Process
- Enhanced release script to handle:
  - Command rules injection
  - Constitution plus override
  - Protocol templates generation
  - Agent-specific file creation

## Files Added

- `templates/commands/understand.md` - New understand command
- `scripts/bash/create-project-understanding.sh` - Thin script for creating project understanding files
- `scripts/powershell/create-project-understanding.ps1` - PowerShell version
- `memory/command-rules.md` - Universal command execution rules
- `memory/constitutionplus.md` - Enhanced constitution template
- `protocol-templates/AGENTS.md` - Universal agent instructions
- `protocol-templates/README.md` - Protocol templates documentation
- `.github/workflows/pypi.yml` - PyPI publishing workflow
- `.github/pull_request_template.md` - PR template

## Files Modified

- `templates/understand-template.md` - Now uses `{{PLACEHOLDER}}` syntax
- `templates/commands/understand.md` - Refactored to follow peer's pattern
- `.github/workflows/scripts/create-release-packages.sh` - Added command-rules injection, constitutionplus support, protocol templates generation

## Breaking Changes

None - this is a feature release with backward compatibility.

## Migration Notes

- Existing projects will get new commands when they re-initialize or update
- New projects automatically include all new features
- `command-rules.md` and `constitutionplus.md` are build metadata only (not in packages)

