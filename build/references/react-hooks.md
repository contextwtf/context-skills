# React Hooks API Reference

Complete hook signatures for `@contextwtf/react`. All query hooks return TanStack Query results (`{ data, isLoading, error, refetch, ... }`). All mutation hooks return `{ mutate, mutateAsync, isPending, error, ... }`.

## Market Hooks

### useMarkets

List and search markets with optional filters.

```typescript
useMarkets(
  params?: SearchMarketsParams,
  options?: UseQueryOptions<MarketList>
)
```

**SearchMarketsParams:**
```typescript
{
  query?: string           // Text search
  status?: string          // "active" | "pending" | "resolved" | "closed"
  category?: string        // Market category
  sortBy?: string          // "new" | "volume" | "trending" | "ending" | "chance"
  limit?: number           // Results per page
  offset?: number          // Pagination offset
}
```

**Example:**
```tsx
function MarketList() {
  const { data, isLoading } = useMarkets({
    status: 'active',
    sortBy: 'trending',
    limit: 20,
  })

  if (isLoading) return <p>Loading...</p>

  return (
    <ul>
      {data?.markets.map(m => (
        <li key={m.id}>{m.question} - {m.status}</li>
      ))}
    </ul>
  )
}
```

### useMarket

Fetch a single market by ID.

```typescript
useMarket(
  marketId: string,
  options?: UseQueryOptions<Market>
)
```

**Example:**
```tsx
function MarketDetail({ id }: { id: string }) {
  const { data: market } = useMarket(id)

  if (!market) return null

  return (
    <div>
      <h2>{market.question}</h2>
      <p>Category: {market.category}</p>
      <p>Status: {market.status}</p>
      <p>Volume: {market.volume}</p>
    </div>
  )
}
```

### useOrderbook

Get the orderbook bid/ask ladder for a market.

```typescript
useOrderbook(
  marketId: string,
  params?: GetOrderbookParams,
  options?: UseQueryOptions<Orderbook>
)
```

**GetOrderbookParams:**
```typescript
{
  depth?: number           // Number of price levels
  outcomeIndex?: number    // 0 = YES, 1 = NO
}
```

**Example:**
```tsx
function Orderbook({ marketId }: { marketId: string }) {
  const { data } = useOrderbook(marketId, { depth: 10 })

  return (
    <div>
      <h4>Bids</h4>
      {data?.bids.map((level, i) => (
        <div key={i}>{level.price}c - {level.size} shares</div>
      ))}
      <h4>Asks</h4>
      {data?.asks.map((level, i) => (
        <div key={i}>{level.price}c - {level.size} shares</div>
      ))}
    </div>
  )
}
```

### useQuotes

Get current bid, ask, and last trade prices.

```typescript
useQuotes(
  marketId: string,
  options?: UseQueryOptions<Quotes>
)
```

**Quotes shape:**
```typescript
{
  yes: { bid: number; ask: number; last: number }
  no: { bid: number; ask: number; last: number }
}
```

**Example:**
```tsx
function PriceDisplay({ marketId }: { marketId: string }) {
  const { data: quotes } = useQuotes(marketId, {
    refetchInterval: 5000, // Poll every 5s
  })

  if (!quotes) return null

  return (
    <div>
      <span>YES: {quotes.yes.bid}/{quotes.yes.ask}</span>
      <span>NO: {quotes.no.bid}/{quotes.no.ask}</span>
    </div>
  )
}
```

### usePriceHistory

Fetch historical price data for charting.

```typescript
usePriceHistory(
  marketId: string,
  params?: GetPriceHistoryParams,
  options?: UseQueryOptions<PriceHistory>
)
```

**GetPriceHistoryParams:**
```typescript
{
  timeframe?: "1h" | "6h" | "1d" | "1w" | "1M" | "all"
}
```

**Example:**
```tsx
function PriceChart({ marketId }: { marketId: string }) {
  const { data } = usePriceHistory(marketId, { timeframe: '1w' })

  // data.points is an array of { timestamp, price } for charting
  return <Chart data={data?.points ?? []} />
}
```

### useMarketActivity

Get recent activity (trades, orders) for a market.

```typescript
useMarketActivity(
  marketId: string,
  params?: GetActivityParams,
  options?: UseQueryOptions<ActivityResponse>
)
```

