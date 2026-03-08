# Context Skills Repo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `contextwtf/context-skills` — markdown instruction sets that teach AI agents to trade, research, and build on Context Markets.

**Architecture:** Three skill packages (trade, research, build), each with a SKILL.md entry point, platform-specific prompt wrappers (Layer A), and reference files with real SDK/MCP method signatures. An install.sh handles Claude Code and Codex installation.

**Tech Stack:** Markdown, Bash (install.sh), Git

---

### Task 1: Repository Setup

**Files:**
- Create: `README.md`
- Create: `.gitignore`
- Create: directory structure for all 3 skills

**Step 1: Init repo and create directory structure**

```bash
cd ~/Desktop/projects/context-ecosystem/context-skills
git init
mkdir -p trade/prompts trade/references
mkdir -p research/prompts research/references
mkdir -p build/prompts build/references
```

**Step 2: Create .gitignore**

```
.DS_Store
node_modules/
```

**Step 3: Create README.md**

Overview of the repo, what skills are, installation instructions for all 6 platforms (Claude Code Plugin, Claude Code standalone, Codex, OpenAI API, Claude API, Cursor/ChatGPT). Link to docs site.

**Step 4: Commit**

```bash
git add -A && git commit -m "feat: init context-skills repo with directory structure"
```

---

### Task 2: Trade Skill — SKILL.md

**Files:**
- Create: `trade/SKILL.md`

**Content covers:**
- What the skill does (order management, bulk ops, cancel-replace, orderbook)
- Prerequisites (MCP server, API key, private key)
- Critical rules:
  - Price encoding: cents 1-99, stored as price × 10,000
  - Size encoding: shares, stored as size × 1,000,000
  - Nonce: random bytes32 via keccak256
  - EIP-712 signing required for all order operations
  - Side: 0 = buy, 1 = sell
  - OutcomeIndex: 0 = YES, 1 = NO
- MCP tools available: `context_place_order`, `context_cancel_order`, `context_my_orders`, `context_simulate_trade`, `context_get_orderbook`, `context_get_quotes`
- SDK methods: `ctx.orders.create`, `createMarket`, `cancel`, `cancelReplace`, `bulkCreate`, `bulkCancel`, `bulk`
- Composite workflows: market maker, order management, arbitrage scanner
- Pointers to reference files

**Step 1: Write trade/SKILL.md**

**Step 2: Commit**

```bash
git add trade/SKILL.md && git commit -m "feat: add trade SKILL.md"
```

---

### Task 3: Trade Skill — Reference Files

**Files:**
- Create: `trade/references/orders.md` — Full order API reference with real signatures from SDK
- Create: `trade/references/signing.md` — EIP-712 signing guide (domain, types, price/size encoding)
- Create: `trade/references/order-lifecycle.md` — Order states, void reasons, fills
- Create: `trade/references/bulk-operations.md` — Bulk create, cancel, mixed operations

**Key signatures to include (from SDK):**

```typescript
// orders.md
ctx.orders.create(req: PlaceOrderRequest): Promise<CreateOrderResult>
ctx.orders.createMarket(req: PlaceMarketOrderRequest): Promise<CreateOrderResult>
ctx.orders.cancel(nonce: Hex): Promise<CancelResult>
ctx.orders.cancelReplace(cancelNonce: Hex, newOrder: PlaceOrderRequest): Promise<CancelReplaceResult>
ctx.orders.list(params?: GetOrdersParams): Promise<OrderList>
ctx.orders.mine(marketId?: string): Promise<OrderList>
ctx.orders.get(id: string): Promise<Order>
ctx.orders.recent(params?: GetRecentOrdersParams): Promise<OrderList>
ctx.orders.simulate(params: OrderSimulateParams): Promise<OrderSimulateResult>

// signing.md — EIP-712 domain
{ name: "Settlement", version: "1", chainId: 84532, verifyingContract: "0xD91935a82Af48ff79a68134d9Eab8fc9e5d3504D" }
// Price: encodePriceCents(cents) => cents * 10_000n
// Size: encodeSize(shares) => shares * 1_000_000n
// Fee: 1% of notional, minimum 1

// bulk-operations.md
ctx.orders.bulkCreate(orders: PlaceOrderRequest[]): Promise<CreateOrderResult[]>
ctx.orders.bulkCancel(nonces: Hex[]): Promise<CancelResult[]>
ctx.orders.bulk(creates: PlaceOrderRequest[], cancelNonces: Hex[]): Promise<BulkResult>
```

**Step 1: Write all 4 reference files**

**Step 2: Commit**

```bash
git add trade/references/ && git commit -m "feat: add trade reference files"
```

