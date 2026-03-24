---
name: context-trade-place-order
description: Place a single limit or market order on a prediction market
---

# Place Order

Buy or sell outcome shares on a prediction market with a limit or market order.

## When to Use

The user wants to buy or sell YES or NO shares on a specific market.

## Steps

1. **Get current prices** — call `context_get_quotes` (MCP) or `ctx.markets.quotes(marketId)` to see bid/ask/last.
2. **Simulate the trade** — call `context_simulate_trade` (MCP) or `ctx.markets.simulate(marketId, { side, amount, amountType: "usd" })` to preview fill price, cost, and slippage.
3. **Place the order:**
   - **MCP:** `context_place_order({ marketId, outcome: "yes", side: "buy", size: 10, price: 45 })` — omit `price` for a market order
   - **SDK limit:** `ctx.orders.create({ marketId, outcome: "yes", side: "buy", priceCents: 45, size: 10 })`
   - **SDK market:** `ctx.orders.createMarket({ marketId, outcome: "yes", side: "buy", maxPriceCents: 99, maxSize: 10 })`
   - **CLI:** `context orders create --market <id> --outcome yes --side buy --price 45 --size 10`
4. **Verify** — call `context_my_orders` or `ctx.orders.mine(marketId)` to confirm the order is open.

## Gotchas

- **Account must be set up and funded first.** Check with `context_account_setup` or `ctx.account.status()`. If not ready, run setup and deposit before placing orders.
- **Price must be 1–99 cents.** 0 and 100 are invalid. Price represents the implied probability.
- **Simulation doesn't guarantee fill price.** The orderbook can change between simulate and place. Simulation is a preview, not a reservation.
- **Market orders use different params** — `maxPriceCents` and `maxSize`, not `priceCents` and `size`. This caps your worst-case fill price.
- **NEVER set `makerRoleConstraint: 1`** (MAKER_ONLY). This causes `InvalidRoleConstraint` reverts that block the entire market. Always use the default (0 = ANY).
- **Check the spread first.** If the bid-ask spread is wide (>10 cents), a limit order at mid-price may sit unfilled. Consider adjusting toward the opposite side.

## Verification

- Call `context_my_orders` or `ctx.orders.mine(marketId)` — your order should appear with status `"open"`.
- If placing a market order, check the returned `order` object — `status`, `percentFilled`, and `remainingSize` should reflect immediate execution.

## See Also

- [Orders API](../references/orders.md) — Full type definitions and method signatures
- [EIP-712 Signing](../references/signing.md) — How orders are signed (SDK handles automatically)
