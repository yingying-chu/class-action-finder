<h1 align="center">Class Action Finder</h1>

<p align="center">
  <strong>Find settlement notices, match purchases to open cases, and remember every claim.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platforms-Claude%20%7C%20Codex%20%7C%20ChatGPT-5b5bd6" alt="Claude, Codex, and ChatGPT">
  <img src="https://img.shields.io/badge/mail-Gmail--first-4285F4" alt="Gmail-first">
  <img src="https://img.shields.io/badge/license-MIT-16a34a" alt="MIT License">
</p>

---

> A portable AI skill that scans connected email for class action settlement notices, checks purchase confirmations against potentially matching open settlements, verifies cases against public sources, flags phishing, produces an actionable HTML report, and tracks claims and payouts over time.

The same source in `skills/class-action-finder/` runs on Claude, Codex, and ChatGPT. Gmail receives the fullest scan, including spam and promotions; other searchable mail providers are supported with any coverage gaps disclosed in the report.

<p align="center">
  <img src="docs/screenshot-report.png" alt="Sample class action settlement report" width="760">
</p>

<p align="center">
  <sub>Illustrative data — <a href="docs/demo-report.html">open the HTML demo</a></sub>
</p>

## Table of contents

- [Installation](#installation)
- [Architecture](#architecture)
- [Quick start](#quick-start)
- [Report contents](#report-contents)
- [Phishing safeguards](#phishing-safeguards)
- [Storage and privacy](#storage-and-privacy)
- [Cost and value](#cost-and-value)
- [Scheduled scans](#scheduled-scans)
- [Project structure](#project-structure)
- [Development](#development)
- [Customization](#customization)
- [License](#license)

---

## Installation

Choose the surface where you want to run the skill. Local Claude and Codex installations keep separate tracker files and do not overwrite one another.

<details open>
<summary><strong>Codex</strong></summary>

Clone the repository and run the Codex installer:

```bash
git clone https://github.com/yingying-chu/class-action-finder.git
cd class-action-finder
./install.sh --codex
```

The skill is installed at:

```text
${CODEX_HOME:-$HOME/.codex}/skills/class-action-finder/
```

Restart Codex, connect a searchable Gmail or Outlook Email app/plugin, then invoke:

```text
$class-action-finder
```

</details>

<details>
<summary><strong>Claude Code</strong></summary>

Clone the repository and run the default installer:

```bash
git clone https://github.com/yingying-chu/class-action-finder.git
cd class-action-finder
./install.sh
```

The skill is installed at:

```text
~/.claude/skills/class-action-finder/
```

Restart Claude Code, connect a searchable Gmail or other mail connector, then invoke:

```text
/class-action-finder
```

</details>

<details>
<summary><strong>Claude.ai</strong></summary>

1. Download [`class-action-finder.zip`](https://raw.githubusercontent.com/yingying-chu/class-action-finder/main/dist/class-action-finder.zip).
2. Ensure **Code execution and file creation** is enabled.
3. Open **Customize → Skills → + → Create skill → Upload a skill**.
4. Upload the ZIP and connect Gmail or another searchable mail integration.
5. Say: `Scan my email for class action settlements.`

Claude.ai returns the HTML report as a downloadable artifact. Keep the generated `class-action-tracker.json` if you want to reuse claim history in another chat.

</details>

<details>
<summary><strong>ChatGPT</strong></summary>

1. Download [`class-action-finder.skill`](https://raw.githubusercontent.com/yingying-chu/class-action-finder/main/dist/class-action-finder.skill).
2. In the ChatGPT sidebar, open **Plugins → Skills → Create → Upload from your computer**.
3. Upload the Skill and connect the **Gmail** or **Outlook Email** app.
4. Say: `Use $class-action-finder to scan my email for class action settlements.`

Personal Skills are generally available for ChatGPT Business, Enterprise, Healthcare, and Edu, subject to workspace settings. Hosted chats return the report and updated tracker as downloadable artifacts.

</details>

Official setup references:

- [Use Skills in Claude](https://support.claude.com/en/articles/12512180-use-skills-in-claude)
- [Use Google Workspace connectors in Claude](https://support.claude.com/en/articles/10166901-use-google-workspace-connectors)
- [Skills in ChatGPT](https://help.openai.com/en/articles/20001066-skills-in-chatgpt)

---

## Architecture

Class Action Finder has three connected jobs:

1. **Find notices** and case updates in connected email.
2. **Match purchases** to potentially relevant open settlements without treating a receipt as proof of eligibility.
3. **Remember** filed claims, payouts, and watch-list items, then refresh the latest report after a record changes.

```text
Connected mail
    │
    ├── Direct notices
    │     Search inbox, spam, and promotions
    │     Verify case and score legitimacy
    │     Extract deadlines, payouts, IDs, PINs, and claim URLs
    │
    └── Purchase confirmations
          Extract merchant, product, and purchase date only
          Search verified public settlement sources
          Compare product, class period, and eligibility facts
                  │
                  ▼
        Match settlement identity
                  │
            ┌─────┴─────┐
            ▼           ▼
      Tracker JSON   HTML report
      filed + paid   actions + reviews + alerts
            │           │
            └─ refresh ─┘
```

The mail step is provider-adaptive. Gmail uses four purpose-built queries. Other providers receive equivalent searches where their syntax allows it; unavailable spam or category coverage is called out instead of silently ignored.

---

## Quick start

A bare invocation scans the previous 12 months:

```text
Scan my email for class action settlements.
```

Specify another date range when needed:

```text
Use $class-action-finder to scan the last 6 months.
Scan all settlement notices from 2024.
Check whether I missed any settlement deadlines this year.
```

Match purchases separately when you want discovery beyond legal notices:

```text
Scan my purchase confirmations from the last three years for possible settlements.
Check whether anything I bought from ExampleStore matches an open class action.
```

Purchase Match keeps settlement legitimacy separate from purchase eligibility. It reports strong and possible matches for review and only moves a case into the filing queue after the material eligibility facts are confirmed.

Update the tracker in normal language:

```text
I filed my ExampleApp settlement claim today.
I received $47 from SampleHealth Group.
Add SampleVoice Privacy to my watch list.
Show all my filed claims and payouts.
```

When a newly recorded filing matches the latest report, the skill can update that report in place and remove the completed filing action.

---

## Report contents

Every report keeps the same five lifecycle sections, plus a separate Purchase Matches to Review panel:

| Report area | What it contains |
|---|---|
| **Purchase Matches to Review** | Receipt-derived strong or possible matches that still need eligibility confirmation |
| **Active Claim Windows** | Open claims sorted by deadline, with eligibility, payout, IDs, and verified links |
| **Watch List** | Proposed settlements or relevant cases without an open claim form |
| **Expired** | Claim windows that have already closed |
| **Already Filed** | Tracker records cross-referenced with current email findings |
| **Phishing Alerts** | Suspicious notices that must not be opened |

The report also includes:

- an at-a-glance actionable payout range;
- a notice-email funnel from messages processed to claims requiring action;
- a separate purchase funnel when receipt matching runs;
- a sticky status navigator for action required, purchase matches, watching, filed, paid, expired, and security alerts;
- discovery badges that distinguish direct notices, purchase matches, and manually added records;
- separate settlement-legitimacy and purchase-eligibility labels;
- urgent-deadline highlighting;
- separate Claim ID and PIN fields;
- an **Already filed** badge that is distinct from legitimacy scoring;
- inbox, spam, and promotions coverage counts; and
- a clearly separated **What To Do Next** queue ordered by the nearest deadline.

<p align="center">
  <img src="docs/screenshot-phishing-action.png" alt="Filed claim tracking and phishing warning" width="680">
</p>

---

## Phishing safeguards

Email bodies, fetched pages, and search results are treated as untrusted data—not as instructions.

Each relevant notice is scored using:

- independent public case verification;
- authenticated sender and administrator reputation;
- court and case identifiers;
- consistency with reported settlement amounts;
- claim-domain relevance;
- payment or credential requests; and
- common phishing patterns.

| Score | Level | Action |
|---|---|---|
| 85–100% | 🟢 High confidence | Verified links may be shown |
| 60–84% | 🟡 Likely legitimate | Proceed with the stated uncertainty |
| 40–59% | 🟠 Uncertain | Show a warning; do not open the claim URL |
| Below 40% | 🔴 Phishing risk | Move to Phishing Alerts; never render the URL |

Two conditions always force a 🔴 result, regardless of copied legitimate case details:

- a fee to file, process, release, or expedite a claim; or
- a request to submit a full SSN, bank-account number, or credit-card number through the notice.

Only absolute `https://` URLs that pass validation can become clickable. Reports contain no scripts, remote images, or inline event handlers and use a restrictive Content Security Policy.

---

## Storage and privacy

### Local runtimes

| Runtime | Tracker | Reports |
|---|---|---|
| Claude Code | `~/.claude/class-action-tracker.json` | `~/.claude/skills/class-action-finder/output/` |
| Codex | `${CODEX_HOME:-$HOME/.codex}/class-action-tracker.json` | `${CODEX_HOME:-$HOME/.codex}/skills/class-action-finder/output/` |

The report always goes to the `output/` directory that belongs to the skill copy being run—never the caller's current working directory or an unrelated repository. When running directly from this checkout, that is:

```text
skills/class-action-finder/output/class-action-report-YYYY-MM-DD.html
```

Everything generated under that directory is ignored by Git except `.gitkeep`.

### Hosted runtimes

Claude.ai and ChatGPT return the HTML report and updated tracker as downloadable artifacts. Do not assume arbitrary files persist across future chats; keep `class-action-tracker.json` and upload it when prior claim history is needed.

### Privacy boundaries

- Email is read through the connected provider integration.
- Email content is never copied into this repository.
- Purchase matching sends only generic merchant/product search terms to the web—never names, addresses, order numbers, account details, payment details, or raw receipt text.
- Purchase history is held only for the active scan and is not persisted unless the user explicitly adds a matched case to the watch list or tracker.
- Local reports and tracker records stay on the user's machine.
- Hosted artifacts follow the storage and retention policy of that product and workspace.
- Reports may contain private claim IDs or PINs and should be handled as sensitive personal records.

---

## Cost and value

**Typical notice-scan workload:** roughly 100 overlapping raw search hits across four searches, de-duplicated to ~25 unique threads read in full, with about 10 public-record checks.

**Purchase Match workload:** a broad scan defaults to the last 12 months and is capped at 100 purchase emails, 25 merchant/product pairs, and 30 public-source searches, stopping early if the 8 highest-priority products come back empty. Its cost varies more than a notice scan because each plausible product may require separate public-source checks. Narrow merchant or product requests are cheaper and more precise.

### Cost is bounded, so coverage is what degrades

Cost follows the number of matching emails actually read, not the width of the date range — and the caps put a ceiling on it:

| Matching emails in range | Actually read | Cost | Coverage |
|---|---|---|---|
| ~20 | 20 | well under typical | complete |
| ~60 | 60 | below typical | complete |
| ~100 | 100 | at the ceiling | complete |
| ~500 | **100** | **same as ~100** | 20% |
| ~2000 | **100** | **same as ~100** | 5% |

Past the ceiling the price stops rising and coverage falls instead. This is also why widening the date range is not the lever it appears to be: mail search returns newest-first, so a 1-year and a 3-year request hand back **the same most-recent 100 messages**. To genuinely see more, name a merchant — which shrinks the search space so 100 messages reach further back — or run consecutive 12-month segments, each of which gets its own budget.

Every capped funnel stage is labelled with its denominator (`100 of ~1,400 · capped`) so a truncated scan is never presented as complete coverage.

| Provider | Model | Estimated typical notice scan | Best fit |
|---|---|---:|---|
| Anthropic | **Opus** | ~$1.40 | Deepest review for ambiguous notices |
| Anthropic | **Sonnet** | ~$0.35 | Balanced everyday scanning |
| Anthropic | **Haiku** | ~$0.12 | Frequent or scheduled scans |
| OpenAI | **GPT-5.6 Sol** | ~$0.70 | Frontier capability |
| OpenAI | **GPT-5.6 Terra** | ~$0.35 | Balanced intelligence and cost |
| OpenAI | **GPT-5.6 Luna** | ~$0.14 | Cost-sensitive, high-volume scans |

These are API-equivalent token estimates for a notice scan with prompt caching, not guaranteed subscription charges. Purchase Match may cost more when it reaches the 25-product cap. Actual cost varies with mailbox volume, date range, tool calls, and reasoning effort. OpenAI rates are based on the published [Sol](https://developers.openai.com/api/docs/models/gpt-5.6-sol), [Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra), and [Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna) pricing available in July 2026.

Recording a filing or payout only reads and updates one small tracker file. One recovered claim deadline can outweigh years of routine scans.

---

## Scheduled scans

Any agent environment that can run a recurring prompt can schedule this skill:

```text
Scan my email for class action settlements from the last 30 days.
```

Recommended operating pattern:

1. Run one manual scan in the same environment to confirm mail authorization.
2. Schedule weekly or monthly rather than daily.
3. Enable a completion notification so the report is actually reviewed.
4. Keep the tracker current so handled claims stop appearing as filing tasks.

---

## Project structure

```text
class-action-finder/
├── README.md
├── LICENSE
├── install.sh
├── skills/
│   └── class-action-finder/
│       ├── SKILL.md
│       ├── agents/
│       │   └── openai.yaml
│       ├── references/
│       │   ├── extraction-guide.md
│       │   ├── phishing-guide.md
│       │   └── report-template.md
│       └── output/
│           └── .gitkeep
├── scripts/
│   ├── check.sh
│   └── package-skill.sh
├── dist/
│   ├── class-action-finder.skill
│   └── class-action-finder.zip
└── docs/
    ├── demo-report.html
    ├── screenshot-report.png
    └── screenshot-phishing-action.png
```

`SKILL.md` is the portable workflow source. The `.zip` and `.skill` files in `dist/` are byte-identical archives for Claude and ChatGPT.

---

## Development

After editing `SKILL.md`, `agents/openai.yaml`, or a reference file, rebuild both portable artifacts:

```bash
./scripts/package-skill.sh
```

Run the full structural, installation, privacy, preservation, and archive test suite:

```bash
./scripts/check.sh
```

The checks verify:

- required skill and reference files;
- valid Skill metadata;
- safe demo HTML;
- Claude and Codex installation behavior;
- tracker and report preservation;
- symlink safety;
- archive integrity and source parity; and
- official Codex Skill validation when the validator is installed.

---

## Customization

The workflow is intentionally small and forkable:

| Change | File |
|---|---|
| Notice scan, purchase matching, record, or refresh behavior | [`SKILL.md`](skills/class-action-finder/SKILL.md) |
| Classification and field extraction | [`extraction-guide.md`](skills/class-action-finder/references/extraction-guide.md) |
| Confidence scoring and administrator domains | [`phishing-guide.md`](skills/class-action-finder/references/phishing-guide.md) |
| Report sections and presentation requirements | [`report-template.md`](skills/class-action-finder/references/report-template.md) |

Useful extensions include provider-specific search tuning, localized settlement conventions, additional trusted administrator signals, or a different report style.

---

## License

[MIT](LICENSE) — use, modify, and redistribute freely, including commercially, while retaining the copyright notice.
