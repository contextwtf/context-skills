# Skill Package Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the Context Skills package from flat API reference docs into workflow-level subskills with gotchas, progressive disclosure, and corrected content verified against live source code.

**Architecture:** Each of 4 categories (trade, build, research, create) gets a router SKILL.md with shared foundations + individual subskill SKILL.md files for each workflow. References stay shared at category level. All prompt variants eliminated. Trade is the reference implementation — the other 3 follow its pattern.

**Tech Stack:** Pure markdown. No code dependencies. Content verified against live SDK/MCP/CLI/React source code from GitHub repos.

**Spec:** `docs/superpowers/specs/2026-03-18-skill-reorganization-design.md`

**Live source repos (fetch via `gh api` for verification):**
- SDK: `contextwtf/context-sdk` — TypeScript client, order types, account module
- MCP: `contextwtf/context-mcp` — 17 MCP tools with Zod schemas
- CLI: `contextwtf/context-cli` — CLI commands with help text
- React: `contextwtf/context-react` — React hooks, provider, query keys

**Content guidelines:**
- Subskills should be 50-100 lines. Routers under 150 lines. References can be longer.
- Tasks 10-12 (research, build, create) should match the content depth of Tasks 4-8 (trade subskills): 3+ interface paths (MCP/SDK/CLI), 4+ specific gotchas, explicit verification steps.
- Each task is a separate commit — use `git revert <hash>` to undo individual tasks if needed.
- `docs/superpowers/` and `.context/` directories are intentionally retained and out of scope for this plan.

---

### Task 1: Delete prompt variants and install.sh

**Files:**
- Delete: `trade/prompts/claude.system.md`
- Delete: `trade/prompts/openai.developer.md`
- Delete: `trade/prompts/full.md`
- Delete: `research/prompts/claude.system.md`
- Delete: `research/prompts/openai.developer.md`
- Delete: `research/prompts/full.md`
- Delete: `build/prompts/claude.system.md`
- Delete: `build/prompts/openai.developer.md`
- Delete: `build/prompts/full.md`
- Delete: `create/prompts/claude.system.md`
- Delete: `create/prompts/openai.developer.md`
- Delete: `create/prompts/full.md`
- Delete: `install.sh`

- [ ] **Step 1: Delete all prompts/ directories and install.sh**

```bash
rm -rf trade/prompts research/prompts build/prompts create/prompts
rm install.sh
```

- [ ] **Step 2: Verify no remaining prompts/ or install.sh**

```bash
find . -name "prompts" -type d
find . -name "install.sh"
```
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: delete prompt variants and install.sh

