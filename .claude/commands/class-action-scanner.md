---
description: Scan Gmail for class action settlement emails and produce an actionable report. Use this skill whenever the user mentions class action settlements, legal notices, settlement claims, or wants to find money owed to them from lawsuits — even if they don't use exact legal vocabulary. Trigger for phrases like /class-action-scanner, "scan my email for settlements", "find class action claims in Gmail", "check if I'm eligible for any settlement money", "did I miss any settlement deadlines", "are there class action lawsuits that affect me", "find unclaimed settlement money in my inbox", "what class actions should I know about", or any time the user wants to audit their email for legal claim opportunities.
argument-hint: [time period — e.g. "6 months" | "2024" | blank = last 12 months]
allowed-tools: [WebFetch, WebSearch, Write, Read]
---

# Class Action Scanner

Scan Gmail (inbox, spam, and promotions) for class action settlement emails. Produce an actionable markdown report with phishing confidence scores, split into five sections: Active Claims, Watch List, Expired, Already Filed, and Phishing Alerts.

## Arguments

The user invoked this with: $ARGUMENTS

## Step 1 — Determine Date Range

Parse `$ARGUMENTS` to determine the lookback period. Today's date is available from the system context.

| Input | Gmail date filter |
|---|---|
| Blank | `after:YYYY/MM/DD` (today minus 365 days) |
| `2024` | `after:2024/01/01 before:2025/01/01` |
| `6 months` | `after:YYYY/MM/DD` (today minus 183 days) |
| `3 months` | `after:YYYY/MM/DD` (today minus 91 days) |
| `2023 to 2024` | `after:2023/01/01 before:2025/01/01` |

Compute the date string before running any searches. Use YYYY/MM/DD format (e.g. `2026/02/09`).

## Step 2 — Load Reference Guides

Read all three reference files now — you'll apply them throughout the remaining steps:

- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/gmail-tools/skills/class-action-scanner/references/extraction-guide.md` — how to classify emails, extract fields, spot irrelevant threads
- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/gmail-tools/skills/class-action-scanner/references/phishing-guide.md` — confidence scoring signals, known admin domains, red flags
- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/gmail-tools/skills/class-action-scanner/references/report-template.md` — the exact table structure and column order for the output report

Loading upfront means you won't need to re-read them mid-workflow.

## Step 3 — Load Already-Filed Tracker

Read `~/.claude/class-action-tracker.json`. If the file doesn't exist, treat it as `{"filed_claims": [], "watch_list": []}`.

Hold the `filed_claims` list in memory — you'll cross-reference it in Step 7 to mark claims the user has already submitted.

## Step 4 — Search Gmail (Four Queries)

Run all four searches using the Gmail MCP `search_threads` tool. The MCP server is the Gmail integration connected via Claude.ai (look for the Gmail MCP in your available tools; the server ID on this machine is `2ad99722-65b9-48e5-a269-19c0384b38b5`). Use `max_results: 50` per query.

**Query A — Inbox, subject-based:**
```
subject:(settlement OR "class action" OR "claim form") after:YYYY/MM/DD
```

**Query B — Inbox, body urgency signals:**
```
("claim deadline" OR "submit your claim" OR "file a claim" OR "settlement administrator" OR "opt out" OR "claims period") after:YYYY/MM/DD
```

**Query C — Spam folder** (many legitimate settlement notices land here due to bulk sending):
```
in:spam (settlement OR "class action" OR "claim form" OR "claim deadline" OR "submit your claim") after:YYYY/MM/DD
```

**Query D — Promotions category:**
```
category:promotions (settlement OR "class action" OR "claim form" OR "claim deadline" OR "submit your claim") after:YYYY/MM/DD
```

Collect all thread IDs from all four queries. De-duplicate by thread ID, sort by most recent, and cap at 100. Keeping only the 100 most recent matters because older threads rarely have open claim windows — processing them wastes time without yielding actionable results. Note in the report header how many came from spam vs. promotions vs. inbox.

## Step 5 — Fetch and Classify Each Thread

For each thread ID, call `get_thread` (same MCP server). Process in batches of 10 to keep context manageable — fetching all threads at once risks losing earlier results as context grows.

Classify each thread immediately using the extraction guide (already loaded in Step 2):
- **Type A (Active):** Claim form open, future deadline, URL to submit a claim present
- **Type B (Potential):** Lawsuit/investigation announced, no claim form yet
- **Suspect:** Matches search terms but has red flags — retain for phishing scoring
- **Irrelevant:** Financial account settlement, marketing copy, law firm solicitation, lease dispute — discard silently

## Step 6 — Score Legitimacy (Every Type A and B Thread)

Apply the scoring methodology from the phishing guide (already loaded in Step 2). Also run a `WebSearch` for the case name or defendant to check whether it appears in news or court records — this is the single most reliable verification signal.

Assign one of four confidence levels:

| Level | Score | Meaning |
|---|---|---|
| 🟢 | 85–100% | High confidence — multiple signals verified |
| 🟡 | 60–84% | Likely legitimate — limited independent verification |
| 🟠 | 40–59% | Uncertain — verify manually before acting |
| 🔴 | < 40% | Phishing risk — do not click any links |

Record the score (e.g., "72%") and the 2–3 signals that drove it (e.g., "Case in Reuters 2024, sender is epiqsystems.com, no payment requested"). Move any 🔴 thread directly to Section 5 of the report — skip field extraction for these.

## Step 7 — Extract Fields

For each Type A and Type B thread (not 🔴), extract the following. Write `"unknown"` for anything not explicitly stated — guessing leads to incorrect deadlines or wrong claim amounts.

| Field | What to look for |
|---|---|
| `company` | Defendant company name |
| `product_service` | The product or service at issue |
| `plaintiff_class` | Who qualifies (e.g., "US residents who used Facebook 2014–2022") |
| `individual_payout` | $ per claimant — range or "pro-rata, unknown" |
| `total_settlement` | Total pool (e.g., "$725 million") |
| `claim_deadline` | Date claims must be submitted |
| `opt_out_deadline` | Date to opt out (often earlier than claim deadline) |
| `claim_url` | Direct URL to claim submission page |
| `claim_id` | Pre-populated claim ID, notice ID, or unique ID from the email |
| `email_date` | Date the email was received |
| `type` | A or B |
| `confidence` | e.g., "🟢 91% — Epiq sender, Reuters article, no payment request" |
| `notes` | One sentence on anything notable |

**Cross-reference tracker:** Check if the `company` (fuzzy match — ignore "Inc.", "LLC", "Corp.", capitalize variations) appears in `filed_claims` from Step 3. If matched, set `already_filed: true` and carry over the filed date and claim ID.

## Step 8 — Web Supplement (Type A + URL + High Enough Confidence)

For Type A emails with a `claim_url` and confidence 🟢 or 🟡, fetch the URL with `WebFetch` to confirm the deadline, payout, and whether the form is still open. The live website is authoritative over the email.

Skip fetching for:
- 🟠 or 🔴 emails — don't visit suspicious URLs
- Type B emails — no form exists yet
- Missing `claim_url` — add "no claim URL in email — verify manually" to notes
- `WebFetch` failures — keep email data, note "website unreachable — verify manually"

If the form has closed (deadline passed), change `type` to `EXPIRED`.

## Step 9 — Write the Report

Write `class-action-report-YYYY-MM-DD.md` to the current working directory. Use the table structure from the report template (already loaded in Step 2). Sort Section 1 by soonest deadline first.

## Step 10 — Report Back to User

Give a 4–5 line summary in the conversation:
1. File path of the saved report
2. Count of actionable claims and rough total payout range
3. Most urgent single deadline
4. How many emails surfaced from spam or promotions (notable when > 0)
5. Count of phishing alerts — remind not to click those links

Don't reproduce the tables in chat. The file is the artifact.

## Edge Cases

- **Zero results from all four queries:** Note in the report — don't run a fifth broadened query unless the user asks.
- **Email chain:** Use the most recent message for deadlines; note if earlier messages had different dates.
- **Ambiguous A vs B:** Default to B — better to watch-list than create false urgency.
- **QR code only, no URL:** Note "QR code in email — scan on your phone" in the `notes` field.
- **Same case, multiple emails:** Deduplicate by company/case name, keep the most recent email's data.
- **Tracker file missing:** Create it at `~/.claude/class-action-tracker.json` with empty arrays during Step 3.
