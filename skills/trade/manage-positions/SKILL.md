---
name: context-trade-manage-positions
description: Monitor, cancel, replace orders and check portfolio positions
---

# Manage Positions

Cancel or replace open orders, check your portfolio, and manage account balances.

## When to Use

The user wants to check open orders, cancel or replace an order, view their portfolio and P&L, or deposit/withdraw funds.

## Cancel or Replace an Order

1. **List your open orders** — `context_my_orders` (MCP) or `ctx.orders.mine(marketId)` (SDK) or `context orders mine` (CLI).
2. **Find the order's nonce** — each order has a unique `nonce` field.
3. **Cancel:**
   - **MCP:** `context_cancel_order({ nonce: "0x..." })`
   - **SDK:** `ctx.orders.cancel("0x..." as Hex)`
   - **CLI:** `context orders cancel --nonce 0x...`
4. **Optionally replace** — use `ctx.orders.cancelReplace(nonce, newOrder)` for atomic cancel + new order. CLI: `context orders cancel-replace --nonce 0x... --market <id> --outcome yes --side buy --price 50 --size 10`
5. **Verify** — the cancelled order should no longer appear in `context_my_orders`.

## Check Portfolio

1. **Get positions** — `context_get_portfolio` with optional `kind` filter: `all`, `active`, `won`, `lost`, `claimable`.
   - SDK: `ctx.portfolio.get(undefined, { kind: "active" })`
   - CLI: `context portfolio get --kind active`
2. **Get balance** — `context_get_balance` for USDC balance breakdown.
   - SDK: `ctx.portfolio.balance()`
   - CLI: `context portfolio balance`
3. **Get P&L stats** — `ctx.portfolio.stats()` or `context portfolio stats`.
4. **Claim winnings** — use `kind: "claimable"` to find resolved markets with unclaimed positions.

## Fund Your Account

1. **Check balance** — `context_get_balance` or `ctx.portfolio.balance()`.
2. **Deposit USDC** — `ctx.account.deposit(amount)` (chain-aware: gasless on testnet, on-chain on mainnet).
3. **Mint test USDC (testnet only)** — `context_mint_test_usdc` or `ctx.account.mintTestUsdc(1000)`.
4. **Withdraw** — `ctx.account.withdraw(amount)` moves USDC from settlement back to wallet.

## Gotchas

- **Cancelled orders may have partially filled.** Check `context_get_portfolio` for position changes, not just order status.
- **`cancelReplace` is atomic.** If the cancel fails (order already fully filled), the new order is NOT placed. This prevents accidental double-positioning.
- **Portfolio `kind: "claimable"`** shows positions on resolved markets where you can claim winnings. Don't forget to claim.
- **Balance has two parts** — wallet USDC and settlement (deposited) USDC. You trade with settlement balance. Deposit moves wallet → settlement. Withdraw does the reverse.
- **`allMine()` auto-paginates; `mine()` returns first page only.** For markets with many orders, use `allMine()` to get the complete list.

## Verification

- After cancel: order no longer in `context_my_orders`.
- After deposit: `context_get_balance` shows increased settlement balance.
- After withdraw: `context_get_balance` shows decreased settlement, increased wallet balance.

## See Also

- [Orders API](../references/orders.md) — cancel, cancelReplace method signatures
- [Order Lifecycle](../references/order-lifecycle.md) — States, void reasons, partial fills
