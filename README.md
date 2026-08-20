<h1 align="center">Class Action Finder</h1>

<p align="center">
  <strong>Find the settlement notices you received and the cases your purchases might reveal.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platforms-Claude%20%7C%20Codex%20%7C%20ChatGPT-5b5bd6" alt="Claude, Codex, and ChatGPT">
  <img src="https://img.shields.io/badge/mail-Gmail--first-4285F4" alt="Gmail-first">
  <img src="https://img.shields.io/badge/license-MIT-16a34a" alt="MIT License">
</p>

---

> Settlement notices are easy to miss. Purchase-based cases may never contact you at all. Class Action Finder checks both paths, verifies what it finds, and turns the results into one private report.

Class Action Finder is a free, open-source AI skill for Claude, Codex, and ChatGPT. It works with connected email, keeps direct notices separate from receipt-based leads, flags suspicious claim links, and remembers what you filed or received.

## Two ways to find a claim

| | **Notice Scan** | **Purchase Match** |
|---|---|---|
| **Looks for** | Settlement notices, claim forms, filing confirmations, and payout emails | Receipts, order confirmations, renewals, and subscriptions |
| **Then does** | Extracts deadlines, payout terms, claim IDs, PINs, and verified claim links | Searches public sources for open settlements covering the merchant, product, and purchase period |
| **Result** | A verified notice with its deadline and next step | A possible match to review, never an automatic claim of eligibility |
| **Try it** | `Scan my email for class action settlements.` | `Scan my purchases for class actions.` |

Both paths feed the same local tracker and mobile-friendly HTML report, so filed claims stop appearing as unfinished tasks and payouts remain part of the record.

<p align="center">
  <img src="docs/screenshot-report.png" alt="Sample class action settlement report" width="760">
</p>

<p align="center">
  <sub>Illustrative UI with fictitious cases and amounts. No eligibility or payout is promised · <a href="docs/demo-report.html">open the HTML demo</a></sub>
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

<details>
<summary><strong>ChatGPT</strong></summary>

