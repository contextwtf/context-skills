# Trade Simulation

## Purpose

Simulation previews what would happen if you placed a trade — the expected fill price, slippage, and fees — without executing anything. It is read-only.

## Parameters

```ts
interface SimulateTradeParams {
  side: "yes" | "no";           // which outcome to buy
  amount: number;               // how much to trade
  amountType?: "usd" | "contracts";  // default: "usd"
  trader?: string;              // optional: address for self-trade detection
}
```

### MCP

```
context_simulate_trade({ marketId, side: "yes", amount: 10 })
```

The MCP tool defaults to USD amount. No `amountType` param — always simulates in USD.

### SDK

```ts
ctx.markets.simulate(marketId, { side: "yes", amount: 10, amountType: "usd" })
```

### CLI

```bash
context markets simulate <marketId> --side yes --amount 10
```

## Interpreting Results

The simulation returns expected fill price, cost, fees, and slippage.

### Slippage Thresholds

| Slippage | Assessment |
|----------|-----------|
| < 2% | Good — sufficient liquidity |
| 2–5% | Acceptable for smaller markets |
| > 5% | Insufficient liquidity — reduce size or use limit order |

### Size Sensitivity

Run multiple simulations at different sizes to understand the orderbook depth:

1. Simulate at $10, $50, $100, $500
2. Compare average fill prices at each level
3. If slippage jumps sharply at a certain size, that's the market's effective depth limit

## Gotchas

- **Simulation ≠ execution.** The orderbook changes between simulate and place. Simulation is a preview, not a reservation.
- **The `amount` is in USD by default.** If you want to simulate a specific number of contracts, set `amountType: "contracts"`.
- **MCP tool always uses USD.** There is no `amountType` param on the MCP tool.
- **Large simulations may show high slippage** even in liquid markets. Split into smaller amounts to find the optimal trade size.

## Note: Two Simulation Methods

The SDK has two different simulate methods:

- `ctx.markets.simulate()` — human-readable params (`side: "yes"|"no"`, `amount`, `amountType`). Use this for research.
- `ctx.orders.simulate()` — on-chain encoding params (`outcomeIndex`, `maxPrice`, `maxSize`). Use this for order-level precision. See [Orders API](../../trade/references/orders.md).
