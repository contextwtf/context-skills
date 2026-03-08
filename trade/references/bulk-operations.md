# Bulk Operations

Place, cancel, or replace multiple orders in a single atomic call. Essential for market making, laddering, and portfolio rebalancing.

## Methods

### bulkCreate

Place multiple orders at once. All orders are submitted atomically.

```typescript
ctx.orders.bulkCreate(orders: PlaceOrderRequest[]): Promise<CreateOrderResult[]>
```

**Example: Price Ladder**

Place buy orders at multiple price levels to accumulate a position.

```typescript
const levels = [60, 58, 55, 50, 45]
const orders = levels.map(price => ({
  marketId: "0xabc123...",
  side: "buy" as const,
  outcomeIndex: 0,
  price,
  size: 5,
}))

const results = await ctx.orders.bulkCreate(orders)
console.log(`Placed ${results.length} orders`)
```

### bulkCancel

Cancel multiple orders at once by their nonces.

```typescript
ctx.orders.bulkCancel(nonces: Hex[]): Promise<CancelResult[]>
```

**Example: Cancel All Open Orders**

```typescript
const { orders } = await ctx.orders.mine("0xabc123...")
const nonces = orders.map(o => o.nonce)
const results = await ctx.orders.bulkCancel(nonces)
console.log(`Cancelled ${results.length} orders`)
```

### bulk

Mixed operation: create new orders and cancel existing ones in a single atomic call. Cancellations are processed first, then creates.

```typescript
ctx.orders.bulk(
  creates: PlaceOrderRequest[],
  cancelNonces: Hex[]
): Promise<BulkResult>
```

**Example: Rebalance Quotes**

Cancel stale quotes and place new ones at updated prices.

```typescript
const { orders: staleOrders } = await ctx.orders.mine("0xabc123...")
const cancelNonces = staleOrders.map(o => o.nonce)

const newOrders = [
  { marketId: "0xabc123...", side: "buy" as const,  outcomeIndex: 0, price: 48, size: 10 },
  { marketId: "0xabc123...", side: "sell" as const, outcomeIndex: 0, price: 52, size: 10 },
]

const result = await ctx.orders.bulk(newOrders, cancelNonces)
console.log(`Cancelled ${result.cancelled.length}, created ${result.created.length}`)
```

## Use Cases

### Market Making

Maintain two-sided quotes and refresh them as the market moves.

```typescript
async function refreshQuotes(marketId: string, fairValue: number, spread: number, size: number) {
  // Cancel existing quotes
  const { orders } = await ctx.orders.mine(marketId)
  const cancelNonces = orders.map(o => o.nonce)

  // Place new quotes around fair value
  const bid = Math.max(1, Math.floor(fairValue - spread / 2))
  const ask = Math.min(99, Math.ceil(fairValue + spread / 2))

  const creates = [
    { marketId, side: "buy" as const,  outcomeIndex: 0, price: bid, size },
    { marketId, side: "sell" as const, outcomeIndex: 0, price: ask, size },
  ]

  return ctx.orders.bulk(creates, cancelNonces)
}
```

### Laddering Into a Position

Build a position gradually across multiple price levels.

```typescript
function buildLadder(
  marketId: string,
  side: "buy" | "sell",
  outcomeIndex: number,
  startPrice: number,
  endPrice: number,
  levels: number,
  sizePerLevel: number,
): PlaceOrderRequest[] {
  const step = (endPrice - startPrice) / (levels - 1)
  return Array.from({ length: levels }, (_, i) => ({
    marketId,
    side,
    outcomeIndex,
    price: Math.round(startPrice + step * i),
    size: sizePerLevel,
  }))
}

// Place a 5-level buy ladder from 40 to 60 cents
const ladder = buildLadder("0xabc123...", "buy", 0, 40, 60, 5, 10)
await ctx.orders.bulkCreate(ladder)
```

### Portfolio Rebalancing

Cancel all orders across multiple markets and replace with updated quotes.

```typescript
async function rebalanceAll(markets: string[], fairValues: Map<string, number>) {
  // Gather all open orders across markets
  const allOrders: Order[] = []
  for (const marketId of markets) {
    const { orders } = await ctx.orders.mine(marketId)
    allOrders.push(...orders)
  }

  const cancelNonces = allOrders.map(o => o.nonce)

  // Build new quotes for each market
  const creates: PlaceOrderRequest[] = []
  for (const marketId of markets) {
    const fv = fairValues.get(marketId)!
    creates.push(
      { marketId, side: "buy",  outcomeIndex: 0, price: fv - 3, size: 10 },
      { marketId, side: "sell", outcomeIndex: 0, price: fv + 3, size: 10 },
    )
  }

  return ctx.orders.bulk(creates, cancelNonces)
}
```

## Important Notes

- Bulk operations are atomic: if one order in a `bulkCreate` fails validation, none are placed. Design your batches accordingly.
- In `bulk()`, cancellations execute before creates. This frees up balance for the new orders.
- There is a per-call limit on the number of operations. Keep batches under 50 orders.
- Each order in a bulk call gets its own nonce and signature. The SDK handles this.
