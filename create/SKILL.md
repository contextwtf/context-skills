# Create Skill

You are an AI agent that designs and submits high-quality prediction markets on Context Markets. You craft precise questions, write unambiguous resolution criteria, configure advanced market features (buckets, comparisons), and submit markets via the API.

## Prerequisites

- **Context MCP server** running (auto-started by this plugin) — for MCP tools
- **API key** (`CONTEXT_API_KEY`) — required for all submission methods
- **Private key** (`CONTEXT_PRIVATE_KEY`) — required for MCP tools and on-chain market creation

## Core Principles

Every market you create will be resolved by an AI oracle that evaluates evidence strictly against your resolution criteria. The oracle cannot use outside knowledge — it can only use eligible social media posts, on-image text, and (for web-enabled markets) research findings from authoritative sources. Your resolution criteria are the oracle's only instructions.

**A great market has:**
- A clear, binary yes/no question
- Resolution criteria that leave zero room for interpretation
- Appropriate evidence sources that can actually confirm the outcome
- A realistic end time that gives the outcome enough time to be observed and reported

**A bad market has:**
- Vague language ("significant," "major," "a lot")
- Criteria that require subjective judgment without defining it
- No specified sources, or sources that won't cover the topic
- An end time too close to the event (no time for evidence to appear)

## Question Design

### Formatting Rules

- Start with "Will..." for forward-looking events
- Include a specific, measurable outcome
- Include a deadline or timeframe when relevant
- Keep under 300 characters (hard limit), aim for under 150
- Create a `shortQuestion` under 200 characters — a condensed version for display

### Claim Type Awareness

The oracle classifies every market into a claim type that determines how it can resolve. Design your question and criteria with this in mind:

| Claim Type | Pattern | Example | Resolution Behavior |
|---|---|---|---|
| **Event-by-deadline** | "Will X happen by Y?" | "Will Apple announce a foldable iPhone before July 2026?" | Can resolve YES early once confirmed. Monotonic — once done, can't be undone. |
| **Threshold** | "Will X reach N?" | "Will Bitcoin hit $150,000 before April 2026?" | Can resolve YES early once threshold is reached. Monotonic. |
| **Period-gated end-state** | "Will X be Y at end of Z?" | "Will the S&P 500 close higher on Friday than it opened?" | Cannot resolve until the period ends. Intermediate states don't matter. |
| **Durational/aggregate** | "Most/total over period" | "Will Tesla sell more cars than Ford in Q2 2026?" | Cannot resolve until the period ends. Partial tallies are not final. |
| **None/never** | "Will X not happen?" | "Will there be no Fed rate cut before June 2026?" | YES requires the full window to pass without the event. A single occurrence forces NO. |

**Design tip:** Event-by-deadline and threshold markets are the easiest to resolve cleanly. Period-gated and durational markets require the full window to elapse, which means longer uncertainty. Choose the claim type that best matches the real-world event.

## Resolution Criteria

Resolution criteria are the most important part of a market. They are the oracle's only guide for deciding YES or NO. Write them as if you're drafting a legal contract.

### Structure

```
This market resolves YES if [specific condition].
This market resolves NO if [the market end time passes without the condition being met].

Evidence sources: [@handle1, @handle2] on X/Twitter.
[OR] Evidence sources: Official announcements, major news outlets, or domain authority sources.

[Additional rules, edge cases, and clarifications as needed.]
```

### Rules for Writing Criteria

1. **Be explicit about what counts as evidence.** Don't say "if announced" — say "if announced via an official post from @Apple on X/Twitter, or confirmed by a major news outlet."

2. **Define ambiguous terms.** If your question mentions "major," define what major means. If it mentions "announce," clarify whether a leak counts or only official statements.

3. **Handle edge cases.** What if the event is partially true? What if it's announced then retracted? What if the source deletes their post?

4. **Specify the evidence mode.** Use `social_only` when X/Twitter posts from specific accounts are sufficient. Use `web_enabled` when the oracle should also search authoritative web sources (official sites, news outlets).

5. **Name your sources.** For `social_only`, list specific X handles (e.g., `@elaboratecat`). For `web_enabled`, describe the types of authoritative sources (e.g., "official NFL website, ESPN, or major sports outlets").

6. **Time-bound everything.** Even if the question has a deadline, restate it in the criteria: "The condition must be met before the market end time."

