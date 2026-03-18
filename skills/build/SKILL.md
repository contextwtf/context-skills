---
name: context-build
description: Build prediction market frontends with the Context React SDK
---

# Build Skill

Build prediction market frontends using React hooks from `context-markets-react`.

## Prerequisites

- `context-markets-react` and `context-markets` >= 0.5
- React 18+, `wagmi` >= 2, `viem` >= 2, `@tanstack/react-query` >= 5
- No API key needed for read-only hooks. Trading hooks require wallet connection.

```bash
npm install context-markets-react context-markets wagmi viem @tanstack/react-query
```

## Shared Foundations

### Provider Hierarchy

Order matters. All three are required.

```tsx
import { WagmiProvider } from "wagmi"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { ContextProvider } from "context-markets-react"

const queryClient = new QueryClient()

function App({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <ContextProvider apiKey={process.env.NEXT_PUBLIC_CONTEXT_API_KEY!}>
          {children}
        </ContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

### Hook Catalog

**Markets (query):** `useMarkets` · `useSearchMarkets` · `useMarket` · `useOrderbook` · `useQuotes` · `usePriceHistory` · `useMarketActivity` · `useSimulateTrade` · `useOracle` · `useLatestOracleQuote`

**Orders (query):** `useOrders` · `useOrder`

**Orders (mutation):** `useCreateOrder` · `useCreateMarketOrder` · `useCancelOrder` · `useCancelReplace`

**Portfolio (query):** `usePortfolio` · `usePositions` · `useBalance` · `useClaimable` · `usePortfolioStats`

**Account (mixed):** `useAccountStatus` · `useAccountSetup` · `useDeposit` · `useWithdraw` · `useApproveUsdc` · `useApproveOperator`

**Questions (mutation):** `useSubmitQuestion` · `useSubmitAndWait` · `useCreateMarket` · `useAgentSubmit` · `useAgentSubmitAndWait`

**Utilities:** `ContextProvider` · `useContextClient` · `contextKeys` · `ContextWalletError`

### Query Keys

Use `contextKeys` for cache invalidation after mutations:

```ts
import { contextKeys } from "context-markets-react"

contextKeys.markets.list(params)
contextKeys.markets.detail(marketId)
contextKeys.markets.quotes(marketId)
contextKeys.orders.list(params)
contextKeys.portfolio.positions(address)
contextKeys.portfolio.balance(address)
```

## Available Workflows

| Workflow | When to use |
|----------|-------------|
| [trading-app](./trading-app/SKILL.md) | Full trading UI with market list, orders, portfolio |
| [market-widget](./market-widget/SKILL.md) | Embeddable single-market component |
| [portfolio-dashboard](./portfolio-dashboard/SKILL.md) | Position tracking and P&L display |
| [account-setup-flow](./account-setup-flow/SKILL.md) | Wallet connect → approve → deposit → ready |

## References

- [React Hooks API](./references/react-hooks.md) — Full hook signatures and return types
- [Provider Setup](./references/provider-setup.md) — ContextProvider, wagmi config, chain config
- [Query Patterns](./references/query-patterns.md) — contextKeys, cache invalidation, polling
- [Wagmi Integration](./references/wagmi-integration.md) — Wallet connection, account setup, Base config
