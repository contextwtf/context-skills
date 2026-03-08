# Build Skill

You are an AI agent skilled at building prediction market frontends using the Context React SDK. You set up providers, wire React hooks to UI components, handle wallet connections, and implement trading workflows.

## Prerequisites

- `@contextwtf/react` v0.1.0 and `@contextwtf/sdk` v0.3.5
- React 18+, wagmi, viem, @tanstack/react-query
- Context MCP server is optional -- all functionality is available through React hooks
- No API key needed for read-only hooks. Trading hooks require wallet connection.

```bash
npm install @contextwtf/react @contextwtf/sdk wagmi viem @tanstack/react-query
```

## Provider Setup

Every Context app needs three nested providers. Order matters.

```tsx
import { ContextProvider } from '@contextwtf/react'
import { WagmiProvider } from 'wagmi'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'

const queryClient = new QueryClient()

function App() {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <ContextProvider>
          {children}
        </ContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

`WagmiProvider` handles wallet connections. `QueryClientProvider` manages data fetching and caching. `ContextProvider` wires the Context SDK to both and exposes hooks to all child components.

## React Hooks

### Markets (query hooks)

| Hook | Purpose |
|------|---------|
| `useMarkets(params?, options?)` | List and search markets |
| `useMarket(marketId, options?)` | Single market details |
| `useOrderbook(marketId, params?, options?)` | Orderbook bid/ask ladder |
| `useQuotes(marketId, options?)` | Current bid, ask, and last prices |
| `usePriceHistory(marketId, params?, options?)` | Historical price data |
| `useMarketActivity(marketId, params?, options?)` | Market activity feed |
| `useSimulateTrade(marketId, params, options?)` | Preview trade execution |
| `useOracle(marketId, options?)` | Oracle probability estimate |

### Orders (query hooks)

| Hook | Purpose |
|------|---------|
| `useOrders(params?, options?)` | List orders |
| `useOrder(orderId, options?)` | Single order details |

### Orders (mutation hooks)

| Hook | Purpose |
|------|---------|
| `useCreateOrder(options?)` | Place a limit order |
| `useCreateMarketOrder(options?)` | Place a market order |
| `useCancelOrder(options?)` | Cancel an open order |
| `useCancelReplace(options?)` | Atomically cancel and replace an order |

### Portfolio (query hooks)

| Hook | Purpose |
|------|---------|
| `usePortfolio(address?, params?, options?)` | Position list |
| `useBalance(address?, options?)` | USDC balance |
| `useClaimable(address?, options?)` | Claimable winnings |
| `usePortfolioStats(address?, options?)` | P&L statistics |

### Account (mixed)

| Hook | Purpose |
|------|---------|
| `useAccountStatus(options?)` | Check if account is set up (query) |
| `useAccountSetup(options?)` | Set up trading account (mutation) |
| `useDeposit(options?)` | Deposit USDC (mutation) |
| `useWithdraw(options?)` | Withdraw USDC (mutation) |

### Questions

| Hook | Purpose |
|------|---------|
| `useSubmitQuestion(options?)` | Submit a question for market creation |
| `useSubmitAndWait(options?)` | Submit and poll until approved |
| `useCreateMarket(options?)` | Create market from approved question |

### Utility

| Export | Purpose |
|--------|---------|
| `contextKeys` | Query key factory for cache invalidation |
| `ContextProvider` | Required wrapper component |
| `useContextClient()` | Access the raw SDK client |

## Common Patterns

### Displaying a Market Card

```tsx
function MarketCard({ marketId }: { marketId: string }) {
  const { data: market } = useMarket(marketId)
  const { data: quotes } = useQuotes(marketId)

  if (!market) return null

  return (
    <div>
      <h3>{market.question}</h3>
      <p>YES: {quotes?.yes.bid}c / {quotes?.yes.ask}c</p>
      <p>NO: {quotes?.no.bid}c / {quotes?.no.ask}c</p>
      <p>Status: {market.status}</p>
    </div>
  )
}
```

### Placing an Order

```tsx
function OrderForm({ marketId }: { marketId: string }) {
  const { mutate: createOrder, isPending } = useCreateOrder()

  const handleBuy = () => {
    createOrder({
      marketId,
      side: 0,          // 0 = buy
      outcomeIndex: 0,  // 0 = YES
      price: 50,        // 50 cents
      size: 10,         // 10 shares
    })
  }

  return <button onClick={handleBuy} disabled={isPending}>Buy YES at 50c</button>
}
```

### Account Setup Flow

```tsx
function AccountSetup() {
  const { data: status } = useAccountStatus()
  const { mutate: setup, isPending } = useAccountSetup()
  const { mutate: deposit } = useDeposit()

  if (status?.ready) return <p>Account ready</p>

  return (
    <div>
      <button onClick={() => setup()} disabled={isPending}>
        Set Up Account
      </button>
      <button onClick={() => deposit(100)}>
        Deposit 100 USDC
      </button>
    </div>
  )
}
```

## Composite Workflows

### Trading App

Full order flow: browse markets, view details, place and manage orders, track portfolio.

1. Use `useMarkets` with search/filter params to render a market list.
2. On market select, use `useMarket`, `useQuotes`, and `useOrderbook` for the detail view.
3. Use `useSimulateTrade` to preview orders before submission.
4. Use `useCreateOrder` or `useCreateMarketOrder` to place trades.
5. Use `useOrders` to show open orders, `useCancelOrder` to cancel.
6. Use `usePortfolio` and `useBalance` for the portfolio view.

### Market Dashboard

Read-only dashboard with live market data and analytics.

1. Use `useMarkets` with `sortBy` options to build filtered views (trending, volume, new).
2. Use `useQuotes` with `refetchInterval` for live price updates.
3. Use `usePriceHistory` to render price charts.
4. Use `useOracle` to display oracle probability alongside market price.
5. Use `useMarketActivity` for a real-time activity feed.

### Prediction Market Widget

Embeddable single-market component with buy/sell buttons.

1. Use `useMarket` and `useQuotes` for market display.
2. Use `useSimulateTrade` to show estimated fill price as the user adjusts size.
3. Use `useCreateMarketOrder` for one-click market orders.
4. Use `useBalance` to show available funds.
5. Wrap in `ContextProvider` so the widget is self-contained.

## References

- [React Hooks API](./references/react-hooks.md) -- Full hook signatures, parameters, and return types
- [Provider Setup](./references/provider-setup.md) -- ContextProvider, wagmi config, and provider hierarchy
- [Query Patterns](./references/query-patterns.md) -- contextKeys, cache invalidation, polling, optimistic updates
- [Wagmi Integration](./references/wagmi-integration.md) -- Wallet connection, account setup flow, Base Sepolia config
