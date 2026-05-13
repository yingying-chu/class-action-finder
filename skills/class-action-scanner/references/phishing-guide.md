# Phishing Detection Guide: Class Action Settlement Emails

Phishing emails impersonating settlement administrators are common. Every Type A and Type B email must be scored before the user acts on it. This guide defines the signals and scoring methodology.

---

## Scoring Method

Start at a baseline of 50%. Apply the signals below. The final score determines the confidence level:

| Range | Level | Action |
|---|---|---|
| 85–100% | 🟢 High confidence | Proceed normally |
| 60–84% | 🟡 Likely legitimate | Proceed, note the uncertainty |
| 40–59% | 🟠 Uncertain | Include in report with caution warning |
| < 40% | 🔴 Phishing risk | Move to Section 5, warn user not to click |

Always run a `WebSearch` for the case name + "settlement" or company name + "class action" to check for news coverage or court records. This is the single most reliable signal.

---

## Green Flags — Add to Score

| Signal | Points | How to detect |
|---|---|---|
| Case verifiable via WebSearch (news article, court record, PACER) | +25 | Search "[Company] class action settlement [year]" |
| Sender email domain is a known settlement administrator (Epiq, Kroll, JND, Rust Consulting, Analytics) | +20 | Check sender domain against list below |
| Email contains a PACER/court case number (format: N:YY-cv-NNNNN) | +15 | Look for "Case No." in the body |
| Claim URL domain contains "settlement" or "claims" and matches the defendant's name | +15 | e.g., `facebookuserprivacysettlement.com`, `applesettlement.com` |
| Email is addressed to a specific claim ID / notice ID tied to the recipient | +10 | Unique code present in email, not generic |
| No request for payment, SSN, bank account, or credit card anywhere | +10 | Scan full email body for these requests |
| Total settlement amount matches publicly reported figures | +10 | Confirm via WebSearch |

Maximum addable: +105 (score can exceed 100 — cap at 100)

---

## Red Flags — Subtract from Score

| Signal | Points | How to detect |
|---|---|---|
| Requests payment to "process" or "expedite" the claim | −40 | "Pay $X processing fee" — legitimate settlements are free to file |
| Requests SSN, bank account number, or credit card | −35 | Any financial account detail request is a major red flag |
| Case name not findable in any news, legal database, or court record via WebSearch | −25 | Unverifiable cases are almost always fabricated |
| Sender domain is random characters or unrelated to settlements | −20 | e.g., `noreply@xk7r2claim.com` vs `notices@epiqsystems.com` |
| Claim URL domain is newly registered or completely unrelated to the defendant | −20 | Domain doesn't mention defendant or case |
| Body is very short (< 100 words) with only a link — no case details | −15 | Real settlement notices are detailed |
| Excessive urgency language ("ACT NOW or FORFEIT FOREVER") | −10 | Real notices use measured, legal language |
| Obvious spelling / grammatical errors | −10 | Settlement administrators use legal professionals |
| Reply-to address differs significantly from sender address | −10 | Check email headers if visible |

---

## Known Legitimate Settlement Administrator Domains

These domains sending settlement emails should add confidence:
- `epiqsystems.com`, `epiqglobal.com`
- `krollsettlementadministration.com`, `kroll.com`
- `jndla.com` (JND Legal Administration)
- `rustconsulting.com`
- `simpluris.com`
- `classactl.com` (Class Action Claims)
- `angeiongroup.com`
- `heffler.com` (Heffler Claims Group)
- `gilardi.com`
- Any domain matching `*settlement*.com` or `*claims*.com` where the subdomain or name matches the defendant

If the sender is one of the above, add +20 to the score.

---

## Red-Flag Patterns by Email Source

**Emails found in spam (Query C):**
- Start with a slight negative bias (−5 baseline adjustment) — Gmail's spam filter caught it for a reason
- But do not dismiss — many legitimate settlement notices land in spam due to bulk sending
- Apply the same signals above; a legitimate case with spam-folder placement is still likely real

**Emails found in promotions (Query D):**
- Neutral baseline — promotions tab is common for bulk settlement mailers
- Apply signals normally

---

## Confidence Rationale Format

When recording the confidence score in the report, always include 2–3 specific signals:

✅ Good: `"🟢 88% — Case verified in WSJ (2024-01), sender is epiqsystems.com, court case No. 3:23-cv-04116 found on PACER"`

❌ Too vague: `"🟢 88% — Looks real"`

✅ Good: `"🔴 18% — Requests $25 processing fee; case name returns zero results; sender domain random-klaim-2024.xyz"`

For 🟠 and 🔴 emails, always include what the user should do: "Verify by searching '[case name] settlement' before acting" or "Do not click any links in this email."

---

## Common Phishing Scenarios

**"Claim your unclaimed settlement" scam:**
- Usually vague about which settlement, very large claimed amounts
- No verifiable case name
- Requests SSN to "verify identity"
- Score: typically 🔴

**Fake Facebook / Google settlement:**
- May cite real historical cases (e.g., "Facebook $725M settlement") even if that claim period has closed
- Check if the claim period is actually still open — if the real case closed, this is phishing
- Score: 🔴 if claim period has passed and the URL is not the official case site

**Law firm "mass action" solicitation:**
- Not phishing, but not a settlement claim — these are firms recruiting clients for a *new* lawsuit
- Correct classification: Irrelevant (skip entirely)
- Key tell: "contact us to join the lawsuit" rather than "submit your claim"