Prompt variants (claude.system.md, openai.developer.md, full.md) are
maintenance overhead with no meaningful value. Single SKILL.md per
skill, onboarding guides handle platform-specific loading."
```

---

### Task 2: Write trade/SKILL.md router with shared foundations

This is the reference implementation — all other categories will follow this pattern.

**Files:**
- Rewrite: `trade/SKILL.md`

**Source verification:** Before writing, fetch the live SDK types and MCP tool schemas:
```bash
gh api repos/contextwtf/context-sdk/contents/src/types.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-mcp/contents/src/tools/orders.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-mcp/contents/src/tools/account.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-mcp/contents/src/tools/portfolio.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-cli/contents/src/commands/orders.ts --jq '.content' | base64 -d
```

- [ ] **Step 1: Write trade/SKILL.md**

The router must include:

**Frontmatter:** `name: context-trade`, `description: Place and manage prediction market orders on Context Markets`

**Prerequisites:** MCP server, API key, private key. Account must be set up (`ctx.account.setup()` or `context_account_setup`) and funded before trading.

**Shared Foundations (content every subskill needs):**
- Price encoding: cents (1-99), on-chain = price × 10,000
- Size encoding: contracts (min 0.01), on-chain = size × 1,000,000
- SDK constructor: `new ContextClient({ chain?: "mainnet" | "testnet", apiKey, signer: { privateKey } })`
- SDK vs MCP `side` mismatch: SDK uses `outcome: "yes"|"no"` + `side: "buy"|"sell"`. MCP uses `side: "yes"|"no"` and always buys. Selling requires SDK or CLI.
- Account setup: `ctx.account.setup()` is chain-aware (gasless on testnet, on-chain on mainnet). Must run before first trade.
- MCP tool catalog: all 17 tools listed with auth requirements (copy from spec)
- CLI command catalog: `context orders create|market|cancel|cancel-replace|bulk-create|bulk-cancel|bulk`

**Routing table:** Links to all 5 subskills with "when to use" descriptions.

**References section:** Links to all 4 reference files.

- [ ] **Step 2: Verify structure matches spec template**

Check: has frontmatter, Prerequisites, Shared Foundations (encoding, constructor, MCP tools, CLI commands, SDK vs MCP mismatch), Available Workflows table, References section. No detailed method signatures or type definitions (those go in references). Keep focused — router should orient the agent, not replicate the references.

- [ ] **Step 3: Commit**

```bash
git add trade/SKILL.md
git commit -m "feat(trade): rewrite SKILL.md as router with shared foundations"
```

---

### Task 3: Update trade/references/ with corrected content

**Files:**
- Rewrite: `trade/references/orders.md`
- Rewrite: `trade/references/signing.md`
- Rewrite: `trade/references/order-lifecycle.md`
- Rewrite: `trade/references/bulk-operations.md`

**Source verification:** Fetch live SDK types for all order-related interfaces:
```bash
gh api repos/contextwtf/context-sdk/contents/src/types.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/modules/orders.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/signing/eip712.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/order-builder/helpers.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/order-builder/builder.ts --jq '.content' | base64 -d
```

- [ ] **Step 1: Rewrite orders.md**

Must include (verified from source):
- `PlaceOrderRequest`: `{ marketId, outcome: "yes"|"no", side: "buy"|"sell", priceCents: number, size: number, expirySeconds?, inventoryModeConstraint?: 0|1|2, makerRoleConstraint?: 0|1|2 }`
- `PlaceMarketOrderRequest`: `{ marketId, outcome: "yes"|"no", side: "buy"|"sell", maxPriceCents, maxSize, expirySeconds? }`
- `CreateOrderResult`, `CancelResult`, `CancelReplaceResult`, `BulkResult` — return types
- All methods: `create`, `createMarket`, `cancel`, `cancelReplace`, `bulkCreate`, `bulkCancel`, `bulk`, `list`, `listAll`, `mine`, `allMine`, `get`, `recent`, `simulate`
- `OrderStatus`: `"open" | "filled" | "cancelled" | "expired" | "voided"`
- `GetOrdersParams`, `GetRecentOrdersParams` — with cursor-based pagination

- [ ] **Step 2: Rewrite signing.md**

Must include:
- EIP-712 domain (with note: chain-specific, resolved via `settlementDomain(chainConfig)`)
- Signed types: Order, MarketOrderIntent, CancelNonce
- Encoding functions: `encodePriceCents`, `encodeSize`, `calculateMaxFee`, `decodePriceCents`, `decodeSize`
- Constraints: `MakerRoleConstraint` (0=ANY, 1=MAKER_ONLY **DANGEROUS**, 2=TAKER_ONLY), `InventoryMode` (0=ANY, 1=REQUIRE_INVENTORY, 2=REQUIRE_NO_INVENTORY)
- Note: SDK handles signing automatically — this reference is for understanding, not manual signing

- [ ] **Step 3: Rewrite order-lifecycle.md**

Must include:
- State machine: open → filled | cancelled | expired | voided (note: `partially_filled` is not a status — partial fills are tracked via fill count on an `open` order)
- Void reasons (from source): insufficient_balance, self_trade_prevention, market_closed, invalid_price, invalid_signature, nonce_already_used, market_not_found, inventory_constraint
- Fill tracking: how partial fills work
- Expiry: expirySeconds param, 0 = no expiry

- [ ] **Step 4: Rewrite bulk-operations.md**

Must include:
- `bulkCreate(orders[])` — max 50 per batch
- `bulkCancel(nonces[])` — max 50 per batch
- `bulk(creates[], cancelNonces[])` — mixed, cancels execute before creates
- Code examples for each
- Gotcha: one bad order can fail the batch

- [ ] **Step 5: Commit**

```bash
git add trade/references/
git commit -m "feat(trade): rewrite reference files with corrected types from source"
```

---

### Task 4: Create trade subskill — place-order

**Files:**
- Create: `trade/place-order/SKILL.md`

- [ ] **Step 1: Create directory and write SKILL.md**

```bash
mkdir -p trade/place-order
```

Content must include:
- **Frontmatter:** `name: context-trade-place-order`, `description: Place a single limit or market order on a prediction market`
- **When to Use:** User wants to buy or sell shares on a specific market
- **Steps:** (1) Get quotes to see current prices, (2) Simulate to preview fill, (3) Place order via MCP/SDK/CLI, (4) Verify order is open
- **MCP path:** `context_get_quotes` → `context_simulate_trade` → `context_place_order` → `context_my_orders`
- **SDK path:** `ctx.markets.quotes()` → `ctx.markets.simulate()` → `ctx.orders.create()` or `ctx.orders.createMarket()` → `ctx.orders.mine()`
- **CLI path:** `context markets quotes <id>` → `context markets simulate <id>` → `context orders create --market <id> --outcome yes --side buy --price 45 --size 10`
- **Gotchas:**
  - MCP `side` means outcome (yes/no), always buys. To sell, use SDK or CLI.
  - Account must be set up and funded first — check with `context_account_setup` or `ctx.account.status()`
  - Price must be 1-99 cents. Price of 0 or 100 is invalid.
  - Simulation doesn't guarantee fill price — orderbook can change between simulate and place.
  - Market orders use `maxPriceCents` and `maxSize` — not `priceCents` and `size`.
  - NEVER set `makerRoleConstraint: 1` (MAKER_ONLY) — causes reverts that block the entire market.
- **Verification:** Call `context_my_orders` or `ctx.orders.mine()` to confirm the order appears with status "open".
- **See Also:** `../references/orders.md`, `../references/signing.md`

- [ ] **Step 2: Verify follows subskill template**

Check: has frontmatter, When to Use, Steps, Gotchas (6+), Verification, See Also.

- [ ] **Step 3: Commit**

```bash
git add trade/place-order/
git commit -m "feat(trade): add place-order subskill"
```

---

### Task 5: Create trade subskill — market-maker

**Files:**
- Create: `trade/market-maker/SKILL.md`

- [ ] **Step 1: Create directory and write SKILL.md**

```bash
mkdir -p trade/market-maker
```

Content must include:
- **Frontmatter:** `name: context-trade-market-maker`, `description: Quote both sides of a prediction market with spread management`
- **When to Use:** User wants to provide liquidity by quoting both sides of a market
- **Steps:** (1) Fetch orderbook to determine fair value, (2) Calculate spread (bid below fair, ask above), (3) Place two-sided quotes via `ctx.orders.bulkCreate()` or two `context_place_order` calls, (4) Monitor fills with `ctx.orders.mine()` / `context_my_orders`, (5) When one side fills, cancel the other and re-quote via `ctx.orders.cancelReplace()` or `ctx.orders.bulk()`, (6) Repeat
- **Gotchas:**
  - Inventory risk: if one side fills repeatedly without the other, you accumulate directional exposure
  - Spread too tight gets picked off by informed traders — start wider (5-10 cents), tighten as you learn the market
  - Use `ctx.orders.bulk()` for atomic cancel+create to avoid being exposed with no quotes
  - MCP only supports buying — market making requires SDK or CLI for the sell side
  - Monitor the oracle: if oracle diverges significantly from your mid-price, re-center your quotes
  - Check `context_get_balance` regularly to ensure sufficient funds
- **Verification:** Both sides of your quote visible in `context_get_orderbook`. Check `ctx.orders.mine()` shows two open orders (one buy, one sell).
- **See Also:** `../references/orders.md`, `../references/bulk-operations.md`

- [ ] **Step 2: Verify follows subskill template**

Check: has frontmatter with `name: context-trade-market-maker`, When to Use, Steps, Gotchas (4+), Verification, See Also.

- [ ] **Step 3: Commit**

```bash
git add trade/market-maker/
git commit -m "feat(trade): add market-maker subskill"
```

---

### Task 6: Create trade subskill — bulk-operations

**Files:**
- Create: `trade/bulk-operations/SKILL.md`

- [ ] **Step 1: Create directory and write SKILL.md**

```bash
mkdir -p trade/bulk-operations
```

Content must include:
- **Frontmatter:** `name: context-trade-bulk-operations`, `description: Create, cancel, or manage multiple orders in a single batch`
- **When to Use:** User wants to place/cancel multiple orders at once, build a price ladder, or atomically update positions
- **Steps:** (1) Build order array — validate all params match `PlaceOrderRequest` schema, (2) Submit batch via `ctx.orders.bulkCreate()`, `ctx.orders.bulkCancel()`, or `ctx.orders.bulk()`, (3) Check results — each order in batch gets its own result, (4) Verify with `ctx.orders.mine()`
- **Gotchas:**
  - Max 50 orders per batch
  - In `bulk()`, cancels execute before creates — use this for atomic rebalancing
  - One invalid order can fail the entire batch — validate all params before submitting
  - Each order needs a unique nonce — the SDK generates these automatically
  - Bulk operations are not available via MCP — must use SDK or CLI
  - `bulkCreate` returns `CreateOrderResult[]`, not a single result
- **Verification:** Call `ctx.orders.mine()` or `context_my_orders` to confirm all orders are open. Compare count against expected.
- **See Also:** `../references/bulk-operations.md`, `../references/orders.md`

- [ ] **Step 2: Verify follows subskill template**

Check: has frontmatter with `name: context-trade-bulk-operations`, When to Use, Steps, Gotchas (4+), Verification, See Also.

- [ ] **Step 3: Commit**

```bash
git add trade/bulk-operations/
git commit -m "feat(trade): add bulk-operations subskill"
```

---

### Task 7: Create trade subskill — manage-positions

**Files:**
- Create: `trade/manage-positions/SKILL.md`

- [ ] **Step 1: Create directory and write SKILL.md**

```bash
mkdir -p trade/manage-positions
```

Content must include:
- **Frontmatter:** `name: context-trade-manage-positions`, `description: Monitor, cancel, replace orders and check portfolio positions`
- **When to Use:** User wants to check open orders, cancel/replace orders, view portfolio, or check balances
- **Steps for cancel/replace:** (1) List orders with `context_my_orders` or `ctx.orders.mine()`, (2) Find the order's nonce, (3) Cancel with `context_cancel_order` / `ctx.orders.cancel(nonce)`, (4) Optionally place replacement with `ctx.orders.cancelReplace(nonce, newOrder)`, (5) Verify cancellation
- **Steps for portfolio check:** (1) Call `context_get_portfolio` with optional `kind` filter (all/active/won/lost/claimable), (2) Call `context_get_balance` for USDC balance, (3) Review positions and P&L
- **Steps for account funding:** (1) Check balance with `context_get_balance` / `ctx.portfolio.balance()`, (2) If low, deposit with `ctx.account.deposit(amount)`, (3) On testnet, mint test USDC with `context_mint_test_usdc` / `ctx.account.mintTestUsdc()`
- **Gotchas:**
  - Cancelled orders may have partially filled — check `context_get_portfolio` not just order status
  - `cancelReplace` is atomic — if the cancel fails (already filled), the new order is not placed
  - Portfolio `kind: "claimable"` shows positions on resolved markets you can claim winnings from
  - Balance shows both wallet USDC and settlement (deposited) USDC — you trade with settlement balance
  - `ctx.orders.allMine()` auto-paginates; `ctx.orders.mine()` returns first page only
- **Verification:** After cancel: order no longer in `context_my_orders`. After deposit: `context_get_balance` shows increased settlement balance.
- **See Also:** `../references/orders.md`, `../references/order-lifecycle.md`

- [ ] **Step 2: Verify follows subskill template**

Check: has frontmatter with `name: context-trade-manage-positions`, When to Use, Steps (3 workflows: cancel/replace, portfolio, funding), Gotchas (4+), Verification, See Also.

- [ ] **Step 3: Commit**

```bash
git add trade/manage-positions/
git commit -m "feat(trade): add manage-positions subskill"
```

---

### Task 8: Create trade subskill — diagnose-order

**Files:**
- Create: `trade/diagnose-order/SKILL.md`

- [ ] **Step 1: Create directory and write SKILL.md**

```bash
mkdir -p trade/diagnose-order
```

Content must include:
- **Frontmatter:** `name: context-trade-diagnose-order`, `description: Troubleshoot orders that aren't filling, got rejected, or show unexpected behavior`
- **When to Use:** An order isn't behaving as expected — not filling, rejected, voided, or producing unexpected results
- **Prerequisites:** Read-only — no API key needed for diagnosis (just MCP read tools). API key needed to check own orders.

