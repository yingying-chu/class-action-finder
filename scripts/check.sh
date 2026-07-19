#!/usr/bin/env bash
# Run repository-level structural, install, and package checks.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/class-action-finder"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/class-action-finder-check.XXXXXX")

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT INT TERM

required_files=(
  "$SKILL_DIR/SKILL.md"
  "$SKILL_DIR/agents/openai.yaml"
  "$SKILL_DIR/references/extraction-guide.md"
  "$SKILL_DIR/references/phishing-guide.md"
  "$SKILL_DIR/references/report-template.md"
  "$REPO_ROOT/docs/demo-report.html"
  "$REPO_ROOT/docs/screenshot-report.png"
  "$REPO_ROOT/docs/screenshot-phishing-action.png"
)

for file in "${required_files[@]}"; do
  test -f "$file"
done

grep -q '^name: class-action-finder$' "$SKILL_DIR/SKILL.md"
grep -q '^description:' "$SKILL_DIR/SKILL.md"
grep -q 'Content-Security-Policy' "$REPO_ROOT/docs/demo-report.html"
if grep -Eiq '<script| on[a-z]+=' "$REPO_ROOT/docs/demo-report.html"; then
  echo "Demo report contains a script or inline event handler." >&2
  exit 1
fi

bash -n \
  "$REPO_ROOT/install.sh" \
  "$REPO_ROOT/scripts/package-skill.sh"

mkdir -p "$TMP_ROOT/unrelated-cwd"
mkdir -p "$TMP_ROOT/claude-home/.claude/skills/other-skill"
printf '%s\n' "leave me alone" \
  >"$TMP_ROOT/claude-home/.claude/skills/other-skill/sentinel.txt"
printf '%s\n' '{"filed_claims":[],"watch_list":[]}' \
  >"$TMP_ROOT/claude-home/.claude/class-action-tracker.json"

(
  cd "$TMP_ROOT/unrelated-cwd"
  HOME="$TMP_ROOT/claude-home" "$REPO_ROOT/install.sh" --claude >/dev/null
)
CLAUDE_SKILL="$TMP_ROOT/claude-home/.claude/skills/class-action-finder"
test -f "$CLAUDE_SKILL/SKILL.md"
grep -q "leave me alone" \
  "$TMP_ROOT/claude-home/.claude/skills/other-skill/sentinel.txt"
grep -q '"filed_claims"' \
  "$TMP_ROOT/claude-home/.claude/class-action-tracker.json"

mkdir -p "$CLAUDE_SKILL/output"
printf '%s\n' "preserve me" >"$CLAUDE_SKILL/output/existing-report.html"
(
  cd "$TMP_ROOT/unrelated-cwd"
  HOME="$TMP_ROOT/claude-home" "$REPO_ROOT/install.sh" --claude >/dev/null
)
grep -q "preserve me" "$CLAUDE_SKILL/output/existing-report.html"

(
  cd "$TMP_ROOT/unrelated-cwd"
  CODEX_HOME="$TMP_ROOT/codex-home" "$REPO_ROOT/install.sh" --codex >/dev/null
)
test -f "$TMP_ROOT/codex-home/skills/class-action-finder/SKILL.md"

mkdir -p "$TMP_ROOT/symlink-home/.claude/skills"
mkdir -p "$TMP_ROOT/symlink-target"
ln -s "$TMP_ROOT/symlink-target" \
  "$TMP_ROOT/symlink-home/.claude/skills/class-action-finder"
if HOME="$TMP_ROOT/symlink-home" \
  "$REPO_ROOT/install.sh" --claude >/dev/null 2>&1; then
  echo "Installer unexpectedly replaced a symlinked destination." >&2
  exit 1
fi
test -L "$TMP_ROOT/symlink-home/.claude/skills/class-action-finder"

if "$REPO_ROOT/install.sh" --unknown >/dev/null 2>&1; then
  echo "Installer unexpectedly accepted an unknown target." >&2
  exit 1
fi

"$REPO_ROOT/scripts/package-skill.sh" >/dev/null
unzip -tq "$REPO_ROOT/dist/class-action-finder.skill" >/dev/null
unzip -tq "$REPO_ROOT/dist/class-action-finder.zip" >/dev/null
cmp "$REPO_ROOT/dist/class-action-finder.skill" \
  "$REPO_ROOT/dist/class-action-finder.zip"

cp "$REPO_ROOT/dist/class-action-finder.skill" \
  "$TMP_ROOT/known-good.skill"
cp "$REPO_ROOT/dist/class-action-finder.zip" \
  "$TMP_ROOT/known-good.zip"
if ZIP_BIN=false "$REPO_ROOT/scripts/package-skill.sh" >/dev/null 2>&1; then
  echo "Packager unexpectedly succeeded with a failing ZIP command." >&2
  exit 1
fi
cmp "$TMP_ROOT/known-good.skill" \
  "$REPO_ROOT/dist/class-action-finder.skill"
cmp "$TMP_ROOT/known-good.zip" \
  "$REPO_ROOT/dist/class-action-finder.zip"

mkdir -p "$TMP_ROOT/unpacked"
unzip -q "$REPO_ROOT/dist/class-action-finder.skill" -d "$TMP_ROOT/unpacked"
diff -ru -x output "$SKILL_DIR" \
  "$TMP_ROOT/unpacked/class-action-finder"

if unzip -Z1 "$REPO_ROOT/dist/class-action-finder.skill" |
  grep -q '/output/'; then
  echo "Packaged archive unexpectedly contains runtime output files." >&2
  exit 1
fi

if [ -f "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" ]; then
  python3 "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
    "$SKILL_DIR"
fi

echo "All checks passed."
