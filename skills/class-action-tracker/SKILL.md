---
name: class-action-tracker
description: >-
  Use this skill for personal class action record-keeping — storing and retrieving the user's own claim history. Trigger when the user narrates a personal settlement event: filing a claim (mentioning a claim ID, expected payout, or filing date), receiving a settlement payment (specific dollar amount, payment method, or receipt date), or updating the status of an existing claim. Also trigger when the user queries their own history: asking if they filed for a specific company, requesting a list of their claims, or asking for their total settlement earnings. Trigger for /class-action-tracker with any argument. Skip for email scanning, research, form-filling help, opting out, and general class action questions.
---

# Class Action Tracker

Read and update `~/.claude/class-action-tracker.json`. This file has two arrays:
- `filed_claims` — claims submitted, with expected and actual payout tracking
- `watch_list` — potential future claims to monitor

## Arguments

The user invoked this with: $ARGUMENTS

## Determine the Command

Parse `$ARGUMENTS` and the user's phrasing to identify intent:

| Intent | Example phrases |
|---|---|
| **Mark as filed** | "filed [company]", "I submitted my claim for [company]", "mark [company] as filed", "log my claim for [company]" |
| **Record a payout** | "I received $45 from [company]", "got a check from [company]", "payout from [company] was $120", "update [company] payout" |
| **Add to watch list** | "watch [company]", "add [company] to watch list" |
| **Remove from watch list** | "remove [company] from watch list" |
| **List / show all** | "list", "show all", "what have I filed", "how much have I made", blank arguments |
| **Help** | "help" — print the command table above and a one-line example for each |

If the intent is still unclear after parsing, ask one question before reading or writing anything.

---

## Command: Mark as Filed

1. Read `~/.claude/class-action-tracker.json`
2. Collect any missing required fields — ask the user if they weren't provided in the original message:
   - Company / case name (required)
   - Claim ID or notice ID (optional — store `null` if absent)
   - Date filed (required — default to today if user says "today" or "just now")
   - Expected payout (optional — store `"unknown"` if absent)
   - Claim URL (optional)
   - Notes (optional — e.g., "Tier 2 with receipts")
3. Check for a duplicate: if a `company` fuzzy-matches an existing entry (ignore "Inc.", "LLC", "Corp.", capitalization differences, and common abbreviations), ask whether to update it or add a new entry (useful when the same company has multiple cases).
4. Add the new entry to `filed_claims`:

```json
{
  "company": "TikTok Inc.",
  "case": "TikTok Privacy Class Action Settlement",
  "filed_date": "2026-05-11",
  "claim_id": "TKTK-99281",
  "claim_url": null,
  "expected_payout": "$15–$30",
  "actual_payout": null,
  "payout_date": null,
  "payment_method": null,
  "notes": ""
}
```

5. Write the complete updated file (both arrays — never write partial JSON).
6. Confirm: "Recorded: [Company] claim filed on [DATE] with claim ID [ID]. I'll track the payout when you receive it."

---

## Command: Record a Payout

1. Read `~/.claude/class-action-tracker.json`
2. Find the matching entry in `filed_claims` using fuzzy company name matching (ignore legal suffixes, capitalization, common abbreviations like "FB" → "Facebook"). If no match, offer to create a new filed entry first — some settlements pay out automatically without requiring a claim form.
3. Ask for any missing info:
   - Amount received (required)
   - Date received (required — default to today; if user says "last week" use today minus 7 days)
   - Payment method (optional — e.g., "check", "PayPal", "Venmo", "direct deposit")
4. Update the matched entry with `actual_payout`, `payout_date`, and `payment_method`.
5. Write the complete updated file.
6. Compare actual vs. expected and tell the user:
   - Actual > expected range: "You received more than estimated — nice!"
   - Actual within expected range: "Payout matched the estimate."
   - Actual < expected range: "Less than the estimate — normal for pro-rata settlements when many people file."
   - Expected was "unknown": just confirm the amount recorded.

---

## Command: Add to Watch List

Add an entry to `watch_list` and write the complete updated file:

```json
{
  "company": "Google LLC",
  "case": "Google Location History Privacy",
  "added_date": "2026-05-12",
  "source": "Email received 2026-04-30",
  "estimated_payout": "unknown",
  "notes": "No claim form yet — investigation announced"
}
```

Confirm which company was added. Remind the user it will appear in the Watch List section next time they run `/class-action-scanner`.

---

## Command: Remove from Watch List

Find the company in `watch_list` using the same fuzzy matching as above. Remove it, write the complete file, confirm removal.

---

## Command: List / Show All

Read `~/.claude/class-action-tracker.json` and display a summary in the conversation (not a file):

```
## Your Class Action Tracker

### Filed Claims ([N] total)

| Company / Case | Filed | Claim ID | Expected | Actual | Status |
|---|---|---|---|---|---|
| Meta / Facebook Privacy | 2024-03-15 | FBP-4821-XY | $25–$100 | $47.23 ✅ | Paid |
| Zoom Privacy | 2024-11-02 | ZM-99312 | $25–$75 | Pending ⏳ | Awaiting |

**Total received so far:** $47.23
**Still pending:** 1 claim

### Watch List ([N] items)

| Company / Case | Added | Estimated Payout | Notes |
|---|---|---|---|
| Amazon Alexa Privacy | 2025-01-10 | unknown | No form yet |
```

After the summary, ask: "Want to update anything?"

---

## Command: Help

Print the command table from the "Determine the Command" section above, plus one concrete example for each command. Keep it short.

---

## File Format Reference

```json
{
  "filed_claims": [
    {
      "company": "string",
      "case": "string or null",
      "filed_date": "YYYY-MM-DD",
      "claim_id": "string or null",
      "claim_url": "string or null",
      "expected_payout": "string — e.g. '$25–$100' or 'pro-rata, unknown'",
      "actual_payout": "string or null",
      "payout_date": "YYYY-MM-DD or null",
      "payment_method": "string or null",
      "notes": "string"
    }
  ],
  "watch_list": [
    {
      "company": "string",
      "case": "string or null",
      "added_date": "YYYY-MM-DD",
      "source": "string",
      "estimated_payout": "string or 'unknown'",
      "notes": "string"
    }
  ]
}
```

Always write the **complete file** (both arrays) on every update — partial writes corrupt the tracker.

---

## Edge Cases

- **Auto-enrolled payout (no claim form):** Add a `filed_claims` entry with `filed_date: null` and note "No claim form required — auto-enrolled."
- **Installment payments:** Record each installment in `notes` (e.g., "Installment 1: $23.50 on 2026-08-15; Installment 2: pending") and update `actual_payout` to the running total.
- **Same company, multiple cases:** When fuzzy match is ambiguous, show the user the matching entries and ask which one to update.
