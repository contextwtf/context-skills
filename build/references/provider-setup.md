# Provider Setup

## Provider Hierarchy

Context apps require three nested providers in this exact order:

```
WagmiProvider          -- Wallet connections (outermost)
  QueryClientProvider  -- Data fetching and caching
    ContextProvider    -- Context SDK hooks (innermost)
```

Placing them out of order will cause runtime errors. `ContextProvider` depends on both wagmi and TanStack Query being available above it in the tree.

## Full Setup

```tsx
import { ContextProvider } from 'context-markets-react'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'
import { injected, walletConnect } from 'wagmi/connectors'

// 1. Configure wagmi for Base Sepolia
const wagmiConfig = createConfig({
  chains: [baseSepolia],
  connectors: [
    injected(),
    walletConnect({ projectId: 'YOUR_WALLETCONNECT_PROJECT_ID' }),
  ],
  transports: {
    [baseSepolia.id]: http(),
  },
})

// 2. Create a QueryClient
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 10_000,       // 10 seconds before data is considered stale
      refetchOnWindowFocus: false,
    },
  },
})

// 3. Assemble the provider tree
function App({ children }: { children: React.ReactNode }) {
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

## Chain Configuration

Context Markets operates on **Base Sepolia** (chain ID `84532`). All wagmi configs must include this chain.

```typescript
import { baseSepolia } from 'wagmi/chains'

// baseSepolia.id === 84532
```

The settlement contract address is `0xD91935a82Af48ff79a68134d9Eab8fc9e5d3504D`. You do not need to reference this directly -- the SDK handles it.

## ContextProvider Props

`ContextProvider` accepts optional configuration:

```tsx
<ContextProvider
  apiKey="optional-api-key"       // Only needed for authenticated endpoints
  privateKey="0x..."              // Only needed for order signing
>
  {children}
</ContextProvider>
```

For read-only apps (dashboards, market browsers), no props are needed. For trading apps, provide `apiKey` and `privateKey` or let the SDK derive them from the connected wallet.

## Minimal Read-Only Setup

If you only need market data (no wallet, no trading):

```tsx
import { ContextProvider } from 'context-markets-react'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'

const config = createConfig({
  chains: [baseSepolia],
  transports: { [baseSepolia.id]: http() },
})

const queryClient = new QueryClient()

function App({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <ContextProvider>
          {children}
        </ContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

This setup supports all query hooks (`useMarkets`, `useQuotes`, etc.) but not mutation hooks that require a wallet.

## Next.js Setup

For Next.js apps, mark the provider component as a client component:

```tsx
'use client'

import { ContextProvider } from 'context-markets-react'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'

const wagmiConfig = createConfig({
  chains: [baseSepolia],
  transports: { [baseSepolia.id]: http() },
})

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
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

Then use it in your root layout:

```tsx
import { Providers } from './providers'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```
