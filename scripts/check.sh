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
  "$SKILL_DIR/assets/app-icon.svg"
  "$SKILL_DIR/assets/logo-lockup.svg"
  "$SKILL_DIR/assets/logo-lockup-dark.svg"
  "$SKILL_DIR/assets/logo-mark.svg"
  "$SKILL_DIR/references/extraction-guide.md"
  "$SKILL_DIR/references/phishing-guide.md"
  "$SKILL_DIR/references/report-template.md"
  "$REPO_ROOT/docs/cost.md"
  "$REPO_ROOT/docs/demo-report.html"
  "$REPO_ROOT/docs/screenshots.manifest"
  "$REPO_ROOT/docs/screenshot-report.png"
  "$REPO_ROOT/docs/screenshot-phishing-action.png"
  "$REPO_ROOT/scripts/shoot-screenshots.sh"
  "$REPO_ROOT/scripts/audit-generated-report.py"
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
grep -q 'icon_small: "./assets/app-icon.svg"' \
  "$SKILL_DIR/agents/openai.yaml"
grep -q 'icon_large: "./assets/logo-lockup.svg"' \
  "$SKILL_DIR/agents/openai.yaml"
grep -q 'brand_color: "#22664F"' \
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
grep -q '| B | High-signal claim phrases \*\*in the body\*\*' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Opt-out language is an extraction field, not a discovery anchor' \
  "$SKILL_DIR/references/extraction-guide.md"
grep -q 'hero has exactly one currency-denominated summary' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Give each claim one lifecycle owner' \
  "$SKILL_DIR/SKILL.md"
grep -q 'A report described as complete must never contain a bucket such as `not individually searched`' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Never render a claim ID or PIN in Expired' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Use these exact IDs for report destinations' \
  "$SKILL_DIR/references/report-template.md"
grep -q 'Wrap the paid subsection heading and every paid card in exactly one `<div id="paid">' \
  "$SKILL_DIR/references/report-template.md"
python3 - "$SKILL_DIR/SKILL.md" <<'PYEOF'
import sys

body_search = next(
    (line for line in open(sys.argv[1], encoding='utf-8') if line.startswith('| B | High-signal claim phrases')),
    '',
)
if not body_search or '"opt out"' in body_search:
    raise SystemExit('The Part A body search is missing or contains standalone "opt out".')
PYEOF
grep -q '@media (max-width: 650px)' "$REPO_ROOT/docs/demo-report.html"
if grep -Eq 'Use at most 100|Keep at most 25|Hard ceiling of \*\*30|<details open>' \
  "$SKILL_DIR/SKILL.md" "$REPO_ROOT/README.md"; then
  echo "A fixed scan cap or auto-open installation panel was reintroduced." >&2
  exit 1
