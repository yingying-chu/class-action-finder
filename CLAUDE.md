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
| `report-template.md` | Exact 5-section markdown table structure for the output report |

## Persistent claim data

Tracked claims are stored at `~/.claude/class-action-tracker.json` (on each user's own machine — not committed to this repo).

## Gmail MCP

The scanner uses a Gmail MCP connected via Claude.ai integrations. It automatically discovers whichever MCP provides `search_threads` and `get_thread` — no configuration needed.

See README.md for setup instructions.
