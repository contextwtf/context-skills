# Role

You are an AI agent that builds prediction market frontends using the Context React SDK. You set up providers, wire React hooks to UI components, handle wallet connections, and implement trading workflows.

# Skill

## Prerequisites

- `context-markets-react` v0.1.0 and `context-markets` v0.3.5
- React 18+, wagmi, viem, @tanstack/react-query
- Context MCP server is optional -- all functionality is available through React hooks
- No API key needed for read-only hooks. Trading hooks require wallet connection.

```bash
npm install context-markets-react context-markets wagmi viem @tanstack/react-query
```

## Provider Setup

Every Context app needs three nested providers. Order matters.

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

## React Hooks

### Markets (query hooks)

- `useMarkets(params?, options?)` -- List and search markets
- `useMarket(marketId, options?)` -- Single market details
- `useOrderbook(marketId, params?, options?)` -- Orderbook bid/ask ladder
- `useQuotes(marketId, options?)` -- Current bid, ask, and last prices
- `usePriceHistory(marketId, params?, options?)` -- Historical price data
- `useMarketActivity(marketId, params?, options?)` -- Market activity feed
- `useSimulateTrade(marketId, params, options?)` -- Preview trade execution
- `useOracle(marketId, options?)` -- Oracle probability estimate

### Orders (query hooks)

- `useOrders(params?, options?)` -- List orders
- `useOrder(orderId, options?)` -- Single order details

### Orders (mutation hooks)

- `useCreateOrder(options?)` -- Place a limit order
- `useCreateMarketOrder(options?)` -- Place a market order
- `useCancelOrder(options?)` -- Cancel an open order
- `useCancelReplace(options?)` -- Atomically cancel and replace an order

### Portfolio (query hooks)

- `usePortfolio(address?, params?, options?)` -- Position list
- `useBalance(address?, options?)` -- USDC balance
- `useClaimable(address?, options?)` -- Claimable winnings
- `usePortfolioStats(address?, options?)` -- P&L statistics

### Account (mixed)

- `useAccountStatus(options?)` -- Check if account is set up (query)
- `useAccountSetup(options?)` -- Set up trading account (mutation)
- `useDeposit(options?)` -- Deposit USDC (mutation)
- `useWithdraw(options?)` -- Withdraw USDC (mutation)

### Questions

- `useSubmitQuestion(options?)` -- Submit a question for market creation
- `useSubmitAndWait(options?)` -- Submit and poll until approved
- `useCreateMarket(options?)` -- Create market from approved question

### Utility

- `contextKeys` -- Query key factory for cache invalidation
- `ContextProvider` -- Required wrapper component
- `useContextClient()` -- Access the raw SDK client

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

1. Connect wallet (wagmi `useConnect`)
2. Check status (`useAccountStatus`) -- returns `{ ready, hasOperator, hasDeposit }`
3. Setup if needed (`useAccountSetup`)
4. Deposit USDC (`useDeposit`)

## Composite Workflows

### Trading App

1. `useMarkets` with search/filter for market list.
2. `useMarket` + `useQuotes` + `useOrderbook` for detail view.
3. `useSimulateTrade` to preview before placing.
4. `useCreateOrder` or `useCreateMarketOrder` to trade.
5. `useOrders` + `useCancelOrder` for order management.
6. `usePortfolio` + `useBalance` for portfolio view.

### Market Dashboard

1. `useMarkets` with `sortBy` for filtered views.
2. `useQuotes` with `refetchInterval` for live prices.
3. `usePriceHistory` for price charts.
4. `useOracle` for oracle probability.
5. `useMarketActivity` for activity feed.

### Prediction Market Widget

1. `useMarket` + `useQuotes` for display.
2. `useSimulateTrade` for fill estimates.
3. `useCreateMarketOrder` for one-click orders.
4. Wrap in `ContextProvider` for self-contained embedding.

# Key Hook Signatures

```typescript
// Query hooks
useMarkets(params?: SearchMarketsParams, options?: UseQueryOptions<MarketList>)
useMarket(marketId: string, options?: UseQueryOptions<Market>)
useOrderbook(marketId: string, params?: GetOrderbookParams, options?: UseQueryOptions<Orderbook>)
useQuotes(marketId: string, options?: UseQueryOptions<Quotes>)
usePriceHistory(marketId: string, params?: GetPriceHistoryParams, options?: UseQueryOptions<PriceHistory>)
useSimulateTrade(marketId: string, params: SimulateTradeParams, options?: UseQueryOptions<SimulateResult>)
useOracle(marketId: string, options?: UseQueryOptions<any>)

// Mutation hooks
useCreateOrder(options?: UseMutationOptions<CreateOrderResult, Error, PlaceOrderRequest>)
useCreateMarketOrder(options?: UseMutationOptions<CreateOrderResult, Error, PlaceMarketOrderRequest>)
useCancelOrder(options?: UseMutationOptions<CancelResult, Error, Hex>)
useCancelReplace(options?: UseMutationOptions<CancelReplaceResult, Error, { cancelNonce: Hex; newOrder: PlaceOrderRequest }>)

// Portfolio hooks
usePortfolio(address?: Address, params?: GetPortfolioParams, options?: UseQueryOptions<Portfolio>)
useBalance(address?: Address, options?: UseQueryOptions<Balance>)

// Account hooks
useAccountStatus(options?: UseQueryOptions<WalletStatus>)
useAccountSetup(options?: UseMutationOptions<GaslessOperatorResult | WalletSetupResult, Error, void>)
useDeposit(options?: UseMutationOptions<GaslessDepositResult | Hex, Error, number>)
useWithdraw(options?: UseMutationOptions<Hex, Error, number>)
```

# contextKeys (cache invalidation)

```typescript
contextKeys.markets.list(params?)
contextKeys.markets.detail(id)
contextKeys.markets.quotes(id)
contextKeys.markets.orderbook(id)
contextKeys.orders.list(params?)
contextKeys.portfolio.balance(addr)
contextKeys.portfolio.positions(addr)
```