fi
grep -q 'Content-Security-Policy' "$REPO_ROOT/docs/demo-report.html"
if command -v shasum >/dev/null 2>&1; then
  demo_hash=$(shasum -a 256 "$REPO_ROOT/docs/demo-report.html" | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
  demo_hash=$(sha256sum "$REPO_ROOT/docs/demo-report.html" | awk '{print $1}')
else
  echo "A SHA-256 tool (shasum or sha256sum) is required." >&2
  exit 1
fi
screenshot_hash=$(awk 'NF {print $1; exit}' "$REPO_ROOT/docs/screenshots.manifest")
if [ "$demo_hash" != "$screenshot_hash" ]; then
  echo "demo-report.html changed since the screenshots were generated." >&2
  echo "Run ./scripts/shoot-screenshots.sh and commit the result." >&2
  exit 1
fi
# Coverage honesty: the funnel must name its folder split, not just a total.
grep -q 'class="coverage-state">Complete coverage' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q 'Inbox 72 · Spam 6 · Promotions 4' \
  "$REPO_ROOT/docs/demo-report.html"
# Responsive intent, without pinning values a designer may legitimately retune.
grep -q 'clamp(' "$REPO_ROOT/docs/demo-report.html"
grep -qE 'width: min\(100%, [0-9]+px\)' "$REPO_ROOT/docs/demo-report.html"
grep -qE 'href="#filed"><strong>[0-9]+</strong>Filed &amp; tracking' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q 'class="brand-mark"' "$REPO_ROOT/docs/demo-report.html"
grep -q 'position: sticky' "$REPO_ROOT/docs/demo-report.html"
grep -q 'position: static' "$REPO_ROOT/docs/demo-report.html"
grep -q 'grid-column: 1 / -1' "$REPO_ROOT/docs/demo-report.html"
grep -q '\.claim-row \.button' "$REPO_ROOT/docs/demo-report.html"
grep -q 'logo-lockup.svg' "$REPO_ROOT/README.md"
# The near-black wordmark vanishes on GitHub's dark theme without this pairing.
grep -q 'prefers-color-scheme: dark' "$REPO_ROOT/README.md"
grep -q 'logo-lockup-dark.svg' "$REPO_ROOT/README.md"
# The wordmark is outlined Inter Bold, not live <text>: a <text> element re-renders in
# whatever font the viewer happens to have, so the lockup must contain no text elements.
for lockup in "$SKILL_DIR/assets/logo-lockup.svg" "$SKILL_DIR/assets/logo-lockup-dark.svg"; do
  if grep -q '<text' "$lockup"; then
    echo "Wordmark in $lockup reverted to live <text>; re-run the outlining step." >&2
    exit 1
  fi
done
# The magnifier handle crosses a same-coloured envelope, so a lone #22664F stroke
# renders as nothing and the mark degrades into a check badge. The handle must stay a
# pair: a #22664F casing under a #F8F7F2 core sharing identical path data. Checked by
# shape, not by coordinates, so the handle can be redrawn without tripping this.
for art in "$SKILL_DIR/assets/logo-mark.svg" "$SKILL_DIR/assets/logo-lockup.svg" \
  "$SKILL_DIR/assets/logo-lockup-dark.svg" "$REPO_ROOT/docs/demo-report.html"; do
  if ! python3 - "$art" <<'PYEOF'
import re, sys
svg = open(sys.argv[1]).read()
strokes = {}
for m in re.finditer(r'<path\b[^>]*>', svg):
    tag = m.group(0)
    colour = re.search(r'stroke="(#[0-9A-Fa-f]{6})"', tag)
    data = re.search(r'\bd="([^"]+)"', tag)
    if colour and data:
        strokes.setdefault(data.group(1), set()).add(colour.group(1).upper())
if not any({'#22664F', '#F8F7F2'} <= c for c in strokes.values()):
    sys.exit(1)
PYEOF
  then
    echo "Magnifier handle in $art lost its casing/core stroke pair." >&2
    exit 1
  fi
done
# Cost figures live in one file so pricing drift cannot scatter through the README.
grep -q 'docs/cost.md' "$REPO_ROOT/README.md"
grep -q 'assets/logo-mark.svg' "$SKILL_DIR/SKILL.md"
# One navigation row, never two: a second row of section links was the confusing part.
test "$(grep -c '<nav' "$REPO_ROOT/docs/demo-report.html")" -eq 1
if grep -q 'Also in this report' "$REPO_ROOT/docs/demo-report.html"; then
  echo "A second navigation row was reintroduced into the report." >&2
  exit 1
fi
# Paid is a subsection of Filed & tracking, so it never gets a peer chip.
if grep -qE '<a href="#paid"[^>]*>' "$REPO_ROOT/docs/demo-report.html"; then
  echo "Paid was promoted to a top-level navigation chip." >&2
  exit 1
fi
# Every navigation chip states a count, and the empty sections are named once.
test "$(grep -c '<a href="#[a-z-]*"><strong>' "$REPO_ROOT/docs/demo-report.html")" -ge 4
grep -q 'class="nav-absent"' "$REPO_ROOT/docs/demo-report.html"
# Sections are visibly separated and long ones offer a way back.
grep -q 'border-top: 1px solid var(--line)' "$REPO_ROOT/docs/demo-report.html"
grep -q 'class="back-to-top"' "$REPO_ROOT/docs/demo-report.html"
grep -q 'id="top"' "$REPO_ROOT/docs/demo-report.html"
grep -q 'one compact pure-CSS \*\*section navigation\*\*' "$SKILL_DIR/SKILL.md"
grep -q 'Paid is never a peer chip' "$SKILL_DIR/SKILL.md"
grep -q 'The action queue owns every claim with an open, user-actionable deadline' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Activate benefit' "$SKILL_DIR/SKILL.md"
grep -q 'open, user-actionable deadline' \
  "$SKILL_DIR/references/report-template.md"
if grep -q 'four-item status strip' "$SKILL_DIR/SKILL.md"; then
  echo "SKILL.md still carries the superseded four-item mobile navigation rule." >&2
  exit 1
fi
grep -q 'at least the sticky row' "$SKILL_DIR/SKILL.md"
grep -q 'Use one section-navigation row, never two' \
  "$SKILL_DIR/references/report-template.md"
grep -q '<span class="label">Potential value</span>' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Open claim form' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Filed &amp; tracking' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Purchase matches to review' "$REPO_ROOT/docs/demo-report.html"
grep -q '🧾 Purchase match' "$REPO_ROOT/docs/demo-report.html"
grep -q 'Scan my purchases for class actions' "$REPO_ROOT/README.md"
grep -q "HTML report is saved in the installed skill's \`output/\` folder" \
  "$REPO_ROOT/README.md"
grep -q 'email funnel' "$SKILL_DIR/SKILL.md"
if grep -Eiq '<script| on[a-z]+=' "$REPO_ROOT/docs/demo-report.html"; then
  echo "Demo report contains a script or inline event handler." >&2
  exit 1
fi

# The official demo enforces the approved report design.
grep -q '\$25–\$735' "$REPO_ROOT/docs/demo-report.html"
for stage in '82 scanned' '6 notices' '5 verified' '2 need action'; do
  grep -q ">$stage<" "$REPO_ROOT/docs/demo-report.html"
done
grep -q 'Receipt coverage:' "$REPO_ROOT/docs/demo-report.html"
grep -q 'No additional open claims in this scan.' "$REPO_ROOT/docs/demo-report.html"
grep -q 'class="button secondary eligibility-button">Check eligibility' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q '\.eligibility-button { display: block;' \
  "$REPO_ROOT/docs/demo-report.html"
grep -q 'render the CTA as an `<a>` only when it points to a validated absolute `https://`' \
  "$SKILL_DIR/SKILL.md"
grep -q 'do not render them in the report' "$SKILL_DIR/SKILL.md"
grep -q 'The action queue owns every claim with an open, user-actionable deadline' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Never apply `white-space: nowrap` to a legitimacy or confidence rationale' \
  "$SKILL_DIR/SKILL.md"
grep -q 'Give those badges `max-width: 100%` and allow their evidence text to wrap' \
  "$SKILL_DIR/references/report-template.md"
grep -q 'give the anchor block formatting' \
  "$SKILL_DIR/references/report-template.md"
grep -q 'without `Section 1–5` numerals' "$SKILL_DIR/SKILL.md"
if sed '/without `Section 1–5` numerals/d' "$SKILL_DIR/SKILL.md" | \
  grep -E 'Sections? [1-5](–[1-5])?' >/dev/null; then
  echo "SKILL.md contains a legacy numbered lifecycle-section name." >&2
  exit 1
fi
for anchor in action-queue purchase-matches active watching expired filed security; do
  grep -q "id=\"$anchor\"" "$REPO_ROOT/docs/demo-report.html"
done
if grep -Eq '>Section [1-5]|[0-9]{1,3}% (confidence|verified|likely|legitimate)|<script| on[a-z]+=' \
  "$REPO_ROOT/docs/demo-report.html"; then
  echo "Demo report reintroduced section numerals, false precision, or active content." >&2
  exit 1
fi
python3 "$REPO_ROOT/scripts/audit-generated-report.py" \
  "$REPO_ROOT/docs/demo-report.html" >/dev/null

# Prove the generated-report audit rejects the launch-blocker failure classes.
BROKEN_REPORT="$TMP_ROOT/broken-generated-report.html"
BROKEN_AUDIT="$TMP_ROOT/broken-generated-report-audit.txt"
python3 - "$REPO_ROOT/docs/demo-report.html" "$BROKEN_REPORT" <<'PYEOF'
import re
import sys

source = open(sys.argv[1], encoding='utf-8').read()
source = source.replace('id="active"', 'id="sec1"', 1)
source = source.replace(
    '</header>',
    '<div>$9M total settlement fund</div><div class="hero-value">extra</div>'
    + ('<span>coverage detail </span>' * 230)
    + '</header>',
    1,
)
source = re.sub(
    r'(<section\b[^>]*\bid="sec1"[^>]*>)',
    r'\1<article><h3>Duplicate audit claim</h3></article>',
    source,
    count=1,
)
source = re.sub(
    r'(<section\b[^>]*\bid="filed"[^>]*>)',
    r'\1<article><h3>Duplicate audit claim</h3></article>',
    source,
    count=1,
)
source = re.sub(
    r'(<section\b[^>]*\bid="expired"[^>]*>)',
    r'\1<p>Claim ID: PRIVATE</p>',
    source,
    count=1,
)
source = source.replace('</body>', '<p>Not individually searched</p></body>', 1)
source = source.replace('<a href="#watching">', '<a href="#paid">', 1)
source = source.replace('id="top"', 'id="was-top"', 1)
source = source.replace('</nav>', '</nav><nav><span>Also in this report</span></nav>', 1)
source = source.replace('<strong>1</strong>Watching', '<strong>99</strong>Watching', 1)
source = source.replace('href="#top"', 'href="#nowhere"')
open(sys.argv[2], 'w', encoding='utf-8').write(source)
PYEOF
if python3 "$REPO_ROOT/scripts/audit-generated-report.py" \
  "$BROKEN_REPORT" >"$BROKEN_AUDIT" 2>&1; then
  echo "Generated-report audit accepted a deliberately broken report." >&2
  exit 1
fi
for expected in \
  'missing one or more required semantic anchors' \
  'uses a positional sec1-sec5 anchor' \
  'Hero exceeds the generated-report readability limit' \
  'Hero must contain exactly one hero-value element' \
  'Hero contains settlement-fund or closed-window money context' \
  'Hero contains currency outside hero-value' \
  'duplicated between Active and Filed' \
  'Expired contains a claim ID or PIN' \
  'complete report contains a not-individually-searched bucket' \
  'must have exactly one navigation row' \
  'contains a second navigation row' \
  'Paid was promoted to a top-level navigation chip' \
  'section with content has no navigation entry' \
  'no #top anchor for back-to-top links' \
  'navigation count does not match' \
  'back-to-top link does not target #top'; do
  grep -Fq "$expected" "$BROKEN_AUDIT"
done

# Removing the affordance and breaking its target are mutually exclusive defects,
# so the second one needs its own fixture.
NOBACK_REPORT="$TMP_ROOT/no-back-to-top-report.html"
NOBACK_AUDIT="$TMP_ROOT/no-back-to-top-audit.txt"
sed 's/class="back-to-top"/class="was-back-to-top"/g' \
  "$REPO_ROOT/docs/demo-report.html" >"$NOBACK_REPORT"
if python3 "$REPO_ROOT/scripts/audit-generated-report.py" \
  "$NOBACK_REPORT" >"$NOBACK_AUDIT" 2>&1; then
  echo "Generated-report audit accepted a report with no back-to-top affordance." >&2
  exit 1
fi
grep -Fq 'offers no back-to-top affordance' "$NOBACK_AUDIT"

# The first live v2 generator run omitted only the Paid destination, despite rendering
# paid cards. Prove that this exact one-anchor drift cannot pass by accident.
MISSING_PAID_REPORT="$TMP_ROOT/missing-paid-anchor.html"
MISSING_PAID_AUDIT="$TMP_ROOT/missing-paid-anchor-audit.txt"
python3 - "$REPO_ROOT/docs/demo-report.html" "$MISSING_PAID_REPORT" <<'PYEOF'
import sys

source = open(sys.argv[1], encoding='utf-8').read()
source = source.replace('id="paid"', 'id="paid-missing"', 1)
open(sys.argv[2], 'w', encoding='utf-8').write(source)
PYEOF
if python3 "$REPO_ROOT/scripts/audit-generated-report.py" \
  "$MISSING_PAID_REPORT" >"$MISSING_PAID_AUDIT" 2>&1; then
  echo "Generated-report audit accepted a missing paid anchor." >&2
  exit 1
fi
grep -Fq 'missing one or more required semantic anchors' "$MISSING_PAID_AUDIT"

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

# Build residue must never be tracked: running the audit script leaves a
# __pycache__ next to it, and one reached main this way.
if git -C "$REPO_ROOT" ls-files \
  | grep -E '__pycache__/|\.py[cod]$|\.DS_Store$' >/dev/null; then
  echo "A build cache or OS metadata file is tracked by git." >&2
  exit 1
fi

# Editor/Finder duplicates ("class-action-finder 2.zip") must never be tracked.
if git -C "$REPO_ROOT" ls-files | \
  grep -E ' [0-9]+\.[A-Za-z]+$| copy( [0-9]+)?\.' >/dev/null; then
  echo "A duplicate editor artifact is tracked by git." >&2
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
  if unzip -Z1 "$archive" | grep '/output/' >/dev/null; then
    echo "Packaged archive unexpectedly contains runtime output files." >&2
    exit 1
  fi
done

if [ -f "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" ]; then
  python3 "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
    "$SKILL_DIR"
fi

echo "All checks passed."
