# Provider Setup

## Provider Hierarchy

Context apps require these providers in this order:

```txt
WagmiProvider
  QueryClientProvider
    ContextProvider
```

`ContextProvider` depends on both wagmi and TanStack Query being available above it.

## Full Setup

### Mainnet (Base, default)

```tsx
import { ContextProvider } from 'context-markets-react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { base } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

const wagmiConfig = createConfig({
  chains: [base],
  connectors: [
    injected(),
    walletConnect({ projectId: 'YOUR_WALLETCONNECT_PROJECT_ID' }),
  ],
  transports: {
    [base.id]: http(),
  },
})

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

### Testnet (Base Sepolia)

```tsx
import { ContextProvider } from 'context-markets-react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'

const wagmiConfig = createConfig({
  chains: [baseSepolia],
  transports: {
    [baseSepolia.id]: http(),
  },
})

const queryClient = new QueryClient()

function App({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <ContextProvider
          apiKey={process.env.NEXT_PUBLIC_CONTEXT_API_KEY!}
          chain="testnet"
        >
          {children}
        </ContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

## Chain Configuration

- Mainnet uses Base and is the SDK default.
- Testnet uses Base Sepolia and should be paired with `chain="testnet"` on `ContextProvider`.
- You do not pass a `privateKey` prop to `ContextProvider`. Trading credentials come from the connected wagmi wallet, or from direct SDK usage outside React.

## ContextProvider Props

`ContextProvider` accepts:

```tsx
<ContextProvider
  apiKey={process.env.NEXT_PUBLIC_CONTEXT_API_KEY!}
  chain="testnet"       // optional, defaults to "mainnet"
  rpcUrl="https://..."
  baseUrl="https://..."
>
  {children}
</ContextProvider>
```

- `apiKey` is required.
- `chain`, `rpcUrl`, and `baseUrl` are optional overrides.
- There is no `privateKey` prop.

## Minimal Read-Only Setup

```tsx
import { ContextProvider } from 'context-markets-react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { base } from 'wagmi/chains'

const wagmiConfig = createConfig({
  chains: [base],
  transports: { [base.id]: http() },
})

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

## Next.js Setup

```tsx
'use client'

import { ContextProvider } from 'context-markets-react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { base } from 'wagmi/chains'

const wagmiConfig = createConfig({
  chains: [base],
  transports: { [base.id]: http() },
})

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
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
