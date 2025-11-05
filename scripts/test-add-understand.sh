#!/usr/bin/env bash
# Quick test script to manually add understand command to an existing project
# Usage: ./scripts/test-add-understand.sh /path/to/your/project [agent]

set -e

PROJECT_PATH="${1:-.}"
AGENT="${2:-claude}"

if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Project path not found: $PROJECT_PATH" >&2
    exit 1
fi

cd "$PROJECT_PATH"

# Determine agent directory and format
case "$AGENT" in
    claude)
        CMD_DIR=".claude/commands"
        CMD_FILE="speckit.understand.md"
        ;;
    cursor-agent)
        CMD_DIR=".cursor/commands"
        CMD_FILE="speckit.understand.md"
        ;;
    gemini)
        CMD_DIR=".gemini/commands"
        CMD_FILE="speckit.understand.toml"
        echo "Note: TOML conversion needed for Gemini" >&2
        ;;
    qwen)
        CMD_DIR=".qwen/commands"
        CMD_FILE="speckit.understand.toml"
        echo "Note: TOML conversion needed for Qwen" >&2
        ;;
    *)
        echo "Agent $AGENT not supported yet. Use: claude, cursor-agent, gemini, qwen" >&2
        exit 1
        ;;
esac

# Create directory
mkdir -p "$CMD_DIR"

# Copy template (this is a simplified version - in real release, it would be processed)
if [[ "$CMD_FILE" == *.md ]]; then
    # For Markdown agents, we need to process the template
    echo "Creating $CMD_DIR/$CMD_FILE..."
    # In a real scenario, the release script processes this
    # For now, just copy the template
    if [[ -f "templates/commands/understand.md" ]]; then
        cp "templates/commands/understand.md" "$CMD_DIR/$CMD_FILE"
        echo "✅ Added understand command to $CMD_DIR/$CMD_FILE"
        echo "Note: This is a test - in production, the release script processes the template"
    else
        echo "Error: Template not found. Make sure you're in the spec-kit repo or have the template." >&2
        exit 1
    fi
else
    echo "TOML format not yet supported in this test script" >&2
    exit 1
fi

echo ""
echo "Command added! You can now use /speckit.understand in your agent."

