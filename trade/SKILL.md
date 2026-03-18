---
name: context-trade
description: Place and manage prediction market orders
---

# Trade Skill

You are an AI agent skilled at trading on Context Markets prediction markets. You place, cancel, and manage orders using the Context MCP server or SDK.

## Prerequisites

- **Context MCP server** running (`npx context-markets-mcp`)
- **CONTEXT_API_KEY** — API key for authentication
- **CONTEXT_PRIVATE_KEY** — Private key (hex) for EIP-712 order signing

## Critical Rules

These encoding rules are non-negotiable. Getting them wrong produces invalid orders.

- **Prices** are in cents (1-99). On-chain encoding: `price * 10,000`.
- **Sizes** are in shares/contracts. On-chain encoding: `size * 1,000,000`.
- **Nonces** are random `bytes32` values (typically `keccak256(timestamp + random)`).
- **EIP-712 signing** is required for all order operations. The SDK handles this automatically.
- **Side**: `0` = buy, `1` = sell.
- **OutcomeIndex**: `0` = YES, `1` = NO.
- **Max fee**: 1% of notional (`price * size / 100`), minimum `1`.
- **YES price + NO price** should approximately equal 100 cents.
- **Settlement contract**: `0xD91935a82Af48ff79a68134d9Eab8fc9e5d3504D` on Base Sepolia (chainId `84532`).

## MCP Tools

Use these tools when operating through an MCP-connected environment.

| Tool | Purpose | Key Params |
|------|---------|------------|
| `context_place_order` | Place a limit order | `{ marketId, side: "yes"\|"no", size, price? }` |
| `context_cancel_order` | Cancel an open order | `{ nonce }` |
| `context_my_orders` | List your open orders | `{ marketId? }` |
| `context_simulate_trade` | Simulate before placing | `{ marketId, side: "yes"\|"no", amount }` |
| `context_get_orderbook` | Get bid/ask ladder | `{ marketId, depth? }` |
| `context_get_quotes` | Get current bid/ask/last | `{ marketId }` |

### Workflow: Place a Limit Order

1. Call `context_get_quotes` to see current prices.
2. Call `context_simulate_trade` to preview fill and slippage.
3. Call `context_place_order` with your desired price and size.
4. Call `context_my_orders` to confirm the order is open.

### Workflow: Cancel and Replace

1. Call `context_my_orders` to find the order's nonce.
2. Call `context_cancel_order` with that nonce.
3. Call `context_place_order` with updated parameters.

## SDK Methods

For agents generating code against the Context SDK (`context-markets`).

### Order Placement

```typescript
ctx.orders.create(req: PlaceOrderRequest): Promise<CreateOrderResult>
ctx.orders.createMarket(req: PlaceMarketOrderRequest): Promise<CreateOrderResult>
```

### Order Cancellation

```typescript
ctx.orders.cancel(nonce: Hex): Promise<CancelResult>
ctx.orders.cancelReplace(cancelNonce: Hex, newOrder: PlaceOrderRequest): Promise<CancelReplaceResult>
```

### Bulk Operations

```typescript
ctx.orders.bulkCreate(orders: PlaceOrderRequest[]): Promise<CreateOrderResult[]>
ctx.orders.bulkCancel(nonces: Hex[]): Promise<CancelResult[]>
ctx.orders.bulk(creates: PlaceOrderRequest[], cancelNonces: Hex[]): Promise<BulkResult>
```

### Order Queries

```typescript
ctx.orders.mine(marketId?: string): Promise<OrderList>
ctx.orders.list(params?: GetOrdersParams): Promise<OrderList>
ctx.orders.get(id: string): Promise<Order>
ctx.orders.recent(params?: GetRecentOrdersParams): Promise<OrderList>
ctx.orders.simulate(params: OrderSimulateParams): Promise<OrderSimulateResult>
```

## Composite Workflows

### Market Maker

Quote both sides of a market, monitor fills, and rebalance inventory.

1. Fetch the orderbook to determine fair value.
2. Place buy and sell limit orders at a spread around fair value.
3. Monitor fills with `ctx.orders.mine()` or `context_my_orders`.
4. When one side fills, cancel the other and re-quote both sides.
5. Use `ctx.orders.cancelReplace()` or `ctx.orders.bulk()` to atomically update quotes.

### Order Ladder

Place multiple orders at different price levels to accumulate a position.

1. Decide on a price range and number of levels.
2. Use `ctx.orders.bulkCreate()` to place all orders at once.
3. Monitor fills and optionally replace filled levels.

### Arbitrage Scanner

Compare oracle-implied probability to market prices.

1. Fetch oracle data to estimate true probability.
2. Fetch market quotes with `context_get_quotes`.
3. If the spread exceeds your threshold, place a trade on the mispriced side.
4. Simulate first with `context_simulate_trade` to check slippage.

## References

- [Order API Reference](./references/orders.md) — Full method signatures, param types, return types
- [EIP-712 Signing](./references/signing.md) — Domain, types, encoding functions
- [Order Lifecycle](./references/order-lifecycle.md) — States, transitions, void reasons
- [Bulk Operations](./references/bulk-operations.md) — Patterns for multi-order operations
