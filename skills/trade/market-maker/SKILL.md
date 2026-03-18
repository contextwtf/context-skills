---
name: context-trade-market-maker
description: Quote both sides of a prediction market with spread management
---

# Market Maker

Provide liquidity by quoting both sides of a market. Place buy and sell orders around a fair value, monitor fills, and rebalance.

## When to Use

The user wants to provide liquidity by quoting both YES buy and YES sell (or NO buy and NO sell) on a market.

## Steps

1. **Determine fair value** — fetch the orderbook with `context_get_orderbook` and the oracle estimate with `context_get_oracle`. The midpoint of the current bid-ask is a starting reference; the oracle provides an independent probability estimate.
2. **Calculate spread** — set your buy price below fair value and sell price above. Start with a 5–10 cent spread and tighten as you learn the market's volatility.
3. **Place two-sided quotes:**
   - **SDK (recommended):** Use `ctx.orders.bulkCreate()` with both a buy and sell order, or two separate `ctx.orders.create()` calls.
   - **CLI:** `context orders create --outcome yes --side buy --price <bid> --size 10` and `context orders create --outcome yes --side sell --price <ask> --size 10`
   - **MCP limitation:** `context_place_order` only buys. For the sell side, you must use SDK or CLI.
4. **Monitor fills** — periodically check `ctx.orders.mine(marketId)` or `context_my_orders`. When one side fills, the other is still open.
5. **Rebalance** — when one side fills, cancel the other and re-quote both sides. Use `ctx.orders.bulk()` for atomic cancel+create to avoid being temporarily unquoted:
   ```ts
   await ctx.orders.bulk(
     [newBuyOrder, newSellOrder],  // creates
     [oldSellNonce],               // cancels (execute first)
   );
   ```
6. **Repeat** — continue monitoring and rebalancing.

## Gotchas

- **Inventory risk.** If one side fills repeatedly without the other, you accumulate directional exposure. Track your net position and widen your spread or reduce size if exposure grows.
- **Spread too tight gets picked off.** Informed traders will trade against you if your spread is tighter than the market's information uncertainty. Start wider (5–10 cents), tighten only after observing fill patterns.
- **Use `bulk()` for atomic rebalancing.** Cancelling and placing separately creates a window where you have no quotes — other participants can move the price against you.
- **MCP only supports buying.** Market making requires the sell side, which means you must use SDK or CLI for at least half your quotes.
- **Monitor the oracle.** If the oracle diverges significantly from your mid-price (>10 cents), re-center your quotes. The oracle reflects independent probability analysis.
- **Check `context_get_balance` regularly.** Ensure your settlement balance can cover the new orders. Insufficient balance will cause orders to be voided.

## Verification

- Both sides of your quote should be visible in `context_get_orderbook`.
- `ctx.orders.mine(marketId)` or `context_my_orders` should show two open orders — one buy, one sell — at your desired prices.

## See Also

- [Orders API](../references/orders.md) — Method signatures for create, cancel, cancelReplace
- [Bulk Operations](../references/bulk-operations.md) — Atomic cancel+create patterns