---

### Task 4: Trade Skill — Prompt Wrappers

**Files:**
- Create: `trade/prompts/claude.system.md` — Claude system prompt format, includes SKILL.md content
- Create: `trade/prompts/openai.developer.md` — OpenAI developer message format
- Create: `trade/prompts/full.md` — Universal format for Cursor/ChatGPT

Each prompt wrapper:
1. Sets the agent identity/role
2. Includes the full SKILL.md content
3. Includes key reference material inline
4. Platform-specific formatting (Claude uses XML tags, OpenAI uses markdown headers)

**Step 1: Write all 3 prompt files**

**Step 2: Commit**

```bash
git add trade/prompts/ && git commit -m "feat: add trade prompt wrappers"
```

---

### Task 5: Research Skill — SKILL.md

**Files:**
- Create: `research/SKILL.md`

**Content covers:**
- Market discovery, oracle analysis, price history, simulation, activity feeds
- No API key needed (read-only)
- MCP tools: `context_list_markets`, `context_get_market`, `context_get_quotes`, `context_get_orderbook`, `context_simulate_trade`, `context_price_history`, `context_get_oracle`, `context_global_activity`
- SDK methods: `ctx.markets.list`, `get`, `quotes`, `orderbook`, `simulate`, `priceHistory`, `oracle`, `oracleQuotes`, `activity`, `globalActivity`
- Composite workflows: market scanner, oracle arbitrage finder, portfolio research
- Pointers to reference files

**Step 1: Write research/SKILL.md**

**Step 2: Commit**

```bash
git add research/SKILL.md && git commit -m "feat: add research SKILL.md"
```

---

### Task 6: Research Skill — Reference Files

**Files:**
- Create: `research/references/markets.md` — Full markets API reference
- Create: `research/references/oracle.md` — Oracle resolution system
- Create: `research/references/price-data.md` — Price history and quote patterns
- Create: `research/references/simulation.md` — Trade simulation guide

**Key signatures:**

```typescript
ctx.markets.list(params?: SearchMarketsParams): Promise<MarketList>
ctx.markets.get(id: string): Promise<Market>
ctx.markets.quotes(marketId: string): Promise<Quotes>
ctx.markets.orderbook(marketId: string, params?: GetOrderbookParams): Promise<Orderbook>
ctx.markets.simulate(marketId: string, params: SimulateTradeParams): Promise<SimulateResult>
ctx.markets.priceHistory(marketId: string, params?: GetPriceHistoryParams): Promise<PriceHistory>
ctx.markets.oracle(marketId: string): Promise<OracleResponse>
ctx.markets.oracleQuotes(marketId: string): Promise<OracleQuotesResponse>
ctx.markets.activity(marketId: string, params?: GetActivityParams): Promise<ActivityResponse>
ctx.markets.globalActivity(params?: GetActivityParams): Promise<ActivityResponse>
```

**MCP tool params:**

```typescript
context_list_markets: { query?: string, status?: "active"|"pending"|"resolved"|"closed", category?: string, sortBy?: "new"|"volume"|"trending"|"ending"|"chance", limit?: number }
context_simulate_trade: { marketId: string, side: "yes"|"no", amount: number }
context_price_history: { marketId: string, timeframe?: "1h"|"6h"|"1d"|"1w"|"1M"|"all" }
```

**Step 1: Write all 4 reference files**

**Step 2: Commit**

```bash
git add research/references/ && git commit -m "feat: add research reference files"
```

---

### Task 7: Research Skill — Prompt Wrappers

**Files:**
- Create: `research/prompts/claude.system.md`
- Create: `research/prompts/openai.developer.md`
- Create: `research/prompts/full.md`

Same structure as trade prompts but for research domain.

**Step 1: Write all 3 prompt files**

**Step 2: Commit**

```bash
git add research/prompts/ && git commit -m "feat: add research prompt wrappers"
```

---

### Task 8: Build Skill — SKILL.md

**Files:**
- Create: `build/SKILL.md`

**Content covers:**
- ContextProvider setup, all React hooks, wallet integration, query patterns
- MCP optional, no API key needed
- React hooks reference:
  - Markets: `useMarkets`, `useMarket`, `useOrderbook`, `useQuotes`, `usePriceHistory`, `useMarketActivity`, `useSimulateTrade`, `useOracle`
  - Orders: `useOrders`, `useOrder`, `useCreateOrder`, `useCreateMarketOrder`, `useCancelOrder`, `useCancelReplace`
  - Portfolio: `usePortfolio`, `useBalance`, `useClaimable`, `usePortfolioStats`
  - Account: `useAccountStatus`, `useAccountSetup`, `useDeposit`, `useWithdraw`
  - Questions: `useSubmitQuestion`, `useSubmitAndWait`, `useCreateMarket`
  - Utility: `contextKeys` (query key factory)
