# Orders API Reference

Complete method signatures and types for `ctx.orders.*` from the `context-markets` SDK.

## Types

### PlaceOrderRequest

```ts
interface PlaceOrderRequest {
  marketId: string;
  outcome: "yes" | "no";
  side: "buy" | "sell";
  priceCents: number;           // 1-99
  size: number;                 // min 0.01 contracts
  expirySeconds?: number;       // omitted = 1 year, 0 = expires immediately
  inventoryModeConstraint?: 0 | 1 | 2;  // 0=ANY, 1=REQUIRE_INVENTORY, 2=REQUIRE_NO_INVENTORY
  makerRoleConstraint?: 0 | 1 | 2;      // 0=ANY, 1=MAKER_ONLY ⚠️, 2=TAKER_ONLY
}
```

> **Never set `makerRoleConstraint: 1` (MAKER_ONLY).** When two maker-only orders cross, Settlement reverts with `InvalidRoleConstraint`, poisoning the entire batch and blocking all trading on the market.

### PlaceMarketOrderRequest

```ts
interface PlaceMarketOrderRequest {
  marketId: string;
  outcome: "yes" | "no";
  side: "buy" | "sell";
  maxPriceCents: number;        // worst acceptable price
  maxSize: number;              // max contracts to fill
  expirySeconds?: number;
}
```

### Return Types

```ts
type CreateOrderResult = { success: true; order: Order };
type CancelResult = { success: boolean; alreadyCancelled: boolean };
type CancelReplaceResult = { cancel: { success: true; trader: string; nonce: string; alreadyCancelled: boolean }; create: CreateOrderResult };
type BulkCreateResult = { results: CreateOrderResult[]; errors: unknown[] };
type BulkCancelResult = { results: CancelResult[]; errors: unknown[] };
type BulkResult = { results: (BulkCreateItem | BulkCancelItem)[] };
```

### Order

```ts
interface Order {
  marketId: string;
  trader: string;
  nonce: string;
  side: number;           // 0=buy, 1=sell (on-chain encoding)
  outcomeIndex: number;   // 0=NO, 1=YES
  price: string;          // on-chain encoded
  size: string;           // on-chain encoded
  filledSize: string;
  remainingSize: string;
  percentFilled: number;
  status: OrderStatus;
  insertedAt: string;
  type: "limit" | "market";
  voidedAt: string | null;
  voidReason:
    | "UNFILLED_MARKET_ORDER"
    | "UNDER_COLLATERALIZED"
    | "MISSING_OPERATOR_APPROVAL"
    | "BELOW_MIN_FILL_SIZE"
    | "INVALID_SIGNATURE"
    | "MARKET_RESOLVED"
    | "ADMIN_VOID"
    | null;
}

type OrderStatus = "open" | "filled" | "cancelled" | "expired" | "voided";
```

### Query Params

```ts
interface GetOrdersParams {
  trader?: Address;
  marketId?: string;
  status?: OrderStatus;
  cursor?: string;        // cursor-based pagination, NOT offset
  limit?: number;
}

interface GetRecentOrdersParams {
  trader?: Address;
  marketId?: string;
  status?: OrderStatus;
  limit?: number;
  windowSeconds?: number;
}
```

## Methods

### Write Operations

```ts
// Limit order
ctx.orders.create(req: PlaceOrderRequest): Promise<CreateOrderResult>

// Market order (fills immediately at best available price)
ctx.orders.createMarket(req: PlaceMarketOrderRequest): Promise<CreateOrderResult>

// Cancel by nonce
ctx.orders.cancel(nonce: Hex): Promise<CancelResult>

// Atomic cancel + new order
ctx.orders.cancelReplace(cancelNonce: Hex, newOrder: PlaceOrderRequest): Promise<CancelReplaceResult>

// Batch operations (see bulk-operations.md)
ctx.orders.bulkCreate(orders: PlaceOrderRequest[]): Promise<BulkCreateResult>
ctx.orders.bulkCancel(nonces: Hex[]): Promise<BulkCancelResult>
ctx.orders.bulk(creates: PlaceOrderRequest[], cancelNonces: Hex[]): Promise<BulkResult>
```

### Read Operations

```ts
// List orders (first page)
ctx.orders.list(params?: GetOrdersParams): Promise<OrderList>

// List ALL orders (auto-paginates through all pages)
ctx.orders.listAll(params?: Omit<GetOrdersParams, "cursor">): Promise<Order[]>

// Your open orders (first page)
ctx.orders.mine(marketId?: string): Promise<OrderList>

// Your open orders (auto-paginates)
ctx.orders.allMine(marketId?: string): Promise<Order[]>

// Single order by ID
ctx.orders.get(id: string): Promise<Order>

// Recent orders (most-recent-first)
ctx.orders.recent(params?: GetRecentOrdersParams): Promise<OrderList>

// Simulate order execution
ctx.orders.simulate(params: OrderSimulateParams): Promise<OrderSimulateResult>
```

### Order Simulation

```ts
interface OrderSimulateParams {
  marketId: string;
  trader: string;
  maxSize: string;
  maxPrice: string;
  outcomeIndex: number;
  side: "bid" | "ask";
}
```

Note: `ctx.orders.simulate()` is different from `ctx.markets.simulate()`. The order simulation uses on-chain encoding (`side: "bid"|"ask"`, `outcomeIndex`). The market simulation uses human-readable params (`side: "yes"|"no"`, `amount`, `amountType: "usd"|"contracts"`).