7. **One condition per market.** Don't combine unrelated conditions. "Will X happen AND Y happen?" is harder to resolve than two separate markets.

### Good vs Bad Criteria

**Bad:** "This market resolves YES if Bitcoin goes up."
- What price? By when? According to what source? "Goes up" from what baseline?

**Good:** "This market resolves YES if Bitcoin's price exceeds $150,000 USD on CoinGecko at any point before the market end time. Evidence: a screenshot or post showing the CoinGecko BTC/USD price above $150,000, or confirmation from @CoinGecko on X/Twitter."

**Bad:** "This market resolves YES if Trump announces tariffs."
- Which tariffs? On what? Does a rumor count? Does a leaked document count?

**Good:** "This market resolves YES if President Trump or the official @WhiteHouse account on X/Twitter announces new tariffs on Chinese imports exceeding 25% on any product category. 'Announces' means an official statement, executive order, or signed proclamation — not a rumor, leak, or unofficial report."

## Market Types

### OBJECTIVE
The outcome is determined by a verifiable real-world event. Most markets should be OBJECTIVE.
- Sports results, election outcomes, price targets, product launches, policy decisions

### SUBJECTIVE
The outcome depends on the oracle's judgment based on evidence. Use sparingly and define the judgment criteria clearly.
- "Will the community reception of X be mostly positive?" — requires defining what "mostly positive" means and how to measure it
- "In the opinion of the oracle" language is valid — the oracle will use its reasoned judgment

## Evidence Modes

### social_only
The oracle resolves based exclusively on X/Twitter posts from specified sources. Use when:
- The event will be announced or discussed on X/Twitter
- You can name specific accounts that will cover it
- You want tight control over what counts as evidence

### web_enabled
The oracle also searches authoritative web sources (official sites, major news outlets, domain authorities). Use when:
- The outcome depends on official data (earnings, stats, scores)
- No single X account reliably covers the topic
- You want the oracle to find evidence from primary sources

**Important:** When using `web_enabled`, the oracle's research findings from authoritative sources can override contradictory social media claims. Web evidence from official/domain-authority sources takes precedence.

## Buckets

Buckets track counts of posts or unique authors matching specific criteria. Use them for threshold or comparative markets.

Each bucket has:
- `key` — unique identifier (e.g., `"positive"`, `"negative"`)
- `label` — human-readable name (e.g., `"Positive reactions"`)
- `countBy` — `"authors"` (unique people) or `"events"` (individual posts)
- `query` — search terms for matching posts
- `instructions` — detailed rules for what qualifies for this bucket
- `target` — optional threshold number (e.g., 10 means "at least 10")
- `includedAuthors` / `excludedAuthors` — optional author filters
- `authorOnly` — if true, only count posts from `includedAuthors`

### Bucket Example

"Will @elonmusk receive more than 50 supportive replies to his next policy post?"

```json
{
  "buckets": [
    {
      "key": "supportive",
      "label": "Supportive replies",
      "countBy": "authors",
      "query": "supportive replies to policy post",
      "instructions": "Count unique authors who reply with clearly supportive sentiment (agreement, praise, endorsement). Exclude neutral or ambiguous replies.",
      "target": 50,
      "includedAuthors": [],
      "excludedAuthors": ["elonmusk"]
    }
  ]
}
```

## Comparisons

Comparisons define relationships between buckets for comparative markets. Four types:

### Binary
Compares two buckets with an operator: `>`, `>=`, `==`, `<=`, `<`.

```json
{
  "type": "binary",
  "key": "more-positive",
  "label": "More positive than negative",
  "aKey": "positive",
  "bKey": "negative",
  "operator": ">"
}
```

### Max / Min
Finds the bucket with the highest or lowest count from a set.

```json
{
  "type": "max",
  "key": "most-discussed",
  "label": "Most discussed topic",
  "bucketKeys": ["topic-a", "topic-b", "topic-c"]
}
```

### Before
Checks which of two events happened first (temporal ordering).

```json
{
  "type": "before",
  "key": "announced-first",
  "label": "Company A announced before Company B",
  "aKey": "company-a",
  "bKey": "company-b",
  "event": "firstEvent",
  "requireBoth": true
}
```

### First
Like "before" but across multiple buckets — finds which had the earliest event.

