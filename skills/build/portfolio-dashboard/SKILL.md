---
name: context-build-portfolio-dashboard
description: Build a portfolio dashboard showing positions, P&L, balances, and claimable winnings
---

# Portfolio Dashboard

Build a dashboard showing current positions, unrealized P&L, balance breakdown, and claimable winnings from resolved markets.

## When to Use

The user wants to build a portfolio view that shows their positions, performance, and balance.

## Steps

1. **Positions list** — `usePortfolio()` or `usePositions()` for current holdings:
   ```tsx
   const { data } = usePortfolio(address, { kind: "active" })
   // data.positions contains market, outcome, size, avgPrice
   ```

2. **Balance breakdown** — `useBalance(address)` for USDC in wallet vs settlement:
   ```tsx
   const { data: balance } = useBalance()
   // balance.usdc.wallet, balance.usdc.settlement
   ```

3. **P&L stats** — `usePortfolioStats(address)` for aggregate performance metrics.

4. **Current prices** — for each position, use `useQuotes(marketId)` to get current price. Compare to entry price for unrealized P&L.

5. **Claimable winnings** — `useClaimable(address)` to find resolved markets with unclaimed winnings:
   ```tsx
   const { data: claimable } = useClaimable()
   // claimable.markets contains resolved positions to claim
   ```

6. **Live updates** — use `refetchInterval` on position and balance hooks:
   ```tsx
   usePortfolio(address, { kind: "active" }, { refetchInterval: 10000 })
   ```

## Gotchas

- **Positions may show stale prices.** The position's entry price is fixed, but current market price changes. Use `useQuotes` with `refetchInterval` for live P&L.
- **Balance has two parts.** Wallet USDC and settlement USDC. Users trade with settlement balance. Show both clearly.
- **Claimable positions don't auto-claim.** Show a "Claim" button that calls the claim function. If you don't surface this, users will miss winnings.
- **Address is optional** — if omitted, hooks use the connected wallet address from wagmi. Pass explicitly if showing another user's portfolio.
- **`usePositions` vs `usePortfolio`** — `usePositions` returns a flat position list, `usePortfolio` returns the full portfolio summary. Choose based on your UI needs.

## Verification

- Positions list shows all active positions with market name and side.
- Balance shows both wallet and settlement USDC.
- P&L calculation: current price minus entry price, multiplied by size.
- Claimable section shows resolved markets with a claim action.

## See Also

- [React Hooks API](../references/react-hooks.md) — usePortfolio, useBalance, useClaimable signatures
- [Query Patterns](../references/query-patterns.md) — refetchInterval for live updates
