# Markets API Reference

Method signatures and types for `ctx.markets.*` from the `context-markets` SDK.

## Search Params

```ts
interface SearchMarketsParams {
  query?: string;
  status?: "active" | "pending" | "resolved" | "closed";
  sortBy?: "new" | "volume" | "trending" | "ending" | "chance";
  sort?: "asc" | "desc";
  category?: string;
  limit?: number;
  cursor?: string;          // cursor-based pagination, NOT offset
  visibility?: "visible" | "hidden" | "all";
  resolutionStatus?: string;
  creator?: string;
  createdAfter?: string;
}

interface GetOrderbookParams {
  depth?: number;
  outcomeIndex?: number;    // 0=NO, 1=YES. Omit for fullOrderbook.
}

interface GetPriceHistoryParams {
  timeframe?: "1h" | "6h" | "1d" | "1w" | "1M" | "all";
}

interface GetActivityParams {
  cursor?: string;          // cursor-based pagination
  limit?: number;
  types?: string;
  startTime?: string;
  endTime?: string;
}
```

## Methods

```ts
// Discovery
ctx.markets.list(params?: SearchMarketsParams): Promise<MarketList>
ctx.markets.get(id: string): Promise<Market>

// Price data
ctx.markets.quotes(marketId: string): Promise<Quotes>
ctx.markets.orderbook(marketId: string, params?: GetOrderbookParams): Promise<Orderbook>
ctx.markets.fullOrderbook(marketId: string, params?): Promise<FullOrderbook>
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

// Market creation (write — requires auth)
ctx.markets.create(questionId: string): Promise<CreateMarketResult>
```

## Key Return Types

### Market
Key fields: `id`, `question`, `shortQuestion`, `status`, `deadline`, `volume`, `resolutionStatus`, `resolutionCriteria`, `metadata.categories`, and `metadata.sourceAccounts`.

### Quotes
```ts
{ yes: { bid, ask, last }, no: { bid, ask, last } }
```

### FullOrderbook
```ts
{ marketId, yes: { bids: Level[], asks: Level[] }, no: { bids: Level[], asks: Level[] } }
```

### SimulateTradeParams
```ts
interface SimulateTradeParams {
  side: "yes" | "no";
  amount: number;
  amountType?: "usd" | "contracts";  // default: "usd"
  trader?: string;
}
```

## MCP-to-SDK Mapping

| MCP Tool | SDK Method |
|----------|-----------|
| `context_list_markets` | `ctx.markets.list()` |
| `context_get_market` | `ctx.markets.get()` |
| `context_get_quotes` | `ctx.markets.quotes()` |
| `context_get_orderbook` | `ctx.markets.fullOrderbook()` |
| `context_simulate_trade` | `ctx.markets.simulate()` |
| `context_price_history` | `ctx.markets.priceHistory()` |
| `context_get_oracle` | `ctx.markets.oracle()` |
| `context_global_activity` | `ctx.markets.globalActivity()` |
