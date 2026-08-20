# Report Template

Use this as the **content guide** when writing `class-action-report-YYYY-MM-DD.html`. It defines what sections to include, what data belongs in each section, and what order to present it. Step 9 of the skill defines the visual HTML structure (editorial hero, email funnel, action queue, cards, and inline CSS); this file defines the content inside that structure.

The HTML-safety rules in Step 9 apply to every section and the action queue. Escape all untrusted values, and never create a clickable link for an 🟠 or 🔴 entry.

Keep three independent concepts visually distinct:

- **Discovery source:** `📩 Direct notice`, `🧾 Purchase match`, or `✍️ Manually added`
- **Settlement legitimacy:** the existing 🟢/🟡/🟠/🔴 score
- **Purchase eligibility:** `confirmed`, `strong`, or `possible` when Part D applies

A source badge is never a confidence badge. A legitimate settlement can still be a weak match for the user's purchase.

---

## Overview and Status Navigation

Start with a bright editorial hero followed by a horizontal anchor/status strip. Use the transparent mark from `assets/logo-mark.svg` beside a live-text product label, following Step 9's self-contained inline-SVG rule. Place the mark directly on the hero with no white tile, border, or drop shadow so its green, purple, and warm-white artwork belongs to the gradient. Do not use a black admin-style header, the full wordmark on the gradient, or ornamental rings/circles.

Keep the top status strip to four decision-oriented links:

1. Action required → the action queue
2. Purchase matches → the Purchase Matches to Review panel
3. Filed claims → Section 4
4. Security alerts → Section 5

Counts must match the underlying cards. `Action required` counts only unfiled 🟢/🟡 filing actions, Filed includes its paid subset, and Security alerts equals the number of 🔴 cards. Active, Watching, Paid, and Expired remain clearly labeled in the report body but do not get separate top-level links. Keep the strip sticky on desktop and static at 900px and below. Use pure anchor links only, with no JavaScript.

---

## Header Block

Show at the top of the page:

