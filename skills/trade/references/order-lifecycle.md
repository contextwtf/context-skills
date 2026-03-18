# Order Lifecycle

How orders move through states from creation to settlement.

## States

```
open ──→ filled
     ──→ cancelled (by trader)
     ──→ expired (expirySeconds elapsed)
     ──→ voided (system rejected)
```

| Status | Meaning |
|--------|---------|
| `open` | Active on the orderbook, waiting to be filled |
| `filled` | Fully filled — all contracts matched |
| `cancelled` | Cancelled by the trader via `cancel()` or `cancelReplace()` |
| `expired` | The `expirySeconds` timer elapsed without full fill |
| `voided` | System rejected the order (see void reasons below) |

**Note:** `partially_filled` is NOT a separate status. An order with partial fills remains `open` with a non-zero fill count. Check the `fills` array on the order to see partial fill progress.

## Void Reasons

When an order is voided, the `voidReason` field explains why:

| Reason | Cause | Fix |
|--------|-------|-----|
| `insufficient_balance` | Not enough USDC in settlement balance | Deposit more: `ctx.account.deposit(amount)` |
| `self_trade_prevention` | Your buy and sell orders crossed each other | Cancel one side before placing the other |
| `market_closed` | Market has ended or been resolved | Cannot trade — check market status first |
| `invalid_price` | Price outside 1-99 range | Use a valid price in cents |
| `invalid_signature` | EIP-712 signature doesn't match trader address | Verify CONTEXT_PRIVATE_KEY matches your account |
| `nonce_already_used` | Duplicate nonce (same order submitted twice) | SDK generates unique nonces automatically — this usually means a retry collision |
| `market_not_found` | Market ID doesn't exist | Verify the market ID with `context_get_market` |
| `inventory_constraint` | `inventoryModeConstraint` prevented execution | Usually means trying to sell without holding tokens |

## Fill Tracking

- Each fill is recorded with price, size, fee, and timestamp
- An `open` order can have partial fills — check `fills.length` and sum of fill sizes
- Once total filled size equals order size, status transitions to `filled`
- `cancelReplace` on a partially-filled order cancels the remaining unfilled portion

## Expiry

- Set `expirySeconds` on `PlaceOrderRequest` to auto-expire orders
- `0` (default) = no expiry — order stays open until filled, cancelled, or voided
- Timer starts from order creation, not from last fill
- Expired orders with partial fills keep those fills — only the unfilled remainder expires