**Symptom → Investigation → Resolution format:**

**"Order not filling":**
1. Check if market is active: `context_get_market` — is status "active"?
2. Check your price vs orderbook: `context_get_orderbook` — is your bid above the lowest ask (for buys) or your ask below the highest bid (for sells)?
3. Check spread: if spread is wide, your limit price may be in the gap
4. Check size: large orders need sufficient depth at your price level
5. Resolution: adjust price closer to the opposite side, or use a market order

**"Order rejected/voided":**
1. Check order status and void reason: `ctx.orders.get(id)` — look at `status` and `voidReason`
2. `insufficient_balance`: check `context_get_balance`, deposit more USDC
3. `self_trade_prevention`: you have an order on the opposite side at a crossing price — cancel one
4. `market_closed`: the market has ended — cannot trade
5. `invalid_signature`: signer mismatch — verify `CONTEXT_PRIVATE_KEY` matches the account
6. `nonce_already_used`: duplicate order — each order needs a unique nonce (SDK handles this automatically)
7. `inventory_constraint`: `inventoryModeConstraint` prevented the order — usually means trying to sell without holding tokens

**"High slippage in simulation":**
1. Check orderbook depth: `context_get_orderbook` — is there sufficient liquidity?
2. Reduce order size and re-simulate
3. Use a limit order instead of a market order to cap your price
4. Slippage thresholds: <2% good, 2-5% acceptable, >5% insufficient liquidity

