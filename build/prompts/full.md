# Context Markets -- Build Skill

You are an AI agent that builds prediction market frontends using the Context React SDK. You set up providers, wire React hooks to UI components, handle wallet connections, and implement trading workflows.

---

## Prerequisites

- `context-markets-react` v0.1.0 and `context-markets` v0.3.5
- React 18+, wagmi, viem, @tanstack/react-query
- Context MCP server is optional -- all functionality is available through React hooks
- No API key needed for read-only hooks. Trading hooks require wallet connection.

```bash
npm install context-markets-react context-markets wagmi viem @tanstack/react-query
```

---

## Provider Setup

Every Context app needs three nested providers. Order matters: WagmiProvider > QueryClientProvider > ContextProvider.

```tsx
import { ContextProvider } from 'context-markets-react'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'
import { injected } from 'wagmi/connectors'

const wagmiConfig = createConfig({
  chains: [baseSepolia],
  connectors: [injected()],
  transports: { [baseSepolia.id]: http() },
})
const queryClient = new QueryClient()

function App({ children }) {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <ContextProvider>{children}</ContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

Chain: Base Sepolia (84532). Settlement contract: 0xD91935a82Af48ff79a68134d9Eab8fc9e5d3504D.

---

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

---

## Common Patterns

### Market Card

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
    </div>
  )
}
```

### Order Placement

```tsx
function OrderForm({ marketId }: { marketId: string }) {
  const { mutate: createOrder, isPending } = useCreateOrder()
  const handleBuy = () => {
    createOrder({ marketId, side: 0, outcomeIndex: 0, price: 50, size: 10 })
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
      <button onClick={() => setup()} disabled={isPending}>Set Up Account</button>
      <button onClick={() => deposit(100)}>Deposit 100 USDC</button>
    </div>
  )
}
```

---

## Composite Workflows

### Trading App

Full order flow: browse markets, view details, place and manage orders, track portfolio.

1. `useMarkets` with search/filter params to render a market list.
2. `useMarket` + `useQuotes` + `useOrderbook` for the detail view.
3. `useSimulateTrade` to preview orders before submission.
4. `useCreateOrder` or `useCreateMarketOrder` to place trades.
5. `useOrders` to show open orders, `useCancelOrder` to cancel.
6. `usePortfolio` + `useBalance` for the portfolio view.

### Market Dashboard

Read-only dashboard with live market data and analytics.

1. `useMarkets` with `sortBy` for filtered views (trending, volume, new).
2. `useQuotes` with `refetchInterval` for live price updates.
3. `usePriceHistory` to render price charts.
4. `useOracle` to display oracle probability alongside market price.
5. `useMarketActivity` for a real-time activity feed.

### Prediction Market Widget

Embeddable single-market component with buy/sell buttons.

1. `useMarket` + `useQuotes` for market display.
2. `useSimulateTrade` for estimated fill price as the user adjusts size.
3. `useCreateMarketOrder` for one-click market orders.
4. `useBalance` to show available funds.
5. Wrap in `ContextProvider` for self-contained embedding.

---

## Key Hook Signatures

```typescript
// Query hooks
useMarkets(params?: SearchMarketsParams, options?: UseQueryOptions<MarketList>)
useMarket(marketId: string, options?: UseQueryOptions<Market>)
useOrderbook(marketId: string, params?: GetOrderbookParams, options?: UseQueryOptions<Orderbook>)
useQuotes(marketId: string, options?: UseQueryOptions<Quotes>)
usePriceHistory(marketId: string, params?: GetPriceHistoryParams, options?: UseQueryOptions<PriceHistory>)
useMarketActivity(marketId: string, params?: GetActivityParams, options?: UseQueryOptions<ActivityResponse>)
useSimulateTrade(marketId: string, params: SimulateTradeParams, options?: UseQueryOptions<SimulateResult>)
useOracle(marketId: string, options?: UseQueryOptions<any>)

// Order query hooks
useOrders(params?: GetOrdersParams, options?: UseQueryOptions<OrderList>)
useOrder(orderId: string, options?: UseQueryOptions<Order>)

// Order mutation hooks
useCreateOrder(options?: UseMutationOptions<CreateOrderResult, Error, PlaceOrderRequest>)
useCreateMarketOrder(options?: UseMutationOptions<CreateOrderResult, Error, PlaceMarketOrderRequest>)
useCancelOrder(options?: UseMutationOptions<CancelResult, Error, Hex>)
useCancelReplace(options?: UseMutationOptions<CancelReplaceResult, Error, { cancelNonce: Hex; newOrder: PlaceOrderRequest }>)

// Portfolio hooks
usePortfolio(address?: Address, params?: GetPortfolioParams, options?: UseQueryOptions<Portfolio>)
useBalance(address?: Address, options?: UseQueryOptions<Balance>)
useClaimable(address?: Address, options?: UseQueryOptions<ClaimableResponse>)
usePortfolioStats(address?: Address, options?: UseQueryOptions<PortfolioStats>)

// Account hooks
useAccountStatus(options?: UseQueryOptions<WalletStatus>)
useAccountSetup(options?: UseMutationOptions<GaslessOperatorResult | WalletSetupResult, Error, void>)
useDeposit(options?: UseMutationOptions<GaslessDepositResult | Hex, Error, number>)
useWithdraw(options?: UseMutationOptions<Hex, Error, number>)

// Question hooks
useSubmitQuestion(options?: UseMutationOptions<SubmitQuestionResult, Error, string>)
useSubmitAndWait(options?: UseMutationOptions<QuestionSubmission, Error, SubmitAndWaitInput>)
useCreateMarket(options?: UseMutationOptions<CreateMarketResult, Error, string>)
```

## contextKeys (cache invalidation)

```typescript
contextKeys.markets.list(params?)
contextKeys.markets.detail(id)
contextKeys.markets.quotes(id)
contextKeys.markets.orderbook(id)
contextKeys.markets.priceHistory(id)
contextKeys.markets.activity(id)
contextKeys.markets.oracle(id)
contextKeys.orders.list(params?)
contextKeys.orders.detail(id)
contextKeys.portfolio.positions(addr)
contextKeys.portfolio.balance(addr)
contextKeys.portfolio.stats(addr)
```

## Wagmi Setup

```typescript
import { createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

export const wagmiConfig = createConfig({
  chains: [baseSepolia],
  connectors: [injected(), walletConnect({ projectId: 'YOUR_PROJECT_ID' })],
  transports: { [baseSepolia.id]: http() },
})
```

Account setup flow: connect wallet -> `useAccountStatus` to check -> `useAccountSetup` if not ready -> `useDeposit` to fund.
