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
   - **CLI:** `context orders bulk-create --orders '[...]'` / `context orders bulk-cancel --nonces '[...]'` / `context orders bulk --creates '[...]' --cancels '[...]'`
3. **Check results** — each order in the batch gets its own result. Inspect the returned array for individual successes and failures.
4. **Verify** — call `ctx.orders.mine(marketId)` or `context_my_orders` to confirm all expected orders are open.

## Gotchas

- **Max 50 orders per batch.** Split larger sets into multiple calls.
- **In `bulk()`, cancels execute before creates.** This is by design — use it for atomic rebalancing so you're never exposed with stale quotes.
- **One invalid order can fail the entire batch.** Validate all params before submitting. Common failures: price out of range, missing marketId, insufficient balance.
- **Each order needs a unique nonce.** The SDK generates these automatically. If you build orders manually, ensure unique nonces.
- **Bulk operations are not available via MCP.** The MCP tool `context_place_order` only handles single orders. For batch operations, use SDK or CLI.
- **`bulkCreate` returns `CreateOrderResult[]`**, not a single result. Check each element individually.

## Verification

- Call `ctx.orders.mine(marketId)` or `context_my_orders` — count of open orders should match expected.
- For `bulkCancel`, verify the cancelled orders no longer appear in `context_my_orders`.

## See Also

- [Bulk Operations Reference](../references/bulk-operations.md) — Code examples for ladders, cancel-all, rebalancing
- [Orders API](../references/orders.md) — PlaceOrderRequest type definition
