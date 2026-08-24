#!/usr/bin/env bash
# Regenerate Product Hunt upload assets from their HTML source and current demo shot.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="$REPO_ROOT/docs/product-hunt/gallery-source.html"
ASSET_DIR="$REPO_ROOT/docs/product-hunt"
MANIFEST="$ASSET_DIR/assets.manifest"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/class-action-product-hunt.XXXXXX")

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
  echo "Node.js is required to regenerate Product Hunt assets." >&2
  exit 1
fi

if [ -n "${PLAYWRIGHT_NODE_MODULES:-}" ]; then
  export NODE_PATH="$PLAYWRIGHT_NODE_MODULES${NODE_PATH:+:$NODE_PATH}"
fi

if ! "$NODE_BIN" -e 'require.resolve("playwright")' >/dev/null 2>&1; then
  echo "Playwright with Chromium is required to regenerate Product Hunt assets." >&2
  echo "Install Playwright or set PLAYWRIGHT_NODE_MODULES to its node_modules directory." >&2
  exit 1
fi

SOURCE_FILE="$SOURCE_FILE" TMP_ROOT="$TMP_ROOT" "$NODE_BIN" <<'NODE'
const { chromium } = require("playwright");
const fs = require("fs");
const { pathToFileURL } = require("url");

(async () => {
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage({
      viewport: { width: 1500, height: 2200 },
      deviceScaleFactor: 1,
    });
    await page.goto(pathToFileURL(process.env.SOURCE_FILE).href, { waitUntil: "load" });

    const assets = [
      { selector: "#thumbnail", name: "thumbnail.png", width: 240, height: 240 },
      { selector: "#gallery-one", name: "gallery-01-report.png", width: 1270, height: 760 },
      { selector: "#gallery-two", name: "gallery-02-workflow.png", width: 1270, height: 760 },
    ];

    for (const asset of assets) {
      if (asset.selector === "#thumbnail") {
        await page.evaluate(() => {
          document.body.style.background = "transparent";
        });
      }
      const locator = page.locator(asset.selector);
      const box = await locator.boundingBox();
      if (!box || Math.round(box.width) !== asset.width || Math.round(box.height) !== asset.height) {
        throw new Error(`${asset.selector} is not ${asset.width}x${asset.height}`);
      }
      await locator.screenshot({
        path: `${process.env.TMP_ROOT}/${asset.name}`,
        type: "png",
        animations: "disabled",
        caret: "hide",
        omitBackground: asset.selector === "#thumbnail",
      });
      const image = fs.readFileSync(`${process.env.TMP_ROOT}/${asset.name}`);
      const colourType = image[25];
      if (asset.selector === "#thumbnail" && colourType !== 6) {
        throw new Error("thumbnail.png must retain RGBA transparency");
      }
      if (asset.selector !== "#thumbnail" && colourType !== 2 && colourType !== 6) {
        throw new Error(`${asset.name} is not a true-colour PNG`);
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

for asset in thumbnail.png gallery-01-report.png gallery-02-workflow.png; do
  mv "$TMP_ROOT/$asset" "$ASSET_DIR/$asset"
done

manifest_files=(
  docs/product-hunt/gallery-source.html
  docs/product-hunt/thumbnail.png
  docs/product-hunt/gallery-01-report.png
  docs/product-hunt/gallery-02-workflow.png
  docs/screenshot-report.png
  skills/class-action-finder/assets/app-icon.svg
  skills/class-action-finder/assets/logo-lockup.svg
)

if command -v shasum >/dev/null 2>&1; then
  (cd "$REPO_ROOT" && shasum -a 256 "${manifest_files[@]}") >"$MANIFEST"
elif command -v sha256sum >/dev/null 2>&1; then
  (cd "$REPO_ROOT" && sha256sum "${manifest_files[@]}") >"$MANIFEST"
else
  echo "A SHA-256 tool (shasum or sha256sum) is required." >&2
  exit 1
fi

echo "Updated Product Hunt assets and docs/product-hunt/assets.manifest."
