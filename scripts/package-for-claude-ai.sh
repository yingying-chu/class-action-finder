#!/bin/bash
# Package skills as .skill files for upload to Claude.ai / Claude apps
# (Settings -> Capabilities -> Skills -> Upload skill), instead of the
# ~/.claude/skills/ install path used by Claude Code.
#
# Usage: ./scripts/package-for-claude-ai.sh

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

mkdir -p "$DIST_DIR"

for skill in "$REPO_ROOT"/skills/*/; do
  skill_name=$(basename "$skill")
  out_file="$DIST_DIR/$skill_name.skill"

  echo "Packaging $skill_name..."

  # cd into skills/ so the zip's top-level entry is the skill folder itself
  # (e.g. class-action-finder/SKILL.md), matching what Claude.ai expects.
  # Exclude the runtime output/ folder — reports there are a local Claude Code
  # concept and don't belong in an uploaded skill (Claude.ai returns the report
  # in-conversation instead).
  rm -f "$out_file"
  (cd "$REPO_ROOT/skills" && zip -rq "$out_file" "$skill_name" \
    -x "*.DS_Store" "*/output/*" "*/output")

  echo "  -> $out_file"
done

echo ""
echo "Done. Upload the .skill files in dist/ at:"
echo "  claude.ai -> Settings -> Capabilities -> Skills -> Upload skill"
