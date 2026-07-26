# CLAUDE.md

This repo contains a single portable skill in `skills/class-action-finder/`. Run `./install.sh` to install it into Claude's global skills directory (`~/.claude/skills/`). Use `./install.sh --codex` for Codex.

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

Stored on each user's own machine (not committed), per runtime:
- **Claude Code** — `~/.claude/class-action-tracker.json`
- **Codex** — `${CODEX_HOME:-$HOME/.codex}/class-action-tracker.json`

Neither platform's installer overwrites the other's tracker. The filename kept the `tracker` name for backward compatibility with existing data — don't rename it.

## Generated reports

Written to `output/` relative to the skill's own installed directory, never the user's cwd or Desktop/Documents. The whole folder is gitignored (everything under `output/` except a `.gitkeep`), so a generated report is **local-only and can never be committed or pushed to the origin repo** — this holds for anyone who clones or forks the project, not just the maintainer. Reports stay on the machine that ran the scan.

A user may redirect the installed skill's `output/` to a more convenient, still-gitignored location (for example, symlink it into a project checkout so reports are easy to find). `install.sh` detects a symlinked `output/` and preserves the link across reinstalls rather than replacing it with a fresh directory.

## Mail tools (Gmail-first, provider-adaptive)

The skill uses whichever connected mail app, connector, or MCP can search mail and retrieve complete results. Gmail is the reference provider (Step 4's queries are Gmail syntax and give the fullest scan). Step 4 is deliberately provider-adaptive: it reads the connected tool's search schema, translates the four searches into that provider's syntax, and degrades gracefully (skipping spam/promotions sweeps where absent, flagging the gap). It only hard-stops if there's no working mail search at all. Don't reduce this back to Gmail-only or hard-code one provider's tool names.

## Portable distribution (dist/)

`dist/class-action-finder.zip` is checked in for Claude uploads, and the byte-identical `dist/class-action-finder.skill` is checked in for ChatGPT. **After editing `SKILL.md`, `agents/openai.yaml`, or a reference file, re-run `./scripts/package-skill.sh` and commit both artifacts** — otherwise the download links go stale.

See README.md for setup instructions.
