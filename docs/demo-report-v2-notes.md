# Demo report v2.1 notes

This mock uses the current demo amounts: ExampleApp `$25–$175`, SampleCorp up to `$560`, and an actionable total of `$25–$735`.

## Presentation-only changes

- The notice funnel separates completion status, scan stages, and folder coverage so it can be read at a glance.
- The purchase funnel is a distinct receipt-coverage summary.
- The action queue owns the complete details for actionable claims. Active claim windows contains only additional open claims, so ExampleApp and SampleCorp are not rendered twice.
- An empty Active claims section keeps its lifecycle anchor but collapses to one quiet line.
- Start here appears before potential value and carries more visual weight.
- Purchase matches retain a compact Check eligibility action without entering the filing queue.
- Rendered headings use lifecycle names without Section 1–5 numerals.
- Claim and tracker rows are denser for faster comparison.
- Brand green is reserved for product chrome; legitimacy uses a separate teal treatment.

## Approved generator rules

- `SKILL.md` Step 9 makes the action queue the single owner of actionable-claim details and keeps notice coverage compact.
- `references/report-template.md` removes rendered section numerals and defines Active claims as additional open claims not already shown in the action queue.
- Report-facing confidence labels drop percentages while keeping the four legitimacy bands and their evidence-based reasons.
- Purchase coverage looks different from notice coverage while legitimacy and purchase eligibility remain separate.
- A real `Check eligibility` CTA is a block-level `<a>` only for a validated absolute `https://` 🟢/🟡 official information URL. Illustrative demos may use a non-interactive `<span>` with the same layout.

These rules are now part of the packaged skill specification.