- **Gotchas:**
  - Simulation and actual execution can differ — the orderbook changes between calls
  - `voided` is different from `cancelled` — voided means the system rejected it, cancelled means you cancelled it
  - Orders on resolved markets are automatically voided
  - `MAKER_ONLY` constraint (makerRoleConstraint=1) causes reverts — if you see `InvalidRoleConstraint`, this is why
- **Verification:** After resolving the issue, place a new order and confirm it appears in `context_my_orders` with status "open".
- **See Also:** `../references/order-lifecycle.md`, `../references/orders.md`

- [ ] **Step 2: Commit**

```bash
git add trade/diagnose-order/
git commit -m "feat(trade): add diagnose-order runbook subskill"
```

---

### Task 9: Review trade category as reference implementation

- [ ] **Step 1: Verify complete file structure**

```bash
find trade/ -name "*.md" | sort
```

Expected:
```
trade/SKILL.md
trade/bulk-operations/SKILL.md
trade/diagnose-order/SKILL.md
trade/manage-positions/SKILL.md
trade/market-maker/SKILL.md
trade/place-order/SKILL.md
trade/references/bulk-operations.md
trade/references/order-lifecycle.md
trade/references/orders.md
trade/references/signing.md
```

- [ ] **Step 2: Verify no leftover prompts/ directory**

