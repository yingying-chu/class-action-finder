# Extraction Guide: Class Action Email Patterns

## How to Identify Irrelevant Emails (Skip These)

These match the Gmail search queries but are NOT class action settlement emails:

| Category | Example signals | Action |
|---|---|---|
| Financial account settlement | "Your account balance has been settled", brokerage margin call resolved | Skip |
| Insurance claim settled | "Your property claim #12345 has been settled" | Skip |
| Lease / rent dispute | Landlord-tenant settlement, HOA settlement | Skip |
| Marketing language | "Settle in for savings", "settle your score" | Skip |
| Generic footer hit | `opt out`, `unsubscribe`, or `manage preferences` appears only in a marketing footer, with no class-action, settlement, case, or claim context | Skip from metadata; do not retrieve the body |
| Law firm solicitation | "Were you harmed by X? Contact us" — recruiting plaintiffs for an investigation or new lawsuit | Skip |
| News / newsletter | Article about a lawsuit but not a settlement notice or class-member-relevant case update | Skip |

**Quick skip heuristic:** If the email does not say "you may be a class member" or "you are entitled to submit a claim" or "you received this notice because", it is almost certainly irrelevant.

Opt-out language is an extraction field, not a discovery anchor. Many unrelated emails use `opt out` in an unsubscribe footer. Only extract an opt-out deadline after other evidence has established that the message is a settlement candidate.

---

## Strong Positive Signals — Definitely Include

- Sender name or domain contains "Settlement Administrator", "Claims Administrator", or "[CaseName]Settlement.com" / "[Company]Claims.com"
- Subject line contains "Notice of Class Action Settlement", "Your Legal Rights", "File a Claim", "Claim Deadline"
- Body contains CAFA-style notice language: "If you received this notice, you may be a class member in a class action lawsuit"
- Body contains a unique **Claim ID**, **Notice ID**, or **Unique ID** — these are per-recipient tokens pre-linked to the claimant's data
- Body links to a domain with "settlement" or "claims" in the hostname (e.g., `facebookuserprivacysettlement.com`, `claims.somecase.com`)
- Email mentions a specific case name (e.g., "Jones v. Meta Platforms Inc., Case No. 3:20-cv-08570")

---

## Extracting Payout Amounts

Payouts appear in several formats — extract exactly what is stated:

| Format | Example | How to record |
|---|---|---|
| Fixed amount | "each class member will receive $45.00" | `$45` |
| Range | "between $25 and $250 depending on proof" | `$25–$250` |
| Tier-based | "Tier 1: $25, Tier 2: up to $100 with receipts" | `$25–$100 (tiered)` |
| Pro-rata unknown | "your share of the $85 million fund" with no per-claimant estimate | `pro-rata, unknown` |
| Stated estimate | "The administrator estimates payments of approximately $42" | `~$42 (administrator estimate)` |
| No amount stated | Type B emails often don't have one | `unknown` |

Never calculate or invent an amount not stated in the email or on the settlement website.

---

## Extracting Deadlines

Deadlines appear in several phrasings — always extract the date as `YYYY-MM-DD` internally, display as `Mon DD, YYYY` in the report.

**Common phrasings:**
- "Claim Deadline: January 15, 2026"
- "You must submit your claim no later than 01/15/2026"
- "Claims must be postmarked by January 15, 2026" ← note: postmark deadline ≠ online submission deadline; prefer the online deadline if both are listed
- "The deadline to exclude yourself (opt out) is December 1, 2025"

