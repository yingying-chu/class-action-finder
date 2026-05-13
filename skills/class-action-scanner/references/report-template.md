# Report Template

Use this exact structure when writing `class-action-report-YYYY-MM-DD.md`.

```markdown
# Class Action Settlement Report
Generated: [today's date] | Period scanned: [date range]
Emails processed: [N] (inbox: [N], spam: [N], promotions: [N])
Active claims: [N] | Already filed: [N] | Watch list: [N] | Expired: [N] | Phishing alerts: [N]

---

## SECTION 1: Active Claims — Action Required

> Submit your claim before the deadline. Sorted by soonest deadline first.
> ✅ = Already filed per your tracker.

| # | Status | Confidence | Company / Case | What It's About | Your Payout | Total Pool | Claim Deadline | Opt-Out By | Claim URL | Your Claim ID | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | ✅ Filed | 🟢 91% | Meta / Facebook Privacy | Data privacy 2014–2022 | $25–$100 | $725M | 2025-08-15 | 2025-07-01 | https://... | FBP-4821-XY | Filed 2024-03-15 |
| 2 | — | 🟡 74% | Google Location History | Location tracking | pro-rata | $392M | 2025-09-30 | — | https://... | unknown | Requires account history |

---

## SECTION 2: Potential Future Claims — Watch List

> No claim form yet. Watch your inbox for when claims open.

| # | Confidence | Company / Case | What It's About | Estimated Payout | Status | Email Date | Notes |
|---|---|---|---|---|---|---|---|
| 1 | 🟢 88% | Amazon Alexa Privacy | Voice recording without consent | unknown | Investigation announced | 2025-03-12 | No form yet |

---

## SECTION 3: Expired / Already Closed

> Deadline has passed. Included for reference only.

| # | Confidence | Company / Case | Deadline Was | Claim URL | Notes |
|---|---|---|---|---|---|
| 1 | 🟡 70% | TikTok Teen Privacy | 2024-07-31 | https://... | Deadline passed — for reference only |

---

## SECTION 4: Already Filed — Your Tracker

> Claims you have previously recorded as filed via /class-action-tracker.

| # | Company / Case | Filed Date | Your Claim ID | Expected Payout | Actual Payout | Notes |
|---|---|---|---|---|---|---|
| 1 | Meta / Facebook Privacy | 2024-03-15 | FBP-4821-XY | $25–$100 | Pending | — |

---

## SECTION 5: Phishing Alerts — Do Not Click

> These emails matched class action search terms but show strong signs of phishing.
> DO NOT visit any URLs in these emails. Report as phishing in Gmail.

| # | Confidence | Sender | Subject | Red Flags | Email Date |
|---|---|---|---|---|---|
| 1 | 🔴 22% | claims@xk7r-settle.xyz | Claim your $5,000 settlement NOW | Requests $25 processing fee; case name unverifiable; random sender domain | 2025-04-01 |

---

## What To Do Next

**Immediate actions (soonest deadline first):**
- **[Company]** — Deadline [DATE]: Visit [URL] to file. Use claim ID [ID] if available.

**Nothing to do yet (watch list):**
- **[Company]**: Watch for claim opening notice.

**Manage your claims:**
- To mark a claim as filed: tell Claude "Mark [Company] as filed with claim ID [ID]" or use `/class-action-tracker`
- To record a payout you received: use `/class-action-tracker`
```

If a section has no entries, write "No entries found." under the heading — never omit the section entirely. This keeps the report structure consistent across runs so sections are easy to scan.
