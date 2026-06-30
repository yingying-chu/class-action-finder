#!/bin/bash
# Install class-action skills into Claude Code's global skills directory
# Usage: ./install.sh

set -e

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

echo "Installing to: $SKILLS_DIR"
echo ""

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
echo "Or just say: \"scan my email for class action settlements\""
