# Order API Reference

Complete reference for the Context SDK order methods.

## Types

### PlaceOrderRequest

```typescript
interface PlaceOrderRequest {
  marketId: string
  side: "buy" | "sell"
  outcomeIndex: number  // 0 = YES, 1 = NO
  price: number         // cents, 1-99
  size: number          // number of contracts
  expiry?: number       // unix timestamp, optional (0 = no expiry)
}
```

### PlaceMarketOrderRequest

```typescript
interface PlaceMarketOrderRequest {
  marketId: string
  side: "buy" | "sell"
  outcomeIndex: number  // 0 = YES, 1 = NO
  maxPrice: number      // max cents willing to pay
  maxSize: number       // max contracts to fill
}
```

### CreateOrderResult

```typescript
interface CreateOrderResult {
  orderId: string
  nonce: Hex
  status: "open" | "filled" | "partially_filled"
  filledSize?: number
  filledPrice?: number
}
```

### CancelResult

```typescript
interface CancelResult {
  nonce: Hex
  status: "cancelled"
}
```

### CancelReplaceResult

```typescript
interface CancelReplaceResult {
  cancelledNonce: Hex
  newOrderId: string
  newNonce: Hex
  status: "open" | "filled" | "partially_filled"
}
```

### BulkResult

```typescript
interface BulkResult {
  created: CreateOrderResult[]
  cancelled: CancelResult[]
}
```

### Order

```typescript
interface Order {
  id: string
  marketId: string
  trader: Address
  side: "buy" | "sell"
  outcomeIndex: number
  price: number
  size: number
  filledSize: number
  remainingSize: number
  status: "open" | "filled" | "partially_filled" | "cancelled" | "expired" | "voided"
  nonce: Hex
  createdAt: string
  updatedAt: string
  voidReason?: string
}
```

### OrderList

```typescript
interface OrderList {
  orders: Order[]
  cursor?: string
  hasMore: boolean
}
```

### GetOrdersParams

```typescript
interface GetOrdersParams {
  marketId?: string
  status?: "open" | "filled" | "cancelled" | "expired" | "voided"
  side?: "buy" | "sell"
  outcomeIndex?: number
  cursor?: string
  limit?: number
}
```

### GetRecentOrdersParams

```typescript
interface GetRecentOrdersParams {
  marketId?: string
  limit?: number
}
```

### OrderSimulateParams

```typescript
interface OrderSimulateParams {
  marketId: string
  side: "buy" | "sell"
  outcomeIndex: number
  size: number
  price?: number  // omit for market order simulation
}
```

### OrderSimulateResult

```typescript
interface OrderSimulateResult {
  estimatedFillSize: number
  estimatedFillPrice: number
  estimatedCost: number
  estimatedSlippage: number
  orderbookDepthUsed: number
}
```

## Methods

### ctx.orders.create

Place a limit order.

```typescript
ctx.orders.create(req: PlaceOrderRequest): Promise<CreateOrderResult>
```

**Example:**

```typescript
const result = await ctx.orders.create({
  marketId: "0xabc123...",
  side: "buy",
  outcomeIndex: 0, // YES
  price: 65,       // 65 cents
  size: 10,        // 10 contracts
})
console.log(`Order ${result.orderId} placed, nonce: ${result.nonce}`)
```

### ctx.orders.createMarket

Place a market order that fills immediately against the orderbook.

```typescript
ctx.orders.createMarket(req: PlaceMarketOrderRequest): Promise<CreateOrderResult>
```

**Example:**

```typescript
const result = await ctx.orders.createMarket({
  marketId: "0xabc123...",
  side: "buy",
  outcomeIndex: 0,
  maxPrice: 70,   // won't pay more than 70 cents
  maxSize: 10,
})
console.log(`Filled ${result.filledSize} at avg ${result.filledPrice}`)
```

### ctx.orders.cancel

Cancel an open order by its nonce.

```typescript
ctx.orders.cancel(nonce: Hex): Promise<CancelResult>
```

**Example:**

```typescript
const result = await ctx.orders.cancel("0xdef456...")
console.log(`Cancelled order with nonce ${result.nonce}`)
```

### ctx.orders.cancelReplace

Atomically cancel an existing order and place a new one.

```typescript
ctx.orders.cancelReplace(
  cancelNonce: Hex,
  newOrder: PlaceOrderRequest
): Promise<CancelReplaceResult>
```

**Example:**

```typescript
const result = await ctx.orders.cancelReplace("0xoldnonce...", {
  marketId: "0xabc123...",
  side: "buy",
  outcomeIndex: 0,
  price: 60, // updated price
  size: 10,
})
console.log(`Replaced ${result.cancelledNonce} with ${result.newOrderId}`)
```

### ctx.orders.list

List orders with optional filters. Returns paginated results.

```typescript
ctx.orders.list(params?: GetOrdersParams): Promise<OrderList>
```

**Example:**

```typescript
const { orders, hasMore, cursor } = await ctx.orders.list({
  marketId: "0xabc123...",
  status: "open",
  limit: 50,
})
```

### ctx.orders.listAll

List all orders matching filters, automatically handling pagination.

```typescript
ctx.orders.listAll(params?: Omit<GetOrdersParams, "cursor">): Promise<Order[]>
```

**Example:**

```typescript
const allOpenOrders = await ctx.orders.listAll({ status: "open" })
```

### ctx.orders.mine

List your own open orders, optionally filtered by market.

```typescript
ctx.orders.mine(marketId?: string): Promise<OrderList>
```

**Example:**

```typescript
const { orders } = await ctx.orders.mine("0xabc123...")
for (const order of orders) {
  console.log(`${order.side} ${order.size} @ ${order.price}`)
}
```

### ctx.orders.allMine

List all your open orders, handling pagination automatically.

```typescript
ctx.orders.allMine(marketId?: string): Promise<Order[]>
```

### ctx.orders.get

Get a single order by ID.

```typescript
ctx.orders.get(id: string): Promise<Order>
```

**Example:**

```typescript
const order = await ctx.orders.get("order-id-123")
console.log(`Status: ${order.status}, filled: ${order.filledSize}/${order.size}`)
```

### ctx.orders.recent

Get recent orders (most recent first).

```typescript
ctx.orders.recent(params?: GetRecentOrdersParams): Promise<OrderList>
```

**Example:**

```typescript
const { orders } = await ctx.orders.recent({ limit: 10 })
```

### ctx.orders.simulate

Simulate an order to preview fill, cost, and slippage without placing it.

```typescript
ctx.orders.simulate(params: OrderSimulateParams): Promise<OrderSimulateResult>
```

**Example:**

```typescript
const sim = await ctx.orders.simulate({
  marketId: "0xabc123...",
  side: "buy",
  outcomeIndex: 0,
  size: 100,
  price: 65,
})
console.log(`Would fill ${sim.estimatedFillSize} @ ${sim.estimatedFillPrice}`)
console.log(`Slippage: ${sim.estimatedSlippage}%`)
```
