# Trade Simulation

## Purpose

Simulation previews what would happen if you placed a trade — the expected fill price, slippage, and fees — without executing anything or modifying any state. It is a read-only operation.

Always simulate before recommending or executing a significant trade. Simulation reveals whether the opportunity you identified (via oracle divergence, price trends, or other analysis) survives real execution costs.

## Parameters

### MCP Tool

```
context_simulate_trade { marketId: string, side: "yes"|"no", amount: number }
```

- **marketId** — The market to simulate against.
- **side** — Whether to simulate buying YES or NO shares.
- **amount** — The dollar amount to trade, in cents.

### SDK Method

```typescript
interface SimulateTradeParams {
  side: "yes" | "no"
  amount: number
}

ctx.markets.simulate(marketId: string, params: SimulateTradeParams): Promise<SimulateResult>
```

## What Simulation Returns

The result includes:

- **Expected fill price** — The average price per share you would pay across all matched orders.
- **Slippage** — The difference between the current best price and your expected fill price. Larger trades eat through more of the orderbook and incur more slippage.
- **Fees** — Transaction fees applied to the trade.
- **Shares received** — The number of shares you would receive for the given amount.

## When to Simulate

- **Before any trade recommendation.** If you are advising on a position, simulate it first to ensure the fill price supports the thesis.
- **When evaluating oracle arbitrage.** A 10-cent oracle divergence means nothing if slippage eats 8 cents at your desired size.
- **When sizing positions.** Simulate at multiple amounts to find where slippage becomes unacceptable.
- **When comparing markets.** Two markets may both show opportunity, but one may have far better execution characteristics.

## Interpreting Results

**Low slippage (under 2 cents):** The market has sufficient depth at your size. Execution quality is good.

**Moderate slippage (2-5 cents):** Acceptable for strong conviction trades. Consider reducing size or splitting across multiple orders.

**High slippage (5+ cents):** The market lacks liquidity at this size. Either reduce the amount significantly or reconsider the trade. The opportunity may not survive execution costs.

**Comparing fill price to oracle estimate:** If the oracle says YES is worth 72 cents and your simulated fill price is 65, there is a 7-cent edge after slippage. If the fill price is 70, only 2 cents of edge remain — likely not worth the risk.

## Size Sensitivity

Simulate at multiple amounts to understand the market's liquidity profile:

```
Simulate $10  -> fill at 58.2, slippage 0.2
Simulate $50  -> fill at 59.1, slippage 1.1
Simulate $200 -> fill at 63.4, slippage 5.4
```

This tells you the market can absorb $50 reasonably but $200 would move the price significantly. Use this to calibrate position sizing recommendations.