```json
{
  "type": "first",
  "key": "first-to-react",
  "label": "First company to react",
  "bucketKeys": ["apple", "google", "microsoft"],
  "event": "firstEvent"
}
```

## Submission Methods

### 1. MCP Tools (recommended for agents)

**`context_agent_submit_market`** — Submit a fully-formed market draft, wait for oracle approval, and create the market on-chain. You control every field: question text, resolution criteria, sources, evidence mode, and end time. This may take 30-90 seconds.

```
context_agent_submit_market({
  formattedQuestion: "Will Apple announce a foldable iPhone at WWDC 2026?",
  shortQuestion: "Foldable iPhone at WWDC 2026?",
  marketType: "OBJECTIVE",
  evidenceMode: "web_enabled",
  resolutionCriteria: "This market resolves YES if Apple officially announces...",
  endTime: "2026-06-15 23:59:59",
  timezone: "America/Los_Angeles",
  sources: ["@Apple", "@tim_cook"],
  explanation: "WWDC 2026 foldable iPhone prediction"
})
```

**Note:** The MCP tool accepts flat parameters (not nested under `market`). Buckets and comparisons are not available via the MCP tool — use the SDK or API for advanced markets.

**`context_create_market`** — Alternative simple path. You provide a natural language question and the oracle generates the full market structure automatically. Best when you trust the oracle to set appropriate criteria.

```
context_create_market({ question: "Will Bitcoin hit $150,000 before April 2026?" })
```

### 2. SDK (full control, supports buckets/comparisons)

Agent submit is a two-step process: first submit your draft and wait for oracle approval, then create the on-chain market from the approved question.

```typescript
import { ContextClient } from '@contextwtf/sdk'

const ctx = new ContextClient({ apiKey: process.env.CONTEXT_API_KEY })

// Step 1: Submit draft and wait for oracle approval
const submission = await ctx.questions.agentSubmitAndWait({
  market: {
    formattedQuestion: "Will Apple announce a foldable iPhone at WWDC 2026?",
    shortQuestion: "Foldable iPhone at WWDC 2026?",
    marketType: "OBJECTIVE",
    evidenceMode: "web_enabled",
    sources: ["@Apple", "@tim_cook"],
    resolutionCriteria: `This market resolves YES if Apple officially announces a foldable iPhone (a phone with a folding screen form factor) during the WWDC 2026 keynote or any associated event.

This market resolves NO if WWDC 2026 concludes without an official foldable iPhone announcement from Apple.

Evidence: Official Apple announcements, posts from @Apple or @tim_cook on X/Twitter, or reporting from major technology outlets (The Verge, TechCrunch, Bloomberg, Reuters).

Clarifications:
- An "announcement" means a public reveal with product details, not a rumor or leak.
- A patent filing or supply chain leak does not count as an announcement.
- If WWDC is cancelled or postponed beyond the market end time, this resolves NO.`,
    endTime: "2026-06-15 23:59:59",
    timezone: "America/Los_Angeles",
    explanation: "WWDC 2026 foldable iPhone announcement prediction"
  }
})

// Step 2: Create the on-chain market from the approved question
const questionId = submission.questions[0].id
const market = await ctx.markets.create(questionId)
```

The SDK's `AgentSubmitMarketDraft` type provides full TypeScript support including `buckets` and `comparisons` fields.

### 3. CLI

Agent submit via CLI is also a two-step process:

```bash
# Step 1: Submit draft and wait for oracle approval
context questions agent-submit-and-wait \
  --formatted-question "Will Apple announce a foldable iPhone at WWDC 2026?" \
  --short-question "Foldable iPhone at WWDC 2026?" \
  --market-type OBJECTIVE \
  --evidence-mode web_enabled \
  --resolution-criteria "This market resolves YES if..." \
  --end-time "2026-06-15 23:59:59" \
  --timezone "America/Los_Angeles" \
  --sources "@Apple,@tim_cook" \
  --explanation "WWDC 2026 foldable iPhone prediction"

# Step 2: Create the on-chain market from the approved question ID
context markets create <questionId>
```

Use `agent-submit` instead of `agent-submit-and-wait` if you want to submit without polling.

### 4. Direct API (any language)

`POST /v2/questions/agent-submit` with the same body structure (nested under `market`). See the [Agent Submit API reference](references/agent-submit-api.md) for the full schema.

## SDK Methods

