# Extraction Guide: Class Action Email Patterns

## How to Identify Irrelevant Emails (Skip These)

These match the Gmail search queries but are NOT class action settlement emails:

| Category | Example signals | Action |
|---|---|---|
| Financial account settlement | "Your account balance has been settled", brokerage margin call resolved | Skip |
| Insurance claim settled | "Your property claim #12345 has been settled" | Skip |
| Lease / rent dispute | Landlord-tenant settlement, HOA settlement | Skip |
| Marketing language | "Settle in for savings", "settle your score" | Skip |
| Law firm solicitation | "Were you harmed by X? Contact us" — seeking clients, not notifying class members | Skip |
| News / newsletter | Article about a lawsuit but not addressed to a class member | Skip |

**Quick skip heuristic:** If the email does not say "you may be a class member" or "you are entitled to submit a claim" or "you received this notice because", it is almost certainly irrelevant.

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
| Pro-rata estimable | "$85M fund, estimated 2M claimants" | `~$42 (estimated)` |
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

## Type A vs. Type B Classification

| Signal | Type A (Active — submit now) | Type B (Potential — watch) |
|---|---|---|
| Claim form exists | Yes | No |
| Specific deadline stated | Yes, future date | No, or "TBD" |
| Sender | Settlement administrator | Law firm, news alert, advocacy org |
| Subject | "File your claim by..." | "Potential class action" / "Investigation announced" |
| Key verb | "You are entitled to submit" / "Claim your settlement" | "You may have a claim" / "We are investigating" |
| Linked domain | claims.somecase.com | Law firm website |
| Claim ID present | Often yes | Almost never |

**When ambiguous, default to Type B.** It is better to watch-list an item than to send the user to a claim form that doesn't exist yet.

---

## Common Edge Cases

**Multiple emails about the same case:**
Deduplicate by matching on case name or defendant company. Keep the most recent email's data (deadlines may have been extended). Add a note: "Updated — earlier email dated [DATE] had different deadline [OLD DATE]."

**Forwarded or CC'd email:**
Read all messages in the thread. The most recent message has the most current deadlines. The original forwarded email may have the claim ID if the latest reply doesn't.

**Email in multiple languages:**
Use the English portions if present. If entirely in another language, note the language and attempt extraction from recognizable dates and URLs.

**Settlement website behind a login wall:**
If `WebFetch` returns a login page, note "website requires account login — verify manually" and keep the email-extracted data.

**Cy pres / no individual payout:**
Some settlements pay no money to claimants and instead donate to charity. If the email says "cy pres" or "residual funds will be donated", record `individual_payout` as "$0 — cy pres distribution" and still list the case.
