---
name: context-research-portfolio-analysis
description: Review current positions, P&L, balances, and claimable winnings
---

# Portfolio Analysis

Check your current positions, unrealized P&L, balances, and claimable winnings from resolved markets.

## When to Use

The user wants to review their trading positions, check their balance, or find resolved markets with unclaimed winnings.

## Prerequisites

Requires API key + private key (portfolio data is per-account, not public).

## Steps

1. **Get positions** — `context_get_portfolio` with optional `kind` filter:
   - `"all"` — everything
   - `"active"` — open positions on active markets
   - `"won"` — positions on markets that resolved in your favor
   - `"lost"` — positions on markets that resolved against you
   - `"claimable"` — resolved markets with unclaimed winnings
   - SDK: `ctx.portfolio.get(undefined, { kind: "active" })`
   - CLI: `context portfolio get --kind active`

2. **For each active position, check current market state:**
   - `context_get_market` — is the market still active, or approaching resolution?
   - `context_get_quotes` — what's the current price? Compare to your entry price for unrealized P&L.
   - `context_get_oracle` — does the oracle support your position or contradict it?

3. **Check balances** — `context_get_balance` shows:
   - Wallet USDC (in your Ethereum wallet)
   - Settlement USDC (deposited, available for trading)
   - Outcome token holdings per market
   - SDK: `ctx.portfolio.balance()`
   - CLI: `context portfolio balance`

4. **Get P&L stats** — `ctx.portfolio.stats()` or `context portfolio stats` for aggregate performance.

5. **Claim winnings** — if `kind: "claimable"` returns results, those are resolved markets where you won. The winnings need to be claimed to appear in your balance.

## Gotchas

- **Portfolio requires auth.** Unlike market data, portfolio data needs your API key and private key since it's account-specific.
- **Balance has two parts.** Wallet USDC and settlement USDC are separate. You trade with settlement balance. Deposits move wallet → settlement.
- **Unrealized P&L is approximate.** Current quotes may not reflect actual fill prices if you were to exit. Always simulate exit trades.
- **Claimable positions don't auto-claim.** Check `kind: "claimable"` periodically and claim winnings, or they'll sit there.
- **`context_get_portfolio` is paginated.** Use `cursor` for markets with many positions.

## Verification

- Portfolio positions should match your expected holdings based on recent trades.
- Balance should reconcile: settlement balance + value of open positions ≈ total account value.

## See Also

- [Markets API](../references/markets.md) — Market data methods for position analysis
- [Price Data](../references/price-data.md) — Quote structure for P&L calculation
