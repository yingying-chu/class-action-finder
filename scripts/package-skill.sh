#!/usr/bin/env bash
# Package each skill as portable archives for Claude and ChatGPT.
# Usage: ./scripts/package-skill.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"
ZIP_BIN="${ZIP_BIN:-zip}"
UNZIP_BIN="${UNZIP_BIN:-unzip}"

mkdir -p "$DIST_DIR"

for skill in "$REPO_ROOT"/skills/*/; do
  skill_name=$(basename "$skill")
  skill_file="$DIST_DIR/$skill_name.skill"
  zip_file="$DIST_DIR/$skill_name.zip"
  stage_root=$(mktemp -d "$DIST_DIR/.${skill_name}.package.XXXXXX")
  staged_archive="$stage_root/$skill_name.zip"
  staged_skill="$stage_root/$skill_name.skill"
  previous_skill="$stage_root/previous.skill"
  previous_zip="$stage_root/previous.zip"
  publishing=0

  cleanup() {
    if [ "$publishing" -eq 1 ]; then
      rm -f "$skill_file" "$zip_file"
      if [ -f "$previous_skill" ]; then
        mv "$previous_skill" "$skill_file"
      fi
      if [ -f "$previous_zip" ]; then
        mv "$previous_zip" "$zip_file"
      fi
    fi
    rm -rf "$stage_root"
  }
  trap cleanup EXIT INT TERM

  echo "Packaging $skill_name..."

  # Keep the skill folder as the archive's single top-level entry. Runtime
  # reports are private local artifacts and never belong in distribution.
  (
    cd "$REPO_ROOT/skills"
    "$ZIP_BIN" -rq "$staged_archive" "$skill_name" \
      -x "*.DS_Store" "*/output/*" "*/output"
  )

  "$UNZIP_BIN" -tq "$staged_archive" >/dev/null

  # Build first, then replace both public artifacts so a packaging failure
  # never destroys the last known-good release.
  cp "$staged_archive" "$staged_skill"

  publishing=1
  if [ -f "$skill_file" ]; then
    mv "$skill_file" "$previous_skill"
  fi
  if [ -f "$zip_file" ]; then
    mv "$zip_file" "$previous_zip"
  fi

  if ! mv "$staged_skill" "$skill_file" ||
    ! mv "$staged_archive" "$zip_file"; then
    cleanup
    echo "Packaging failed; restored the previous release artifacts." >&2
    exit 1
  fi

  publishing=0
  cleanup
  trap - EXIT INT TERM

  echo "  -> $skill_file (ChatGPT)"
  echo "  -> $zip_file (Claude)"
done

echo ""
echo "Done. Upload the .zip file to Claude or the .skill file to ChatGPT."
