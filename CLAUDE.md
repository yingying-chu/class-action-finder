# CLAUDE.md

This repo contains a single portable skill in `skills/class-action-finder/`. Run `./install.sh` to install it into Claude's global skills directory (`~/.claude/skills/`). Use `./install.sh --codex` for Codex.

## The skill

`class-action-finder` does three jobs that feed each other, in one `SKILL.md`:
- **Find notices** — scans the user's connected email for direct class action settlement notices and produces a styled HTML report (`SKILL.md` Part A)
- **Match purchases** — extracts minimal, non-sensitive evidence from purchase confirmations and checks public sources for potentially matching open settlements (`SKILL.md` Part D)
- **Remember** — reads and writes a persistent record of what the user has filed and been paid (`SKILL.md` Part B), and can refresh the current report after a correction without re-scanning email (Part C)

Purchase Match is deliberately separate from direct-notice discovery. It uses a source badge plus a categorical eligibility match, never treats a receipt as proof of class membership, never sends personal receipt details to web search, and does not persist purchase history automatically.

## Invocation defaults

- A bare skill invocation or a generic request to scan email for class actions runs **Part A — Notice Scan** for the previous 12 months.
- Purchase Match runs only when the user explicitly mentions purchases, receipts, orders, subscriptions, or something they bought; its default range is the previous 12 months. Step 2 measures the match count, then pages or adaptively partitions the requested range until it is completely covered. A wider range must never mean "take the provider's first page and stop."
- A request for both paths runs both defaults unless the user supplies another range, and announces the cost before starting.
- Record commands update the tracker only and do not scan the mailbox.

## Invariants worth protecting

These encode bugs that were found and fixed; don't regress them.

- **Parts A and D share one report file per day.** Part D Step 10 defines three merge cases. A purchase scan must never regenerate the file and blank out Sections 1–5.
- **Part D loads the tracker itself** (Step 2), so it can run without Part A.
- **Legitimacy and eligibility are separate judgments.** A 🟢 settlement can be a `possible` match; never collapse them into one score.
- **No skill-imposed coverage caps.** Do not stop after a fixed number of messages, product pairs, searches, or empty results. Finish every requested range. If a provider imposes a hard, non-pageable limit, adaptively partition by date; if complete coverage is technically impossible, say exactly what the provider prevented rather than presenting the result as complete.
- **Measure before scanning, and size partitions from density.** Part D Step 2 probes the match count first. Fixed-length segments are not a fix on their own — if each segment still overflows one page, recursively split the dense windows until the provider can return every result.
- **Read mail economically** (see that section). Always request plain text rather than the default HTML body; triage on search metadata before retrieving anything; page through matches instead of treating page one as the result set. Retrieve every remaining ambiguous candidate, but never retrieve messages that metadata already resolves. Reverting any of these silently multiplies cost several-fold.

It was previously two separate skills (`class-action-scanner` + `class-action-tracker`); they were merged so the record ↔ report loop lives in one place. If you see stale references to the old names anywhere, update them.

## Reference files

The skill reads these at runtime from its own `references/` directory:

| File | Purpose |
|---|---|
| `extraction-guide.md` | How to classify notices and purchase confirmations, extract minimal fields (incl. claim ID vs. PIN), and skip irrelevant threads |
| `phishing-guide.md` | Confidence scoring signals and known settlement administrator domains |
| `report-template.md` | Content guide for the 5 lifecycle sections plus Purchase Matches review panel |

## Brand assets

The skill's `assets/` directory contains the production SVG logo set:

| File | Purpose |
|---|---|
| `logo-mark.svg` | Transparent mark for generated report headers and light surfaces |
| `app-icon.svg` | Green square icon for compact skill UI placements |
| `logo-lockup.svg` | Horizontal wordmark for the repository README and large UI placements |

Generated reports remain self-contained. Inline the trusted static artwork from `logo-mark.svg` into the HTML rather than linking to a local file or placing the full wordmark on the report gradient.

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

`dist/class-action-finder.zip` is checked in for Claude uploads, and the byte-identical `dist/class-action-finder.skill` is checked in for ChatGPT. **After editing `SKILL.md`, `agents/openai.yaml`, an asset, or a reference file, re-run `./scripts/package-skill.sh` and commit both artifacts** so the download links stay current.

See README.md for setup instructions.
