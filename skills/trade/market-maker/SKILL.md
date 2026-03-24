---
name: context-trade-market-maker
description: Quote both sides of a prediction market with spread management
---

# Market Maker

Provide liquidity by quoting both sides of a market. Place buy and sell orders around a fair value, monitor fills, and rebalance.

## When to Use

The user wants to provide liquidity by quoting both YES buy and YES sell (or NO buy and NO sell) on a market.

## Steps

1. **Determine fair value** — fetch the orderbook with `context_get_orderbook`. Use `context_get_oracle` for the oracle's evidence summary, and if you need a numeric oracle quote use `ctx.markets.latestOracleQuote(marketId)` from the SDK. The midpoint of the current bid-ask is a starting reference; the latest oracle quote is a separate pricing input.
2. **Calculate spread** — set your buy price below fair value and sell price above. Start with a 5–10 cent spread and tighten as you learn the market's volatility.
3. **Place two-sided quotes:**
   - **SDK (recommended):** Use `ctx.orders.bulkCreate()` with both a buy and sell order, or two separate `ctx.orders.create()` calls.
   - **CLI:** `context orders create --outcome yes --side buy --price <bid> --size 10` and `context orders create --outcome yes --side sell --price <ask> --size 10`
   - **MCP:** you can place both buys and sells with `context_place_order({ marketId, outcome, side, size, price })`
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
- **Numeric oracle quotes are SDK-only.** MCP exposes `context_get_oracle` for evidence and summary text, not `latestOracleQuote()`.
- **Monitor the oracle.** If the latest oracle quote diverges significantly from your mid-price (>10 cents), re-center your quotes.
- **Check `context_get_balance` regularly.** Ensure your settlement balance can cover the new orders. Insufficient balance will cause orders to be voided.

## Verification

- Both sides of your quote should be visible in `context_get_orderbook`.
- `ctx.orders.mine(marketId)` or `context_my_orders` should show two open orders — one buy, one sell — at your desired prices.

## See Also

- [Orders API](../references/orders.md) — Method signatures for create, cancel, cancelReplace
- [Bulk Operations](../references/bulk-operations.md) — Atomic cancel+create patterns
