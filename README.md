<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="skills/class-action-finder/assets/logo-lockup-dark.svg">
    <img src="skills/class-action-finder/assets/logo-lockup.svg" alt="Class Action Finder" width="640">
  </picture>
</p>

<p align="center">
  <strong>Find money and benefits hiding in your inbox.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/portable-AI%20agent%20skill-5b5bd6" alt="Portable AI agent skill" align="middle">
  <img src="https://img.shields.io/badge/mail-Gmail--first-4285F4" alt="Gmail-first" align="middle">
  <img src="https://img.shields.io/badge/license-MIT-16a34a" alt="MIT License" align="middle">
  <a href="https://www.producthunt.com/products/class-action-finder" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/launched%20on-Product%20Hunt-ff6154?logo=producthunt&amp;logoColor=white" alt="Launched on Product Hunt" align="middle">
  </a>
</p>

---

> Settlement notices are easy to miss. Purchase-based cases may never contact you at all. Class Action Finder checks both paths, verifies what it finds, and turns the results into one private report.

Class Action Finder is a free, open-source skill for AI assistants and agents. It works with connected email, keeps direct notices separate from receipt-based leads, flags suspicious claim links, and remembers what you filed or received.

The core workflow is platform-independent. It can run in an agent environment that can search email, check public web sources, and create files. Ready-to-use installation paths are included for ChatGPT, Claude, and Codex; other capable agents may only need a thin adapter for their skill format and tools, not a separate scanning workflow.

<p align="center">
  <img src="docs/screenshot-report.png" alt="Sample class action settlement report" width="760">
</p>

<p align="center">
  <sub>Illustrative UI with fictitious cases and amounts. No eligibility or payout is promised · <a href="docs/demo-report.html">open the HTML demo</a></sub>
</p>

## Two ways to find a claim

| | **Notice Scan** | **Purchase Match** |
|---|---|---|
| **Looks for** | Settlement notices, claim forms, filing confirmations, and payout emails | Receipts, order confirmations, renewals, and subscriptions |
| **Then does** | Extracts deadlines, payout terms, claim IDs, PINs, and verified claim links | Searches public sources for open settlements covering the merchant, product, and purchase period |
| **Result** | A verified notice with its deadline and next step | A possible match to review, never an automatic claim of eligibility |
| **Try it** | `Scan my email for settlement notices.` | `Scan my purchases for class actions.` |

Both paths use the same claim tracker and mobile-friendly HTML report. Scans read existing claim history; record commands save filings and payouts, and purchase leads are added to the watch list only when you ask. Filed claims stop appearing as filing tasks, but any remaining benefit-activation, payment-election, or proof deadline still appears in Action required.

## Quick start

Install for your platform, connect a searchable mail integration, then just say what you want:

| Goal | Prompt |
|---|---|
| Not sure — let it ask | `Scan my email for class actions.` |
| Find settlement notices | `Scan my email for settlement notices.` |
| Match receipts to possible cases | `Scan my purchases for class actions.` |
| Run both discovery paths | `Scan both my settlement notices and purchases.` |
| Track a claim or payout | `I filed my ExampleApp claim today.` |

A bare invocation (`/class-action-finder` in Claude Code or `$class-action-finder` in Codex) or a general request asks which scan to run — `1. Settlement notices only`, `2. Purchases & receipts only`, or `3. Both` — so you never need to remember the exact wording. Explicit notice or purchase requests skip that question; if you decline to choose or say “just scan,” it runs Notice Scan. Record commands do not scan email. Both scans cover the previous 12 months by default. Purchase Match treats every result as a lead until eligibility is confirmed. Add a merchant, product, or date range to narrow either scan.

On local runtimes, the HTML report is saved in the installed skill's `output/` folder as `class-action-report-YYYY-MM-DD.html`.

## Installation

ChatGPT, Claude, and Codex are the currently packaged and tested environments. They are examples of where the portable workflow runs, not the boundary of the project. Local Claude and Codex installations keep separate tracker files and do not overwrite one another.

<details>
<summary><strong>ChatGPT</strong></summary>

