---
name: context-trade-diagnose-order
description: Troubleshoot orders that aren't filling, got rejected, or show unexpected behavior
---

# Diagnose Order

Troubleshoot orders that aren't filling, were rejected or voided, or are behaving unexpectedly.

## When to Use

An order isn't working as expected — not filling, got voided, shows an error, or produced unexpected results.

## Prerequisites

Read-only diagnosis uses MCP read tools (no auth). Checking your own orders requires API key + private key.

## Order Not Filling

1. **Is the market active?** Call `context_get_market` — check that `status` is `"active"`. If `"pending"`, `"resolved"`, or `"closed"`, the market is not accepting new trades.
2. **Is your price competitive?** Call `context_get_orderbook` — for a buy order, your bid must be at or above the lowest ask to fill immediately. For a sell, your ask must be at or below the highest bid.
3. **Is the spread wide?** If the bid-ask spread is large (>10 cents), your limit price may sit in the gap unfilled. Adjust closer to the opposite side, or use a market order.
4. **Is there sufficient depth?** Large orders need enough liquidity at your price level. Check the orderbook depth — if only 5 contracts are available at 45c and you want 100, most of your order will sit unfilled.
5. **Resolution:** Adjust price closer to the opposite side, reduce size, or switch to a market order for immediate fill.

## Order Rejected or Voided

1. **Get the order details** — `ctx.orders.get(orderId)` and check `status` and `voidReason`.
2. **Diagnose by void reason:**

| Void Reason | Cause | Fix |
|-------------|-------|-----|
| `UNFILLED_MARKET_ORDER` | Market order could not fill immediately | Reduce size, widen the cap price, or use a limit order |
| `UNDER_COLLATERALIZED` | Not enough USDC or inventory to support the order | Check `context_get_balance`, then deposit or adjust inventory mode |
| `MISSING_OPERATOR_APPROVAL` | Trading approvals are missing | Run `context_account_setup` |
| `BELOW_MIN_FILL_SIZE` | Executable remainder is below the minimum fill size | Increase size or use a limit order |
| `INVALID_SIGNATURE` | Private key doesn't match account | Verify `CONTEXT_PRIVATE_KEY` is correct |
| `MARKET_RESOLVED` | Market ended or resolved | Cannot trade this market |
| `ADMIN_VOID` | Order was voided administratively by the system | Inspect account and market state, then retry if appropriate |

## High Slippage in Simulation

1. **Check orderbook depth** — `context_get_orderbook` — is there sufficient liquidity at reasonable prices?
2. **Reduce size** — re-simulate with a smaller amount. Large orders eat through the book.
3. **Use a limit order** — instead of a market order, set a `priceCents` that caps your worst-case fill.
4. **Slippage thresholds:** <2% is good, 2–5% is acceptable for small markets, >5% means insufficient liquidity — reduce size or wait.

## Gotchas

- **Simulation and execution can differ.** The orderbook changes between calls. Simulate is a preview, not a guarantee.
- **`voided` ≠ `cancelled`.** Voided means the system rejected it (bad params, no balance). Cancelled means you cancelled it intentionally.
- **Orders on resolved markets are automatically voided.** If a market resolves while your order is open, it gets voided — this is expected behavior.
- **`MAKER_ONLY` constraint causes reverts.** If you see `InvalidRoleConstraint` errors, someone set `makerRoleConstraint: 1`. Never use this value.

## Verification

After resolving the issue, place a new order and confirm it appears in `context_my_orders` with status `"open"`.

## See Also

- [Order Lifecycle](../references/order-lifecycle.md) — All states, void reasons, fill tracking
- [Orders API](../references/orders.md) — Method signatures and types
