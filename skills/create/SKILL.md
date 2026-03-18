---
name: context-create
description: Create prediction markets from natural language on Context Markets
---

# Create Skill

Design and submit prediction markets with precise questions, unambiguous resolution criteria, and appropriate evidence sources.

## Prerequisites

- **Context MCP server** running (`npx context-markets-mcp`)
- **CONTEXT_API_KEY** — required for all submission methods
- **CONTEXT_PRIVATE_KEY** — required for on-chain market creation

## Shared Foundations

### How Resolution Works

Every market is resolved by an AI oracle that evaluates evidence strictly against your resolution criteria. The oracle cannot use outside knowledge — it can only use eligible evidence (social media posts, web sources) matched against your criteria. Your criteria are the oracle's only instructions.

### Evidence Modes

- **`social_only`** — oracle resolves based on X/Twitter posts from specified accounts. Use when the event will be announced or discussed on X.
- **`web_enabled`** — oracle also searches authoritative web sources (official sites, news outlets). Use when the outcome depends on official data. Web evidence from authoritative sources overrides social media.

### Claim Types

| Type | Pattern | Resolution |
|------|---------|-----------|
| Event-by-deadline | "Will X happen by Y?" | Can resolve YES early. Monotonic. |
| Threshold | "Will X reach N?" | Can resolve YES early. Monotonic. |
| Period-gated | "Will X be Y at end of Z?" | Must wait until period ends. |
| Durational | "Most/total over period" | Must wait until period ends. |
| None/never | "Will X not happen?" | YES requires full window without event. |

### Market Types

- **OBJECTIVE** — verifiable real-world event (sports, elections, prices). Most markets.
- **SUBJECTIVE** — depends on oracle judgment. Define judgment criteria clearly.

### Question Rules

- Start with "Will..."
- Include a specific, measurable, binary outcome
- Include a deadline or timeframe
- Under 300 characters (aim for 150)
- Create a `shortQuestion` under 200 characters

### Submission Methods

**MCP (recommended for agents):**
- `context_agent_submit_market` — full control over question, criteria, sources, end time. Takes 30–90 seconds.
- `context_create_market` — simple path. You provide a question, oracle generates everything.

**SDK:**
- `ctx.questions.agentSubmitAndWait({ market: { ... } })` — full control, polls until complete
- `ctx.questions.submitAndWait("question")` — simple path

**CLI:**
- `context questions agent-submit-and-wait --formatted-question "..." --resolution-criteria "..." ...`
- `context questions submit-and-wait "Will...?"`

## Available Workflows

| Workflow | When to use |
|----------|-------------|
| [news-to-market](./news-to-market/SKILL.md) | Turn a news headline into a well-formed market |
| [diagnose-resolution](./diagnose-resolution/SKILL.md) | Troubleshoot rejected submissions or wrong resolutions |

## References

- [Agent Submit API](./references/agent-submit-api.md) — Full endpoint schema, field reference, types
- [Resolution Criteria Guide](./references/resolution-criteria.md) — Writing criteria the oracle can resolve
