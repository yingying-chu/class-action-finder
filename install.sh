#!/bin/bash
# Install class-action skills into Claude's global skills directory
# Usage: ./install.sh

set -e

# Find the skills directory
SKILLS_BASE="$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin"

if [ ! -d "$SKILLS_BASE" ]; then
  echo "Error: Claude skills directory not found at:"
  echo "  $SKILLS_BASE"
  echo ""
  echo "Make sure Claude Code is installed and has been opened at least once."
  exit 1
fi

# Find the most recently modified session/plugin directory
SKILLS_DIR=$(find "$SKILLS_BASE" -name "skills" -type d | sort | tail -1)

if [ -z "$SKILLS_DIR" ]; then
  echo "Error: Could not find a 'skills' directory inside $SKILLS_BASE"
  exit 1
fi

echo "Installing to: $SKILLS_DIR"
echo ""

# Install each skill
for skill in skills/*/; do
  skill_name=$(basename "$skill")
  dest="$SKILLS_DIR/$skill_name"

  if [ -d "$dest" ]; then
    echo "  Updating $skill_name..."
    rm -rf "$dest"
  else
    echo "  Installing $skill_name..."
  fi

  cp -r "$skill" "$dest"
done

echo ""
echo "Done. Restart Claude Code for the skills to take effect."
echo ""
echo "Then try: /class-action-scanner"
