---
name: context-build-trading-app
description: Scaffold a full prediction market trading UI with market list, orders, and portfolio
---

# Trading App

Build a full trading application: browse markets, view details, place orders, and manage a portfolio.

## When to Use

The user wants to build a complete trading frontend with market browsing, order placement, and portfolio management.

## Steps

1. **Set up providers** — wrap the app with `WagmiProvider > QueryClientProvider > ContextProvider`. See the provider setup in the build SKILL.md.

2. **Market list page** — use `useMarkets({ status: "active", sortBy: "trending" })` to render a filterable list. Add search with `useSearchMarkets`.

3. **Market detail view** — on market select:
   - `useMarket(marketId)` for title, description, status
   - `useQuotes(marketId)` for current prices (consider `refetchInterval: 5000` for live updates)
   - `useOrderbook(marketId)` for bid/ask depth
   - `useOracle(marketId)` for oracle evidence and summary
   - `useLatestOracleQuote(marketId)` for the latest numeric oracle quote

4. **Order form** — place trades:
   - `useSimulateTrade(marketId, { side, amount, amountType: "usd" })` for preview as user adjusts size
   - `useCreateOrder()` for limit orders: `mutate({ marketId, outcome: "yes", side: "buy", priceCents: 45, size: 10 })`
   - `useCreateMarketOrder()` for instant execution
   - Invalidate `contextKeys.orders.list()` and `contextKeys.portfolio.positions()` on success

5. **Order management** — show open orders and allow cancellation:
   - `useOrders({ marketId })` to list
   - `useCancelOrder()` to cancel by nonce

6. **Portfolio view** — `usePortfolio()` for positions, `useBalance()` for funds, `usePortfolioStats()` for P&L.

## Gotchas

- **Provider order matters.** `WagmiProvider` must be outermost, then `QueryClientProvider`, then `ContextProvider`. Wrong order = hooks fail silently.
- **Wallet must be connected for mutations.** `useCreateOrder`, `useCancelOrder`, etc. require an active wallet connection. Check `useAccount()` from wagmi first.
- **Invalidate caches after mutations.** After placing or cancelling orders, invalidate the relevant query keys so the UI updates. Use `queryClient.invalidateQueries()` with `contextKeys`.
- **`ContextProvider` requires `apiKey` prop.** Even for read-only hooks, the provider needs an API key to authenticate requests.
- **Use `enabled` option to prevent premature queries.** Don't fetch orderbook data until the user selects a market: `useOrderbook(marketId, {}, { enabled: !!marketId })`.

## Verification

- Market list renders with active markets and prices.
- Clicking a market shows detail view with quotes and orderbook.
- Order form previews fill with simulation and successfully places orders.
- Portfolio shows current positions and balance.

## See Also

- [React Hooks API](../references/react-hooks.md) — Full hook signatures
- [Query Patterns](../references/query-patterns.md) — Cache invalidation, polling, optimistic updates
