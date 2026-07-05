# CLAUDE.md

This repo contains a single Claude skill in `skills/class-action-finder/`. Run `./install.sh` to install it into Claude's global skills directory (`~/.claude/skills/`) so it works across all projects.

## The skill

`class-action-finder` does two jobs that feed each other, in one `SKILL.md`:
- **Find** — scans the user's connected email for class action settlement notices and produces a styled HTML report (`SKILL.md` Part A)
- **Remember** — reads and writes a persistent record of what the user has filed and been paid (`SKILL.md` Part B), and can refresh the current report after a correction without re-scanning email (Part C)

It was previously two separate skills (`class-action-scanner` + `class-action-tracker`); they were merged so the record ↔ report loop lives in one place. If you see stale references to the old names anywhere, update them.

## Reference files

The skill reads these at runtime from its own `references/` directory:

| File | Purpose |
|---|---|
| `extraction-guide.md` | How to classify emails, extract fields (incl. claim ID vs. PIN), skip irrelevant threads |
| `phishing-guide.md` | Confidence scoring signals and known settlement administrator domains |
| `report-template.md` | Content guide for the 5-section HTML report |

## Persistent claim record

Stored at `~/.claude/class-action-tracker.json` on each user's own machine (not committed). The filename kept the `tracker` name for backward compatibility with existing data — don't rename it.

## Generated reports

Written to `skills/class-action-finder/output/` — relative to the skill's own installed directory, never the user's cwd or Desktop/Documents. That folder is gitignored (`*.html`, `*.json`) except for a `.gitkeep`, so reports stay local and the repo doesn't accumulate personal scan data.

## Mail MCP (Gmail-first, provider-adaptive)

The skill uses whichever connected mail MCP provides `search_threads` and `get_thread`. Gmail is the reference provider (Step 4's queries are Gmail syntax and give the fullest scan). Step 4 is deliberately provider-adaptive: it reads the connected MCP's search-tool schema, translates the four searches into that provider's syntax, and degrades gracefully (skipping spam/promotions sweeps where absent, flagging the gap). It only hard-stops if there's no working mail search at all. Don't reduce this back to Gmail-only.

## Claude.ai distribution (dist/)

`dist/class-action-finder.skill` is checked in (not gitignored) so the README download link works for people with no terminal. **After editing `SKILL.md` or a reference file, re-run `./scripts/package-for-claude-ai.sh` and commit the updated `.skill`** — otherwise the download link goes stale.

See README.md for setup instructions.
