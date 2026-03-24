# React Hooks API Reference

Complete hook signatures for `context-markets-react`. Query hooks return TanStack Query results such as `{ data, isLoading, error, refetch }`. Mutation hooks return `{ mutate, mutateAsync, isPending, error }`.

## Market Hooks

### useMarkets

```ts
useMarkets(
  params?: SearchMarketsParams,
  options?: UseQueryOptions<MarketList>
)
```

**SearchMarketsParams:**

```ts
{
  query?: string
  status?: "active" | "pending" | "resolved" | "closed"
  sortBy?: "new" | "volume" | "trending" | "ending" | "chance"
  sort?: "asc" | "desc"
  limit?: number
  cursor?: string
  visibility?: "visible" | "hidden" | "all"
  resolutionStatus?: string
  creator?: string
  category?: string
  createdAfter?: string
}
```

### useMarket

```ts
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
      <p>Categories: {market.metadata.categories?.join(', ') ?? 'None'}</p>
      <p>Status: {market.status}</p>
      <p>Deadline: {market.deadline}</p>
    </div>
  )
}
```

### useOrderbook

```ts
useOrderbook(
  marketId: string,
  params?: GetOrderbookParams,
  options?: UseQueryOptions<Orderbook>
)
```

**GetOrderbookParams:**

```ts
{
  depth?: number
  outcomeIndex?: number    // 0 = NO, 1 = YES
}
```

### useQuotes

```ts
useQuotes(
  marketId: string,
  options?: UseQueryOptions<Quotes>
)
```

**Quotes shape:**

```ts
{
  yes: { bid: number | null; ask: number | null; last: number | null }
  no: { bid: number | null; ask: number | null; last: number | null }
  spread: number | null
  timestamp: string
}
```

### usePriceHistory

```ts
usePriceHistory(
  marketId: string,
  params?: GetPriceHistoryParams,
  options?: UseQueryOptions<PriceHistory>
)
```

**GetPriceHistoryParams:**

```ts
{
  timeframe?: "1h" | "6h" | "1d" | "1w" | "1M" | "all"
}
```

**Example:**

```tsx
function PriceChart({ marketId }: { marketId: string }) {
  const { data } = usePriceHistory(marketId, { timeframe: '1w' })
  return <Chart data={data?.prices ?? []} />
}
```

### useMarketActivity

```ts
useMarketActivity(
  marketId: string,
  params?: GetActivityParams,
  options?: UseQueryOptions<ActivityResponse>
)
```

**GetActivityParams:**

```ts
{
  cursor?: string
  limit?: number
  types?: string
  startTime?: string
  endTime?: string
}
```

### useSimulateTrade

```ts
useSimulateTrade(
  marketId: string,
  params: SimulateTradeParams,
  options?: UseQueryOptions<SimulateResult>
)
```

**SimulateTradeParams:**

```ts
{
  side: "yes" | "no"
  amount: number
  amountType?: "usd" | "contracts"
  trader?: string
}
```

**Example:**

```tsx
function TradePreview({ marketId }: { marketId: string }) {
  const [amount, setAmount] = useState(10)
  const { data: sim } = useSimulateTrade(
    marketId,
    { side: 'yes', amount, amountType: 'usd' },
    { enabled: amount > 0 }
  )

  return (
    <div>
      <input type="number" value={amount} onChange={e => setAmount(+e.target.value)} />
      {sim && (
        <div>
          <p>Avg price: {sim.estimatedAvgPrice}c</p>
          <p>Contracts: {sim.estimatedContracts}</p>
          <p>Slippage: {sim.estimatedSlippage}%</p>
        </div>
      )}
    </div>
  )
}
```

### useOracle

Returns the oracle summary and evidence payload, not a numeric quote.

```ts
useOracle(
  marketId: string,
  options?: UseQueryOptions<OracleResponse>
)
```

**Example:**

```tsx
function OracleSummary({ marketId }: { marketId: string }) {
  const { data: oracle } = useOracle(marketId)

  return (
    <div>
      <p>Decision: {oracle?.oracle?.summary.shortSummary ?? 'No oracle summary yet'}</p>
      <p>Confidence: {oracle?.oracle?.confidenceLevel ?? 'unknown'}</p>
    </div>
  )
}
```

### useLatestOracleQuote

Returns the latest numeric oracle quote.

```ts
useLatestOracleQuote(
  marketId: string,
  options?: UseQueryOptions<OracleQuoteLatest>
)
```

**Example:**

```tsx
function OracleQuoteBadge({ marketId }: { marketId: string }) {
  const { data: latest } = useLatestOracleQuote(marketId)
  return <span>{latest?.quote.probability ?? '...'}%</span>
}
```

## Order Hooks

### useOrders

```ts
useOrders(
  params?: GetOrdersParams,
  options?: UseQueryOptions<OrderList>
)
```

**GetOrdersParams:**

```ts
{
  trader?: Address
  marketId?: string
  status?: "open" | "filled" | "cancelled" | "expired" | "voided"
  cursor?: string
  limit?: number
}
```

### useOrder

```ts
useOrder(
  orderId: string,
  options?: UseQueryOptions<Order>
)
```

### useCreateOrder

