# Class Action Settlement Tools for Claude Code

Two Claude Code slash commands that scan your Gmail for class action settlements, score each email for legitimacy, and track what you've filed and received — so you don't leave money on the table.

---

## How it works

Most people have unclaimed class action settlements sitting in their inbox (or spam folder). These tools:

1. **Scan** your Gmail across inbox, spam, and promotions using targeted search queries
2. **Score** every email for phishing risk before you act on it (🟢 safe → 🔴 do not click)
3. **Verify** open deadlines and payouts by fetching the actual settlement website
4. **Report** everything in one structured file: what to file now, what to watch, what expired, and what you've already submitted

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
3. That's it — no API keys or config files needed

### 3. Clone and run

```bash
git clone https://github.com/yingying-chu/yy-creatives.git
cd yy-creatives
claude
```

Then type:

```
/class-action-scanner
```

---

## `/class-action-scanner`

Searches your Gmail and produces a dated report file with every class action settlement it finds.

### Usage

```
/class-action-scanner              # last 12 months (default)
/class-action-scanner 6 months     # last 6 months
/class-action-scanner 2024         # all of 2024
/class-action-scanner 2023 to 2024 # custom range
```

### What the report contains

| Section | What's in it |
|---|---|
| **Active Claims** | Open claim windows with deadlines — sorted soonest first |
| **Watch List** | Lawsuits announced but claim form not yet open |
| **Expired** | Deadlines already passed — for reference |
| **Already Filed** | Cross-referenced from your tracker |
| **Phishing Alerts** | Emails that scored below 40% — do not click these |

### Phishing scoring

Every email gets a confidence score before it reaches you. The score starts at 50% and moves based on signals:

| Score | Level | Meaning |
|---|---|---|
| 85–100% | 🟢 High confidence | Case verified in news/court records, known admin domain |
| 60–84% | 🟡 Likely legitimate | Most signals positive, limited independent verification |
| 40–59% | 🟠 Uncertain | Verify manually before acting |
| < 40% | 🔴 Phishing risk | Do not visit any links — report as phishing |

Green flags: sender is a known administrator (Epiq, Kroll, JND), case appears in news or PACER, no payment requested, court case number present.

Red flags: requests a processing fee, asks for SSN or bank account, case name returns zero search results, random sender domain.

### Example output

```
Report saved: class-action-report-2026-05-12.md

  3 actionable claims found
  Potential payout range: $125 – $10,200+
  Most urgent: LastPass — deadline Jul 2, 2026 (51 days)
  2 emails surfaced from spam
  0 phishing alerts
```

---

## `/class-action-tracker`

Keeps a running record of what you've filed, what you're watching, and what you've been paid. Data lives in `~/.claude/class-action-tracker.json` on your machine — never committed to this repo.

### Usage

```
/class-action-tracker list
```
Shows all filed claims, watch list items, and payouts received.

```
/class-action-tracker filed LastPass claim ID SAMPLE-ID-0001
```
Marks a claim as filed and saves the claim ID.

```
/class-action-tracker payout "Blue Cross Blue Shield" $47.30
```
Records a payment received.

```
/class-action-tracker watch "Amazon Alexa Privacy"
```
Adds a case to your watch list for when the claim form opens.

The scanner automatically cross-references this tracker and marks already-filed claims with ✅ in the report.

---

## Files in this repo

```
.claude/
  commands/
    class-action-scanner.md      # scanner slash command
    class-action-tracker.md      # tracker slash command
  class-action-references/
    extraction-guide.md          # email classification rules
    phishing-guide.md            # confidence scoring methodology
    report-template.md           # output table structure
```

The reference files ship with the repo — no separate installation needed.

---

## Privacy

- The scanner uses Gmail's search API (read-only) via Claude's MCP integration
- No email content is stored anywhere by these tools
- The tracker file (`~/.claude/class-action-tracker.json`) is local to your machine and not synced
- Settlement websites are fetched to verify deadlines — only the claim URL is visited, not your personal data