```bash
ls trade/prompts/ 2>&1
```
Expected: "No such file or directory"

- [ ] **Step 3: Verify all subskills have correct frontmatter**

Each subskill SKILL.md must have `name: context-trade-<subskill>` and a `description` field.

- [ ] **Step 4: Verify all cross-references resolve**

Check that every `See Also` link points to a file that exists.

- [ ] **Step 5: Present to user for review**

Show the user the complete trade/ structure and ask for feedback before proceeding to other categories.

---

### Task 10: Write research category (router + 4 subskills + updated references)

**Files:**
- Rewrite: `research/SKILL.md` (router)
- Rewrite: `research/references/markets.md`
- Rewrite: `research/references/oracle.md`
- Rewrite: `research/references/price-data.md`
- Rewrite: `research/references/simulation.md`
- Create: `research/market-scanner/SKILL.md`
- Create: `research/mispricing-finder/SKILL.md`
- Create: `research/portfolio-analysis/SKILL.md`
- Create: `research/activity-monitor/SKILL.md`

**Source verification:**
```bash
gh api repos/contextwtf/context-sdk/contents/src/modules/markets.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/modules/portfolio.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-mcp/contents/src/tools/markets.ts --jq '.content' | base64 -d
```

- [ ] **Step 1: Rewrite research/SKILL.md router**