- Composite workflows: trading app, market dashboard, prediction market widget
- Pointers to reference files

**Step 1: Write build/SKILL.md**

**Step 2: Commit**

```bash
git add build/SKILL.md && git commit -m "feat: add build SKILL.md"
```

---

### Task 9: Build Skill — Reference Files

**Files:**
- Create: `build/references/react-hooks.md` — Full hook API reference with signatures
- Create: `build/references/provider-setup.md` — ContextProvider and wagmi config
- Create: `build/references/query-patterns.md` — TanStack Query best practices, contextKeys
- Create: `build/references/wagmi-integration.md` — Wallet connection patterns

**Key hook signatures:**

```typescript
// Query hooks
useMarkets(params?: SearchMarketsParams, options?: UseQueryOptions<MarketList>)
useMarket(marketId: string, options?: UseQueryOptions<Market>)
useOrderbook(marketId: string, params?: GetOrderbookParams, options?: UseQueryOptions<Orderbook>)
useQuotes(marketId: string, options?: UseQueryOptions<Quotes>)
useBalance(address?: Address, options?: UseQueryOptions<Balance>)

// Mutation hooks
useCreateOrder(options?: UseMutationOptions<CreateOrderResult, Error, PlaceOrderRequest>)
useCancelOrder(options?: UseMutationOptions<CancelResult, Error, Hex>)
useDeposit(options?: UseMutationOptions<GaslessDepositResult | Hex, Error, number>)
useAccountSetup(options?: UseMutationOptions<GaslessOperatorResult | WalletSetupResult, Error, void>)
```

**Step 1: Write all 4 reference files**

**Step 2: Commit**

```bash
git add build/references/ && git commit -m "feat: add build reference files"
```

---

### Task 10: Build Skill — Prompt Wrappers

**Files:**
- Create: `build/prompts/claude.system.md`
- Create: `build/prompts/openai.developer.md`
- Create: `build/prompts/full.md`

Same structure as other prompts but for React/build domain.

**Step 1: Write all 3 prompt files**

**Step 2: Commit**

```bash
git add build/prompts/ && git commit -m "feat: add build prompt wrappers"
```

---

### Task 11: install.sh

**Files:**
- Create: `install.sh`

**Behavior:**
1. Accept optional skill name arg (`./install.sh trade` or `./install.sh` for all)
2. Claude Code: symlink skill dirs into `~/.claude/skills/context-{name}/`
3. Codex: copy to `.agents/skills/context-{name}/`
4. Print success message with next steps

```bash
#!/bin/bash
set -e

SKILLS=("trade" "research" "build")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# If specific skill requested, only install that one
if [ -n "$1" ]; then
  SKILLS=("$1")
fi

# Claude Code installation
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  target="$CLAUDE_SKILLS_DIR/context-$skill"
  if [ -L "$target" ] || [ -d "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$SCRIPT_DIR/$skill" "$target"
  echo "Installed context-$skill -> $target"
done

echo ""
echo "Skills installed. Add the MCP server:"
echo "  claude mcp add context-markets -- npx @contextwtf/mcp"
```

**Step 1: Write install.sh**

**Step 2: Make executable and commit**

```bash
chmod +x install.sh
git add install.sh && git commit -m "feat: add install.sh"
```

---

### Task 12: Create GitHub Repo and Push

**Step 1: Create repo on GitHub**

```bash
gh repo create contextwtf/context-skills --public --description "Model-agnostic AI skills for Context Markets" --source .
```

**Step 2: Push**

```bash
git push -u origin main
```

---

## Task Summary

| Task | What | Files |
|------|------|-------|
| 1 | Repo setup | README.md, .gitignore, dirs |
| 2 | Trade SKILL.md | trade/SKILL.md |
| 3 | Trade references | 4 files in trade/references/ |
| 4 | Trade prompts | 3 files in trade/prompts/ |
| 5 | Research SKILL.md | research/SKILL.md |
| 6 | Research references | 4 files in research/references/ |
| 7 | Research prompts | 3 files in research/prompts/ |
| 8 | Build SKILL.md | build/SKILL.md |
| 9 | Build references | 4 files in build/references/ |
| 10 | Build prompts | 3 files in build/prompts/ |
| 11 | install.sh | install.sh |
| 12 | GitHub repo | Push to contextwtf/context-skills |

**Total: 12 tasks, ~25 files**
