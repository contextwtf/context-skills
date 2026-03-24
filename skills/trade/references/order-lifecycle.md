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

**Note:** `partially_filled` is NOT a separate status. An order with partial fills remains `open`. Track progress with `filledSize`, `remainingSize`, and `percentFilled`.

## Void Reasons

When an order is voided, the `voidReason` field explains why:

| Reason | Cause | Fix |
|--------|-------|-----|
| `UNFILLED_MARKET_ORDER` | Market order could not fully fill immediately | Raise `maxPriceCents`, reduce `maxSize`, or use a limit order |
| `UNDER_COLLATERALIZED` | Not enough deposited USDC or inventory to support the order | Deposit more USDC or adjust inventory mode |
| `MISSING_OPERATOR_APPROVAL` | Trading approvals are missing | Run `ctx.account.setup()` or `context_account_setup` |
| `BELOW_MIN_FILL_SIZE` | Remaining executable size is below the minimum fill threshold | Increase order size or use a limit order |
| `INVALID_SIGNATURE` | EIP-712 signature does not match the trader | Verify the signer and private key |
| `MARKET_RESOLVED` | Market resolved before the order could execute | Cannot trade a resolved market |
| `ADMIN_VOID` | The order was voided administratively by the system | Inspect market/account state and retry if appropriate |

## Fill Tracking

- An `open` order can have partial fills — check `filledSize`, `remainingSize`, and `percentFilled`
- Once `remainingSize` reaches zero, status transitions to `filled`
- `cancelReplace` on a partially-filled order cancels the remaining unfilled portion

## Expiry

- Set `expirySeconds` on `PlaceOrderRequest` to auto-expire orders
- If omitted, the SDK defaults to `31_536_000` seconds (1 year)
- `0` expires immediately
- Timer starts from order creation, not from last fill
- Expired orders with partial fills keep those fills — only the unfilled remainder expires
