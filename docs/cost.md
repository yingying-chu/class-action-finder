# Cost model

How much a scan costs, and why coverage and cost are not the tradeoff they first appear to be.

## Where the cost actually is

Full message bodies can be much larger than search metadata. Search results often carry sender, subject, date, and a snippet; those results also consume model tokens. Server-side search and web verification may have provider-specific charges. The example below illustrates metadata and body input volume, not a complete bill:

```text
10,000 emails in the last 12 months
   │  server-side filtering (provider-dependent cost)
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

Three choices do most of the work here:

1. **Plain text instead of the default HTML body.** Marketing HTML wrapped around three useful fields is often ten to fifty times larger than its plain-text equivalent, and contains nothing extra that matters.
2. **Triage on metadata first.** Sender, subject, and snippet identify the merchant for most receipts and often the product too. Full reads stay selective.
3. **Group by merchant and cache verified cases.** One settlement result is reused across related products instead of repeating the same public-source search.

The practical effect: a wide metadata sweep with narrow, plain-text reads is usually both broader *and* cheaper than a narrow sweep of full-HTML fetches.

The funnel leaves out the largest line on a real bill. An agent works in a loop, and every model request re-reads the conversation so far, mostly from the prompt cache. In the [measured run](#measured-scan-cost) below, cache reads came to about 4.6M tokens, against about 53K output tokens. Fewer model requests and smaller tool results therefore save more than any single read.

## Workload by scan type

**Notice Scan** — four overlapping metadata searches, de-duplicated before any body retrieval, followed by plain-text reads only for relevant candidates and public-record checks only for unique cases.

**Purchase Match** — defaults to the last 12 months. Sweeps every matching receipt at the metadata level, then reads in full only those whose product still needs identifying. Classifies every de-duplicated merchant/product pair and reuses merchant- and case-level web findings. Cost grows with mailbox volume and the number of distinct products needing public verification. Narrow merchant or product requests are cheaper and more precise.

**Recording a filing or payout** — reads and updates one small tracker file. Negligible.

## No coverage ceilings

The skill has no fixed 100-message, 25-product, or 30-search ceiling. It follows continuation tokens to completion and adaptively partitions dense date ranges when a provider has a non-pageable result window.

This matters more than it sounds. Mail search returns results newest-first, so a scan that takes only the first page makes a 12-month request and a 3-year request return the same recent messages — while reporting both as complete. If an external service makes complete coverage genuinely impossible, the report names that provider constraint and the known coverage instead of silently sampling.

## Measured scan cost

These figures come from one real run on September 21, 2026. It was a **Both** scan (settlement notices and purchases) of one personal mailbox over the default 12 months, run in Claude Code on Claude Sonnet 5 with prompt caching. It cost about **$2.29** at Claude Sonnet 5 list prices.

| | Notice phase | Full scan |
|---|---:|---:|
| Model requests | 11 | 26 |
| Cache reads | 942K | 4.58M |
| Cache writes | 220K | 337K |
| Output tokens | 10K | 53K |
| Largest single request | 168K | 285K |

The notice phase ends at the first purchase search, so it does not include writing the report. A notice-only scan therefore costs somewhat more than that column.

### The same workload at current prices

This table applies the measured token counts to each model's list price as of October 17, 2026. Each request is priced separately, so long-prompt tiers apply where a request crosses them: Claude Haiku 5.5 above 100K prompt tokens, and OpenAI models above 272K input tokens. These are API-equivalent costs, not subscription charges.

| Provider | Model | Notice phase | Full scan | Best fit |
|---|---|---:|---:|---|
| Anthropic | **Claude Opus 5.5** | ~$1.50 | ~$3.70 | Deepest review for ambiguous notices |
| Anthropic | **Claude Sonnet 5.5** | ~$0.75 | ~$1.80 | Balanced everyday scanning |
| Anthropic | **Claude Haiku 5.5** | ~$0.13 | ~$0.50 | Frequent or scheduled scans |
| OpenAI | **GPT-6 Astra** | ~$4.20 | ~$13 | OpenAI's most capable model |
| OpenAI | **GPT-6.1 Sol** | ~$0.75 | ~$2.00 | Balanced capability and cost |
| OpenAI | **GPT-6 Luna** | ~$0.04 | ~$0.13 | Cost-sensitive, high-volume scans |

Treat this as an order of magnitude, not a quote:

- It is one run on one mailbox. A busier inbox, a longer date range, or more distinct purchases raises the cost; a narrow merchant, product, or date request lowers it.
- Other models tokenize text differently, and they take different numbers of turns and write different amounts of output for the same task.
- Prices change. Rates used: [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing), [OpenAI pricing](https://developers.openai.com/api/docs/pricing), and the [GPT-6 Astra](https://developers.openai.com/api/docs/models/gpt-6-astra), [GPT-6.1 Sol](https://developers.openai.com/api/docs/models/gpt-6.1-sol), and [GPT-6 Luna](https://developers.openai.com/api/docs/models/gpt-6-luna) model pages, all checked October 17, 2026.

One recovered claim can outweigh many routine scans.