**GetActivityParams:**
```typescript
{
  limit?: number
  offset?: number
}
```

### useSimulateTrade

Preview trade execution without placing an order. Returns expected fill price, slippage, and fees.

```typescript
useSimulateTrade(
  marketId: string,
  params: SimulateTradeParams,
  options?: UseQueryOptions<SimulateResult>
)
```

**SimulateTradeParams:**
```typescript
{
  side: "yes" | "no"
  amount: number           // Dollar amount or share count
}
```

**Example:**
```tsx
function TradePreview({ marketId }: { marketId: string }) {
  const [amount, setAmount] = useState(10)
  const { data: sim } = useSimulateTrade(marketId, {
    side: 'yes',
    amount,
  }, {
    enabled: amount > 0,
  })

  return (
    <div>
      <input type="number" value={amount} onChange={e => setAmount(+e.target.value)} />
      {sim && (
        <div>
          <p>Avg price: {sim.avgPrice}c</p>
          <p>Shares: {sim.shares}</p>
          <p>Fee: {sim.fee}</p>
        </div>
      )}
    </div>
  )
}
```

### useOracle

Get the AI oracle probability estimate for a market.

```typescript
useOracle(
  marketId: string,
  options?: UseQueryOptions<any>
)
```

**Example:**
```tsx
function OracleView({ marketId }: { marketId: string }) {
  const { data: oracle } = useOracle(marketId)
  const { data: quotes } = useQuotes(marketId)

  const divergence = oracle && quotes
    ? Math.abs(oracle.probability * 100 - quotes.yes.last)
    : 0

  return (
    <div>
      <p>Oracle: {oracle?.probability ? `${(oracle.probability * 100).toFixed(0)}%` : '...'}</p>
      <p>Market: {quotes?.yes.last}c</p>
      {divergence > 10 && <p>Significant divergence detected</p>}
    </div>
  )
}
```

## Order Hooks

### useOrders (query)

List orders with optional filters.

```typescript
useOrders(
  params?: GetOrdersParams,
  options?: UseQueryOptions<OrderList>
)
```

**GetOrdersParams:**
```typescript
{
  marketId?: string
  status?: string          // "open" | "filled" | "cancelled" | "void"
  limit?: number
  offset?: number
}
```

### useOrder (query)

Fetch a single order by ID.

```typescript
useOrder(
  orderId: string,
  options?: UseQueryOptions<Order>
)
```

### useCreateOrder (mutation)

Place a limit order. Requires wallet connection and account setup.

```typescript
useCreateOrder(
  options?: UseMutationOptions<CreateOrderResult, Error, PlaceOrderRequest>
)
```

**PlaceOrderRequest:**
```typescript
{
  marketId: string
  side: 0 | 1              // 0 = buy, 1 = sell
  outcomeIndex: 0 | 1      // 0 = YES, 1 = NO
  price: number             // Cents (1-99)
  size: number              // Shares
}
```

**Example:**
```tsx
function LimitOrderForm({ marketId }: { marketId: string }) {
  const { mutate: createOrder, isPending, error } = useCreateOrder({
    onSuccess: (result) => {
      console.log('Order placed:', result.orderId)
    },
  })

  const handleSubmit = (price: number, size: number) => {
    createOrder({
      marketId,
      side: 0,
      outcomeIndex: 0,
      price,
      size,
    })
  }

  return (
    <form onSubmit={e => { e.preventDefault(); handleSubmit(50, 10) }}>
      <button type="submit" disabled={isPending}>
        {isPending ? 'Placing...' : 'Buy 10 YES @ 50c'}
      </button>
      {error && <p>{error.message}</p>}
    </form>
  )
}
```

### useCreateMarketOrder (mutation)

Place a market order that fills immediately at the best available price.

```typescript
useCreateMarketOrder(
  options?: UseMutationOptions<CreateOrderResult, Error, PlaceMarketOrderRequest>
)
```

**PlaceMarketOrderRequest:**
```typescript
{
  marketId: string
  side: 0 | 1
  outcomeIndex: 0 | 1
  amount: number            // Dollar amount to spend
}
```

### useCancelOrder (mutation)

Cancel an open order by its nonce.

```typescript
useCancelOrder(
  options?: UseMutationOptions<CancelResult, Error, Hex>
)
```

