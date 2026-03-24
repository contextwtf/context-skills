# Query Patterns

TanStack Query best practices for Context React hooks.

## contextKeys Factory

All Context hooks use a structured query key factory. Use `contextKeys` to interact with the cache directly.

```typescript
import { contextKeys } from 'context-markets-react'

// Market keys
contextKeys.markets.list(params?)      // useMarkets query key
contextKeys.markets.get(id)            // useMarket query key
contextKeys.markets.orderbook(id)      // useOrderbook query key
contextKeys.markets.quotes(id)         // useQuotes query key
contextKeys.markets.priceHistory(id)   // usePriceHistory query key
contextKeys.markets.activity(id)       // useMarketActivity query key
contextKeys.markets.oracle(id)         // useOracle query key

// Order keys (scoped by wallet address)
contextKeys.orders.list(address?, params?)  // useOrders query key
contextKeys.orders.get(address?, id?)       // useOrder query key

// Portfolio keys
contextKeys.portfolio.get(addr)        // usePortfolio query key
contextKeys.portfolio.balance(addr)    // useBalance query key
contextKeys.portfolio.stats(addr)      // usePortfolioStats query key
```

## Cache Invalidation After Mutations

After placing or cancelling an order, invalidate related queries so the UI reflects the new state.

```tsx
import { useQueryClient } from '@tanstack/react-query'
import { contextKeys, useCreateOrder } from 'context-markets-react'

function OrderForm({ marketId }: { marketId: string }) {
  const queryClient = useQueryClient()

  const { mutate: createOrder } = useCreateOrder({
    onSuccess: () => {
      // Invalidate orderbook -- it changed because of the new order
      queryClient.invalidateQueries({
        queryKey: contextKeys.markets.orderbook(marketId),
      })

      // Invalidate quotes -- bid/ask may have shifted
      queryClient.invalidateQueries({
        queryKey: contextKeys.markets.quotes(marketId),
      })

      // Invalidate order list
      queryClient.invalidateQueries({
        queryKey: contextKeys.orders.list(),
      })

      // Invalidate balance -- funds are now committed
      queryClient.invalidateQueries({
        queryKey: contextKeys.portfolio.balance(),
      })
    },
  })
}
```

## Polling with refetchInterval

For live data, set `refetchInterval` in the hook options.

```tsx
// Poll quotes every 5 seconds
const { data: quotes } = useQuotes(marketId, {
  refetchInterval: 5_000,
})

// Poll orderbook every 10 seconds
const { data: orderbook } = useOrderbook(marketId, {}, {
  refetchInterval: 10_000,
})

// Poll portfolio balance every 30 seconds
const { data: balance } = useBalance(undefined, {
  refetchInterval: 30_000,
})
```

Choose intervals based on how fast the data changes and how critical freshness is. Quotes and orderbooks change frequently; portfolio stats do not.

## Conditional Queries with enabled

Disable a query until its dependencies are ready.

```tsx
// Only fetch orderbook when a market is selected
const [selectedMarket, setSelectedMarket] = useState<string | null>(null)

const { data: orderbook } = useOrderbook(selectedMarket ?? '', {}, {
  enabled: !!selectedMarket,
})

// Only simulate when the user has entered an amount
const [amount, setAmount] = useState(0)

const { data: sim } = useSimulateTrade(marketId, {
  side: 'yes',
  amount,
}, {
  enabled: amount > 0,
})
```

## Optimistic Updates for Order Placement

Show the order in the UI immediately, then reconcile when the server responds.

```tsx
const queryClient = useQueryClient()

const { mutate: createOrder } = useCreateOrder({
  onMutate: async (newOrder) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries({
      queryKey: contextKeys.orders.list(),
    })

    // Snapshot current orders
    const previousOrders = queryClient.getQueryData(
      contextKeys.orders.list()
    )

    // Optimistically add the new order
    queryClient.setQueryData(contextKeys.orders.list(), (old: any) => ({
      ...old,
      orders: [
        { ...newOrder, status: 'open', id: 'temp-' + Date.now() },
        ...(old?.orders ?? []),
      ],
    }))

    return { previousOrders }
  },

  onError: (_err, _newOrder, context) => {
    // Roll back on failure
    if (context?.previousOrders) {
      queryClient.setQueryData(
        contextKeys.orders.list(),
        context.previousOrders,
      )
    }
  },

  onSettled: () => {
    // Refetch to get the real server state
    queryClient.invalidateQueries({
      queryKey: contextKeys.orders.list(),
    })
  },
})
```

## Prefetching

Prefetch data before the user navigates to improve perceived performance.

```tsx
const queryClient = useQueryClient()

function MarketListItem({ market }: { market: Market }) {
  const prefetch = () => {
    queryClient.prefetchQuery({
      queryKey: contextKeys.markets.get(market.id),
      queryFn: () => fetchMarket(market.id),
    })
    queryClient.prefetchQuery({
      queryKey: contextKeys.markets.quotes(market.id),
      queryFn: () => fetchQuotes(market.id),
    })
  }

  return (
    <Link to={`/market/${market.id}`} onMouseEnter={prefetch}>
      {market.question}
    </Link>
  )
}
```

## Stale Time Configuration

Set `staleTime` to control how long data is considered fresh. Fresh data is served from cache without a background refetch.

```tsx
// Market details change rarely -- cache for 60 seconds
const { data: market } = useMarket(marketId, {
  staleTime: 60_000,
})

// Quotes change rapidly -- keep stale time low
const { data: quotes } = useQuotes(marketId, {
  staleTime: 2_000,
})
```

Global defaults can be set on the `QueryClient`:

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 10_000,
      refetchOnWindowFocus: false,
    },
  },
})
```
