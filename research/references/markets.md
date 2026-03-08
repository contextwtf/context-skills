# Markets API Reference

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

interface GetActivityParams {
  limit?: number
  cursor?: string
}

interface SimulateTradeParams {
  side: "yes" | "no"
  amount: number
}
```

## SDK Methods

All methods are read-only.

### List Markets

```typescript
ctx.markets.list(params?: SearchMarketsParams): Promise<MarketList>
```

Search and filter markets. Supports pagination via `cursor`. Default sort is by relevance when `query` is provided, otherwise by creation date.

**Examples:**

```typescript
// Trending active markets
const trending = await ctx.markets.list({ status: "active", sortBy: "trending" })

// Search by keyword
const elections = await ctx.markets.list({ query: "election", limit: 10 })

// High-volume markets
const liquid = await ctx.markets.list({ sortBy: "volume", status: "active" })

// Markets ending soon
const expiring = await ctx.markets.list({ sortBy: "ending", status: "active" })
```

### Get Market

```typescript
ctx.markets.get(id: string): Promise<Market>
```

Returns full market details including question, description, category, status, resolution date, and current prices.

### Quotes

```typescript
ctx.markets.quotes(marketId: string): Promise<Quotes>
```

Returns the current best bid, best ask, and last trade price for both YES and NO outcomes. See [Price Data](./price-data.md) for interpreting quotes.

### Orderbook

```typescript
ctx.markets.orderbook(marketId: string, params?: GetOrderbookParams): Promise<Orderbook>
```

Returns bids and asks at each price level. Use `outcomeIndex` to get one side (0 = YES, 1 = NO). Use `depth` to limit the number of price levels returned.

```typescript
ctx.markets.fullOrderbook(marketId: string, params?: Omit<GetOrderbookParams, "outcomeIndex">): Promise<FullOrderbook>
```

Returns the orderbook for both YES and NO outcomes in a single call.

### Price History

```typescript
ctx.markets.priceHistory(marketId: string, params?: GetPriceHistoryParams): Promise<PriceHistory>
```

Returns historical price points at the specified timeframe resolution. See [Price Data](./price-data.md) for timeframe selection guidance.

### Oracle

```typescript
ctx.markets.oracle(marketId: string): Promise<OracleResponse>
```

Returns the AI oracle's probability estimate and analysis. See [Oracle System](./oracle.md) for details.

```typescript
ctx.markets.oracleQuotes(marketId: string): Promise<OracleQuotesResponse>
```

Returns oracle-derived price quotes, distinct from market-derived quotes.

```typescript
ctx.markets.requestOracleQuote(marketId: string): Promise<OracleQuoteRequestResult>
```

Requests a fresh oracle analysis. The oracle may cache results; use this to force a re-evaluation.

### Simulation

```typescript
ctx.markets.simulate(marketId: string, params: SimulateTradeParams): Promise<SimulateResult>
```

Simulates a trade without executing it. Returns expected fill price, slippage, and fees. See [Simulation](./simulation.md) for interpretation.

### Activity

```typescript
ctx.markets.activity(marketId: string, params?: GetActivityParams): Promise<ActivityResponse>
```

Returns recent trading activity for a specific market. Supports pagination.

```typescript
ctx.markets.globalActivity(params?: GetActivityParams): Promise<ActivityResponse>
```

Returns recent trading activity across all markets.

### Create Market

```typescript
ctx.markets.create(questionId: string): Promise<CreateMarketResult>
```

Creates a new market from an approved question. This is the only write method on the markets namespace.

## MCP Tool Mapping

| MCP Tool | SDK Method |
|----------|-----------|
| `context_list_markets` | `ctx.markets.list()` |
| `context_get_market` | `ctx.markets.get()` |
| `context_get_quotes` | `ctx.markets.quotes()` |
| `context_get_orderbook` | `ctx.markets.orderbook()` |
| `context_simulate_trade` | `ctx.markets.simulate()` |
| `context_price_history` | `ctx.markets.priceHistory()` |
| `context_get_oracle` | `ctx.markets.oracle()` |
| `context_global_activity` | `ctx.markets.globalActivity()` |
