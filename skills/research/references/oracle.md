# Oracle System

## What the Oracle Is

The Context oracle is an AI-powered probability estimator that evaluates prediction markets independently of trading activity. It analyzes available evidence — social media posts, authoritative web sources — and produces a probability estimate for each market's outcome.

The oracle's estimate is independent of the market price. When they diverge, that's the primary signal for identifying mispricings.

## Oracle vs Market Quotes

- **Market quotes** (`context_get_quotes` / `ctx.markets.quotes()`) — the current bid/ask/last from the orderbook. Driven by trader activity.
- **Oracle quotes** (`ctx.markets.oracleQuotes()`) — the oracle's probability estimates over time. Driven by evidence analysis.

These are fundamentally different data sources. A market might trade at 45c while the oracle estimates 70% — that 25-cent divergence is the arbitrage signal.

## SDK Methods

```ts
// Get the latest oracle summary with confidence and reasoning
ctx.markets.oracle(marketId): Promise<OracleResponse>

// Get oracle quote history
ctx.markets.oracleQuotes(marketId): Promise<OracleQuotesResponse>

// Request a fresh oracle evaluation (triggers re-analysis)
ctx.markets.requestOracleQuote(marketId): Promise<OracleQuoteRequestResult>
```

## Mispricing Detection Workflow

1. Get market price: `context_get_quotes` → YES last price
2. Get oracle estimate: `context_get_oracle` → probability percentage
3. Compare: `|oracle_probability - market_price|` = divergence
4. Apply thresholds:
   - **< 5 cents** — noise, market and oracle roughly agree
   - **5–10 cents** — monitor, may develop into opportunity
   - **> 10 cents** — significant divergence, likely mispricing
5. If divergence is large, simulate a trade: `context_simulate_trade` to check if the opportunity survives slippage

## Gotchas

- Oracle updates lag the market. The oracle re-evaluates periodically, not on every trade.
- `requestOracleQuote()` triggers a fresh evaluation but takes time to complete (seconds to minutes).
- Oracle confidence varies. A high-confidence 70% estimate is more actionable than a low-confidence one.
- Oracle can only evaluate evidence it can access. For `social_only` markets, it only sees X/Twitter posts from specified sources.
