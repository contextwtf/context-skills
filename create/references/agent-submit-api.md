# Agent Submit API Reference

## Endpoint

```
POST /v2/questions/agent-submit
```

**Base URLs:**
- Testnet: `https://api-testnet.context.markets`
- Production: `https://api.context.markets`

**Authentication:** Bearer token via `Authorization: Bearer <CONTEXT_API_KEY>`

## Request Body

All fields are nested under a required `market` object.

### Required Fields

| Field | Type | Constraints | Description |
|---|---|---|---|
| `formattedQuestion` | string | 1-300 chars | Full market question text. Start with "Will..." |
| `shortQuestion` | string | 1-200 chars | Condensed version for display |
| `marketType` | enum | `SUBJECTIVE` \| `OBJECTIVE` | Market classification |
| `evidenceMode` | enum | `social_only` \| `web_enabled` | What evidence the oracle can use |
| `resolutionCriteria` | string | 1-6000 chars | Rules the oracle uses to resolve the market |
| `endTime` | string | `YYYY-MM-DD HH:MM:SS` | When the market closes, in the specified timezone |

### Optional Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `timezone` | string | `America/New_York` | IANA timezone identifier for `endTime` |
| `sources` | string[] | `[]` | X/Twitter handles or reference URLs (max 25) |
| `buckets` | Bucket[] | — | Data tracking buckets for count/threshold markets |
| `comparisons` | Comparison[] | — | Relationships between buckets |
| `explanation` | string | — | Market rationale summary (max 120 chars) |

## Bucket Schema

```typescript
interface Bucket {
  key: string           // Unique identifier (e.g., "positive")
  label: string         // Human-readable name
  countBy: "authors" | "events"  // Count unique authors or individual posts
  query: string         // Search terms for matching posts
  instructions: string  // Detailed rules for what qualifies
  target?: number       // Threshold (positive integer). Market can resolve YES when reached.
  includedAuthors?: string[]  // Only count posts from these authors
  excludedAuthors?: string[]  // Exclude posts from these authors
  authorOnly?: boolean  // If true, only match posts from includedAuthors
  order?: number        // Display order (>= 0)
}
```

## Comparison Schemas

### Binary Comparison

Compare two buckets with an operator.

```typescript
interface BinaryComparison {
  type: "binary"
  key: string           // Unique identifier
  label: string         // Human-readable description
  aKey: string          // First bucket key
  bKey: string          // Second bucket key
  operator?: ">" | ">=" | "==" | "<=" | "<"  // Default: ">"
  aWeight?: number      // Weight multiplier for bucket A (> 0)
  bWeight?: number      // Weight multiplier for bucket B (> 0)
  margin?: number       // Required margin of victory (>= 0)
}
```

### Max/Min Comparison

Find the bucket with the highest or lowest count.

```typescript
interface MaxMinComparison {
  type: "max" | "min"
  key: string
  label: string
  bucketKeys: string[]  // At least 2 bucket keys
}
```

### Before Comparison

Check temporal ordering — which event happened first.

```typescript
interface BeforeComparison {
  type: "before"
  key: string
  label: string
  aKey: string          // Bucket that should happen first
  bKey: string          // Bucket that should happen second
  event?: "firstEvent" | "targetReached"  // Default: "firstEvent"
  requireBoth?: boolean // Both must occur? Default: true
}
```

### First Comparison

Find which bucket had the earliest event across multiple buckets.

```typescript
interface FirstComparison {
  type: "first"
  key: string
  label: string
  bucketKeys: string[]  // At least 2 bucket keys
  event?: "firstEvent" | "targetReached"  // Default: "firstEvent"
}
```

## Response (200 OK)

```typescript
interface SubmissionResponse {
  submissionId: string
  questions: SubmissionQuestion[]
  accounts: Record<string, SubmissionAccount>
  qualityExplanation: string | null
  refuseToResolve: boolean
  status: string
  statusUpdates: { tool: string; status: string; timestamp: string }[]
  pollUrl?: string
}
```

After submission, poll `GET /v2/questions/submissions/{submissionId}` until `status` is `"completed"` or `"failed"`.

## Error Responses

