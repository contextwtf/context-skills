---
name: context-trade
description: Place and manage prediction market orders on Context Markets
---

# Trade Skill

Place, cancel, and manage orders on Context Markets prediction markets.

## Prerequisites

- **Context MCP server** running (`npx context-markets-mcp`)
- **CONTEXT_API_KEY** — API key from context.markets
- **CONTEXT_PRIVATE_KEY** — Ethereum private key for signing orders
- **Account setup** — must run `ctx.account.setup()` or `context_account_setup` before first trade
- **Funded account** — deposit USDC via `ctx.account.deposit()` or mint test USDC on testnet

## Shared Foundations

### Price & Size Encoding

- **Prices** are in cents (1–99). A price of 65 = 65% implied probability.
- **Sizes** are in contracts (min 0.01).
- On-chain encoding: `price × 10,000`, `size × 1,000,000`. The SDK handles this automatically.
- YES price + NO price ≈ 100 cents.

### SDK Constructor

```ts
import { ContextClient } from "context-markets";

const ctx = new ContextClient({
  chain: "testnet",       // "mainnet" | "testnet" (defaults to mainnet)
  apiKey: "ctx_pk_...",
  signer: { privateKey: "0x..." },
});
```

### SDK vs MCP: The `side` Mismatch

The SDK and MCP use `side` to mean different things. This will cause bugs if confused.

**SDK** — `side` is the trade direction, `outcome` is which side of the market:
```ts
ctx.orders.create({ marketId, outcome: "yes", side: "buy", priceCents: 45, size: 10 })
```

**MCP** — `side` is the outcome to buy. There is no direction param because the tool always buys:
```
context_place_order({ marketId, side: "yes", size: 10, price: 45 })
```

**CLI** — uses both params explicitly:
```bash
context orders create --market <id> --outcome yes --side buy --price 45 --size 10
```

**To sell**, you must use the SDK or CLI. The MCP tool only supports buying.

### Account Setup

`ctx.account.setup()` is chain-aware:
- **Testnet**: uses gasless setup (no ETH needed)
- **Mainnet**: on-chain transactions (requires ETH for gas)

Must run before first trade. Check status with `ctx.account.status()` or `context_account_setup`.

### MCP Tool Catalog (17 tools)

**Markets (8 — read-only, no auth):**
`context_list_markets` · `context_get_market` · `context_get_quotes` · `context_get_orderbook` · `context_simulate_trade` · `context_price_history` · `context_get_oracle` · `context_global_activity`

**Orders (3 — requires API key + private key):**
`context_place_order` · `context_cancel_order` · `context_my_orders`

**Portfolio (2 — requires API key + private key):**
`context_get_portfolio` · `context_get_balance`

**Account (2 — requires API key + private key):**
`context_account_setup` · `context_mint_test_usdc`

**Questions (2 — requires API key + private key):**
`context_create_market` · `context_agent_submit_market`

### CLI Commands

```
context orders create          Place a limit order
context orders market          Place a market order
context orders cancel          Cancel by nonce
context orders cancel-replace  Atomic cancel + new order
context orders bulk-create     Batch create
context orders bulk-cancel     Batch cancel
context orders bulk            Mixed batch (cancels + creates)
```

## Available Workflows

| Workflow | When to use |
|----------|-------------|
| [place-order](./place-order/SKILL.md) | Buy or sell on a specific market |
| [market-maker](./market-maker/SKILL.md) | Quote both sides with spread management |
| [bulk-operations](./bulk-operations/SKILL.md) | Batch create, cancel, or rebalance orders |
| [manage-positions](./manage-positions/SKILL.md) | Cancel, replace, check portfolio and balances |
| [diagnose-order](./diagnose-order/SKILL.md) | Troubleshoot orders not filling or getting rejected |

## References

- [Orders API](./references/orders.md) — Method signatures, param types, return types
- [EIP-712 Signing](./references/signing.md) — Domain, types, encoding functions
- [Order Lifecycle](./references/order-lifecycle.md) — States, transitions, void reasons
- [Bulk Operations](./references/bulk-operations.md) — Patterns for multi-order operations
