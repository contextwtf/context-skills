# Resolution Criteria Guide

This guide explains how to write resolution criteria that the Context Markets oracle can evaluate cleanly. The oracle is an AI system that reads your criteria as its sole instructions and evaluates evidence strictly against them.

## How the Oracle Works

The oracle receives:
1. Your resolution criteria (verbatim)
2. Social media posts from specified sources within the market's time window
3. Web research findings (if `evidenceMode: "web_enabled"`)

It does NOT have:
- Access to information outside these inputs
- Ability to follow URLs or links in posts
- Memory of other markets or previous conversations
- Real-time data feeds

The oracle classifies your market into a claim type and applies strict decision logic:
- **Monotonic claims** (event-by-deadline, threshold) can resolve YES early when confirmed
- **Period-gated claims** (end-state, durational) MUST wait until the market ends
- **Never/none claims** require the full window to pass without the event

Your criteria should make the claim type obvious. Don't write period-gated criteria for what should be a simple event-by-deadline market.

## The Criteria Template

```
This market resolves YES if [precise condition with measurable outcome].

This market resolves NO if [the market end time passes without the YES condition being met / specific disconfirming event].

Evidence sources: [specific X handles and/or authoritative source types].

Clarifications:
- [Edge case 1]
- [Edge case 2]
- [Definition of any ambiguous term]
```

## Writing the YES Condition

The YES condition must be:

1. **Observable** — something that produces evidence (announcements, data releases, scores)
2. **Binary** — clearly either true or false, no partial credit
3. **Specific** — names, numbers, dates, not "significant" or "major"
4. **Source-linked** — tied to evidence that the oracle can actually find

### Quantitative Conditions

When your market involves numbers, specify:
- The exact threshold (">$150,000", "at least 10", "more than 50%")
- The data source ("according to CoinGecko", "per the official box score")
- The measurement point ("at any point before end time" vs "at market close")

```
Resolves YES if Bitcoin's spot price on CoinGecko exceeds $150,000 USD
at any point before the market end time.
```

### Event Conditions

When your market involves something happening, specify:
- What constitutes the event ("announces" vs "leaks" vs "files")
- Who must do it ("official Apple account" vs "any credible source")
- What level of confirmation is required ("official statement" vs "credible report")

```
Resolves YES if Apple officially announces (via keynote presentation, press release,
or post from @Apple on X/Twitter) a new MacBook model with an M5 chip.
A supply chain leak or analyst prediction does not count as an announcement.
```

## Writing the NO Condition

For most markets, the NO condition is simply: "The market end time passes without the YES condition being met."

Explicit NO conditions are needed when:
- A specific disconfirming event exists (team eliminated, bill vetoed, event cancelled)
- The market is a "none/never" type where YES means something didn't happen

```
This market resolves NO if the FOMC meeting concludes and the committee
votes to hold rates steady or increase them.
```

## Specifying Evidence Sources

### For social_only markets

List specific X/Twitter handles that will cover the topic:

```
Evidence sources: @Apple, @tim_cook on X/Twitter.
```

- Use exact handles (case-insensitive matching)
- Max 25 sources
- Choose accounts that reliably post about the topic
- Include both official accounts and authoritative commentators
- Multiple sources use OR semantics by default — proof from any one source suffices

### For web_enabled markets

Describe the types of authoritative sources:

```
Evidence: Official Federal Reserve press release (federalreserve.gov),
or reporting from major financial outlets (Bloomberg, Reuters, CNBC, WSJ),
or posts from @FederalReserve on X/Twitter.
```

Web-enabled evidence hierarchy (oracle uses this priority):
1. **Official sources** — government sites, company IR pages, league officials
2. **Major outlets** — Reuters, AP, Bloomberg, NYT, etc.
3. **Domain authorities** — specialized outlets with expertise (ESPN for sports, TechCrunch for tech)
4. **Other** — aggregators, blogs, secondary sources

When web research conflicts with social media claims, authoritative web evidence takes precedence.

## Handling Edge Cases

Always consider and address:

### Cancellations and Postponements
```
If the event is cancelled or postponed beyond the market end time,
this market resolves NO.
```

### Partial Outcomes
```
A partial announcement (e.g., announcing the product category but not
the specific model) does not satisfy the YES condition. The full
product with the specified feature must be announced.
```

### Retractions
```
If the announcement is made and then retracted before the market end time,
the retraction governs — this resolves NO.
```

### Ambiguous Timing
```
The announcement must occur during the scheduled keynote (June 9, 2026,
10:00 AM - 12:00 PM PT) or any official Apple event during WWDC week.
Pre-event leaks do not count.
```

### Source Conflicts
```
If sources conflict, the official @Apple account takes precedence over
third-party reporting.
```

## Criteria for Different Market Types

### Sports Markets
```
This market resolves YES if the Los Angeles Lakers defeat the Boston Celtics
in Game 7 of the 2026 NBA Finals (final score, including overtime if applicable).

Evidence: Official @NBA or @NBAOfficial posts, or the official box score
on nba.com, or reporting from ESPN, The Athletic, or other major sports outlets.

If Game 7 is not played (series decided earlier), this market resolves NO.
```

### Political Markets
```
This market resolves YES if President Biden signs an executive order
imposing new sanctions on Russian energy exports before July 1, 2026.

Evidence: Official White House announcement (whitehouse.gov), posts from
@WhiteHouse or @POTUS, or reporting from Reuters, AP, or Bloomberg.

Clarifications:
- "New sanctions" means sanctions not already in effect as of market creation.
- Congressional legislation is not an executive order — only EOs count.
- A draft or leaked EO does not count until signed and published.
```

### Crypto/Finance Markets
```
This market resolves YES if Ethereum's spot price on CoinGecko exceeds
$10,000 USD at any point before the market end time.

Evidence: Posts citing or showing CoinGecko ETH/USD price above $10,000,
or the CoinGecko website showing this price level was reached.

Clarifications:
- Brief wicks above $10,000 count — the price only needs to touch the level.
- Other exchanges or aggregators do not count — CoinGecko is the sole reference.
- If CoinGecko is down or unavailable, this market resolves NO unless the
  price level is confirmed by CoinGecko data after the outage.
```

### Tech/Product Markets
```
This market resolves YES if OpenAI publicly releases (makes available for
general use, not just research preview or waitlist) a model they designate
as "GPT-5" before September 1, 2026.

Evidence: Official OpenAI blog post (openai.com/blog), posts from @OpenAI
or @sama on X/Twitter, or reporting from major tech outlets.

Clarifications:
- "Publicly releases" means available to the general public, not just
  enterprise or API-only access.
- A model called "GPT-4.5" or "GPT-5-preview" does not satisfy this unless
  OpenAI explicitly designates it as "GPT-5".
- A research paper or demo does not count as a public release.
```

## Common Mistakes

1. **Using "significant" without definition.** The oracle cannot judge significance without criteria. Define it: "more than 5%", "covered by at least 3 major outlets", etc.

2. **Assuming the oracle knows context.** It doesn't know what happened yesterday or what's common knowledge. State everything explicitly.

3. **Writing criteria that require following links.** The oracle cannot click URLs. Evidence must be in post text or on-image text.

4. **Forgetting the NO path.** Every market needs a clear path to NO resolution, usually "end time passes without condition being met."

5. **Time zone confusion.** Always specify the timezone. "By end of day" means nothing without a timezone.

6. **Source handles without @.** Use the exact X/Twitter handle format: `@handle`.

7. **Over-complicated multi-part criteria.** If your criteria have more than 2-3 conditions, consider splitting into multiple markets.