Follow the trade/SKILL.md pattern. Shared foundations: market concepts (binary YES/NO, prices = probability), market statuses, read-only MCP tools (8), read-only SDK methods, oracle concepts, simulation concepts. Route to 4 subskills.

- [ ] **Step 2: Update all 4 reference files with corrected types from source**

Key corrections: `SearchMarketsParams` uses `cursor` not `offset`. `SimulateTradeParams` has `amountType?: "usd" | "contracts"`. `GetActivityParams` uses `cursor` not `offset`. Document return types (`Market`, `Quotes`, `OracleResponse`, `PriceHistory`).

- [ ] **Step 3: Create market-scanner/SKILL.md**

Steps: list markets with filters → get quotes for each → rank by spread/volume/trend. Gotchas: `sortBy: "trending"` is relative, use volume for absolute activity.

- [ ] **Step 4: Create mispricing-finder/SKILL.md**

Steps: list active markets → get oracle for each → get quotes → compare → simulate to check slippage. Gotchas: oracle updates lag market, divergence <5 cents is noise, >10 cents is signal.

- [ ] **Step 5: Create portfolio-analysis/SKILL.md**

Steps: get portfolio with `context_get_portfolio` → for each position, check market status and current quotes → calculate unrealized P&L → identify claimable positions. Gotchas: portfolio requires API key + private key (not read-only), balance shows wallet + settlement separately.

- [ ] **Step 6: Create activity-monitor/SKILL.md**

Steps: call `context_global_activity` for cross-market feed → filter by market/type → track volume patterns. Gotchas: activity feed is paginated (use cursor), default limit varies.

- [ ] **Step 7: Verify structure and commit**

```bash
find research/ -name "*.md" | sort
git add research/
git commit -m "feat(research): rewrite as router + 4 subskills with corrected references"
```

---

### Task 11: Write build category (router + 4 subskills + updated references)

**Files:**
- Rewrite: `build/SKILL.md` (router)
- Rewrite: `build/references/react-hooks.md`
- Rewrite: `build/references/provider-setup.md`
- Rewrite: `build/references/query-patterns.md`
- Rewrite: `build/references/wagmi-integration.md`
- Create: `build/trading-app/SKILL.md`
- Create: `build/market-widget/SKILL.md`
- Create: `build/portfolio-dashboard/SKILL.md`
- Create: `build/account-setup-flow/SKILL.md`

**Source verification:**
```bash
gh api repos/contextwtf/context-react/contents/src/index.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/provider.tsx --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/query-keys.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/hooks/useMarkets.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/hooks/useOrderMutations.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/hooks/usePortfolio.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/hooks/useAccount.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-react/contents/src/hooks/useQuestions.ts --jq '.content' | base64 -d
```

- [ ] **Step 1: Rewrite build/SKILL.md router**

Shared foundations: provider hierarchy (`WagmiProvider > QueryClientProvider > ContextProvider`), peer deps (`context-markets >= 0.5`, `wagmi >= 2`, `viem >= 2`, `@tanstack/react-query >= 5`), `ContextProvider` props (apiKey required), full hook catalog. Route to 4 subskills.

