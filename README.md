# yy-creatives

Personal Claude Code skills and tools.

## Skills

### `/class-action-scanner`

Scans Gmail for class action settlement emails and produces an actionable markdown report.

**Features:**
- Searches inbox, spam, and promotions folders
- Phishing confidence scoring (🟢/🟡/🟠/🔴) with reasoning
- Cross-references your filed-claims tracker to mark already-submitted claims
- Visits settlement websites to confirm deadlines and payouts
- Output split into: Active Claims, Watch List, Expired, Already Filed, Phishing Alerts

**Usage:**
```
/class-action-scanner              # last 12 months (default)
/class-action-scanner 2024         # all of 2024
/class-action-scanner 6 months     # last 6 months
```

Saves a report to `class-action-report-YYYY-MM-DD.md` in your working directory.

---

### `/class-action-tracker`

Manages a persistent JSON record of filed claims and payouts received.

**Usage:**
```
/class-action-tracker list                      # show all filed claims and watch list
/class-action-tracker filed Meta               # mark a claim as filed
/class-action-tracker payout Meta $47          # record a payout received
/class-action-tracker watch Google             # add to watch list
```

Data is stored at `~/.claude/class-action-tracker.json`.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) (the CLI)
- A Gmail account connected to Claude.ai via the Gmail MCP integration

### Setting up the Gmail MCP

The scanner needs Claude to be able to read your Gmail. Here's how to connect it:

1. Open [Claude.ai](https://claude.ai) in your browser
2. Go to **Settings → Integrations** (or look for "Connected apps")
3. Find **Gmail** and click **Connect**
4. Authorize read access to your Gmail account
5. The MCP will now be available when you use Claude Code in this repo

Once connected, run `/class-action-scanner` and Claude will automatically find and use the Gmail MCP — no configuration needed.

### First-time setup

```bash
git clone https://github.com/yingyingchu/yy-creatives.git
cd yy-creatives
claude  # open Claude Code in this directory
```

Then type `/class-action-scanner` to run your first scan.
