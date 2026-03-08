# Oracle System

## What the Oracle Is

The Context oracle is an AI-powered probability estimator that evaluates prediction markets independently of trading activity. It analyzes available evidence — news, data feeds, historical patterns — and produces a probability estimate for each market's outcome.

The oracle operates separately from the market's price discovery mechanism. A market priced at 45 cents YES might have an oracle estimate of 62%, indicating the oracle believes the market is underpriced.

## Getting Oracle Data

### MCP Tool

```
context_get_oracle { marketId: string }
```

Returns the oracle's probability estimate, confidence level, and reasoning summary.

### SDK Methods

```typescript
// Get oracle analysis (probability + reasoning)
ctx.markets.oracle(marketId: string): Promise<OracleResponse>

// Get oracle-derived price quotes
ctx.markets.oracleQuotes(marketId: string): Promise<OracleQuotesResponse>

// Request a fresh oracle evaluation
ctx.markets.requestOracleQuote(marketId: string): Promise<OracleQuoteRequestResult>
```

## Oracle Quotes vs Market Quotes

**Market quotes** (`context_get_quotes` / `ctx.markets.quotes()`) reflect the current best bid and ask from actual traders on the orderbook. They represent what you could buy or sell at right now.

**Oracle quotes** (`ctx.markets.oracleQuotes()`) are derived from the oracle's probability estimate. They represent what the oracle thinks the fair price should be, independent of current trading activity.

The distinction matters because:
- Market quotes tell you the current price.
- Oracle quotes tell you what an independent AI analysis thinks the price should be.
- The gap between them is the mispricing signal.

## Requesting Fresh Oracle Data

Oracle analyses may be cached. If you need a current evaluation — for example, after a significant news event — use `requestOracleQuote` to trigger a fresh analysis:

```typescript
// Force a re-evaluation
await ctx.markets.requestOracleQuote(marketId)

// Then read the updated result
const oracle = await ctx.markets.oracle(marketId)
```

Via MCP, `context_get_oracle` always returns the most recent available analysis. There is no MCP tool to explicitly request a refresh; the server handles caching internally.

## Identifying Mispricings

The primary research use of the oracle is detecting divergence between oracle estimates and market prices.

**Workflow:**

1. Get the oracle estimate:
   ```
   context_get_oracle { marketId: "abc123" }
   ```
   Suppose it returns a probability of 0.72 (72%).

2. Get the market price:
   ```
   context_get_quotes { marketId: "abc123" }
   ```
   Suppose YES last price is 58 cents.

3. Calculate divergence: 72 - 58 = 14 cents. The oracle thinks this market is significantly underpriced on YES.

4. Validate with simulation:
   ```
   context_simulate_trade { marketId: "abc123", side: "yes", amount: 50 }
   ```
   Check whether the expected fill price still offers value after slippage.

**Thresholds to consider:**
- Under 5 cents divergence: Likely noise. Not actionable.
- 5-10 cents: Worth monitoring. Check price history for trend direction.
- 10+ cents: Significant signal. Validate with simulation and check liquidity.

Oracle estimates are not infallible. They are one data point among several. Always cross-reference with price trends, volume, and orderbook depth before drawing conclusions.