- [ ] **Step 2: Update all 4 reference files with corrected hook signatures from source**

Key corrections: add `useSearchMarkets`, `useLatestOracleQuote`, `usePositions`, `useApproveUsdc`, `useApproveOperator`. Fix `PlaceOrderRequest.side` from numeric to string. Fix pagination from offset to cursor. Add `ContextWalletError`.

- [ ] **Step 3: Create trading-app/SKILL.md**

Steps: scaffold with providers → market list with `useMarkets` → detail view with `useMarket`/`useQuotes`/`useOrderbook` → order form with `useCreateOrder` → portfolio with `usePortfolio`. Gotchas: provider order matters, wallet must be connected for mutations, invalidate queries after mutations.

- [ ] **Step 4: Create market-widget/SKILL.md**

Steps: self-contained component with own `ContextProvider` → `useMarket` + `useQuotes` for display → `useSimulateTrade` for preview → `useCreateMarketOrder` for one-click trade. Gotchas: widget needs its own provider if embedded outside a Context app.

- [ ] **Step 5: Create portfolio-dashboard/SKILL.md**

Steps: `usePortfolio` for positions → `useBalance` for funds → `usePortfolioStats` for P&L → `useClaimable` for resolved winnings → claim button. Gotchas: positions may show stale prices, use `refetchInterval` for live updates.

- [ ] **Step 6: Create account-setup-flow/SKILL.md**

Steps: wallet connect via wagmi → `useAccountStatus` to check → `useAccountSetup` to approve → `useDeposit` to fund → ready state. Gotchas: testnet auto-uses gasless setup, mainnet requires ETH for gas, `useApproveUsdc` and `useApproveOperator` for granular control.

- [ ] **Step 7: Verify structure and commit**

```bash
find build/ -name "*.md" | sort
git add build/
git commit -m "feat(build): rewrite as router + 4 subskills with corrected hook catalog"
```

---

### Task 12: Write create category (router + 2 subskills + updated references)

**Files:**
- Rewrite: `create/SKILL.md` (router)
- Rewrite: `create/references/agent-submit-api.md`
- Rewrite: `create/references/resolution-criteria.md`
- Create: `create/news-to-market/SKILL.md`
- Create: `create/diagnose-resolution/SKILL.md`

**Source verification:**
```bash
gh api repos/contextwtf/context-sdk/contents/src/modules/questions.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-sdk/contents/src/types.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-mcp/contents/src/tools/questions.ts --jq '.content' | base64 -d
gh api repos/contextwtf/context-cli/contents/src/commands/questions.ts --jq '.content' | base64 -d
```

- [ ] **Step 1: Rewrite create/SKILL.md router**

Shared foundations: oracle model (resolves based on evidence against criteria), evidence modes (social_only vs web_enabled), claim types (event-by-deadline, threshold, period-gated, durational, none/never), market types (OBJECTIVE vs SUBJECTIVE), question formatting rules, submission methods (MCP, SDK, CLI, API). Route to 2 subskills.

**Important:** The old `create/SKILL.md` lines 419-421 reference `../../references/api-reference.md`, `../../references/patterns.md`, and `../../references/examples.md` which don't exist. Do NOT carry these forward — they are broken links from the old structure.

- [ ] **Step 2: Update reference files with corrected API from source**

Key corrections: `AgentSubmitMarketDraft` structure (nested under `market`), `Bucket` and `AgentSubmitComparison` types (from SDK types.ts), all CLI question commands (submit, submit-and-wait, agent-submit, agent-submit-and-wait, status).

- [ ] **Step 3: Create news-to-market/SKILL.md**

Steps: (1) Evaluate if news is resolvable/binary/timely, (2) Identify claim type, (3) Draft question, (4) Write resolution criteria, (5) Choose evidence mode, (6) List sources, (7) Set end time with buffer, (8) Submit via `context_agent_submit_market` (MCP) or `ctx.questions.agentSubmitAndWait()` (SDK), (9) Verify with `context_get_market`. Gotchas: end time too tight, no sources specified, ambiguous criteria, combining conditions, period-gated confusion.

