# Price Data

## Quote Structure

Quotes show the current best bid, best ask, and last trade price for both outcomes:

```ts
interface Quotes {
  yes: { bid: number | null; ask: number | null; last: number | null };
  no:  { bid: number | null; ask: number | null; last: number | null };
}
```

- **bid** — highest price someone is willing to buy at
- **ask** — lowest price someone is willing to sell at
- **last** — most recent trade price
- All prices in cents (1–99). Null if no orders on that side.

## Spread Analysis

The bid-ask spread indicates liquidity:

| Spread | Interpretation |
|--------|---------------|
| 1–3 cents | Tight — liquid market, easy to trade |
| 4–8 cents | Moderate — tradeable but watch slippage |
| 9+ cents | Wide — illiquid, limit orders recommended |

Spread = `ask - bid`. A wide spread means less liquidity and higher trading costs.

## Price History

```ts
ctx.markets.priceHistory(marketId, { timeframe: "1d" })
```

Timeframes: `"1h"` · `"6h"` · `"1d"` · `"1w"` · `"1M"` · `"all"`

Returns `PriceHistory` with an array of `{ time, price }` data points. Use for trend analysis.

Note: `PricePoint` is the correct type. `Candle` is deprecated — the API returns `{time, price}` not OHLCV candles. `PriceInterval` is deprecated — use `PriceTimeframe`.

## Orderbook Depth

```ts
ctx.markets.orderbook(marketId, { depth: 10 })       // single outcome
ctx.markets.fullOrderbook(marketId, { depth: 10 })    // both YES and NO
```

The orderbook shows available liquidity at each price level. Deeper books mean larger orders can fill without significant price impact.

## MCP Tools

| Tool | Returns |
|------|---------|
| `context_get_quotes` | Current bid/ask/last for YES and NO |
| `context_get_orderbook` | Full orderbook (both sides) |
| `context_price_history` | Historical price data |
