# Report Template

Use this as the **content guide** when writing `class-action-report-YYYY-MM-DD.html`. It defines what sections to include, what data belongs in each section, and what order to present it. Step 9 of the skill defines the visual HTML structure (editorial hero, compact coverage funnel, action queue, cards, and inline CSS); this file defines the content inside that structure.

The HTML-safety rules in Step 9 apply to every section and the action queue. Escape all untrusted values. A report CTA is an `<a>` only when its absolute `https://` destination has been validated and the settlement is 🟢 or 🟡. Render 🟠 actions as non-clickable explanatory text and never render a 🔴 URL.

Keep three independent concepts visually distinct:

- **Discovery source:** `📩 Direct notice`, `🧾 Purchase match`, or `✍️ Manually added`
- **Settlement legitimacy:** the existing 🟢/🟡/🟠/🔴 band and a short evidence-based reason; do not render the internal percentage
- **Purchase eligibility:** `confirmed`, `strong`, or `possible` when Part D applies

A source badge is never a confidence badge. A legitimate settlement can still be a weak match for the user's purchase.

---

## Overview and Status Navigation

Start with a bright editorial hero followed by a horizontal anchor/status strip. Use the transparent mark from `assets/logo-mark.svg` beside a live-text product label, following Step 9's self-contained inline-SVG rule. Place the mark directly on the hero with no white tile, border, or drop shadow so its green, purple, and warm-white artwork belongs to the gradient. Do not use a black admin-style header, the full wordmark on the gradient, or ornamental rings/circles.

Use one section-navigation row, never two. It carries a chip per section that has content, each with its count, in this fixed order:

1. Action required → the action queue
2. Security alerts → Security alerts
3. Purchase matches → the Purchase Matches to Review panel
4. Filed & tracking → Filed & tracking, with its paid subset as a nested secondary count in the same chip
5. Watching → Watching
6. Expired → Expired
7. Active claims → Active claims

The order is fixed so the layout is predictable; membership is not. Omit any section whose count is zero and name the omitted ones in a single muted trailing line, e.g. `Nothing found in Active claims or Expired`. Navigation then describes this report rather than a fixed set of categories that are usually half empty.

`Paid` never gets its own chip — it is a subsection inside Filed & tracking, so promoting it to a peer of Active/Watching/Expired states the wrong hierarchy.

Counts must match the underlying cards. `Action required` counts only unfiled 🟢/🟡 filing actions, `Filed & tracking` counts all filed records including the paid subset, and `Security alerts` equals the number of 🔴 cards. Keep the row sticky on desktop and static at 900px and below; let chips wrap rather than shrink. Pure anchor links only, with no JavaScript.

Use these exact IDs for report destinations: `action-queue`, `purchase-matches`, `active`, `watching`, `expired`, `filed`, `paid`, and `security`. These are semantic contracts, not examples. Do not generate positional IDs such as `sec1` through `sec5`.

Every section starts with a visible rule and real space above it, and a head carrying an eyebrow, a heading, and a right-aligned item count. Every section long enough to fill a viewport ends with a quiet right-aligned `↑ Back to top` link.

---

## Header Block

Show at the top of the page:

