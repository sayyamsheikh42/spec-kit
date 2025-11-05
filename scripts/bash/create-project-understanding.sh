#!/usr/bin/env bash
set -euo pipefail

# create-project-understanding.sh - Create a new Project Understanding document deterministically
#
# This script ONLY:
#   1. Creates the correct directory structure (.specify/)
#   2. Copies the template with {{PLACEHOLDERS}} intact
#   3. Returns metadata (path, template) for AI to fill in
#
# The calling AI agent is responsible for filling {{PLACEHOLDERS}}
#
# Usage:
#   scripts/bash/create-project-understanding.sh \
#     [--json]

JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --help|-h)
      cat <<EOF
Usage: $0 [options]

Optional:
  --json               Output JSON with path and template info

Output:
  Creates project-understanding.md file with template placeholders ({{PROJECT_NAME}}, {{DATE}}, etc.)
  AI agent must fill these placeholders after creation

Examples:
  $0 --json
  $0
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SPECIFY_DIR="$REPO_ROOT/.specify"
mkdir -p "$SPECIFY_DIR"

# Check for template (try both locations)
TPL=""
if [[ -f "$REPO_ROOT/.specify/templates/understand-template.md" ]]; then
  TPL="$REPO_ROOT/.specify/templates/understand-template.md"
elif [[ -f "$REPO_ROOT/templates/understand-template.md" ]]; then
  TPL="$REPO_ROOT/templates/understand-template.md"
else
  echo "Error: understand-template.md not found at .specify/templates/ or templates/" >&2
  exit 1
fi

OUTFILE="$SPECIFY_DIR/project-understanding.md"

# Simply copy the template (AI will fill placeholders)
cp "$TPL" "$OUTFILE"

ABS=$(cd "$(dirname "$OUTFILE")" && pwd)/$(basename "$OUTFILE")
if $JSON; then
  printf '{"path":"%s","template":"%s"}\n' "$ABS" "$(basename "$TPL")"
else
  echo "✅ Project Understanding template copied → $ABS"
  echo "Note: AI agent should now fill in {{PLACEHOLDERS}}"
fi

