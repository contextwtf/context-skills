# Price Data

## Quote Structure

Quotes represent the current state of a market's pricing. Each market has quotes for both YES and NO outcomes.

### MCP Tool

```
context_get_quotes { marketId: string }
```

### SDK Method

```typescript
ctx.markets.quotes(marketId: string): Promise<Quotes>
```

### Fields

Each outcome (YES and NO) has three price fields:

- **Bid** — The highest price someone is willing to pay. This is the price you would receive if you sold right now.
- **Ask** — The lowest price someone is willing to sell at. This is the price you would pay if you bought right now.
- **Last** — The price of the most recent executed trade.

All prices are in cents, ranging from 1 to 99. YES and NO prices are complementary: if YES bid is 60, the NO ask is approximately 40 (they sum to roughly 100, minus the spread).

### Spread Analysis

The bid-ask spread is the difference between the ask and bid price for a given outcome.

- **Tight spread (1-3 cents):** High liquidity. Trades execute near the last price with minimal slippage.
- **Moderate spread (4-8 cents):** Decent liquidity. Larger orders may experience noticeable slippage.
- **Wide spread (9+ cents):** Low liquidity. Trading costs are high. Consider smaller position sizes or limit orders.

**Example:**
```
YES bid: 55, YES ask: 58 -> spread = 3 (tight, liquid)
YES bid: 40, YES ask: 52 -> spread = 12 (wide, illiquid)
```

A narrowing spread over time suggests improving liquidity. A widening spread may indicate traders pulling orders ahead of uncertainty.

## Price History

### MCP Tool

```
context_price_history { marketId: string, timeframe?: "1h"|"6h"|"1d"|"1w"|"1M"|"all" }
```

### SDK Method

```typescript
ctx.markets.priceHistory(marketId: string, params?: GetPriceHistoryParams): Promise<PriceHistory>
```

### Timeframe Selection

| Timeframe | Use case |
|-----------|----------|
| `1h` | Intraday momentum, recent volatility |
| `6h` | Short-term trend detection |
| `1d` | Daily pattern analysis |
| `1w` | Weekly trend, medium-term outlook |
| `1M` | Monthly trend, long-term positioning |
| `all` | Full market history since creation |

Default timeframe when not specified varies by market age.

### Analyzing Price Trends

**Directional movement:** Compare the first and last data points in the series. A market moving from 40 to 65 over one week shows strong bullish momentum on YES.

**Volatility:** Look at the range between highest and lowest prices in the series. A market that swung between 30 and 70 in a day is highly volatile. One that stayed between 48 and 52 is stable.

**Trend reversal:** A sustained move in one direction followed by a sharp reversal often correlates with new information entering the market. Cross-reference with `context_global_activity` to see if there was a burst of trading.

**Convergence to extremes:** Markets approaching 90+ or below 10 are nearing consensus. The remaining uncertainty is whether a low-probability event could still occur.

## Orderbook Depth

### MCP Tool

```
context_get_orderbook { marketId: string, depth?: number }
```

### SDK Methods

```typescript
ctx.markets.orderbook(marketId: string, params?: GetOrderbookParams): Promise<Orderbook>
ctx.markets.fullOrderbook(marketId: string, params?: Omit<GetOrderbookParams, "outcomeIndex">): Promise<FullOrderbook>
```

The orderbook shows resting limit orders at each price level. Use it to assess:

- **Depth at the best bid/ask:** How much volume can execute at current prices before the price moves.
- **Support/resistance levels:** Clusters of orders at specific prices that may slow price movement.
- **Asymmetric depth:** More bids than asks (or vice versa) suggests directional sentiment.

Use `depth` to limit results when you only need the top of book. Use `fullOrderbook` when you need both YES and NO sides in one call.