- Product label: "Class Action Finder"
- Generated date (today's date) and period scanned
- A direct headline such as: "[N] claims could be worth [ACTIONABLE VALUE]."
- A one-sentence priority cue naming the nearest actionable deadline
- Actionable potential value, calculated exactly as Step 9 specifies. If amounts are ranges, show the summed range; if some are unknown, append `+ unknown`.
- A compact value breakdown by actionable claim. Keep it textual or use simple proportional horizontal bars scaled against the largest known upper bound; always print the numeric ranges directly.
- Notice funnel when Part A ran: emails processed → relevant settlement notices → verified unique cases → action-required claims
- Purchase funnel when Part D ran: purchase emails processed → unique products/services → verified open settlements → matches to review
- Optional provider coverage line: inbox / spam / promotions counts, and any unsupported folder

Each funnel is a count transformation, not a proportional value chart. Render rectangular labeled stages with arrows so a small verified count is not visually exaggerated. If both scans ran, label both funnels and do not mix purchase confirmations into the settlement-notice count.

**Coverage must be explicit.** For a fully traversed range, show `800 of 800 · complete`. If an external provider prevents complete traversal even after paging and adaptive date partitioning, show the known fraction with `provider-limited` and name the exact provider constraint beneath the funnel. Never print a partial count as though it were complete.

The report must be mobile-first as well as desktop-friendly. At widths up to 650px, keep the hero headline at roughly 28–34px with a readable line height, reduce hero spacing, stack the value ledger, render funnels as a compact two-column grid, disable sticky navigation, and collapse multi-column action/card/filed layouts to one readable column. No content, badge, ID, or CTA may overflow the viewport; use wrapping or horizontal scrolling only for genuinely unbreakable identifiers.

---

## Purchase Matches to Review

Place this panel immediately after the action queue and before Section 1. Keep it present with an empty-state note when Part D ran and produced no matches. Unconfirmed purchase matches do not count toward Action required or actionable potential value.

**Each card must include:**

| Field | Notes |
|---|---|
| Source badge | Always `🧾 Purchase match`; add `📩 Direct notice` too only after settlement-identity matching |
| Purchase evidence | Merchant, product/service, and purchase date only; no order, address, account, or payment identifiers |
| Covered class | Product/model/service, class period, and geography from a verified source |
| Settlement legitimacy | Existing 🟢/🟡 score and rationale |
| Eligibility match | `Strong` or `Possible`, displayed separately from legitimacy |
| Missing facts | State exactly what still needs confirmation |
| Deadline and payout | Only values supported by the verified settlement source |
| CTA | `Check eligibility`, linked only to a validated 🟢/🟡 official information page |

Do not use `Submit claim` in this panel. A `confirmed` purchase match may move to Section 1 and the action queue, but it keeps the `🧾 Purchase match` badge and a note that it was not discovered through a personalized legal notice.

---

## Section 1 — Active Claim Windows

One card per open claim window. Sort by soonest deadline first. A claim already recorded as filed remains here for deadline and documentation reference, but must not appear as a filing task in the "What To Do Next" panel.

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
| Claim URL | Clickable only for verified 🟢/🟡 `https://` URLs; show 🟠 URLs as non-clickable text with a warning |
| Notes | One sentence on anything notable (e.g., "CA residents get +$100 CCPA") |
| Discovery source | One or more source badges; keep them separate from confidence and filed status |

Include auto-enrolled cases here too (no form needed, but payout is pending).

When an active card has `already_filed: true`, keep it in this section for reference, show the filed badge prominently, and give it no filing CTA.

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
| Advice | Always include: "Do not click any links. Report it as phishing in your mail provider." |

If no phishing emails were found, show: "No phishing emails detected in this scan."

---

## "What To Do Next" Action Queue

Place this immediately after the hero and status strip, before Section 1. List items sorted by soonest deadline first. Every action must be visually separated into its own row or card so the action, deadline, value, and CTA cannot blur together.

Keep all action CTAs equal in width and height. On wide layouts, center each CTA vertically inside a dedicated action column. When the action row collapses at tablet or mobile widths, place the CTA on its own full grid row but cap the button at a compact width of roughly 220–260px and center it. Do not stretch a short CTA across the mobile viewport.

Include filing actions only for unfiled 🟢/🟡 claims with a validated `https://` URL. Do not put already-filed, 🟠, or 🔴 claims in this panel as click-through actions.

An unconfirmed Part D finding never enters this queue. Only `eligibility_match: confirmed` may enter; retain the `🧾 Purchase match` badge and explain that eligibility was confirmed from purchase evidence rather than a personalized notice.

**Each action item contains:**

| Field | Notes |
|---|---|
| Step number | Sequential, deadline order |
| Action verb | Usually "Submit claim"; never imply the assistant submitted it |
| Company / case | |
| Why act | One short sentence about eligibility and verification |
| Deadline | Include days remaining; visually urgent at ≤14 days |
| Estimated value | The individual payout range or "unknown" |
| Confidence | Score and level |
| CTA | `Open claim form` for a validated 🟢/🟡 URL |

Use `Open claim form`, not `File verified claim`: the link only opens the external form. A lower-confidence entry that is not eligible for a clickable URL must not appear here; its card should instead explain what must be verified.

**Equivalent text structure:**

```
[Company] — Deadline [DATE]:
  Visit [URL] · ID: [CLAIM_ID] · PIN: [PIN]
  [One sentence on what to bring or what to expect]

[Company] — Redeem your [PAYMENT TYPE]:
  Visit [URL] · Enter code [CODE]

[Company] — Watch for payment:
  Monitor [URL] for distribution updates.
```

Payout-monitoring reminders belong in Section 4 rather than the filing-action queue unless there is a concrete time-sensitive redemption action.

Also include a reminder:
- To log a filed claim: just tell the assistant (e.g. "I already filed the [company] one")
- To record a payout received: just tell the assistant (e.g. "I got $47 from [company]")

---

## Section 4 Status Presentation

Within Section 4, present awaiting-payout claims first and paid claims second. Each row/card must make the lifecycle state obvious:

- `Filed · awaiting payout`
- `Auto-enrolled · awaiting payout`
- `Paid [date]`
- `Action needed · redeem payment`

Show filed date, claim ID and PIN, expected payout, actual payout, payout date, and payment method when known. These records remain visible across future scans through the tracker, even though they are excluded from the filing-action queue and the actionable-value total.

---

## Empty Section Rule

If a section has no entries, show a brief italicized note — never omit the section entirely:

- Section 1: "No active claims found in this scan."
- Section 2: "No potential future claims found."
- Section 3: "No expired claims found."
- Section 4: `No previously filed claims on record. Say "I already filed [company]" to log it.`
- Section 5: "No phishing emails detected in this scan."

When Part D ran, also use: `No potentially matching open settlements found for the purchase confirmations reviewed.`

This keeps the report structure consistent across runs.
