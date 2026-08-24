# CLAUDE.md

This repo contains a single portable skill in `skills/class-action-finder/`. Run `./install.sh` to install it into Claude's global skills directory (`~/.claude/skills/`). Use `./install.sh --codex` for Codex.

## The skill

`class-action-finder` does three jobs that feed each other, in one `SKILL.md`:
- **Find notices** — scans the user's connected email for direct class action settlement notices and produces a styled HTML report (`SKILL.md` Part A)
- **Match purchases** — extracts minimal, non-sensitive evidence from purchase confirmations and checks public sources for potentially matching open settlements (`SKILL.md` Part D)
- **Remember** — reads and writes a persistent record of what the user has filed and been paid (`SKILL.md` Part B), and can refresh the current report after a correction without re-scanning email (Part C)

Purchase Match is deliberately separate from direct-notice discovery. It uses a source badge plus a categorical eligibility match, never treats a receipt as proof of class membership, never sends personal receipt details to web search, and does not persist purchase history automatically.

## Architecture

```text
Connected mail
    │
    ├── Direct notices                      (SKILL.md Part A)
    │     Search inbox, spam, and promotions
    │     Verify case and score legitimacy
    │     Extract deadlines, payouts, IDs, PINs, and claim URLs
    │
    └── Purchase confirmations              (SKILL.md Part D)
          Extract merchant, product, and purchase date only
          Search verified public settlement sources
          Compare product, class period, and eligibility facts
                  │
                  ▼
        Match settlement identity
                  │
            ┌─────┴─────┐
            ▼           ▼
      Tracker JSON   HTML report
      filed + paid   actions + reviews + alerts
            │           │
            └─ refresh ─┘            (SKILL.md Parts B and C)
```

```text
class-action-finder/
├── README.md                 user-facing
├── CLAUDE.md                 this file — contributor source of truth
├── AGENTS.md                 pointer to this file for Codex
├── install.sh                --claude (default) | --codex
├── skills/class-action-finder/
│   ├── SKILL.md              the portable workflow (Parts A–D)
│   ├── agents/openai.yaml    ChatGPT interface metadata
│   ├── assets/               brand SVGs
│   ├── references/           runtime-loaded guides
│   └── output/               generated reports (gitignored)
├── scripts/                  package-skill.sh, shoot-screenshots.sh, check.sh
├── dist/                     .zip + byte-identical .skill
└── docs/                     demo report, screenshots, cost model
```

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
- **Footer language is not a discovery signal.** Never search the mail body for standalone `opt out`, `unsubscribe`, or `manage preferences`: marketing footers make those terms match at mailbox scale. Opt-out deadlines are extracted only after another signal establishes a settlement candidate. If a search proves footer-dominated, refine it and complete the corrected search rather than sampling the noise and stopping.
- **Hero money always means the user's actionable estimate.** The hero has one currency summary only. Never sum settlement funds or present a total fund as the user's payout, potential value, or missed money. Fund sizes belong only on their individual case cards with an explicit `Total settlement fund` label.
- **One lifecycle owner per claim.** Unfiled verified actions belong in the action queue, open 🟠 verification cases belong in Active claims, and filed or auto-enrolled claims belong in Filed & tracking even while their windows remain open. Never duplicate a full card between Active claims and Filed & tracking.
- **Purchase coverage has two layers.** Completing the mailbox traversal does not prove that every product/service pair was classified. A complete report needs a terminal classification for every pair, and cannot contain a `not individually searched` bucket. Negative-result disclosures use compact category counts and never persist a named list of healthcare providers.
- **Generated-report destinations are semantic.** Use `action-queue`, `purchase-matches`, `active`, `watching`, `expired`, `filed`, `paid`, and `security`; positional IDs such as `sec1` are drift. Filed & tracking always contains exactly one `<div id="paid">...</div>`, even when the paid subset is empty.

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
| `logo-lockup.svg` | Horizontal wordmark for the README and large UI placements (light backgrounds) |
| `logo-lockup-dark.svg` | Dark-background wordmark. The README pairs it with the light one via `<picture>` + `prefers-color-scheme`; without it the near-black wordmark is invisible on GitHub's dark theme. |

**The magnifier handle must stay visible.** It is drawn as two stacked strokes — a `#22664F` casing under a `#F8F7F2` core — because the handle crosses the same-colour envelope. A single `#22664F` stroke there renders as nothing at all (the mark then reads as a check badge, not a finder), which is exactly the bug this pairing fixes. `app-icon.svg` achieves the same result with a plain white stroke only because its green square backdrop supplies the casing.

Generated reports remain self-contained. Inline the trusted static artwork from `logo-mark.svg` into the HTML rather than linking to a local file or placing the full wordmark on the report gradient.

## Persistent claim record

Stored on each user's own machine (not committed), per runtime:
- **Claude Code** — `~/.claude/class-action-tracker.json`
- **Codex** — `${CODEX_HOME:-$HOME/.codex}/class-action-tracker.json`

Neither platform's installer overwrites the other's tracker. The filename kept the `tracker` name for backward compatibility with existing data — don't rename it.

## Generated reports

Written to `output/` relative to the skill's own installed directory, never the user's cwd or Desktop/Documents. The whole folder is gitignored (everything under `output/` except a `.gitkeep`), so a generated report is **local-only and can never be committed or pushed to the origin repo** — this holds for anyone who clones or forks the project, not just the maintainer. Reports stay on the machine that ran the scan.

A user may redirect the installed skill's `output/` to a more convenient, still-gitignored location (for example, symlink it into a project checkout so reports are easy to find). `install.sh` detects a symlinked `output/` and preserves the link across reinstalls rather than replacing it with a fresh directory.

For a private live-run report, use `python3 scripts/audit-generated-report.py /absolute/path/to/report.html`. The audit reports structural failures without printing case names, claim IDs, PINs, merchant names, or other report contents. It checks rules that can be established from HTML, including semantic anchors, hero money placement, gross hero density, Active/Filed duplication, expired identifiers, coverage contradictions, CSP, links, and active content. It does not replace a rendered desktop/mobile review or prove that a model followed the underlying scan workflow.

## Demo screenshots

The README screenshots are build products of `docs/demo-report.html`, not independent assets. After changing the demo HTML, run `./scripts/shoot-screenshots.sh` and commit both PNGs plus `docs/screenshots.manifest`. The script renders at 1280px, derives both crop regions from live DOM boundaries, and writes true-colour PNGs. `scripts/check.sh` compares the demo's SHA-256 with the manifest so stale screenshots cannot pass CI; it does not require a browser itself.

## Mail tools (Gmail-first, provider-adaptive)

The skill uses whichever connected mail app, connector, or MCP can search mail and retrieve complete results. Gmail is the reference provider (Step 4's queries are Gmail syntax and give the fullest scan). Step 4 is deliberately provider-adaptive: it reads the connected tool's search schema, translates the four searches into that provider's syntax, and degrades gracefully (skipping spam/promotions sweeps where absent, flagging the gap). It only hard-stops if there's no working mail search at all. Don't reduce this back to Gmail-only or hard-code one provider's tool names.

## Portable distribution (dist/)

`dist/class-action-finder.zip` is checked in for Claude uploads, and the byte-identical `dist/class-action-finder.skill` is checked in for ChatGPT. **After editing `SKILL.md`, `agents/openai.yaml`, an asset, or a reference file, re-run `./scripts/package-skill.sh` and commit both artifacts** so the download links stay current.

The cost model and per-model estimates live in [`docs/cost.md`](docs/cost.md); README links to it rather than inlining it, so pricing drift is contained to one file.

See README.md for setup instructions.