```ts
useCreateOrder(
  options?: UseMutationOptions<CreateOrderResult, Error, PlaceOrderRequest>
)
```

**PlaceOrderRequest:**

```ts
{
  marketId: string
  outcome: "yes" | "no"
  side: "buy" | "sell"
  priceCents: number
  size: number
  expirySeconds?: number
  inventoryModeConstraint?: 0 | 1 | 2
  makerRoleConstraint?: 0 | 1 | 2
}
```

**Example:**

```tsx
function LimitOrderForm({ marketId }: { marketId: string }) {
  const { mutate: createOrder, isPending, error } = useCreateOrder({
    onSuccess: (result) => {
      console.log('Order placed:', result.order.nonce)
    },
  })

  return (
    <button
      disabled={isPending}
      onClick={() =>
        createOrder({
          marketId,
          outcome: 'yes',
          side: 'buy',
          priceCents: 50,
          size: 10,
        })
      }
    >
      Buy 10 YES @ 50c
      {error ? ` (${error.message})` : ''}
    </button>
  )
}
```

### useCreateMarketOrder

```ts
useCreateMarketOrder(
  options?: UseMutationOptions<CreateOrderResult, Error, PlaceMarketOrderRequest>
)
```

**PlaceMarketOrderRequest:**

```ts
{
  marketId: string
  outcome: "yes" | "no"
  side: "buy" | "sell"
  maxPriceCents: number
  maxSize: number
  expirySeconds?: number
}
```

### useCancelOrder

```ts
useCancelOrder(
  options?: UseMutationOptions<CancelResult, Error, Hex>
)
```

### useCancelReplace

```ts
useCancelReplace(
  options?: UseMutationOptions<
    CancelReplaceResult,
    Error,
    { cancelNonce: Hex; newOrder: PlaceOrderRequest }
  >
)
```

## Portfolio Hooks

### usePortfolio

```ts
usePortfolio(
  address?: Address,
  params?: GetPortfolioParams,
  options?: UseQueryOptions<Portfolio>
)
```

**Example:**

```tsx
function Positions() {
  const { data } = usePortfolio(undefined, { kind: 'active' })

  return (
    <div>
      {data?.portfolio.map(pos => (
        <div key={`${pos.marketId}-${pos.outcomeIndex}`}>
          {pos.marketId}: {pos.balance}
        </div>
      ))}
    </div>
  )
}
```

### useBalance

```ts
useBalance(
  address?: Address,
  options?: UseQueryOptions<Balance>
)
```

### useClaimable

```ts
useClaimable(
  address?: Address,
  options?: UseQueryOptions<ClaimableResponse>
)
```

### usePortfolioStats

```ts
usePortfolioStats(
  address?: Address,
  options?: UseQueryOptions<PortfolioStats>
)
```

### usePositions

```ts
usePositions(
  address?: Address,
  params?: GetPositionsParams,
  options?: UseQueryOptions<PositionList>
)
```

## Account Hooks

### useAccountStatus

```ts
useAccountStatus(
  options?: UseQueryOptions<AccountStatus>
)
```

**AccountStatus:**

```ts
{
  address: Address
  ethBalance: bigint
  usdcBalance: bigint
  usdcAllowance: bigint
  isOperatorApproved: boolean
  needsUsdcApproval: boolean
  needsOperatorApproval: boolean
  isReady: boolean
}
```

### useAccountSetup

```ts
useAccountSetup(
  options?: UseMutationOptions<SetupResult, Error, void>
)
```

### useDeposit

```ts
useDeposit(
  options?: UseMutationOptions<DepositResult, Error, number>
)
```

### useWithdraw

```ts
useWithdraw(
  options?: UseMutationOptions<Hex, Error, number>
)
```

## Question Hooks

### useSubmitQuestion

```ts
useSubmitQuestion(
  options?: UseMutationOptions<SubmitQuestionResult, Error, string>
)
```

### useSubmitAndWait

```ts
useSubmitAndWait(
  options?: UseMutationOptions<QuestionSubmission, Error, SubmitAndWaitInput>
)
```

### useCreateMarket

```ts
useCreateMarket(
  options?: UseMutationOptions<CreateMarketResult, Error, string>
)
```

## Utility

### contextKeys

```ts
contextKeys.markets.list(params?)             // useMarkets
contextKeys.markets.get(id)                   // useMarket
contextKeys.markets.orderbook(id, params?)    // useOrderbook
contextKeys.markets.quotes(id)                // useQuotes
contextKeys.markets.priceHistory(id, params?) // usePriceHistory
contextKeys.markets.activity(id, params?)     // useMarketActivity
contextKeys.markets.oracle(id)                // useOracle
contextKeys.markets.latestOracleQuote(id)     // useLatestOracleQuote
contextKeys.orders.list(address?, params?)     // useOrders
contextKeys.orders.get(address?, id?)          // useOrder
contextKeys.portfolio.get(addr, params?)      // usePortfolio
contextKeys.portfolio.positions(addr, params?)// usePositions
contextKeys.portfolio.balance(addr)           // useBalance
contextKeys.portfolio.stats(addr)             // usePortfolioStats
```

### useContextClient

```ts
const client = useContextClient()
```