**Example:**
```tsx
function CancelButton({ nonce }: { nonce: Hex }) {
  const { mutate: cancel, isPending } = useCancelOrder()

  return (
    <button onClick={() => cancel(nonce)} disabled={isPending}>
      {isPending ? 'Cancelling...' : 'Cancel'}
    </button>
  )
}
```

### useCancelReplace (mutation)

Atomically cancel an existing order and place a new one.

```typescript
useCancelReplace(
  options?: UseMutationOptions<CancelReplaceResult, Error, {
    cancelNonce: Hex
    newOrder: PlaceOrderRequest
  }>
)
```

## Portfolio Hooks

### usePortfolio (query)

Get positions for a wallet address. Defaults to the connected wallet.

```typescript
usePortfolio(
  address?: Address,
  params?: GetPortfolioParams,
  options?: UseQueryOptions<Portfolio>
)
```

**Example:**
```tsx
function Positions() {
  const { data } = usePortfolio()

  return (
    <div>
      {data?.positions.map(pos => (
        <div key={pos.marketId}>
          {pos.marketQuestion}: {pos.shares} {pos.outcome} shares
        </div>
      ))}
    </div>
  )
}
```

### useBalance (query)

Get USDC balance for a wallet address.

```typescript
useBalance(
  address?: Address,
  options?: UseQueryOptions<Balance>
)
```

### useClaimable (query)

Get claimable winnings from resolved markets.

```typescript
useClaimable(
  address?: Address,
  options?: UseQueryOptions<ClaimableResponse>
)
```

### usePortfolioStats (query)

Get profit and loss statistics.

```typescript
usePortfolioStats(
  address?: Address,
  options?: UseQueryOptions<PortfolioStats>
)
```

## Account Hooks

### useAccountStatus (query)

Check whether the connected wallet has a trading account set up.

```typescript
useAccountStatus(
  options?: UseQueryOptions<WalletStatus>
)
```

**WalletStatus:**
```typescript
{
  ready: boolean
  hasOperator: boolean
  hasDeposit: boolean
}
```

### useAccountSetup (mutation)

Set up a trading account for the connected wallet. This is a one-time operation.

```typescript
useAccountSetup(
  options?: UseMutationOptions<GaslessOperatorResult | WalletSetupResult, Error, void>
)
```

### useDeposit (mutation)

Deposit USDC into the trading account.

```typescript
useDeposit(
  options?: UseMutationOptions<GaslessDepositResult | Hex, Error, number>
)
```

The `number` argument is the USDC amount to deposit.

### useWithdraw (mutation)

Withdraw USDC from the trading account.

```typescript
useWithdraw(
  options?: UseMutationOptions<Hex, Error, number>
)
```

## Question Hooks

### useSubmitQuestion (mutation)

Submit a question for potential market creation.

```typescript
useSubmitQuestion(
  options?: UseMutationOptions<SubmitQuestionResult, Error, string>
)
```

### useSubmitAndWait (mutation)

Submit a question and poll until it is approved or rejected.

```typescript
useSubmitAndWait(
  options?: UseMutationOptions<QuestionSubmission, Error, SubmitAndWaitInput>
)
```

### useCreateMarket (mutation)

Create a market from an approved question.

```typescript
useCreateMarket(
  options?: UseMutationOptions<CreateMarketResult, Error, string>
)
```

## Utility

### contextKeys

Query key factory for TanStack Query cache operations. Use these to invalidate or prefetch specific data.

```typescript
contextKeys.markets.list(params?)     // Key for useMarkets
contextKeys.markets.detail(id)        // Key for useMarket
contextKeys.markets.orderbook(id)     // Key for useOrderbook
contextKeys.markets.quotes(id)        // Key for useQuotes
contextKeys.markets.priceHistory(id)  // Key for usePriceHistory
contextKeys.markets.activity(id)      // Key for useMarketActivity
contextKeys.markets.oracle(id)        // Key for useOracle
contextKeys.orders.list(params?)      // Key for useOrders
contextKeys.orders.detail(id)         // Key for useOrder
contextKeys.portfolio.positions(addr) // Key for usePortfolio
contextKeys.portfolio.balance(addr)   // Key for useBalance
contextKeys.portfolio.stats(addr)     // Key for usePortfolioStats
```

### useContextClient

Access the raw SDK client for advanced use cases not covered by hooks.

```typescript
const client = useContextClient()
// client is the Context SDK instance
```