```typescript
// Agent submit (full control — recommended)
ctx.questions.agentSubmit(draft: AgentSubmitMarketDraft): Promise<SubmitQuestionResult>
ctx.questions.agentSubmitAndWait(draft: AgentSubmitMarketDraft, options?: SubmitAndWaitOptions): Promise<QuestionSubmission>

// Simple submit (oracle generates criteria — alternative)
ctx.questions.submit(question: string): Promise<SubmitQuestionResult>
ctx.questions.submitAndWait(question: string, options?: SubmitAndWaitOptions): Promise<QuestionSubmission>

// Check submission status
ctx.questions.getSubmission(submissionId: string): Promise<QuestionSubmission>

// Create on-chain market from approved question
ctx.markets.create(questionId: string): Promise<CreateMarketResult>
```

### Key Types

```typescript
import type { AgentSubmitMarketDraft, AgentSubmitComparison, Bucket } from '@contextwtf/sdk'
```

## React Hooks

For React applications using `@contextwtf/react`:

```typescript
import { useAgentSubmit, useAgentSubmitAndWait } from '@contextwtf/react'

// Fire-and-forget submission
const { mutate: submit } = useAgentSubmit()
submit({ market: { formattedQuestion: "...", ... } })

// Submit and wait for processing
const { mutate: submitAndWait } = useAgentSubmitAndWait()
submitAndWait({
  draft: { market: { formattedQuestion: "...", ... } },
  options: { pollIntervalMs: 2000, maxAttempts: 45 }
})
```

`useAgentSubmitAndWait` automatically invalidates the market list cache on success.

## Composite Workflows

### News-to-Market

Turn a news headline into a well-structured market.

1. Evaluate the input — is it resolvable, binary, timely, and interesting?
2. Identify the claim type (event-by-deadline, threshold, period-gated, etc.)
3. Draft the question — start with "Will...", include a specific outcome and timeframe
4. Write resolution criteria — be explicit about evidence sources, edge cases, and what counts
5. Choose evidence mode — `social_only` if X accounts cover it, `web_enabled` for official data
6. List sources — specific X handles and/or authoritative source types
7. Set end time — give enough buffer after the expected event for evidence to appear
8. Submit via `context_agent_submit_market` (MCP, handles everything) or `agentSubmitAndWait` + `markets.create` (SDK/CLI). Use `context_create_market` for simple cases where you trust oracle-generated criteria.
9. Verify the market was created with `context_get_market`

### Batch Market Creation

Creating multiple markets from a list of topics.

1. Generate all questions first — present the full list for user approval
2. Submit one at a time — avoid overwhelming the API
3. Wait at least 10 seconds between submissions
4. Verify each market was created
5. Report all created markets at the end with IDs and links

### Advanced Market with Buckets

For markets that track counts or compare quantities.

1. Define the question with clear comparative or threshold language
2. Create bucket definitions for each thing being counted
3. Write bucket instructions that precisely define what qualifies
4. Add comparisons if the resolution depends on relationships between buckets
5. Write resolution criteria that reference the bucket/comparison mechanics
6. Submit via `agentSubmit` (buckets require the structured endpoint)

## Common Mistakes to Avoid

1. **End time too tight.** If an event happens at 3pm, don't set the end time to 3:01pm. Give at least a few hours for evidence to appear on social media or news outlets.

2. **No sources specified.** Without sources, the oracle has no eligible evidence. Always specify X handles or use `web_enabled`.

3. **Ambiguous resolution.** "If it goes well" — what does "well" mean? Define every subjective term.

4. **Wrong evidence mode.** Using `social_only` for an earnings report that will be on the SEC website but not tweeted by anyone specific.

5. **Combining conditions.** "Will X happen and Y happen?" — make two separate markets instead.

6. **Forgetting edge cases.** What if the event is cancelled? Postponed? Partially true? Address these in the criteria.

7. **Period-gated confusion.** Don't write criteria that imply early resolution for end-of-period questions. "Will X be higher than Y at the end of the day?" cannot resolve early.

## References

- [Agent Submit API](references/agent-submit-api.md) — Full endpoint schema and field reference
- [Resolution Criteria Guide](references/resolution-criteria.md) — Deep dive on writing criteria the oracle can resolve

For cross-cutting SDK reference, see:
- [Full API Reference](../../references/api-reference.md)
- [Common Patterns](../../references/patterns.md)
- [Examples](../../references/examples.md)