- Product label: "Class Action Finder"
- Generated date (today's date) and period scanned
- A direct headline such as: "[N] claims need action."
- An optional summary of no more than one or two short sentences. Omit it when it only repeats the headline, `Start here`, value panel, or funnels.
- A prominent `Start here` cue naming the nearest actionable case and deadline. Place it before the value panel in reading order. If no claim is actionable, use the compact state `Nothing to file right now` and do not promote a non-actionable case into this slot.
- Exactly one currency-denominated hero summary: the actionable-potential-value panel, in an element whose class includes `hero-value`, calculated exactly as Step 9 specifies. If amounts are ranges, show the summed range; if some are unknown, append `+ unknown`. If no numeric actionable estimate exists, show `No actionable payout estimate`. Do not repeat this number in an adjacent subtitle and do not add other money cards.
- Notice funnel when Part A ran: emails processed → relevant settlement notices → verified unique cases → action-required claims
- Purchase funnel when Part D ran: purchase emails processed → unique products/services → verified open settlements → matches to review
- A visually distinct coverage state such as `Complete coverage`, followed by the notice-funnel stages
- A quieter provider coverage line beneath it: inbox / spam / promotions counts, and any unsupported folder

Each funnel is a count transformation, not a proportional value chart. Render rectangular labeled stages with arrows so a small verified count is not visually exaggerated. If both scans ran, label both funnels and do not mix purchase confirmations into the settlement-notice count.

**Coverage must be explicit.** For a fully traversed range, show `800 of 800 · complete`. If an external provider prevents complete traversal even after paging and adaptive date partitioning, show the known fraction with `provider-limited` and name the exact provider constraint. Keep extended methodology, exclusions, and limitations outside the hero in a closed-by-default `Coverage details` disclosure. Never print a partial count as though it were complete.

The hero must never use a total settlement fund as the user's payout, potential value, or missed money. Do not sum settlement funds. A fund amount belongs only inside its individual case card and must be labeled `Total settlement fund`.

The report must be mobile-first as well as desktop-friendly. At widths up to 650px, keep the hero headline at roughly 28–34px with a readable line height, reduce hero spacing, keep `Start here` visible before potential value, wrap the compact coverage sequence, disable sticky navigation, and collapse multi-column action/card/filed layouts to one readable column. No content, badge, ID, or CTA may overflow the viewport; use wrapping or horizontal scrolling only for genuinely unbreakable identifiers. Never apply `white-space: nowrap` to a legitimacy or confidence rationale. Give those badges `max-width: 100%` and allow their evidence text to wrap.

---

## Purchase Matches to Review

Place this panel immediately after the action queue and before Active claims. Keep it present with an empty-state note when Part D ran and produced no matches. Unconfirmed purchase matches do not count toward Action required or actionable potential value.

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
| CTA | `Check eligibility`; in a real report, use `<a href="https://…" rel="noopener noreferrer">` only for a validated 🟢/🟡 official information page |

Put the CTA on its own line below the `Next step` label. When the label and CTA share a grid cell, give the anchor block formatting so the label cannot collide with the button border. A disabled illustrative demo may use a non-interactive `<span>` with the same block layout; generated reports must use the validated anchor described above. Do not use `Submit claim` in this panel. Do not render a clickable CTA for 🟠 or 🔴 settlements. A `confirmed` purchase match may move to the action queue, but it keeps the `🧾 Purchase match` badge and a note that it was not discovered through a personalized legal notice.

---

## Active Claims

Render the heading as `Active claims`, with `id="active"` and without a `Section 1` numeral. The action queue is the single owner of complete details for unfiled 🟢/🟡 filing actions. Filed & tracking is the single owner of filed and auto-enrolled claims, including claims whose filing windows remain open. Use Active claims only for additional open, non-filed items that cannot enter the action queue, principally 🟠 entries that need a non-clickable verification note. Sort nonempty cards by soonest deadline first. Never repeat a full claim card from Filed & tracking here.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | Defendant + case citation if available |
| What it's about | One sentence describing the alleged harm |
| Legitimacy | e.g., `High confidence` plus `PCWorld coverage, Epiq sender, no payment requested`; omit the percentage |
| Claim deadline | Highlight as urgent if ≤ 14 days away |
| Opt-out deadline | Show if different from claim deadline |
| Your payout | Amount or range; "pro-rata, unknown" if not stated |
| Total settlement fund | e.g., "$725M"; label it clearly so it cannot be mistaken for the claimant's payout |
| Claim URL | Clickable only for verified 🟢/🟡 `https://` URLs; show 🟠 URLs as non-clickable text with a warning |
| Notes | One sentence on anything notable (e.g., "CA residents get +$100 CCPA") |
| Discovery source | One or more source badges; keep them separate from confidence and filed status |

Do not include already-filed or auto-enrolled cases here. They belong only in Filed & tracking.

---

## Watching

Render the heading as `Watching`, without a section numeral. Use one card per case when no claim form exists yet or an eligibility condition applies.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | |
| What it's about | |
| Legitimacy band and reason | No percentage in report-facing text |
| Eligibility condition | Who qualifies (e.g., "legally blind individuals only") |
| Estimated payout | "unknown" if not stated |
| Status | e.g., "Trial pending", "Investigation announced", "No claim form yet" |
| Case website | If available |
| Notes | Including any opt-out or important dates already passed |

---

## Expired

Render the heading as `Expired`, without a section numeral. Use one card per case whose deadline has passed.

**Each card must include:**

| Field | Notes |
|---|---|
| Company / case name | |
| Legitimacy band and reason | No percentage in report-facing text |
| What the deadline was | |
| What benefits were available | |
| Claim URL | For reference even if closed |

Do not render a claim ID or PIN in Expired. Those identifiers no longer support an action and unnecessarily increase the sensitivity of the local report.

---

## Filed & Tracking

Render the heading as `Filed & tracking`, without a section numeral. Use one card per claim previously submitted or auto-enrolled. Cross-reference the tracker and current emails.

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

If a filed or auto-enrolled claim's window remains open, show an `Open window` state and its deadline on this card. Do not duplicate it in Active claims.

---

## Security Alerts

Render the heading as `Security alerts`, without a section numeral. Use one card per suspicious email. Move any email scoring 🔴 (<40%) here instead of the other lifecycle sections.

**Each card must include:**

| Field | Notes |
|---|---|
| Sender / domain | |
| Subject line | |
| Legitimacy | `Phishing risk` plus the evidence-based reason; omit the percentage |
| Red flags | List the specific signals that drove the low score |
| Email date | |
| Advice | Always include: "Do not click any links. Report it as phishing in your mail provider." |

If no phishing emails were found, show: "No phishing emails detected in this scan."

---

## "What To Do Next" Action Queue

This queue holds every claim with an **open, user-actionable deadline**, not only unfiled ones. Filing is one such action; activating an awarded benefit, electing a payment method, and uploading proof are others, and each carries its own deadline. A filed claim with an outstanding action belongs here, with the CTA verb matching the action (`Activate benefit`, not `Open claim form`). Its Filed & tracking row then keeps only the record and links here rather than repeating the deadline and CTA. A filed claim with nothing outstanding stays in Filed & tracking alone.

Place this immediately after the hero and status strip, before Active claims. List items sorted by soonest deadline first. Every action must be visually separated into its own row or card so the action, deadline, value, and CTA cannot blur together.

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
| Legitimacy | Band and evidence-based reason, without the internal percentage |
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

Payout-monitoring reminders belong in Filed & tracking rather than the filing-action queue unless there is a concrete time-sensitive redemption action.

Also include a reminder:
- To log a filed claim: just tell the assistant (e.g. "I already filed the [company] one")
- To record a payout received: just tell the assistant (e.g. "I got $47 from [company]")

---

## Filed Status Presentation

Within Filed & tracking, present awaiting-payout claims first and paid claims second. Each row/card must make the lifecycle state obvious:

- `Filed · awaiting payout`
- `Auto-enrolled · awaiting payout`
- `Paid [date]`
- `Action needed · redeem payment`

Show filed date, claim ID and PIN, expected payout, actual payout, payout date, and payment method when known. These records remain visible across future scans through the tracker, even though they are excluded from the filing-action queue and the actionable-value total.

Wrap the paid subsection heading and every paid card in exactly one `<div id="paid">...</div>`. The wrapper is mandatory even when there are no paid claims; in that case leave it empty. Do not put awaiting-payout cards inside it. This is the stable Paid destination required by the report anchor contract.

---

## Purchase Search Audit

When Part D runs, state how many distinct product/service pairs reached a terminal classification out of how many were found. Email traversal and product classification are different coverage claims; do not use completion of the mailbox metadata sweep to imply that every product was checked.

An optional `Searched and ruled out` note may summarize no-match classifications by broad category and count. Keep it compact. Name a merchant only when the user explicitly requested it or its identity is material to a displayed match. For healthcare providers and similarly sensitive merchants, use categories and counts rather than names. A complete report must not contain a `not individually searched` bucket. If the user narrows scope, mark the remainder `user-limited`; if an external provider blocks completion, mark it `provider-limited` and state the constraint.

---

## Empty Section Rule

Keep every lifecycle anchor in the document even when it has no entries. Use semantic headings without rendered section numerals. For an empty Active claims section, collapse the entire section to one quiet line rather than rendering an eyebrow, heading, subtitle, and empty-state card. Use these messages:

- Active claims: "No additional open claims in this scan."
- Watching: "No potential future claims found."
- Expired: "No expired claims found."
- Filed & tracking: `No previously filed claims on record. Say "I already filed [company]" to log it.`
- Security alerts: "No phishing emails detected in this scan."

When Part D ran, also use: `No potentially matching open settlements found for the purchase confirmations reviewed.`

This keeps the report structure consistent across runs.
