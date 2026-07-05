# Report Template

Use this as the **content guide** when writing `class-action-report-YYYY-MM-DD.html`. It defines what sections to include, what data belongs in each section, and what order to present it. Step 9 of the skill defines the visual HTML structure (cards, dark header, inline CSS); this file defines the content inside that structure.

---

## Header Block

Show at the top of the page:

- Report title: "Class Action Settlement Report"
- Generated date (today's date)
- Period scanned (date range from Step 1)
- Counts: active claims, filed/auto-enrolled, watch list, expired, phishing alerts
- Emails processed: total, broken down by inbox / spam / promotions

---

## Section 1 — Active Claims (Action Required)

One card per claim. Sort by soonest deadline first.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | Defendant + case citation if available |
| What it's about | One sentence describing the alleged harm |
| Confidence score | e.g., "🟢 96% — PCWorld coverage, Epiq sender, no payment requested" |
| Already filed? | If `already_filed` is true (Step 7), show a distinct "✅ Already filed on [date]" badge — separate from the confidence score, so it can't be mistaken for a phishing signal |
| Claim deadline | Highlight as urgent if ≤ 14 days away |
| Opt-out deadline | Show if different from claim deadline |
| Your payout | Amount or range; "pro-rata, unknown" if not stated |
| Total settlement pool | e.g., "$725M" |
| Claim ID / PIN | Two separate monospace boxes — `claim_id` and `pin` from Step 7. Omit the PIN box entirely if none was extracted; don't show an empty one |
| Claim URL | Clickable link |
| Notes | One sentence on anything notable (e.g., "CA residents get +$100 CCPA") |

Include auto-enrolled cases here too (no form needed, but payout is pending).

---

## Section 2 — Watch List (Potential Future Claims)

One card per case. No claim form exists yet, or eligibility condition applies.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | |
| What it's about | |
| Confidence score | |
| Eligibility condition | Who qualifies (e.g., "legally blind individuals only") |
| Estimated payout | "unknown" if not stated |
| Status | e.g., "Trial pending", "Investigation announced", "No claim form yet" |
| Case website | If available |
| Notes | Including any opt-out or important dates already passed |

---

## Section 3 — Expired / Already Closed

One card per case. Deadline has passed.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | |
| Confidence score | |
| What the deadline was | |
| What benefits were available | |
| Your claim ID | If one was found in the email |
| Claim URL | For reference even if closed |

---

## Section 4 — Already Filed / Payouts Received

One card per claim previously submitted or auto-enrolled. Cross-referenced from tracker (Step 3) and from current emails.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | |
| Filed date | From tracker or email |
| Your claim ID / PIN | From tracker or email — show both if the tracker has a `pin` |
| Expected payout | From tracker or email |
| Actual payout | If received; "Pending ⏳" if not |
| Payment method | e.g., "Zelle", "Virtual Visa", "check" |
| Notes | Include any action still needed (e.g., redeem a prepaid card) |

---

## Section 5 — Phishing Alerts (Do Not Click)

One card per suspicious email. Move any email scoring 🔴 (<40%) here instead of Sections 1–4.

**Each card must include:**

| Field | Notes |
|---|---|
| Sender / domain | |
| Subject line | |
| Confidence score | e.g., "🔴 18%" |
| Red flags | List the specific signals that drove the low score |
| Email date | |
| Advice | Always include: "Do not click any links. Report as phishing in Gmail." |

If no phishing emails were found, show: "No phishing emails detected in this scan."

---

## "What To Do Next" Panel

A highlighted action panel at the bottom. List items sorted by soonest deadline first.

**Format:**

```
[Company] — Deadline [DATE]:
  Visit [URL] · ID: [CLAIM_ID] · PIN: [PIN]
  [One sentence on what to bring or what to expect]

[Company] — Redeem your [PAYMENT TYPE]:
  Visit [URL] · Enter code [CODE]

[Company] — Watch for payment:
  Monitor [URL] for distribution updates.
```

Also include a reminder:
- To log a filed claim: just tell Claude (e.g. "I already filed the [company] one")
- To record a payout received: just tell Claude (e.g. "I got $47 from [company]")

---

## Empty Section Rule

If a section has no entries, show a brief italicized note — never omit the section entirely:

- Section 1: "No active claims found in this scan."
- Section 2: "No potential future claims found."
- Section 3: "No expired claims found."
- Section 4: "No previously filed claims on record. Tell Claude "I already filed [company]" to log it."
- Section 5: "No phishing emails detected in this scan."

This keeps the report structure consistent across runs.
