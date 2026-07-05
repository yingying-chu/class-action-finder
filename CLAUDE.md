# CLAUDE.md

This repo contains Claude skills stored in `skills/`. Run `./install.sh` to install them into Claude's global skills directory so they work across all projects.

## Skills in this repo

| Skill | Directory | What it does |
|---|---|---|
| `class-action-scanner` | `skills/class-action-scanner/` | Scans Gmail for class action settlement emails |
| `class-action-tracker` | `skills/class-action-tracker/` | Tracks filed claims and payouts |

## Reference files

The scanner loads these at runtime from its own `references/` directory (bundled inside the skill):

| File | Purpose |
|---|---|
| `extraction-guide.md` | How to classify emails, extract fields, skip irrelevant threads |
| `phishing-guide.md` | Confidence scoring signals and known settlement administrator domains |
| `report-template.md` | Content guide for the 5-section HTML report output |

## Generated reports

The scanner writes HTML reports to `skills/class-action-scanner/output/` — relative to the skill's own installed directory, never the user's cwd or Desktop/Documents. That folder is gitignored (`*.html`) except for a `.gitkeep` placeholder, so reports stay local and the repo doesn't accumulate personal scan data.

## Claude.ai distribution (dist/)

`dist/class-action-scanner.skill` and `dist/class-action-tracker.skill` are checked into the repo (not gitignored) so README download links work for people with no terminal — they just click and upload straight to Claude.ai. **After editing either `SKILL.md`, re-run `./scripts/package-for-claude-ai.sh` and commit the updated `.skill` files** — otherwise those download links go stale and Claude.ai users get an outdated skill.

## Persistent claim data

Tracked claims are stored at `~/.claude/class-action-tracker.json` (on each user's own machine — not committed to this repo).

## Mail MCP (Gmail-first, provider-adaptive)

The scanner uses a mail MCP connected via Claude.ai integrations — whichever one provides `search_threads` and `get_thread`. No configuration needed.

**Gmail is the reference provider.** Step 4's four searches are written in Gmail syntax (`in:spam`, `category:promotions`, `after:YYYY/MM/DD`) and give the fullest scan (including spam/promotions folders). But Step 4 is deliberately **provider-adaptive**: it instructs the model to read the connected MCP's search-tool schema, translate the four searches into that provider's syntax, and degrade gracefully (skip spam/promotions sweeps where the provider has no such folders, flagging the gap in the report). It only hard-stops if there's no working mail search at all.

This adaptation is instruction-level, not a fabricated per-provider API — the model reads whatever mail MCP is actually connected and adapts. README's "Using a different email provider" section explains the same to users, and is explicit that providers with no Claude integration simply can't be reached (a limit of available integrations, not the skill).

See README.md for setup instructions.
