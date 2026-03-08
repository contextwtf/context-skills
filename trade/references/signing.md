# EIP-712 Signing Reference

The Context protocol uses EIP-712 typed data signing for all order operations. The SDK handles signing automatically, but understanding the encoding is essential for debugging and verification.

## Domain

All signatures use this EIP-712 domain:

```typescript
const domain = {
  name: "Settlement",
  version: "1",
  chainId: 84532,                                                    // Base Sepolia
  verifyingContract: "0xD91935a82Af48ff79a68134d9Eab8fc9e5d3504D",  // Settlement contract
}
```

## Signed Types

### Order

Used for limit orders (`ctx.orders.create`, `ctx.orders.cancelReplace`).

```typescript
Order: [
  { name: "marketId",                type: "bytes32" },
  { name: "trader",                  type: "address" },
  { name: "price",                   type: "uint256" },   // encodePriceCents(cents)
  { name: "size",                    type: "uint256" },    // encodeSize(shares)
  { name: "outcomeIndex",           type: "uint8" },      // 0 = YES, 1 = NO
  { name: "side",                    type: "uint8" },      // 0 = buy, 1 = sell
  { name: "nonce",                   type: "bytes32" },    // random unique identifier
  { name: "expiry",                  type: "uint256" },    // unix timestamp, 0 = no expiry
  { name: "maxFee",                  type: "uint256" },    // 1% of notional, min 1
  { name: "makerRoleConstraint",     type: "uint8" },      // 0 = ANY, 1 = MAKER_ONLY, 2 = TAKER_ONLY
  { name: "inventoryModeConstraint", type: "uint8" },      // 0 = ANY, 1 = REQUIRE_INVENTORY, 2 = REQUIRE_NO_INVENTORY
]
```

### MarketOrderIntent

Used for market orders (`ctx.orders.createMarket`).

```typescript
MarketOrderIntent: [
  { name: "marketId",     type: "bytes32" },
  { name: "trader",       type: "address" },
  { name: "maxSize",      type: "uint256" },   // encodeSize(maxShares)
  { name: "maxPrice",     type: "uint256" },   // encodePriceCents(maxCents)
  { name: "outcomeIndex", type: "uint8" },
  { name: "side",         type: "uint8" },
  { name: "nonce",        type: "bytes32" },
  { name: "expiry",       type: "uint256" },
  { name: "maxFee",       type: "uint256" },
]
```

### CancelNonce

Used for order cancellation (`ctx.orders.cancel`).

```typescript
CancelNonce: [
  { name: "trader", type: "address" },
  { name: "nonce",  type: "bytes32" },
]
```

## Encoding Functions

### Price Encoding

Prices are in cents (1-99) and encoded on-chain with 4 decimal places of precision.

```typescript
function encodePriceCents(cents: number): bigint {
  // Validates: cents >= 1 && cents <= 99
  return BigInt(cents) * 10_000n
}

function decodePriceCents(raw: bigint): number {
  return Number(raw / 10_000n)
}
```

Examples:
- 50 cents (50% probability) = `500_000n`
- 1 cent = `10_000n`
- 99 cents = `990_000n`

### Size Encoding

Sizes are in shares/contracts and encoded on-chain with 6 decimal places of precision.

```typescript
function encodeSize(shares: number): bigint {
  // Validates: shares >= 0.01
  return BigInt(Math.round(shares * 1_000_000))
}

function decodeSize(raw: bigint): number {
  return Number(raw) / 1_000_000
}
```

Examples:
- 10 shares = `10_000_000n`
- 0.5 shares = `500_000n`
- 100 shares = `100_000_000n`

### Fee Calculation

Max fee is 1% of notional value (price times size), with a minimum of 1.

```typescript
function calculateMaxFee(price: bigint, size: bigint): bigint {
  const notional = price * size
  const fee = notional / 100n
  return fee < 1n ? 1n : fee
}
```

Example: 65 cents, 10 shares = `650_000n * 10_000_000n / 100n = 65_000_000_000n`

### Nonce Generation

Nonces must be unique `bytes32` values. The SDK generates them from a timestamp and random data.

```typescript
import { keccak256, encodePacked } from "viem"

function generateNonce(): Hex {
  const timestamp = BigInt(Date.now())
  const random = BigInt(Math.floor(Math.random() * 1e18))
  return keccak256(encodePacked(["uint256", "uint256"], [timestamp, random]))
}
```

## Constraints

### makerRoleConstraint

Controls whether the order can be a maker, taker, or either.

| Value | Meaning | Use Case |
|-------|---------|----------|
| `0` | ANY | Default. Order can be maker or taker. |
| `1` | MAKER_ONLY | Order rests on the book. Use for market making. |
| `2` | TAKER_ONLY | Order fills immediately or is voided. Use for aggressive fills. |

### inventoryModeConstraint

Controls whether the order requires or prohibits existing inventory.

| Value | Meaning | Use Case |
|-------|---------|----------|
| `0` | ANY | Default. No inventory requirement. |
| `1` | REQUIRE_INVENTORY | Only fills if trader holds the opposing position (reduce-only). |
| `2` | REQUIRE_NO_INVENTORY | Only fills if trader has no existing position (open-only). |

## What the SDK Handles

When you call `ctx.orders.create()` or any order method, the SDK automatically:

1. Encodes price and size to on-chain format.
2. Generates a random nonce.
3. Calculates the max fee.
4. Constructs the EIP-712 typed data.
5. Signs with the configured private key.
6. Submits the signed order to the API.

You only need to understand encoding for debugging (e.g., verifying on-chain values match expected cents/shares) or building custom signing flows.
