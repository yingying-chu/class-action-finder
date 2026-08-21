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

## Generator rules to change after approval

- `SKILL.md` Step 9 must make the action queue the single owner of actionable-claim details and demote notice coverage to one line.
- `references/report-template.md` must remove rendered section numerals and define Active claim windows as additional open claims not already shown in the action queue.
- Report-facing confidence labels must drop percentages while keeping the four legitimacy bands and their evidence-based reasons.
- Purchase coverage must look different from notice coverage while legitimacy and purchase eligibility remain separate.

No generator rule is changed by this mock.