| Status | Meaning |
|---|---|
| 400 | Invalid request body — check field constraints |
| 401 | Missing or invalid API key |
| 403 | Forbidden — account not authorized |
| 404 | Not found |
| 429 | Rate limited — check `X-RateLimit-Reset` header |
| 500 | Server error — retry with backoff |

## Rate Limiting

Response headers:
- `X-RateLimit-Limit` — requests allowed per window
- `X-RateLimit-Remaining` — requests remaining
- `X-RateLimit-Reset` — Unix timestamp when the window resets

## Full Example

```bash
curl -X POST https://api.context.markets/v2/questions/agent-submit \
  -H "Authorization: Bearer $CONTEXT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "market": {
      "formattedQuestion": "Will the Federal Reserve cut interest rates at the June 2026 FOMC meeting?",
      "shortQuestion": "Fed rate cut June 2026?",
      "marketType": "OBJECTIVE",
      "evidenceMode": "web_enabled",
      "sources": ["@FederalReserve", "@business", "@Reuters"],
      "resolutionCriteria": "This market resolves YES if the Federal Reserve announces a reduction in the federal funds target rate at the June 2026 FOMC meeting.\n\nThis market resolves NO if the Fed holds rates steady or increases them.\n\nEvidence: Official Federal Reserve press release, posts from @FederalReserve on X/Twitter, or reporting from major financial outlets (Bloomberg, Reuters, CNBC).\n\nClarifications:\n- Only the decision announced at the scheduled June 2026 FOMC meeting counts.\n- Emergency inter-meeting cuts before or after do not count.\n- The size of the cut does not matter — any reduction resolves YES.",
      "endTime": "2026-06-18 20:00:00",
      "timezone": "America/New_York",
      "explanation": "Federal Reserve June 2026 rate decision"
    }
  }'
```

## SDK Usage

```typescript
import { ContextClient } from 'context-markets'
import type { AgentSubmitMarketDraft } from 'context-markets'

const ctx = new ContextClient({ apiKey: process.env.CONTEXT_API_KEY })

// Option A: Submit and wait (polls automatically until completed/failed)
const submission = await ctx.questions.agentSubmitAndWait({
  market: {
    formattedQuestion: "...",
    shortQuestion: "...",
    marketType: "OBJECTIVE",
    evidenceMode: "web_enabled",
    sources: ["@FederalReserve"],
    resolutionCriteria: "...",
    endTime: "2026-06-18 20:00:00",
    timezone: "America/New_York",
    explanation: "..."
  }
}, {
  pollIntervalMs: 2000,  // optional, default 2000
  maxAttempts: 45,       // optional, default 45
})

// Option B: Submit without waiting (returns submissionId immediately)
const { submissionId } = await ctx.questions.agentSubmit({
  market: { ... }
})
// Check status later:
const result = await ctx.questions.getSubmission(submissionId)
// result.status: "processing" | "completed" | "failed"
```

## React Hooks

```typescript
import { useAgentSubmit, useAgentSubmitAndWait } from 'context-markets-react'

// Fire-and-forget
const { mutate: submit } = useAgentSubmit()
submit({ market: { formattedQuestion: "...", ... } })

// Submit and wait (auto-invalidates market cache on success)
const { mutate: submitAndWait } = useAgentSubmitAndWait()
submitAndWait({
  draft: { market: { formattedQuestion: "...", ... } },
  options: { pollIntervalMs: 2000, maxAttempts: 45 }
})
```

## CLI Usage

```bash
# Submit and wait for processing
context questions agent-submit-and-wait \
  --formatted-question "Will the Fed cut rates at the June 2026 FOMC meeting?" \
  --short-question "Fed rate cut June 2026?" \
  --market-type OBJECTIVE \
  --evidence-mode web_enabled \
  --resolution-criteria "This market resolves YES if..." \
  --end-time "2026-06-18 20:00:00" \
  --timezone "America/New_York" \
  --sources "@FederalReserve,@business,@Reuters" \
  --explanation "Federal Reserve June 2026 rate decision"

# Submit without waiting (returns submissionId)
context questions agent-submit ...

# Check status
context questions status <submissionId>
```
