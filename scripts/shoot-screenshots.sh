#!/usr/bin/env bash
# Regenerate README screenshots from the canonical HTML demo.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_FILE="$REPO_ROOT/docs/demo-report.html"
REPORT_SHOT="$REPO_ROOT/docs/screenshot-report.png"
TRACKER_SHOT="$REPO_ROOT/docs/screenshot-phishing-action.png"
MANIFEST="$REPO_ROOT/docs/screenshots.manifest"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/class-action-screenshots.XXXXXX")

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT INT TERM

NODE_BIN="${NODE_BIN:-}"
if [ -z "$NODE_BIN" ]; then
  NODE_BIN=$(command -v node || true)
fi

if [ -z "${PLAYWRIGHT_NODE_MODULES:-}" ] && \
  ! "${NODE_BIN:-false}" -e 'require.resolve("playwright")' >/dev/null 2>&1; then
  for candidate in \
    "$HOME"/.cache/codex-runtimes/*/dependencies/node/node_modules; do
    if [ -d "$candidate/playwright" ]; then
      PLAYWRIGHT_NODE_MODULES="$candidate"
      if [ -x "${candidate%/node_modules}/bin/node" ]; then
        NODE_BIN="${candidate%/node_modules}/bin/node"
      fi
      break
    fi
  done
fi

if [ -z "$NODE_BIN" ] || ! [ -x "$NODE_BIN" ]; then
  echo "Node.js is required to regenerate screenshots." >&2
  exit 1
fi

if [ -n "${PLAYWRIGHT_NODE_MODULES:-}" ]; then
  export NODE_PATH="$PLAYWRIGHT_NODE_MODULES${NODE_PATH:+:$NODE_PATH}"
fi

if ! "$NODE_BIN" -e 'require.resolve("playwright")' >/dev/null 2>&1; then
  echo "Playwright with Chromium is required to regenerate screenshots." >&2
  echo "Install Playwright or set PLAYWRIGHT_NODE_MODULES to its node_modules directory." >&2
  exit 1
fi

DEMO_FILE="$DEMO_FILE" TMP_ROOT="$TMP_ROOT" "$NODE_BIN" <<'NODE'
const { chromium } = require("playwright");
const fs = require("fs");
const { pathToFileURL } = require("url");

(async () => {
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage({
      viewport: { width: 1280, height: 950 },
      deviceScaleFactor: 1,
    });
    await page.goto(pathToFileURL(process.env.DEMO_FILE).href, {
      waitUntil: "load",
    });

    const bounds = await page.evaluate(() => {
      const rect = (selector) => {
        const element = document.querySelector(selector);
        if (!element) throw new Error(`Missing screenshot boundary: ${selector}`);
        const box = element.getBoundingClientRect();
        return {
          top: box.top + window.scrollY,
          bottom: box.bottom + window.scrollY,
        };
      };
      return {
        report: { top: rect(".hero").top, bottom: rect("#action-queue").bottom },
        tracker: { top: rect("#filed").top, bottom: rect("#security").bottom },
        documentHeight: document.documentElement.scrollHeight,
      };
    });

    await page.setViewportSize({
      width: 1280,
      height: Math.ceil(bounds.documentHeight),
    });

    const clip = ({ top, bottom }) => ({
      x: 0,
      y: Math.floor(top),
      width: 1280,
      height: Math.ceil(bottom) - Math.floor(top),
    });

    await page.screenshot({
      path: `${process.env.TMP_ROOT}/screenshot-report.png`,
      type: "png",
      clip: clip(bounds.report),
      animations: "disabled",
      caret: "hide",
      omitBackground: false,
    });
    await page.screenshot({
      path: `${process.env.TMP_ROOT}/screenshot-phishing-action.png`,
      type: "png",
      clip: clip(bounds.tracker),
      animations: "disabled",
      caret: "hide",
      omitBackground: false,
    });

    for (const name of ["screenshot-report.png", "screenshot-phishing-action.png"]) {
      const image = fs.readFileSync(`${process.env.TMP_ROOT}/${name}`);
      const colourType = image[25];
      if (colourType !== 2 && colourType !== 6) {
        throw new Error(`${name} is not a true-colour PNG`);
      }
    }
  } finally {
    await browser.close();
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
NODE

mv "$TMP_ROOT/screenshot-report.png" "$REPORT_SHOT"
mv "$TMP_ROOT/screenshot-phishing-action.png" "$TRACKER_SHOT"

if command -v shasum >/dev/null 2>&1; then
  demo_hash=$(shasum -a 256 "$DEMO_FILE" | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
  demo_hash=$(sha256sum "$DEMO_FILE" | awk '{print $1}')
else
  echo "A SHA-256 tool (shasum or sha256sum) is required." >&2
  exit 1
fi

printf '%s  %s\n' "$demo_hash" "docs/demo-report.html" >"$MANIFEST"
echo "Updated README screenshots and docs/screenshots.manifest."
