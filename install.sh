#!/usr/bin/env bash
# Install skills into Claude Code (default) or Codex.
# Usage: ./install.sh [--codex|--claude]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:---claude}"

case "$TARGET" in
  --codex)
    SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
    PRODUCT="Codex"
    INVOCATION='$class-action-finder'
    ;;
  --claude)
    SKILLS_DIR="$HOME/.claude/skills"
    PRODUCT="Claude Code"
    INVOCATION='/class-action-finder'
    ;;
  *)
    echo "Usage: ./install.sh [--codex|--claude]" >&2
    exit 2
    ;;
esac

mkdir -p "$SKILLS_DIR"

echo "Installing for $PRODUCT to: $SKILLS_DIR"
echo ""

for skill in "$REPO_ROOT"/skills/*/; do
  skill_name=$(basename "$skill")
  dest="$SKILLS_DIR/$skill_name"
  stage_root=$(mktemp -d "$SKILLS_DIR/.${skill_name}.install.XXXXXX")
  staged="$stage_root/new"
  previous="$stage_root/previous"

  cleanup() {
    if [ -d "$previous" ] && [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
      mv "$previous" "$dest"
    fi
    rm -rf "$stage_root"
  }
  trap cleanup EXIT INT TERM

  if [ -L "$dest" ]; then
    echo "Refusing to replace symlink: $dest" >&2
    exit 1
  fi

  mkdir -p "$staged"
  cp -R "$skill"/. "$staged"/

  if [ -d "$dest" ]; then
    echo "  Updating $skill_name..."

    # Reports are private runtime data. Preserve them when refreshing the
    # installed skill from this repository.
    if [ -d "$dest/output" ]; then
      mkdir -p "$staged/output"
      cp -R "$dest/output"/. "$staged/output"/
    fi

    mv "$dest" "$previous"
  else
    echo "  Installing $skill_name..."
  fi

  if ! mv "$staged" "$dest"; then
    if [ -d "$previous" ]; then
      mv "$previous" "$dest"
    fi
    echo "Install failed; restored the previous $skill_name installation." >&2
    exit 1
  fi

  rm -rf "$previous"
  cleanup
  trap - EXIT INT TERM
done

echo ""
echo "Done. Restart $PRODUCT for the skill to take effect."
echo ""
echo "Then try: $INVOCATION"
echo "Or just say: \"scan my email for class action settlements\""
