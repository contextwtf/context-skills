# Bulk Operations

Place, cancel, or replace multiple orders in a single call. Essential for market making, laddering, and portfolio rebalancing.

## Methods

### bulkCreate — Place multiple orders

```ts
const results = await ctx.orders.bulkCreate([
  { marketId, outcome: "yes", side: "buy", priceCents: 40, size: 5 },
  { marketId, outcome: "yes", side: "buy", priceCents: 35, size: 5 },
  { marketId, outcome: "yes", side: "buy", priceCents: 30, size: 5 },
]);
// Returns: { success: true, results: BulkCreateItem[] }
```

### bulkCancel — Cancel multiple orders

```ts
const results = await ctx.orders.bulkCancel([
  "0xnonce1...",
  "0xnonce2...",
  "0xnonce3...",
]);
// Returns: { success: true, results: BulkCancelItem[] }
```

### bulk — Mixed operations (atomic)

Cancels execute before creates. Use this for atomic rebalancing — cancel old quotes and place new ones in a single call.

```ts
const result = await ctx.orders.bulk(
  // Creates (execute second)
  [
    { marketId, outcome: "yes", side: "buy", priceCents: 42, size: 10 },
    { marketId, outcome: "no", side: "buy", priceCents: 55, size: 10 },
  ],
  // Cancel nonces (execute first)
  ["0xoldNonce1...", "0xoldNonce2..."],
);
// Returns: { success: true, results: (BulkCancelItem | BulkCreateItem)[] }
```

### CLI equivalents

```bash
# Bulk create (pass JSON array)
context orders bulk-create --orders '[{"marketId":"0x...","outcome":"yes","side":"buy","priceCents":40,"size":5}]'

# Bulk cancel
context orders bulk-cancel --nonces '["0xnonce1...","0xnonce2..."]'

# Mixed bulk
context orders bulk --creates '[...]' --cancels '["0xnonce1..."]'
```

## Common Patterns

### Price Ladder

Place buy orders at decreasing prices to accumulate a position:

```ts
const levels = [45, 40, 35, 30, 25];
const orders = levels.map(price => ({
  marketId,
  outcome: "yes",
  side: "buy" as const,
  priceCents: price,
  size: 10,
}));
await ctx.orders.bulkCreate(orders);
```

### Cancel All Open Orders

```ts
const openOrders = await ctx.orders.allMine(marketId);
const nonces = openOrders.map(o => o.nonce as `0x${string}`);
await ctx.orders.bulkCancel(nonces);
```

### Market Making Rebalance

Atomically cancel old quotes and place new ones:

```ts
const oldOrders = await ctx.orders.allMine(marketId);
const oldNonces = oldOrders.map(o => o.nonce as `0x${string}`);

await ctx.orders.bulk(
  [
    { marketId, outcome: "yes", side: "buy", priceCents: newBid, size: 10 },
    { marketId, outcome: "yes", side: "sell", priceCents: newAsk, size: 10 },
  ],
  oldNonces,
);
```

## Gotchas

- **Max 50 orders per batch.** Split larger batches into multiple calls.
- **One bad order can fail the entire batch.** Validate all params before submitting.
- **In `bulk()`, cancels execute before creates.** This is the desired behavior for rebalancing — you won't be briefly exposed with no quotes.
- **Each order needs a unique nonce.** The SDK generates these automatically. If you see `nonce_already_used` errors in bulk, it's likely a retry collision.
- **MCP supports all three bulk paths.**
  - `context_bulk_create_orders({ orders })`
  - `context_bulk_cancel_orders({ nonces })`
  - `context_bulk_orders({ creates, cancelNonces })`
- **Bulk methods return an object**, not a plain array. Check `success` and inspect `results` for the per-operation items.
