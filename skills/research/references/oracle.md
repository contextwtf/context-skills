# Oracle System

## What the Oracle Is

The Context oracle is an AI system that evaluates prediction markets independently of trading activity. It analyzes available evidence — social media posts and authoritative web sources — and returns summary text, supporting evidence, and separate quote objects.

The oracle's estimate is independent of the market price. When they diverge, that's the primary signal for identifying mispricings.

## Oracle vs Market Quotes

- **Market quotes** (`context_get_quotes` / `ctx.markets.quotes()`) — the current bid/ask/last from the orderbook. Driven by trader activity.
- **Oracle summaries** (`context_get_oracle` / `ctx.markets.oracle()`) — evidence, reasoning, and summary text. Not numeric price quotes.
- **Oracle quotes** (`ctx.markets.latestOracleQuote()` / `ctx.markets.oracleQuotes()`) — numeric probability estimates over time. Driven by evidence analysis.

These are fundamentally different data sources. A market might trade at 45c while the oracle estimates 70% — that 25-cent divergence is the arbitrage signal.

## SDK Methods

```ts
// Get the latest oracle summary with confidence and reasoning
ctx.markets.oracle(marketId): Promise<OracleResponse>

// Get the latest numeric oracle quote
ctx.markets.latestOracleQuote(marketId): Promise<OracleQuoteLatest>

// Get oracle quote history
ctx.markets.oracleQuotes(marketId): Promise<OracleQuotesResponse>

// Request a fresh oracle evaluation (triggers re-analysis)
ctx.markets.requestOracleQuote(marketId): Promise<OracleQuoteRequestResult>
```

## Mispricing Detection Workflow

1. Get market price: `context_get_quotes` → YES last price
2. Get oracle evidence: `context_get_oracle` or `ctx.markets.oracle(marketId)`
3. Get the numeric oracle quote: `ctx.markets.latestOracleQuote(marketId)`
4. Compare: `|latest_oracle_quote - market_price|` = divergence
5. Apply thresholds:
   - **< 5 cents** — noise, market and oracle roughly agree
   - **5–10 cents** — monitor, may develop into opportunity
   - **> 10 cents** — significant divergence, likely mispricing
6. If divergence is large, simulate a trade: `context_simulate_trade` to check if the opportunity survives slippage

## Gotchas

- Oracle updates lag the market. The oracle re-evaluates periodically, not on every trade.
- `requestOracleQuote()` triggers a fresh evaluation but takes time to complete (seconds to minutes).
- MCP does not expose oracle quote tools yet. Use the SDK when you need a numeric oracle probability.
- Oracle confidence varies. A high-confidence 70% estimate is more actionable than a low-confidence one.
- Oracle can only evaluate evidence it can access. For `social_only` markets, it only sees X/Twitter posts from specified sources.
