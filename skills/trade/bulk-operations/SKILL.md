---
name: context-trade-bulk-operations
description: Create, cancel, or manage multiple orders in a single batch
---

# Bulk Operations

Place, cancel, or atomically update multiple orders in one call. Used for price ladders, cancel-all, and portfolio rebalancing.

## When to Use

The user wants to place or cancel multiple orders at once, build a price ladder, or atomically replace existing orders with new ones.

## Steps

1. **Build the order array** — construct an array of `PlaceOrderRequest` objects. Validate that every order has a valid `marketId`, `outcome`, `side`, `priceCents` (1–99), and `size` (min 0.01).
2. **Choose the operation:**
   - **Create only:** `ctx.orders.bulkCreate(orders)` — places all orders
   - **Cancel only:** `ctx.orders.bulkCancel(nonces)` — cancels by nonce
   - **Mixed (atomic):** `ctx.orders.bulk(creates, cancelNonces)` — cancels execute first, then creates
   - **MCP create:** `context_bulk_create_orders({ orders })`
   - **MCP cancel:** `context_bulk_cancel_orders({ nonces })`
   - **MCP mixed:** `context_bulk_orders({ creates, cancelNonces })`
   - **CLI:** `context orders bulk-create --orders '[...]'` / `context orders bulk-cancel --nonces '[...]'` / `context orders bulk --creates '[...]' --cancels '[...]'`
3. **Check results** — verify `result.success` is `true`, then inspect `result.results` for the per-operation items.
4. **Verify** — call `ctx.orders.mine(marketId)` or `context_my_orders` to confirm all expected orders are open.

## Gotchas

- **Max 50 orders per batch.** Split larger sets into multiple calls.
- **In `bulk()`, cancels execute before creates.** This is by design — use it for atomic rebalancing so you're never exposed with stale quotes.
- **One invalid order can fail the entire batch.** Validate all params before submitting. Common failures: price out of range, missing marketId, insufficient balance.
- **Each order needs a unique nonce.** The SDK generates these automatically. If you build orders manually, ensure unique nonces.
- **MCP bulk tools use the same order semantics.** Each create entry still needs `marketId`, `outcome`, `side`, `priceCents`, and `size`.
- **Bulk methods return a result object**, not a plain array. Check `success`, then inspect `results`.

## Verification

- Call `ctx.orders.mine(marketId)` or `context_my_orders` — count of open orders should match expected.
- For `bulkCancel`, verify the cancelled orders no longer appear in `context_my_orders`.

## See Also

- [Bulk Operations Reference](../references/bulk-operations.md) — Code examples for ladders, cancel-all, rebalancing
- [Orders API](../references/orders.md) — PlaceOrderRequest type definition
