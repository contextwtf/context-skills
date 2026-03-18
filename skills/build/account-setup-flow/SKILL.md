---
name: context-build-account-setup-flow
description: Build the wallet connect → approve → deposit → ready-to-trade UI flow
---

# Account Setup Flow

Build the onboarding flow that takes a user from wallet connection to ready-to-trade: connect wallet, approve contracts, deposit USDC.

## When to Use

The user wants to build the account setup UI — the first thing a new user sees before they can trade.

## Steps

1. **Wallet connection** — use wagmi's `useConnect()` and `useAccount()`:
   ```tsx
   const { connect, connectors } = useConnect()
   const { address, isConnected } = useAccount()
   ```

2. **Check account status** — `useAccountStatus()` returns whether approvals and deposits are needed:
   ```tsx
   const { data: status } = useAccountStatus()
   // status.isReady — true if account is fully set up
   // status.needsUsdcApproval — needs USDC spend approval
   // status.needsOperatorApproval — needs operator approval
   ```

3. **One-click setup** — `useAccountSetup()` handles both approvals in one call:
   ```tsx
   const { mutate: setup, isPending } = useAccountSetup()
   // On testnet: gasless (no ETH needed)
   // On mainnet: on-chain transactions (requires ETH for gas)
   ```

4. **Granular approvals** (optional) — for UIs that want separate steps:
   - `useApproveUsdc()` — approve USDC spending
   - `useApproveOperator()` — approve the settlement contract as operator

5. **Deposit USDC** — `useDeposit()` to fund the trading account:
   ```tsx
   const { mutate: deposit } = useDeposit()
   deposit(100)  // deposit 100 USDC
   ```

6. **Show ready state** — once `status.isReady` is true and balance > 0, the user can trade.

## Gotchas

- **Testnet auto-uses gasless setup.** On testnet, `useAccountSetup` uses signature-based approvals (no ETH needed). On mainnet, it sends on-chain transactions requiring ETH for gas.
- **`useApproveUsdc` and `useApproveOperator` for granular control.** Use these if your UI wants separate approval steps with progress indicators. `useAccountSetup` combines both.
- **Chain must be correct.** If the user is on the wrong chain, wallet operations will fail. Use wagmi's `useSwitchChain()` to prompt switching to Base (mainnet) or Base Sepolia (testnet).
- **Handle `ContextWalletError`.** Import from `context-markets-react` — it covers user rejection, wrong chain, and insufficient funds with structured error types.
- **Deposit requires prior approval.** If the user hasn't run setup/approve first, deposit will fail. Check `status.isReady` or `status.needsUsdcApproval` before showing the deposit button.

## Verification

- Wallet connects and address displays.
- Account status correctly shows what's needed (approvals, deposit).
- Setup completes without errors (testnet: instant, mainnet: waits for tx).
- After deposit, balance shows in `useBalance()` and `status.isReady` is true.

## See Also

- [Wagmi Integration](../references/wagmi-integration.md) — Wallet connection, chain switching, error handling
- [Provider Setup](../references/provider-setup.md) — ContextProvider configuration