1. Download [`class-action-finder.skill`](https://raw.githubusercontent.com/yingying-chu/class-action-finder/main/dist/class-action-finder.skill).
2. In the ChatGPT sidebar, open **Plugins → Skills → Create → Upload from your computer**.
3. Upload the Skill and connect the **Gmail** or **Outlook Email** app.
4. Select the skill with `@` where supported, or say: `Use class-action-finder to scan my email for class actions.`

Skills are available to eligible ChatGPT Business, Enterprise, Healthcare, and Edu users, subject to workspace settings and product availability. Upload and invocation controls can differ by surface. Hosted chats return the report and updated tracker as downloadable artifacts.

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
<summary><strong>Claude Code</strong></summary>

```bash
git clone https://github.com/yingying-chu/class-action-finder.git
cd class-action-finder
./install.sh
```

Installs to `~/.claude/skills/class-action-finder/`. Restart Claude Code, connect a searchable Gmail or other mail connector, then invoke `/class-action-finder`.

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
git clone https://github.com/yingying-chu/class-action-finder.git
cd class-action-finder
./install.sh --codex
```

Installs to `${CODEX_HOME:-$HOME/.codex}/skills/class-action-finder/`. Restart Codex, connect a searchable Gmail or Outlook Email app/plugin, then invoke `$class-action-finder`.

</details>

Setup references checked September 21, 2026: [Skills in Claude](https://support.claude.com/en/articles/12512180-use-skills-in-claude) · [Google Workspace connectors](https://support.claude.com/en/articles/10166901-use-google-workspace-connectors) · [Skills in ChatGPT](https://help.openai.com/en/articles/20001066-skills-in-chatgpt) · [ChatGPT and Codex skill invocation](https://learn.chatgpt.com/docs/build-skills)

To update a local installation, pull the latest repository changes and rerun the same installer command. Existing reports (including an `output/` symlink) and tracker files are preserved. For hosted installations, download and upload the latest archive again.

## Report contents

The HTML report answers four questions:

- **What needs action now?** Verified filing opportunities (including confirmed purchase matches), benefit activations, payment elections, and proof requests sorted by deadline.
- **Which purchases might match?** Receipt-based leads that still need an eligibility check.
- **What is being tracked?** Active, watching, filed, paid, and expired cases.
- **What looks unsafe?** Suspicious notices and links kept out of the action queue.

Each finding shows its source, legitimacy band with supporting reasons, deadline, payout terms, and next step when available. Purchase matches also show a separate eligibility level. Claim IDs and PINs appear only where needed in the private report; expired cases omit them.

<p align="center">
  <img src="docs/screenshot-phishing-action.png" alt="Filed claim tracking and phishing warning" width="680">
</p>

## Phishing safeguards

Email bodies, fetched pages, and search results are treated as untrusted data, not as instructions.

Each relevant notice is scored on independent public case verification, authenticated sender and administrator reputation, court and case identifiers, consistency with reported settlement amounts, claim-domain relevance, payment or credential requests, and common phishing patterns.

The scores below are internal heuristics, not calibrated probabilities; reports show the band and reasons rather than a percentage.

| Internal score | Level | Action |
|---|---|---|
| 85–100% | 🟢 High confidence | Verified links may be shown |
| 60–84% | 🟡 Likely legitimate | Proceed with the stated uncertainty |
| 40–59% | 🟠 Uncertain | Show a warning; do not open the claim URL |
| Below 40% | 🔴 Phishing risk | Move to Security alerts; never render the URL |

Two conditions always force a 🔴 result, regardless of copied legitimate case details:

- a fee to file, process, release, or expedite a claim; or
- a request to submit a full SSN, bank-account number, or credit-card number through the notice.

Only absolute `https://` URLs that pass validation can become clickable. Reports contain no scripts, remote images, or inline event handlers and use a restrictive Content Security Policy.

## Storage and privacy

| Runtime | Tracker | Reports |
|---|---|---|
| Claude Code | `~/.claude/class-action-tracker.json` | `~/.claude/skills/class-action-finder/output/` |
| Codex | `${CODEX_HOME:-$HOME/.codex}/class-action-tracker.json` | `${CODEX_HOME:-$HOME/.codex}/skills/class-action-finder/output/` |
| Claude.ai / ChatGPT | Returned as a downloadable artifact | Returned as a downloadable artifact |

On local runtimes, the report goes to the `output/` directory that belongs to the skill copy being run, never the caller's current working directory or an unrelated repository. This repository ignores generated files there except `.gitkeep`, and distribution archives exclude `output/`. Gitignore prevents ordinary accidental staging; it does not prevent forced adds or copies elsewhere. Never commit or push private reports.

On hosted runtimes, do not assume arbitrary files persist across chats; keep `class-action-tracker.json` and upload it when prior claim history is needed.

**Privacy boundaries**

- Email is read through the connected provider integration and processed by the assistant/model provider. The skill does not publish email content to this repository; generated reports contain selected findings.
- Purchase matching sends only generic merchant/product search terms to the web. It never sends names, addresses, order numbers, account details, payment details, or raw receipt text.
- Raw purchase history is not saved as a separate ledger. Displayed matches can include the product/service and purchase date in the report. Saving a lead to the tracker requires your request and records the case, not the receipt.
- Local report and tracker files are saved on your machine, but their contents may be processed in the assistant session. Conversation, connector, and hosted-artifact retention follow the relevant providers' policies.
- Reports may contain private claim IDs or PINs and should be handled as sensitive personal records.

## Cost

The skill itself is free. Model usage, subscription limits, and any search or connector charges depend on your runtime and provider. Search metadata, retrieved messages, verification, and generated output all contribute to usage; selective plain-text reads reduce it. Purchase Match grows with mailbox volume and the number of distinct products.

The skill has **no fixed 100-message, 25-product, or 30-search ceiling**. It pages to completion and adaptively partitions dense date ranges rather than silently sampling a first page and calling it complete.

→ [Illustrative workload model and dated per-model estimates](docs/cost.md). Check your provider’s current pricing before relying on a dollar estimate.

## Scheduled scans

Use a scheduler that can access the skill, authorized mail tools, web search, and report storage at run time. Name the scan mode explicitly so the run skips the interactive scan-mode question:

```text
Scan settlement notices only from the last 30 days.
```

Run one manual scan first to confirm mail authorization, schedule weekly or monthly rather than daily, enable a completion notification, and keep the tracker current so handled claims stop appearing as filing tasks.

## Development

Contributor documentation lives in [`CLAUDE.md`](CLAUDE.md) — architecture, invariants, and packaging rules.

```bash
./scripts/package-skill.sh   # rebuild dist/ after editing the skill
./scripts/check.sh           # structural, install, privacy, and archive tests
```

| Change | File |
|---|---|
| Notice scan, purchase matching, record, or refresh behavior | [`SKILL.md`](skills/class-action-finder/SKILL.md) |
| Classification and field extraction | [`extraction-guide.md`](skills/class-action-finder/references/extraction-guide.md) |
| Confidence scoring and administrator domains | [`phishing-guide.md`](skills/class-action-finder/references/phishing-guide.md) |
| Report sections and presentation requirements | [`report-template.md`](skills/class-action-finder/references/report-template.md) |
| Logo mark, app icon, and wordmark | [`assets/`](skills/class-action-finder/assets/) |

## License

[MIT](LICENSE). Use, modify, and redistribute freely, including commercially, while retaining the copyright notice.