1. Download [`class-action-finder.skill`](https://raw.githubusercontent.com/yingying-chu/class-action-finder/main/dist/class-action-finder.skill).
2. In the ChatGPT sidebar, open **Plugins → Skills → Create → Upload from your computer**.
3. Upload the Skill and connect the **Gmail** or **Outlook Email** app.
4. Say: `Use $class-action-finder to scan my email for class action settlements.`

Personal Skills are generally available for ChatGPT Business, Enterprise, Healthcare, and Edu, subject to workspace settings. Hosted chats return the report and updated tracker as downloadable artifacts.

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

Tell the skill what you want:

| Goal | Prompt |
|---|---|
| Find settlement notices | `Scan my email for class action settlements.` |
| Match receipts to possible cases | `Scan my purchases for class actions.` |
| Run both discovery paths | `Scan both my settlement notices and purchases.` |
| Track a claim or payout | `I filed my ExampleApp claim today.` |

Both Notice Scan and Purchase Match cover the previous 12 months by default. Purchase Match treats every result as a lead until eligibility is confirmed. Add a merchant, product, or date range to narrow either scan.

On local runtimes, the HTML report is saved in the installed skill's `output/` folder as `class-action-report-YYYY-MM-DD.html`.

---

## Report contents

The HTML report answers four questions:

- **What needs action now?** Open, verified notices sorted by deadline.
- **Which purchases might match?** Receipt-based leads that still need an eligibility check.
- **What have I already handled?** Watching, filed, paid, and expired cases.
- **What looks unsafe?** Suspicious notices and links kept out of the action queue.

Each finding shows its source, confidence, deadline, payout terms, and next step when available. Claim IDs and PINs stay in the private report.

<p align="center">
  <img src="docs/screenshot-phishing-action.png" alt="Filed claim tracking and phishing warning" width="680">
</p>

---

## Phishing safeguards

Email bodies, fetched pages, and search results are treated as untrusted data, not as instructions.

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

The report always goes to the `output/` directory that belongs to the skill copy being run, never the caller's current working directory or an unrelated repository. When running directly from this checkout, that is:

```text
skills/class-action-finder/output/class-action-report-YYYY-MM-DD.html
```

Everything generated under that directory is ignored by Git except `.gitkeep`.

### Hosted runtimes

Claude.ai and ChatGPT return the HTML report and updated tracker as downloadable artifacts. Do not assume arbitrary files persist across future chats; keep `class-action-tracker.json` and upload it when prior claim history is needed.

### Privacy boundaries

- Email is read through the connected provider integration.
- Email content is never copied into this repository.
- Purchase matching sends only generic merchant/product search terms to the web. It never sends names, addresses, order numbers, account details, payment details, or raw receipt text.
- Purchase history is held only for the active scan and is not persisted unless the user explicitly adds a matched case to the watch list or tracker.
- Local reports and tracker records stay on the user's machine.
- Hosted artifacts follow the storage and retention policy of that product and workspace.
- Reports may contain private claim IDs or PINs and should be handled as sensitive personal records.

---

## Cost and value

**Typical notice-scan workload:** four overlapping metadata searches, de-duplicated before any body retrieval, followed by plain-text reads only for relevant candidates and public-record checks only for unique cases. There is no fixed workload ceiling.

**Purchase Match workload:** a broad scan defaults to the last 12 months. It sweeps every matching receipt at the metadata level, then reads in full only those whose product still needs identifying. It classifies every de-duplicated merchant/product pair and reuses merchant- and case-level web findings instead of repeating searches. Narrow merchant or product requests remain cheaper and more precise.

### Where the cost actually is

Reading a message is roughly fifty times more expensive than looking at it. Server-side search is free, search results already carry sender, subject, date, and a snippet, and only full message retrieval costs real tokens:

```text
10,000 emails in the last 12 months
   │  server-side search: free
   ▼
~800 purchase confirmations matched
   │  metadata sweep: sender + subject + snippet
   │  ~40 tokens each → ~32k total
   ▼
~50 receipts whose product is still unclear
   │  full read, plain text (not HTML)
   │  ~800 tokens each → ~40k total
   ▼
complete coverage of all 800, for ~70k
```

Three choices do most of the work here. Requesting **plain text instead of the default HTML body** avoids paying for layout, tracking pixels, and marketing markup to extract three fields. **Triaging on metadata first** keeps full reads selective. And **grouping by merchant plus caching verified cases** avoids repeating the same public-source search for related products.

The practical effect: coverage and cost are not the tradeoff they appear to be. A wide metadata sweep with narrow, plain-text reads is usually both broader *and* cheaper than a narrow sweep of full-HTML fetches.

The skill has no fixed 100-message, 25-product, or 30-search ceiling. It follows continuation tokens to completion and adaptively partitions dense date ranges when a provider has a non-pageable result window. If an external service still makes complete coverage impossible, the report identifies that provider constraint and the known coverage instead of silently sampling.

| Provider | Model | Estimated typical notice scan | Best fit |
|---|---|---:|---|
| Anthropic | **Opus** | ~$1.40 | Deepest review for ambiguous notices |
| Anthropic | **Sonnet** | ~$0.35 | Balanced everyday scanning |
| Anthropic | **Haiku** | ~$0.12 | Frequent or scheduled scans |
| OpenAI | **GPT-5.6 Sol** | ~$0.70 | Frontier capability |
| OpenAI | **GPT-5.6 Terra** | ~$0.28 | Balanced intelligence and cost |
| OpenAI | **GPT-5.6 Luna** | ~$0.03 | Cost-sensitive, high-volume scans |

These are API-equivalent token estimates for a notice scan with prompt caching, not guaranteed subscription charges. Purchase Match cost grows with mailbox volume and the number of distinct products that require public verification. Actual cost varies with date range, tool calls, and reasoning effort. OpenAI estimates use the published [Sol](https://developers.openai.com/api/docs/models/gpt-5.6-sol), [Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra), and [Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna) rates checked in August 2026.

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

[MIT](LICENSE). Use, modify, and redistribute freely, including commercially, while retaining the copyright notice.