- [ ] **Step 4: Create diagnose-resolution/SKILL.md**

Symptom → investigation format: "Market resolved wrong" → check resolution criteria, check evidence sources, check claim type behavior. "Submission rejected" → check `refuseToResolve`, check `rejectionReasons`. "Submission stuck" → check status with `ctx.questions.getSubmission()`, typical processing is 30-90 seconds.

- [ ] **Step 5: Verify structure and commit**

```bash
find create/ -name "*.md" | sort
git add create/
git commit -m "feat(create): rewrite as router + 2 subskills with corrected submission API"
```

---

### Task 13: Rewrite onboarding guides for agent consumption

**Files:**
- Rewrite: `onboarding/claude-code.md`
- Rewrite: `onboarding/codex.md`
- Rewrite: `onboarding/openclaw.md`
- Create: `onboarding/hermes.md`

- [ ] **Step 1: Rewrite claude-code.md**

Agent-consumable format. Steps: (1) Get API key from context.markets, (2) Generate wallet private key, (3) Add MCP server: `claude mcp add context-markets -- npx context-markets-mcp`, (4) Set env vars for MCP, (5) Install plugin: `claude plugin add contextwtf/context-plugin`, (6) Verify: call `context_list_markets`, (7) Fund wallet: `context_mint_test_usdc` (testnet) or deposit USDC (mainnet). Note: skills are loaded via the plugin — no manual skill loading needed.

- [ ] **Step 2: Rewrite codex.md**

Steps: (1) Get API key, (2) Generate wallet, (3) Add MCP: `codex mcp add context-markets -- npx context-markets-mcp`, (4) Set env vars in `~/.codex/config.toml`, (5) Load skills: copy SKILL.md content into `AGENTS.md` or reference via file path, (6) Verify, (7) Fund wallet.

- [ ] **Step 3: Rewrite openclaw.md**

Steps: (1) Get API key, (2) Generate wallet, (3) Configure MCP in `~/.openclaw/openclaw.json`, (4) Restart gateway, (5) Load skills via file path, (6) Verify, (7) Fund wallet.

- [ ] **Step 4: Rewrite hermes.md**

Steps: (1) Get API key, (2) Generate wallet, (3) Configure MCP for Hermes runtime, (4) Load skills, (5) Verify MCP tools discovered (expect 17), (6) Fund wallet.

- [ ] **Step 5: Commit**

```bash
git add onboarding/
git commit -m "feat(onboarding): rewrite guides for agent consumption, add hermes"
```

---

### Task 14: Rewrite README.md as package entry point

**Files:**
- Rewrite: `README.md`

- [ ] **Step 1: Rewrite README.md**

Must include:
- What this is (one paragraph): AI agent skill files for Context Markets
- Quick start: "Drop this repo link to your agent" → agent reads README → follows onboarding guide → ready to trade
- Category index: 4 categories with one-line descriptions and links to their SKILL.md
- Onboarding links: one per platform
- Ecosystem table: links to SDK, MCP, CLI, React, plugin repos
- License

Keep under 80 lines. This is the "drop a link" entry point — concise, not exhaustive.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "feat: rewrite README as package entry point"
```

---

### Task 15: Final verification

- [ ] **Step 1: Verify complete directory structure**

```bash
find . -name "*.md" -not -path "./.git/*" -not -path "./.context/*" -not -path "./docs/*" | sort
```

Compare against spec's target structure.

- [ ] **Step 2: Verify no leftover prompts/ directories**

```bash
find . -name "prompts" -type d
```
Expected: no output

- [ ] **Step 3: Verify no broken internal links**

Check every `See Also` and `References` link points to a file that exists.

- [ ] **Step 4: Verify all frontmatter is correct**

Every SKILL.md (category + subskill) must have `name` and `description` in frontmatter.

- [ ] **Step 5: Final commit if any fixes needed**

Stage only the specific files that were fixed — do not use `git add -A`.

```bash
git add <fixed-files>
git commit -m "chore: final verification fixes"
```
