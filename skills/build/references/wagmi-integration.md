# Wagmi Integration

Wallet connection and account setup patterns for Context Markets.

## Wagmi Config

Context Markets supports Base mainnet and Base Sepolia. Pair your wagmi chain config with the `ContextProvider` `chain` prop:

- Base mainnet: wagmi `base`, `ContextProvider` default (`chain` omitted)
- Base Sepolia: wagmi `baseSepolia`, `ContextProvider chain="testnet"`

```typescript
import { createConfig, http } from 'wagmi'
import { base, baseSepolia } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

export const mainnetConfig = createConfig({
  chains: [base],
  connectors: [
    injected(),
    walletConnect({ projectId: 'YOUR_WALLETCONNECT_PROJECT_ID' }),
  ],
  transports: {
    [base.id]: http(),
  },
})

export const testnetConfig = createConfig({
  chains: [baseSepolia],
  connectors: [
    injected(),
    walletConnect({ projectId: 'YOUR_WALLETCONNECT_PROJECT_ID' }),
  ],
  transports: {
    [baseSepolia.id]: http(),
  },
})
```

To use a custom RPC endpoint:

```typescript
transports: {
  [base.id]: http('https://your-mainnet-rpc.com'),
  [baseSepolia.id]: http('https://your-testnet-rpc.com'),
}
```

## Wallet Connection

Use wagmi's `useConnect` and `useDisconnect` hooks to manage wallet state.

```tsx
import { useAccount, useConnect, useDisconnect } from 'wagmi'

function WalletButton() {
  const { address, isConnected } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div>
        <span>{address?.slice(0, 6)}...{address?.slice(-4)}</span>
        <button onClick={() => disconnect()}>Disconnect</button>
      </div>
    )
  }

  return (
    <div>
      {connectors.map(connector => (
        <button key={connector.id} onClick={() => connect({ connector })}>
          {connector.name}
        </button>
      ))}
    </div>
  )
}
```

## Account Setup Flow

Before a wallet can trade on Context Markets, it needs a one-time account setup. The full flow:

1. **Connect wallet** via wagmi
2. **Check status** with `useAccountStatus`
3. **Setup** with `useAccountSetup` if not ready
4. **Deposit** with `useDeposit` to fund the account

```tsx
import { useAccount } from 'wagmi'
import { useAccountStatus, useAccountSetup, useDeposit, useBalance } from 'context-markets-react'

function OnboardingFlow() {
  const { isConnected } = useAccount()
  const { data: status, isLoading: statusLoading } = useAccountStatus()
  const { mutate: setup, isPending: settingUp } = useAccountSetup()
  const { mutate: deposit, isPending: depositing } = useDeposit()
  const { data: balance } = useBalance()

  // Step 1: Not connected
  if (!isConnected) {
    return <WalletButton />
  }

  // Step 2: Loading status
  if (statusLoading) {
    return <p>Checking account...</p>
  }

  // Step 3: Account not set up
  if (!status?.isReady) {
    return (
      <button onClick={() => setup()} disabled={settingUp}>
        {settingUp ? 'Setting up...' : 'Set Up Trading Account'}
      </button>
    )
  }

  // Step 4: No balance
  if (balance && balance.usdc.balance === '0') {
    return (
      <button onClick={() => deposit(100)} disabled={depositing}>
        {depositing ? 'Depositing...' : 'Deposit 100 USDC'}
      </button>
    )
  }

  // Ready to trade
  return <p>Account ready. Wallet balance: {balance?.usdc.walletBalance} USDC</p>
}
```

## Error Handling

Wallet interactions can fail for several reasons. Handle them gracefully:

```tsx
import { useConnect } from 'wagmi'

function ConnectWithErrors() {
  const { connect, connectors, error } = useConnect()

  return (
    <div>
      {connectors.map(connector => (
        <button key={connector.id} onClick={() => connect({ connector })}>
          {connector.name}
        </button>
      ))}
      {error && <p>Connection failed: {error.message}</p>}
    </div>
  )
}
```

Common error scenarios:

- **User rejected** -- User declined the connection or transaction in their wallet.
- **Wrong chain** -- Wallet is on a different chain. Use wagmi's `useSwitchChain` to prompt switching.
- **Insufficient funds** -- Not enough USDC for a deposit or trade.

### Chain Switching

```tsx
import { useAccount, useSwitchChain } from 'wagmi'
import { base } from 'wagmi/chains'

function ChainGuard({ children }: { children: React.ReactNode }) {
  const { chainId } = useAccount()
  const { switchChain } = useSwitchChain()

  if (chainId !== base.id) {
    return (
      <div>
        <p>Please switch to Base</p>
        <button onClick={() => switchChain({ chainId: base.id })}>
          Switch Network
        </button>
      </div>
    )
  }

  return <>{children}</>
}
```

## Combining Wagmi and Context Hooks

A typical trading component uses wagmi for wallet state and Context hooks for market data and order placement:

```tsx
import { useAccount } from 'wagmi'
import {
  useMarket,
  useQuotes,
  useBalance,
  useCreateOrder,
  useAccountStatus,
} from 'context-markets-react'

function TradingPanel({ marketId }: { marketId: string }) {
  const { isConnected } = useAccount()
  const { data: status } = useAccountStatus()
  const { data: market } = useMarket(marketId)
  const { data: quotes } = useQuotes(marketId, { refetchInterval: 5000 })
  const { data: balance } = useBalance()
  const { mutate: createOrder, isPending } = useCreateOrder()

  if (!isConnected) return <WalletButton />
  if (!status?.isReady) return <OnboardingFlow />
  if (!market || !quotes) return <p>Loading market...</p>

  return (
    <div>
      <h2>{market.question}</h2>
      <p>YES: {quotes.yes.bid}/{quotes.yes.ask}</p>
      <p>Balance: {balance?.usdc.walletBalance} USDC</p>
      <button
        disabled={isPending}
        onClick={() => createOrder({
          marketId,
          outcome: 'yes',
          side: 'buy',
          priceCents: quotes.yes.ask ?? 50,
          size: 10,
        })}
      >
        Buy 10 YES
      </button>
    </div>
  )
}
```
