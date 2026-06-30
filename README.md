# Class Action Settlement Tools for Claude Code

Two Claude skills that scan your Gmail for class action settlements, score each email for legitimacy, and track what you've filed and received — so you don't leave money on the table.

Once installed, the skills work **globally** — in any folder, any project, any Claude Code session.

---

## Quick start

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Connect Gmail

The scanner reads your Gmail via Claude's MCP integration — it never stores or transmits your email data.

1. Go to [claude.ai](https://claude.ai) → **Settings → Integrations**
2. Connect **Gmail** and authorize read access

### 3. Clone and install

```bash
git clone https://github.com/yingying-chu/yy-class-action-finder.git
cd yy-class-action-finder
./install.sh
```

Restart Claude Code, then run your first scan:

```
/class-action-scanner
```

---

## How it works

Most people have unclaimed class action settlements sitting in their inbox (or spam folder). These tools:

1. **Scan** your Gmail across inbox, spam, and promotions using targeted search queries
2. **Score** every email for phishing risk before you act on it (🟢 safe → 🔴 do not click)
3. **Verify** open deadlines and payouts by fetching the actual settlement website
4. **Report** everything in a styled HTML file you can open in any browser

---

## `/class-action-scanner`

### Usage

```
/class-action-scanner              # last 12 months (default)
/class-action-scanner 6 months     # last 6 months
/class-action-scanner 2024         # all of 2024
/class-action-scanner 2023 to 2024 # custom range
```

Or trigger it in natural language:

- *"scan my email for class action settlements"*
- *"any class action claims I should file?"*
- *"find unclaimed settlement money in my inbox"*

### What the report contains

| Section | What's in it |
|---|---|
| **Active Claims** | Open claim windows with deadlines — sorted soonest first |
| **Watch List** | Lawsuits announced but claim form not yet open |
| **Expired** | Deadlines already passed — for reference |
| **Already Filed** | Cross-referenced from your tracker |
| **Phishing Alerts** | Emails that scored below 40% — do not click these |

### Example output

After the scan, Claude reports:

```
Report saved: class-action-report-2026-05-12.html

  3 actionable claims found
  Potential payout: $125 – $10,200+
  Most urgent: LastPass — deadline Jul 2, 2026 (51 days)
  2 emails surfaced from spam
  0 phishing alerts
```

Open the `.html` file in any browser to see the full report with cards, color-coded confidence indicators, and clickable claim links.

**Active Claims — Action Required**

| Company / Case | What It's About | Your Payout | Deadline |
|---|---|---|---|
| LastPass / Security Breach | 2022 data breach exposed account data | $25 base; up to $10,000 with losses | Jul 2, 2026 |

**Watch List — No Action Yet**

| Company / Case | What It's About | Status |
|---|---|---|
| Google / Android Cellular Data | Android phones transferred data without permission | Awaiting final approval Jun 23, 2026 |

**Already Filed**

| Company / Case | Filed | Expected | Actual |
|---|---|---|---|
| Blue Cross Blue Shield Antitrust | before 2021 | pro-rata share of $2.67B | Pending |
| Facebook / Internet Tracking | unknown | $4.01 | ✅ $4.01 received |

### Phishing scoring

Every email gets a confidence score before it reaches you:

| Score | Level | Meaning |
|---|---|---|
| 85–100% | 🟢 High confidence | Case verified in news/court records, known admin domain |
| 60–84% | 🟡 Likely legitimate | Most signals positive, limited independent verification |
| 40–59% | 🟠 Uncertain | Verify manually before acting |
| < 40% | 🔴 Phishing risk | Do not visit any links — report as phishing |

Green flags: sender is a known administrator (Epiq, Kroll, JND), case appears in news or PACER, no payment requested, court case number present.

Red flags: requests a processing fee, asks for SSN or bank account, case name returns zero search results, random sender domain.

---

## `/class-action-tracker`

Keeps a running record of what you've filed, what you're watching, and what you've been paid. Data lives in `~/.claude/class-action-tracker.json` on your machine — never committed to this repo.

### Usage

```
/class-action-tracker list
```
Shows all filed claims, watch list items, and payouts received.

Or trigger it in natural language:

- *"I filed my LastPass claim"*
- *"I got a $47 check from Blue Cross Blue Shield"*
- *"add Amazon Alexa Privacy to my watch list"*
- *"show me all my filed claims"*

### What it tracks

```
Your Class Action Tracker

Filed Claims (4 total)
──────────────────────────────────────────────────────────
Company / Case          Filed       Expected    Actual
Blue Cross Blue Shield  pre-2021    pro-rata    Pending ⏳
Kaiser Privacy Breach   2026-01-14  pro-rata    Pending ⏳
Ashley Furniture        2026-05-12  voucher     Pending ⏳
Facebook Tracking       unknown     $4.01       $4.01 ✅

Total received: $4.01
Still pending: 3 claims

Watch List (1 item)
──────────────────────────────────────────────────────────
Amazon Alexa Privacy — no claim form yet
```

The scanner automatically cross-references this tracker and marks already-filed claims with ✅ in the report.

---

## Repo structure

```
skills/
  class-action-scanner/
    SKILL.md                     # scanner skill
    references/
      extraction-guide.md        # email classification rules
      phishing-guide.md          # confidence scoring methodology
      report-template.md         # HTML report content guide
  class-action-tracker/
    SKILL.md                     # tracker skill
install.sh                       # copies skills into ~/.claude/skills/
```

---

## Privacy

- The scanner uses Gmail's search API (read-only) via Claude's MCP integration
- No email content is stored anywhere by these tools
- The tracker file (`~/.claude/class-action-tracker.json`) is local to your machine and not synced
- Settlement websites are fetched to verify deadlines — only the claim URL is visited, not your personal data
