---
name: context-build-market-widget
description: Build an embeddable single-market prediction widget with buy/sell buttons
---

# Market Widget

Build a self-contained, embeddable component that shows a single market with price, oracle estimate, and one-click trading.

## When to Use

The user wants to embed a prediction market into an existing page — a compact component showing price, oracle, and a buy button.

## Steps

1. **Self-contained provider wrapper** — if embedding outside a Context app, the widget needs its own provider stack:
   ```tsx
   function MarketWidget({ marketId, apiKey }: { marketId: string; apiKey: string }) {
     return (
       <WagmiProvider config={wagmiConfig}>
         <QueryClientProvider client={queryClient}>
           <ContextProvider apiKey={apiKey}>
             <WidgetContent marketId={marketId} />
           </ContextProvider>
         </QueryClientProvider>
       </WagmiProvider>
     )
   }
   ```

2. **Market display** — `useMarket(marketId)` for question text, `useQuotes(marketId)` for current prices.

3. **Oracle badge** — `useOracle(marketId)` to show the oracle's probability alongside the market price. Highlight divergence.

4. **Trade preview** — `useSimulateTrade(marketId, params)` to show estimated fill as the user adjusts the amount slider.

5. **One-click trade** — `useCreateMarketOrder()` for instant execution at market price. Show the simulation result before confirming.

6. **Balance display** — `useBalance()` to show available funds. Disable buy button if insufficient.

## Gotchas

- **Widget needs its own providers if embedded externally.** If the host app already has wagmi/QueryClient providers, you can share them — but `ContextProvider` is always required.
- **API key must be publishable.** The `apiKey` in `ContextProvider` is sent to the browser. Use a read-only key if the widget is public.
- **Wallet connection required for trading.** The widget can be read-only (show prices) without a wallet, but trading needs `useAccount()` from wagmi.
- **Keep it compact.** A widget shouldn't fetch the full orderbook — `useQuotes` is enough for display. Only fetch `useOrderbook` if showing depth.
- **Handle loading and error states.** All hooks return `isLoading` and `error` — show appropriate UI for each.

## Verification

- Widget renders market question and current YES/NO prices.
- Oracle estimate displays alongside market price.
- Simulation preview updates as user changes amount.
- Trade executes and balance updates on success.

## See Also

- [Provider Setup](../references/provider-setup.md) — ContextProvider props, minimal setup
- [React Hooks API](../references/react-hooks.md) — useMarket, useQuotes, useSimulateTrade signatures
