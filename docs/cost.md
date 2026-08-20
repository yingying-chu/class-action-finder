# Cost model

How much a scan costs, and why coverage and cost are not the tradeoff they first appear to be.

## Where the cost actually is

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

Three choices do most of the work here:

1. **Plain text instead of the default HTML body.** Marketing HTML wrapped around three useful fields is often ten to fifty times larger than its plain-text equivalent, and contains nothing extra that matters.
2. **Triage on metadata first.** Sender, subject, and snippet identify the merchant for most receipts and often the product too. Full reads stay selective.
3. **Group by merchant and cache verified cases.** One settlement result is reused across related products instead of repeating the same public-source search.

The practical effect: a wide metadata sweep with narrow, plain-text reads is usually both broader *and* cheaper than a narrow sweep of full-HTML fetches.

## Workload by scan type

**Notice Scan** — four overlapping metadata searches, de-duplicated before any body retrieval, followed by plain-text reads only for relevant candidates and public-record checks only for unique cases.

**Purchase Match** — defaults to the last 12 months. Sweeps every matching receipt at the metadata level, then reads in full only those whose product still needs identifying. Classifies every de-duplicated merchant/product pair and reuses merchant- and case-level web findings. Cost grows with mailbox volume and the number of distinct products needing public verification. Narrow merchant or product requests are cheaper and more precise.

**Recording a filing or payout** — reads and updates one small tracker file. Negligible.

## No coverage ceilings

The skill has no fixed 100-message, 25-product, or 30-search ceiling. It follows continuation tokens to completion and adaptively partitions dense date ranges when a provider has a non-pageable result window.

This matters more than it sounds. Mail search returns results newest-first, so a scan that takes only the first page makes a 12-month request and a 3-year request return the same recent messages — while reporting both as complete. If an external service makes complete coverage genuinely impossible, the report names that provider constraint and the known coverage instead of silently sampling.

## Rough per-scan estimates

API-equivalent token estimates for a **notice scan** with prompt caching — not guaranteed subscription charges.

| Provider | Model | Estimated typical notice scan | Best fit |
|---|---|---:|---|
| Anthropic | **Opus** | ~$1.40 | Deepest review for ambiguous notices |
| Anthropic | **Sonnet** | ~$0.35 | Balanced everyday scanning |
| Anthropic | **Haiku** | ~$0.12 | Frequent or scheduled scans |
| OpenAI | **GPT-5.6 Sol** | ~$0.70 | Frontier capability |
| OpenAI | **GPT-5.6 Terra** | ~$0.28 | Balanced intelligence and cost |
| OpenAI | **GPT-5.6 Luna** | ~$0.03 | Cost-sensitive, high-volume scans |

Actual cost varies with date range, tool calls, and reasoning effort. OpenAI estimates use the published [Sol](https://developers.openai.com/api/docs/models/gpt-5.6-sol), [Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra), and [Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna) rates checked in August 2026. Model pricing changes; treat this table as an order of magnitude, not a quote.

One recovered claim deadline can outweigh years of routine scans.
