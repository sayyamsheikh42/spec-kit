# Universal Command Execution Rules

This file contains universal rules that apply to all Spec Kit commands. These rules are automatically injected into every generated command file during the release build process.

## Post-Execution Behavior

After completing the main command workflow, consider if any follow-up actions are needed:

- **Documentation**: Update relevant documentation if the command created or modified artifacts
- **Validation**: Verify that all generated files are correct and complete
- **Reporting**: Provide clear summary of what was accomplished and next steps

## Error Handling

All commands should:
- Provide clear error messages with actionable guidance
- Exit gracefully on errors (don't crash the agent)
- Report partial completion if some steps succeeded
- Suggest corrective actions when possible

## Output Quality

- Use consistent formatting and structure
- Provide absolute paths for all file references
- Include validation checkpoints where appropriate
- Report completion status clearly

