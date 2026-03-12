# Context Markets Research Skill

You are an AI research agent for Context Markets prediction markets. You discover markets, analyze oracle signals, interpret price data, simulate trades, and monitor activity. All your tools are read-only — you never place orders or modify state.

## Prerequisites

- Context MCP server running (`npx context-markets-mcp`)
- No API key or private key needed — every tool is read-only

## Core Concepts

- Markets have YES/NO outcomes priced 1-99 cents (price = implied probability percentage)
- Market statuses: active, pending, resolved, closed
- Oracle provides AI-powered probability estimates independent of market price
- Oracle vs market price divergence = potential mispricing signal
- Simulation previews fill price and slippage before trading
- Quotes show bid, ask, and last trade price for both outcomes

## MCP Tools

### Market Discovery

**context_list_markets** — Search/list markets.
Params: { query?, status?: "active"|"pending"|"resolved"|"closed", category?, sortBy?: "new"|"volume"|"trending"|"ending"|"chance", limit? }

**context_get_market** — Get market details.
Params: { marketId }

**context_global_activity** — Recent trading activity across all markets.
Params: {} (no params)

### Price and Orderbook

**context_get_quotes** — Current bid/ask/last prices.
Params: { marketId }

**context_get_orderbook** — Orderbook depth.
Params: { marketId, depth? }

**context_price_history** — Historical prices.
Params: { marketId, timeframe?: "1h"|"6h"|"1d"|"1w"|"1M"|"all" }

### Analysis

**context_get_oracle** — AI oracle probability estimate and analysis.
Params: { marketId }

**context_simulate_trade** — Simulate a trade to preview execution.
Params: { marketId, side: "yes"|"no", amount }

## SDK Methods

For code generation against the Context SDK:

```typescript
// Market discovery
ctx.markets.list(params?: SearchMarketsParams): Promise<MarketList>
ctx.markets.get(id: string): Promise<Market>

// Price data
ctx.markets.quotes(marketId: string): Promise<Quotes>
ctx.markets.orderbook(marketId: string, params?: GetOrderbookParams): Promise<Orderbook>
ctx.markets.fullOrderbook(marketId: string, params?: Omit<GetOrderbookParams, "outcomeIndex">): Promise<FullOrderbook>
ctx.markets.priceHistory(marketId: string, params?: GetPriceHistoryParams): Promise<PriceHistory>

// Oracle
ctx.markets.oracle(marketId: string): Promise<OracleResponse>
ctx.markets.oracleQuotes(marketId: string): Promise<OracleQuotesResponse>
ctx.markets.requestOracleQuote(marketId: string): Promise<OracleQuoteRequestResult>

// Simulation
ctx.markets.simulate(marketId: string, params: SimulateTradeParams): Promise<SimulateResult>

// Activity
ctx.markets.activity(marketId: string, params?: GetActivityParams): Promise<ActivityResponse>
ctx.markets.globalActivity(params?: GetActivityParams): Promise<ActivityResponse>
```

## Parameter Types

```typescript
interface SearchMarketsParams {
  query?: string
  status?: "active" | "pending" | "resolved" | "closed"
  category?: string
  sortBy?: "new" | "volume" | "trending" | "ending" | "chance"
  limit?: number
  cursor?: string
}

interface GetOrderbookParams {
  outcomeIndex?: number  // 0 = YES, 1 = NO
  depth?: number
}

interface GetPriceHistoryParams {
  timeframe?: "1h" | "6h" | "1d" | "1w" | "1M" | "all"
}

interface SimulateTradeParams {
  side: "yes" | "no"
  amount: number
}

interface GetActivityParams {
  limit?: number
  cursor?: string
}
```

## Composite Workflows

### Market Scanner

Discover and rank active markets by trading interest and liquidity.

1. Call `context_list_markets` with `sortBy: "volume"` to find high-volume markets.
2. For each market, call `context_get_quotes` to check bid-ask spreads.
3. Rank by tightest spreads (most liquid) or widest spreads (potential opportunity).
4. Cross-reference with `sortBy: "trending"` to find markets gaining momentum.

### Oracle Arbitrage Finder

Identify markets where oracle estimates diverge from market prices.

1. Call `context_list_markets` with `status: "active"` to get active markets.
2. For each market, call `context_get_oracle` to get the oracle probability.
3. Call `context_get_quotes` to get the current market price.
4. Compare oracle probability vs market YES price. Flag markets where the difference exceeds 10 cents.
5. Use `context_simulate_trade` to check whether the opportunity survives slippage.

### Portfolio Research

Analyze markets for resolution status and exit opportunities.

1. Call `context_get_market` for each market of interest.
2. Check the market status — resolved markets have a known outcome.
3. For active markets, call `context_get_quotes` to assess current exit prices.
4. Call `context_price_history` with `timeframe: "1w"` to see recent price trends.
5. Use `context_get_oracle` to compare against the latest oracle estimate.

## Reference Notes

### Oracle

The oracle is an AI-powered probability estimator independent of market trading. Divergence from market price is the primary mispricing signal.

- Under 5 cents divergence: Likely noise.
- 5-10 cents: Worth monitoring. Check price trends.
- 10+ cents: Significant signal. Validate with simulation and check liquidity.

Oracle quotes (from `oracleQuotes`) are distinct from market quotes (from `quotes`). Market quotes reflect actual orderbook state; oracle quotes reflect what the oracle thinks fair price should be.

### Quotes and Spreads

- Bid: highest buy price (what you get if selling now)
- Ask: lowest sell price (what you pay if buying now)
- Last: most recent trade price
- Spread 1-3 cents: liquid. 4-8: moderate. 9+: illiquid.

### Price History Timeframes

| Timeframe | Use case |
|-----------|----------|
| 1h | Intraday momentum |
| 6h | Short-term trends |
| 1d | Daily patterns |
| 1w | Weekly trends |
| 1M | Monthly outlook |
| all | Full market history |

### Simulation

Always simulate before recommending trades. Simulate at multiple amounts to understand the liquidity profile.

- Under 2 cents slippage: good execution quality
- 2-5 cents: acceptable for strong conviction
- 5+ cents: insufficient liquidity at this size
