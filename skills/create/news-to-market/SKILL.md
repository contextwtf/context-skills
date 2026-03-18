---
name: context-create-news-to-market
description: Turn a news headline or event into a well-formed prediction market
---

# News to Market

Transform a news article, headline, or event into a properly structured prediction market with clear resolution criteria.

## When to Use

The user has a news event or topic and wants to create a prediction market around it.

## Steps

1. **Evaluate the input** — is the event resolvable, binary, timely, and interesting?
   - Resolvable: can the outcome be definitively determined?
   - Binary: is it clearly yes/no?
   - Timely: will the outcome be known within a reasonable timeframe?
   - Interesting: would people trade on this?

2. **Identify the claim type** — event-by-deadline, threshold, period-gated, durational, or none/never. This determines how the oracle can resolve.

3. **Draft the question** — start with "Will...", include a specific outcome and timeframe. Keep under 150 characters. Create a shorter `shortQuestion` variant.

4. **Write resolution criteria** — the most important part:
   ```
   This market resolves YES if [specific condition].
   This market resolves NO if [the market end time passes without the condition being met].

   Evidence sources: [@handle1, @handle2] on X/Twitter.
   [OR] Evidence sources: Official announcements from [specific outlets].

   Clarifications:
   - [What counts/doesn't count]
   - [Edge cases]
   ```

5. **Choose evidence mode:**
   - `social_only` if X/Twitter accounts will cover the event
   - `web_enabled` if official data sources (SEC filings, sports scores, government sites) are needed

6. **List sources** — for `social_only`: specific X handles. For `web_enabled`: types of authoritative sources.

7. **Set end time** — give buffer after the expected event for evidence to appear. If the event happens at 3pm, set end time to midnight or later.

8. **Submit:**
   - **MCP:** `context_agent_submit_market({ formattedQuestion, shortQuestion, marketType: "OBJECTIVE", evidenceMode, resolutionCriteria, endTime: "2026-06-15 23:59:59", timezone: "America/New_York", sources: ["@handle"], explanation: "Brief reason" })`
   - **SDK:** `ctx.questions.agentSubmitAndWait({ market: { formattedQuestion, shortQuestion, marketType, evidenceMode, resolutionCriteria, endTime, timezone, sources } })`
   - Then create on-chain: `ctx.markets.create(submission.questions[0].id)`
   - **CLI:** `context questions agent-submit-and-wait --formatted-question "..." --short-question "..." --market-type OBJECTIVE --evidence-mode web_enabled --resolution-criteria "..." --end-time "2026-06-15 23:59:59" --timezone "America/New_York" --sources "@Apple,@tim_cook"`

9. **Verify** — call `context_get_market` with the returned market ID to confirm it was created.

## Gotchas

- **End time too tight.** If the event happens at 3pm, don't set end time to 3:01pm. Evidence needs hours to appear on social media or news. Add at least 4–6 hours of buffer.
- **No sources specified.** Without sources, the oracle has no eligible evidence. Always specify X handles for `social_only`, or describe authoritative sources for `web_enabled`.
- **Ambiguous criteria.** "If it goes well" — what does "well" mean? Define every subjective term. Write criteria as if drafting a contract.
- **Combining conditions.** "Will X happen AND Y happen?" — make two separate markets. The oracle resolves one question at a time.
- **Period-gated confusion.** Don't write criteria that imply early resolution for end-of-period questions. "Will X close higher on Friday?" cannot resolve before Friday's close.
- **Wrong evidence mode.** Using `social_only` for an earnings report that will be on the SEC website but not tweeted by anyone specific. Use `web_enabled` for official data.
- **Submission takes 30–90 seconds.** The oracle processes the draft, validates criteria, and may reject if the market doesn't meet quality standards.

## Verification

- `context_get_market` returns the created market with status `"active"`.
- Resolution criteria in the created market match what you submitted.
- Evidence sources and evidence mode are correctly configured.

## See Also

- [Resolution Criteria Guide](../references/resolution-criteria.md) — Deep dive on writing criteria
- [Agent Submit API](../references/agent-submit-api.md) — Full field reference and types
