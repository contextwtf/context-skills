# Research Skill

You are an AI agent skilled at researching and analyzing prediction markets on Context Markets. You discover markets, interpret oracle signals, analyze price data, simulate trades, and monitor activity — all without placing orders or modifying any state.

## Prerequisites

- Context MCP server running (`npx context-markets-mcp`)
- No API key or private key needed — every tool in this skill is read-only

## Core Concepts

**Markets** are binary prediction contracts with YES and NO outcomes. Prices range from 1 to 99 cents and represent the market's implied probability. A YES price of 72 means the market assigns a 72% chance to the event occurring.

**Market statuses:** `active` (trading open), `pending` (awaiting resolution), `resolved` (outcome determined), `closed` (no longer trading).

**Oracle** is an AI-powered probability estimator that analyzes markets independently of trading activity. Oracle estimates often diverge from market prices — this divergence is the primary signal for identifying mispricings.

**Quotes** show the current best bid, best ask, and last trade price for both YES and NO sides. The bid-ask spread indicates liquidity depth.

**Simulation** previews what would happen if you placed a trade at a given size — expected fill price, slippage, and fees — without executing anything.

## MCP Tools

### Market Discovery

**`context_list_markets`** — Search and list markets.
```
{ query?: string, status?: "active"|"pending"|"resolved"|"closed", category?: string, sortBy?: "new"|"volume"|"trending"|"ending"|"chance", limit?: number }
```

**`context_get_market`** — Get full market details.
```
{ marketId: string }
```

**`context_global_activity`** — Recent trading activity across all markets.
```
{} (no params)
```

### Price and Orderbook

**`context_get_quotes`** — Current bid/ask/last prices for a market.
```
{ marketId: string }
```

**`context_get_orderbook`** — Orderbook depth for a market.
```
{ marketId: string, depth?: number }
```

**`context_price_history`** — Historical price data.
```
{ marketId: string, timeframe?: "1h"|"6h"|"1d"|"1w"|"1M"|"all" }
```

### Analysis

**`context_get_oracle`** — AI oracle probability estimate and analysis.
```
{ marketId: string }
```

**`context_simulate_trade`** — Simulate a trade to preview execution.
```
{ marketId: string, side: "yes"|"no", amount: number }
```

## SDK Methods

For agents that generate code against the Context SDK:

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
4. Compare oracle probability vs market YES price. Flag markets where the difference exceeds a threshold (e.g., 10+ cents).
5. Use `context_simulate_trade` to check whether the opportunity survives slippage at a realistic size.

### Portfolio Research

Analyze a set of markets for resolution status and exit opportunities.

1. Call `context_get_market` for each market of interest.
2. Check the market status — `resolved` markets have a known outcome.
3. For active markets, call `context_get_quotes` to assess current exit prices.
4. Call `context_price_history` with `timeframe: "1w"` to see recent price trends.
5. Use `context_get_oracle` to compare your position against the latest oracle estimate.

## References

- [Markets API](./references/markets.md) — Full method signatures and parameter types
- [Oracle System](./references/oracle.md) — Oracle resolution, quotes, and mispricing detection
- [Price Data](./references/price-data.md) — Quotes, price history, and spread analysis
- [Simulation](./references/simulation.md) — Trade simulation parameters and interpretation
