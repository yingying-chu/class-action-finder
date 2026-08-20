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
grep -q 'Company name only — a possible match, never an automatic match' \
  "$SKILL_DIR/SKILL.md"
grep -q '# PART D — Match purchase confirmations to possible settlements' \
  "$SKILL_DIR/SKILL.md"
grep -q 'A bare `/class-action-finder`, `$class-action-finder`, or skill-name invocation is not ambiguous' \
  "$SKILL_DIR/SKILL.md"
grep -q 'settlement notices from the last 12 months' \
  "$SKILL_DIR/agents/openai.yaml"
grep -q 'Never put those values into a web search or report' \
  "$SKILL_DIR/SKILL.md"
grep -q '## Purchase Confirmation Extraction' \
  "$SKILL_DIR/references/extraction-guide.md"
grep -q '## Purchase Matches to Review' \
  "$SKILL_DIR/references/report-template.md"
grep -q 'forces the final score below 40% (🔴)' \
  "$SKILL_DIR/references/phishing-guide.md"
grep -q 'the `output/` directory that belongs to the skill copy being run' \
  "$REPO_ROOT/README.md"
grep -q 'Plugins → Skills → Create → Upload from your computer' \
  "$REPO_ROOT/README.md"
grep -q 'no fixed 100-message, 25-product, or 30-search ceiling' \
  "$REPO_ROOT/README.md"
grep -q 'there is no fixed search ceiling' "$SKILL_DIR/SKILL.md"
grep -q '@media (max-width: 650px)' "$REPO_ROOT/docs/demo-report.html"
grep -q 'font-size: clamp(28px, 8.5vw, 34px)' \
  "$REPO_ROOT/docs/demo-report.html"
if grep -Eq 'Use at most 100|Keep at most 25|Hard ceiling of \*\*30|<details open>' \
  "$SKILL_DIR/SKILL.md" "$REPO_ROOT/README.md"; then
  echo "A fixed scan cap or auto-open installation panel was reintroduced." >&2
  exit 1
fi
grep -q 'Content-Security-Policy' "$REPO_ROOT/docs/demo-report.html"
grep -q '82 emails processed (inbox: 72, spam: 6, promotions: 4)' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q 'class="email-funnel"' "$REPO_ROOT/docs/demo-report.html"
grep -q 'href="#section-1"><strong>2</strong>Active claims' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q 'Actionable potential value' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Open claim form' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Filed &amp; tracking' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Purchase matches to review' "$REPO_ROOT/docs/demo-report.html"
grep -q '🧾 Purchase match' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Scan my purchases for class actions' "$REPO_ROOT/README.md"
grep -q 'Tell the skill what you want' "$REPO_ROOT/README.md"
grep -q "HTML report is saved in the installed skill's \`output/\` folder" \
  "$REPO_ROOT/README.md"
grep -q 'email funnel' "$SKILL_DIR/SKILL.md"
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

TRACKED_SKILL="$REPO_ROOT/dist/class-action-finder.skill"
TRACKED_ZIP="$REPO_ROOT/dist/class-action-finder.zip"
unzip -tq "$TRACKED_SKILL" >/dev/null
unzip -tq "$TRACKED_ZIP" >/dev/null
cmp "$TRACKED_SKILL" "$TRACKED_ZIP"

mkdir -p "$TMP_ROOT/tracked-unpacked"
unzip -q "$TRACKED_SKILL" -d "$TMP_ROOT/tracked-unpacked"
diff -ru -x output "$SKILL_DIR" \
  "$TMP_ROOT/tracked-unpacked/class-action-finder"

GENERATED_DIST="$TMP_ROOT/generated-dist"
PACKAGE_DIST_DIR="$GENERATED_DIST" \
  "$REPO_ROOT/scripts/package-skill.sh" >/dev/null
GENERATED_SKILL="$GENERATED_DIST/class-action-finder.skill"
GENERATED_ZIP="$GENERATED_DIST/class-action-finder.zip"
unzip -tq "$GENERATED_SKILL" >/dev/null
unzip -tq "$GENERATED_ZIP" >/dev/null
cmp "$GENERATED_SKILL" "$GENERATED_ZIP"

cp "$GENERATED_SKILL" \
  "$TMP_ROOT/known-good.skill"
cp "$GENERATED_ZIP" \
  "$TMP_ROOT/known-good.zip"
if PACKAGE_DIST_DIR="$GENERATED_DIST" ZIP_BIN=false \
  "$REPO_ROOT/scripts/package-skill.sh" >/dev/null 2>&1; then
  echo "Packager unexpectedly succeeded with a failing ZIP command." >&2
  exit 1
fi
cmp "$TMP_ROOT/known-good.skill" \
  "$GENERATED_SKILL"
cmp "$TMP_ROOT/known-good.zip" \
  "$GENERATED_ZIP"

mkdir -p "$TMP_ROOT/unpacked"
unzip -q "$GENERATED_SKILL" -d "$TMP_ROOT/unpacked"
diff -ru -x output "$SKILL_DIR" \
  "$TMP_ROOT/unpacked/class-action-finder"

for archive in "$TRACKED_SKILL" "$GENERATED_SKILL"; do
  if unzip -Z1 "$archive" | grep -q '/output/'; then
    echo "Packaged archive unexpectedly contains runtime output files." >&2
    exit 1
  fi
done

if [ -f "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" ]; then
  python3 "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
    "$SKILL_DIR"
fi

echo "All checks passed."
