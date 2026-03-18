# EIP-712 Signing Reference

The Context protocol uses EIP-712 typed data signing for all order operations. The SDK handles signing automatically — this reference is for understanding and debugging, not manual signing.

## Domain

The EIP-712 domain is chain-specific, resolved via `settlementDomain(chainConfig)`:

```ts
// Testnet (Base Sepolia)
{ name: "Settlement", version: "1", chainId: 84532, verifyingContract: TESTNET_CONFIG.settlement }

// Mainnet (Base)
{ name: "Settlement", version: "1", chainId: 8453, verifyingContract: MAINNET_CONFIG.settlement }
```

The SDK resolves this automatically based on the `chain` option in `ContextClient`.

## Signed Types

### Order (limit orders)

```ts
{
  Order: [
    { name: "trader", type: "address" },
    { name: "market", type: "bytes32" },
    { name: "price", type: "uint256" },
    { name: "size", type: "uint256" },
    { name: "side", type: "uint8" },          // 0=buy, 1=sell
    { name: "outcomeIndex", type: "uint8" },  // 0=YES, 1=NO
    { name: "nonce", type: "bytes32" },
    { name: "expiry", type: "uint256" },
    { name: "maxFee", type: "uint256" },
    { name: "makerRoleConstraint", type: "uint8" },
    { name: "inventoryModeConstraint", type: "uint8" },
  ]
}
```

### MarketOrderIntent (market orders)

```ts
{
  MarketOrderIntent: [
    { name: "trader", type: "address" },
    { name: "market", type: "bytes32" },
    { name: "maxPrice", type: "uint256" },
    { name: "maxSize", type: "uint256" },
    { name: "side", type: "uint8" },
    { name: "outcomeIndex", type: "uint8" },
    { name: "nonce", type: "bytes32" },
    { name: "expiry", type: "uint256" },
    { name: "maxFee", type: "uint256" },
  ]
}
```

### CancelNonce (cancellations)

```ts
{
  CancelNonce: [
    { name: "trader", type: "address" },
    { name: "nonce", type: "bytes32" },
  ]
}
```

## Encoding Functions

The SDK exports these for advanced use cases:

```ts
import { encodePriceCents, encodeSize, calculateMaxFee, decodePriceCents, decodeSize } from "context-markets";

encodePriceCents(45)        // 45n * 10_000n = 450_000n
encodeSize(10)              // 10n * 1_000_000n = 10_000_000n
calculateMaxFee(45, 10)     // (45 * 10) / 100 = 4 (min 1)
decodePriceCents(450_000n)  // 45
decodeSize(10_000_000n)     // 10
```

## Constraints

### MakerRoleConstraint

| Value | Name | Behavior |
|-------|------|----------|
| 0 | ANY | No constraint — **always use this** |
| 1 | MAKER_ONLY | **DANGEROUS — do NOT use.** When two maker-only orders cross, Settlement reverts with `InvalidRoleConstraint`, poisoning the entire batch and blocking all trading on the market. |
| 2 | TAKER_ONLY | Order must fill immediately or gets voided. Useful for ensuring immediate execution. |

### InventoryMode

| Value | Name | Behavior |
|-------|------|----------|
| 0 | ANY | No constraint (default) |
| 1 | REQUIRE_INVENTORY | Must hold tokens to sell. Prevents naked shorts. |
| 2 | REQUIRE_NO_INVENTORY | Set to 2 for SELL orders without existing token inventory. |
