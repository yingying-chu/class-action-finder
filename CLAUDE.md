# CLAUDE.md

This repo contains personal Claude Code slash commands stored in `.claude/commands/`.

## Commands in this repo

| Command | File | What it does |
|---|---|---|
| `/class-action-scanner` | `.claude/commands/class-action-scanner.md` | Scans Gmail for class action settlement emails |
| `/class-action-tracker` | `.claude/commands/class-action-tracker.md` | Tracks filed claims and payouts |

## Reference files (bundled in this repo)

The scanner reads these at runtime from `.claude/class-action-references/`:

| File | Purpose |
|---|---|
| `extraction-guide.md` | How to classify emails, extract fields, skip irrelevant threads |
| `phishing-guide.md` | Confidence scoring signals and known settlement administrator domains |
| `report-template.md` | Exact 5-section markdown table structure for the output report |

## Persistent claim data

Tracked claims are stored at `~/.claude/class-action-tracker.json` (on each user's own machine — not committed to this repo).

## Gmail MCP

Both commands use a Gmail MCP connected via Claude.ai integrations. The scanner automatically discovers it by looking for whichever MCP provides `search_threads` and `get_thread`.

See the Prerequisites section in README.md for setup instructions.
