# Order Lifecycle

How orders move through states from creation to settlement.

## States

| State | Description |
|-------|-------------|
| `open` | Order is resting on the orderbook, waiting for a match. |
| `filled` | Order has been completely filled. All contracts matched. |
| `partially_filled` | Some contracts matched, remainder still on the book. |
| `cancelled` | Trader cancelled the order via `cancel` or `cancelReplace`. |
| `expired` | Order's expiry timestamp passed without being fully filled. |
| `voided` | System rejected the order. See void reasons below. |

## State Transitions

```
Created
  |
  v
open -----> filled              (fully matched)
  |
  |-------> partially_filled    (some matched, rest on book)
  |           |
  |           |---> filled      (remainder matched)
  |           |---> cancelled   (trader cancels remainder)
  |           |---> expired     (expiry reached)
  |           |---> voided      (system rejects remainder)
  |
  |-------> cancelled           (trader cancels)
  |-------> expired             (expiry reached)
  |-------> voided              (system rejects)
```

## Void Reasons

An order is voided when the system cannot process it. Common reasons:

| Reason | Description |
|--------|-------------|
| `insufficient_balance` | Trader does not have enough USDC to cover the order. |
| `self_trade_prevention` | Order would match against another order from the same trader. |
| `market_closed` | The market is no longer accepting orders (resolved, paused, or expired). |
| `invalid_price` | Price is outside the valid range (1-99 cents). |
| `invalid_signature` | EIP-712 signature verification failed. |
| `nonce_already_used` | The nonce has been used by a previous order. |
| `market_not_found` | The specified market ID does not exist. |
| `inventory_constraint` | Order violates the inventory mode constraint. |

## Checking Order Status

### Via MCP

```
context_my_orders { marketId: "0xabc123..." }
```

Returns all your open orders for the given market. To check a specific order's final state, you need the SDK.

### Via SDK

```typescript
// Get a specific order by ID
const order = await ctx.orders.get("order-id-123")
console.log(`Status: ${order.status}`)
if (order.voidReason) {
  console.log(`Void reason: ${order.voidReason}`)
}

// List all your orders, including non-open ones
const { orders } = await ctx.orders.list({
  marketId: "0xabc123...",
  status: "filled",
})

// Get recent orders across all markets
const { orders: recent } = await ctx.orders.recent({ limit: 20 })
```

## Fills

When an order matches, a fill is created. Each fill records:

- The matched size (number of contracts)
- The fill price
- The counterparty order
- The timestamp

A partially filled order has one or more fills and a `remainingSize > 0`. You can check fill progress:

```typescript
const order = await ctx.orders.get("order-id-123")
console.log(`Filled: ${order.filledSize} / ${order.size}`)
console.log(`Remaining: ${order.remainingSize}`)
```

## Expiry

Orders can optionally include an `expiry` timestamp (unix seconds). When set:

- The order is valid until that timestamp.
- After expiry, the order transitions to `expired` and any unfilled portion is removed from the book.
- Set `expiry: 0` or omit it for no expiry (good-till-cancelled).

```typescript
await ctx.orders.create({
  marketId: "0xabc123...",
  side: "buy",
  outcomeIndex: 0,
  price: 65,
  size: 10,
  expiry: Math.floor(Date.now() / 1000) + 3600, // expires in 1 hour
})
```