**What to do when a deadline has passed (before today's date):**
- Change `type` to `EXPIRED` regardless of whether it was originally Type A
- Move the entry to Section 3 of the report
- Do not skip it — include it with the original deadline date for reference

**When no deadline is found:**
- Type A: record `claim_deadline` as "unknown — check website"
- Type B: record `claim_deadline` as "TBD — claim not yet open"

---

## Extracting Claim URLs

**Preference order** (use the first one found):
1. Hyperlinked text labeled "File a Claim", "Submit Claim", "File Your Claim Online"
2. Hyperlinked text labeled "Click Here" pointing to a claims domain
3. Bare URL in body text pointing to a domain with "settlement" or "claims"
4. General settlement info URL (if no claim-specific URL exists)

**Do not use:**
- Court document URLs (pacer.gov, court websites)
- Class counsel law firm URLs (these are for class representatives, not claimants)
- Opt-out mailing address (this is an address, not a URL)

**QR codes:** If the email only shows a QR code without a URL, record `claim_url` as "QR code in email — scan to access" and note in `notes` that the user should open the email on their phone.

---

## Extracting Claim IDs, Notice Numbers, and PINs

Administrators use inconsistent terminology for the same idea (a per-recipient token that pre-fills the claim form). Extract each one you find into its own field rather than merging them:

| Term seen in email | Record as |
|---|---|
| "Claim ID", "Claimant ID", "Confirmation Number" | `claim_id` |
| "Notice ID", "Unique ID" | `claim_id` (these are functionally the same as a claim ID — use whichever the email calls it) |
| "PIN", "Access Code", "Security Code" | `pin` |

**Many settlements require both to log in** (e.g., "Unique ID: ABC1234XYZ, PIN: 0000") — extract both when present. Don't fold a PIN into `claim_id` or vice versa; the report needs to show them as separate labeled values so the user can tell which one goes in which login field. If only one code is present, record it as `claim_id` and leave `pin` as `null`.

---

## Type A vs. Type B Classification

| Signal | Type A (Active — submit now) | Type B (Potential — watch) |
|---|---|---|
| Claim form exists | Yes | No |
| Specific deadline stated | Yes, future date | No, or "TBD" |
| Sender | Settlement administrator | Settlement administrator, court notice, or reputable class-member notice |
| Subject | "File your claim by..." | "Proposed settlement" / "Settlement approval pending" |
| Key verb | "You are entitled to submit" / "Claim your settlement" | "A settlement has been proposed" / "Claim process not yet open" |
| Linked domain | claims.somecase.com | Court, administrator, or case-information website |
| Claim ID present | Often yes | Almost never |

**When ambiguous, default to Type B.** It is better to watch-list an item than to send the user to a claim form that doesn't exist yet.

Generic law-firm recruitment ("we are investigating—contact us to join") and ordinary news coverage remain irrelevant. Type B requires a real proposed settlement or a case update plausibly directed to affected class members.

---

## Purchase Confirmation Extraction

Use this section only for Part D purchase matching. A receipt proves that a transaction may have occurred; it does not prove that the buyer is a settlement class member.

### Include

- Order confirmations, store receipts, paid invoices, app-store receipts, and subscription or membership confirmations
- Messages that explicitly name a merchant plus a product, model, plan, or service
- A purchase/transaction date from the message; use the order date rather than shipping or delivery date when both appear

### Skip

- Shipping, delivery, or tracking updates when an order confirmation for the same purchase is already present
- Cancellations, refunds, returns, declined payments, quotes, carts, and wishlist messages
- Bank or credit-card transaction alerts that identify only an amount and merchant but no product/service
- Marketplace summaries that do not reveal the actual item or service

### Extract only minimal evidence

| Field | Rule |
|---|---|
| `merchant` | Prefer the manufacturer/service provider when explicit; otherwise use the seller |
| `product_service` | Preserve a stated model, plan, size, or variant that may affect eligibility |
| `purchase_date` | Normalize to `YYYY-MM-DD`; never substitute shipment date without noting it |
| `purchase_region` | State/country only if explicit and material; otherwise `unknown` |
| `evidence_note` | One sentence describing the non-sensitive evidence that supports matching |

Never extract into the finding or web query: buyer name, street address, phone, email address, full order or invoice number, account number, payment method, card digits, loyalty ID, unrelated basket items, or raw receipt text. Do not copy full email bodies into the report.

### Normalize without over-merging

- Remove obvious legal suffixes from merchant comparison (`Inc.`, `LLC`, `Ltd.`), but retain the displayed name in the report.
- Treat model or plan variants as distinct until the verified settlement criteria show they belong to the same covered group.
- De-duplicate shipping and receipt emails using the provider's thread/message relationship first. Use an order identifier only in memory for de-duplication, then discard it.
- A merchant-only match is a lead, never an eligibility match. Require a related product/service or explicit category before searching or reporting.

---

## Common Edge Cases

**Multiple emails about the same case:**
Deduplicate by matching on case name or defendant company. Keep the most recent email's data (deadlines may have been extended). Add a note: "Updated — earlier email dated [DATE] had different deadline [OLD DATE]."

**Forwarded or CC'd email:**
Read all messages in the thread. The most recent message has the most current deadlines. The original forwarded email may have the claim ID if the latest reply doesn't.

**Email in multiple languages:**
Use the English portions if present. If entirely in another language, note the language and attempt extraction from recognizable dates and URLs.

**Settlement website behind a login wall:**
If the web browser or fetch tool returns a login page, note "website requires account login — verify manually" and keep the email-extracted data.

**Cy pres / no individual payout:**
Some settlements pay no money to claimants and instead donate to charity. If the email says "cy pres" or "residual funds will be donated", record `individual_payout` as "$0 — cy pres distribution" and still list the case.
