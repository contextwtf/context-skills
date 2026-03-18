# Skill Package Reorganization Design

**Date:** 2026-03-18
**Status:** Draft

## Problem

The current skill package has four skills (build, create, research, trade) that are essentially API reference docs wrapped in skill format. They lack:

- **Gotchas sections** — the highest-signal content per the Claude Code team
- **Actionable workflows** — composite workflows are 3-line descriptions, not step-by-step procedures
- **Scripts/templates/data** — skills are pure markdown, missing the folder-as-context pattern
- **Progressive disclosure** — SKILL.md files are 200-400 lines trying to include everything
- **Accuracy** — multiple outdated method signatures, missing tools, wrong version numbers
- **Workflow coverage** — no troubleshooting/runbook skills, no account management, no position monitoring
- **Platform support** — 3 prompt variants per skill is a maintenance burden with no meaningful value

## Decisions Made

1. **Workflow-level subskills** — each major workflow becomes its own SKILL.md (~3-5 per category, ~15 total)
2. **Category SKILL.md = router + shared foundations** — routing table plus knowledge all subskills need
3. **Eliminate prompts/ folders** — single SKILL.md per skill, onboarding guides explain platform loading
4. **Shared references at category level** — `references/` stays at category level, not duplicated per subskill
5. **Full rewrite** — all content rewritten from scratch with gotchas, steps, verification
6. **Category-by-category** — trade first as reference implementation, then the other three
7. **Onboarding stays separate** — rewritten for agent consumption (agents do the setup, humans just provide keys)

## Target Structure

```
porto/
  README.md                          # Package overview, "drop this link" entry point
  onboarding/
    claude-code.md                   # Agent-consumable setup instructions
    codex.md
    openclaw.md
    hermes.md

  build/
    SKILL.md                         # Router + shared: provider setup, hook catalog, encoding
    references/
      react-hooks.md                 # Full hook signatures with TypeScript types
      provider-setup.md              # ContextProvider, wagmi config, chain config
      query-patterns.md              # contextKeys, cache invalidation, polling
      wagmi-integration.md           # Wallet connection, account setup, chain switching
    trading-app/SKILL.md             # Scaffold a full trading UI
    market-widget/SKILL.md           # Embeddable prediction market widget
    portfolio-dashboard/SKILL.md     # Position tracking + P&L display
    account-setup-flow/SKILL.md      # Wallet connect → deposit → ready-to-trade UI

  create/
    SKILL.md                         # Router + shared: oracle model, evidence modes, claim types
    references/
      agent-submit-api.md            # Full endpoint schema and field reference
      resolution-criteria.md         # Writing criteria the oracle can resolve
    news-to-market/SKILL.md          # News article → well-formed market
    diagnose-resolution/SKILL.md     # Market resolved wrong / unexpectedly

  research/
    SKILL.md                         # Router + shared: price encoding, data sources, thresholds
    references/
      markets.md                     # Market schemas, search params, SDK method signatures
      oracle.md                      # Oracle system, quotes, mispricing detection
      price-data.md                  # Quote structure, spread analysis, price history
      simulation.md                  # Simulation params and interpretation
    market-scanner/SKILL.md          # Find markets matching criteria
    mispricing-finder/SKILL.md       # Oracle vs market divergence analysis
    portfolio-analysis/SKILL.md      # Current positions, P&L, exposure
    activity-monitor/SKILL.md        # Track trades, volume, market movements

  trade/
    SKILL.md                         # Router + shared: encoding, signing, MCP tools, account setup
    references/
      orders.md                      # Full type defs, method signatures
      signing.md                     # EIP-712 domain, types, encoding functions
      order-lifecycle.md             # States, transitions, void reasons
      bulk-operations.md             # Patterns for multi-order operations
    place-order/SKILL.md             # Single limit or market order
    market-maker/SKILL.md            # Spread management, laddering
    bulk-operations/SKILL.md         # Batch create/cancel/mixed
    manage-positions/SKILL.md        # Cancel, replace, monitor fills, check portfolio
    diagnose-order/SKILL.md          # Runbook: order not filling, rejected, high slippage
```

### Deleted

- All `prompts/` folders (12 files)
- `install.sh`
- Old `docs/superpowers/plans/` (this spec and any future plans survive until all phases complete)
- Broken cross-references in `create/SKILL.md` (lines 419-421 point to `../../references/` files that don't exist)

## Naming Convention

- Category skills: `context-<category>` → `context-trade`, `context-build`, `context-research`, `context-create`
- Subskills: `context-<category>-<subskill>` → `context-trade-place-order`, `context-trade-market-maker`, `context-build-trading-app`
- Reference files share the category namespace but aren't skills — they're reference material with no frontmatter

Note: `trade/bulk-operations/SKILL.md` (subskill) and `trade/references/bulk-operations.md` (reference) share a name. This is intentional — the subskill is the workflow ("how to do bulk ops"), the reference is the API spec ("what methods exist"). The subskill points to the reference via its "See Also" section.

## Subskill SKILL.md Template

Every subskill follows this format. Subskills inherit prerequisites from their category router — only add a `## Prerequisites` section if the subskill has additional requirements beyond the category level (e.g., a funded account for trading subskills vs. read-only for diagnostic subskills).

```markdown
---
name: context-<category>-<subskill>
description: <when to trigger — written for the model, not humans>
---

# <Title>

<1-2 sentence purpose>

## When to Use
<One sentence>

## Steps
1. ...
2. ...
3. ...

## Gotchas
- <Common failure + how to avoid>
- ...

## Verification
- <How to confirm it worked>

## See Also
- <Pointer to category references>
```

## Category Router SKILL.md Template

```markdown
---
name: context-<category>
description: <category-level trigger description>
---

# <Category> Skill

<Purpose statement>

## Prerequisites
<What's needed>

## Shared Foundations
<Knowledge every subskill needs — encoding rules, tool catalog, etc.>

## Available Workflows

| Workflow | When to use |
|----------|-------------|
| [place-order](./place-order/SKILL.md) | User wants to buy/sell on a market |
| [market-maker](./market-maker/SKILL.md) | User wants to quote both sides |
| ... | ... |

## References
- [Orders API](./references/orders.md)
- ...
```

## Subskill Discovery (Runtime Behavior)

Subskills are **not** independently registered. The agent loads a category SKILL.md (via plugin, manual load, or onboarding-configured path). The category SKILL.md contains a routing table with relative links to subskill files. When the agent determines which workflow applies, it reads the subskill SKILL.md on demand. This is progressive disclosure — the agent only pulls what it needs.

This works the same on all platforms: Claude Code, Codex, OpenClaw, Hermes. The only platform-specific step is *how* the category SKILL.md gets loaded initially (covered in onboarding guides).

## SDK vs MCP Semantic Mismatch: `side` Parameter

**Critical gotcha that must be documented prominently in the trade category.**

The SDK and MCP use `side` to mean different things:

- **SDK**: `side: "buy" | "sell"` — the trade direction. Outcome is a separate param: `outcome: "yes" | "no"`.
  ```ts
  ctx.orders.create({ marketId, outcome: "yes", side: "buy", priceCents: 45, size: 10 })
  ```

- **MCP**: `side: "yes" | "no"` — the outcome to buy. There is no separate side param because the tool always buys.
  ```
  context_place_order({ marketId, side: "yes", size: 10, price: 45 })
  ```

**To sell via MCP**, you cannot — the MCP tool only supports buying. Selling requires the SDK or CLI.

**To sell via CLI**: `context orders create --market <id> --outcome yes --side sell --price 55 --size 10`

This mismatch will confuse agents switching between MCP and SDK. Every subskill that involves order placement must specify which interface it's using and use the correct parameter names.

## Accuracy Corrections

All content will be rewritten against the actual source code (verified 2026-03-18). Key corrections:

### SDK

| Item | Old (Wrong) | New (Correct) |
|------|------------|---------------|
| Chain support | Testnet only (Base Sepolia 84532) | `chain: "mainnet" \| "testnet"` (defaults to mainnet) |
| Constructor | Not shown clearly | `new ContextClient({ chain?, apiKey?, signer?: { privateKey } })` |
| Order params | Numeric `Side: 0`, `OutcomeIndex: 0` | Strings: `outcome: "yes" \| "no"`, `side: "buy" \| "sell"` |
| Account setup | Not mentioned | `ctx.account.setup()` — chain-aware (gasless on testnet, on-chain on mainnet) |
| Deposit | Not mentioned | `ctx.account.deposit(amount)` — chain-aware |
| Gasless | Not mentioned | `ctx.account.gaslessSetup()`, `ctx.account.gaslessDeposit()` |
| Mint test USDC | Not mentioned | `ctx.account.mintTestUsdc(amount?)` |
| Advanced positions | Not mentioned | `ctx.account.mintCompleteSets()`, `ctx.account.burnCompleteSets()` |
| `MAKER_ONLY` danger | Not mentioned | makerRoleConstraint=1 causes reverts — NEVER use |
| `allMine()` method | Not listed | `ctx.orders.allMine(marketId?)` — paginated version |
| `listAll()` method | Not listed | `ctx.orders.listAll(params?)` — auto-paginates |
| Errors | Not mentioned | `ContextApiError`, `ContextSigningError`, `ContextConfigError` |
| Deprecated types | Not flagged | `Candle` → use `PricePoint`, `PriceInterval` → use `PriceTimeframe`, `WalletStatus` → use `AccountStatus` |

### MCP Tools (17 total, verified from source)

**Markets (8 — read-only, no auth):**
`context_list_markets`, `context_get_market`, `context_get_quotes`, `context_get_orderbook`, `context_simulate_trade`, `context_price_history`, `context_get_oracle`, `context_global_activity`

**Orders (3 — requires API key + private key):**
`context_place_order`, `context_cancel_order`, `context_my_orders`

**Portfolio (2 — requires API key + private key):**
`context_get_portfolio`, `context_get_balance`

**Account (2 — requires API key + private key):**
`context_account_setup`, `context_mint_test_usdc`

**Questions (2 — requires API key + private key):**
`context_create_market`, `context_agent_submit_market`

| Item | Old | New |
|------|-----|-----|
| Tool count | 6 in trade, 8 in research | 17 total (listed above) |
| Missing from trade skill | — | `context_get_portfolio`, `context_get_balance`, `context_account_setup`, `context_mint_test_usdc` |
| `context_place_order` semantics | Not explained | `side` means outcome (yes/no), always buys. See SDK vs MCP mismatch section above. |

### React SDK

| Item | Old | New |
|------|-----|-----|
| Version | `context-markets-react v0.1.0`, `context-markets v0.3.5` | `context-markets >= 0.5`, `wagmi >= 2`, `viem >= 2`, `@tanstack/react-query >= 5` |
| Missing hooks | — | `useSearchMarkets`, `useLatestOracleQuote`, `usePositions`, `useApproveUsdc`, `useApproveOperator` |
| ContextProvider | No props shown | `<ContextProvider apiKey={...}>` — apiKey prop |
| ChainOption export | Not mentioned | `ChainOption` type exported for chain configuration |
| ContextWalletError | Not mentioned | Exported error class for wallet-related errors |

### CLI

| Item | Old | New |
|------|-----|-----|
| Coverage | Not referenced in any skill | Full command set: markets, orders, portfolio, account, questions, gasless |
| Package name | — | `context-markets-cli` (npm), `context` (binary) |
| Output format | — | All output is JSON to stdout, errors JSON to stderr |

**CLI questions commands (verified from source):**
- `context questions submit <question>` — simple submit
- `context questions submit-and-wait <question>` — simple submit + poll
- `context questions agent-submit` — full draft with all flags
- `context questions agent-submit-and-wait` — full draft + poll
- `context questions status <submissionId>` — check status

### Create Skill

| Item | Old | New |
|------|-----|-----|
| SDK simple path | `ctx.questions.submitAndWait("question")` | Confirmed correct |
| SDK agent path | `ctx.questions.agentSubmitAndWait({market: {...}})` | Confirmed correct |
| CLI commands | Previously said "no agent prefix" | Actually: CLI **does** have both `agent-submit` and `agent-submit-and-wait` as separate commands (verified from source) |

## Implementation Approach

### Phase 1: Trade (reference implementation)

1. Write `trade/SKILL.md` router with corrected shared foundations
2. Write all 5 subskills with gotchas, steps, verification
3. Update `trade/references/` with corrected type definitions
4. Review with user, iterate until approved

### Phase 2: Research

1. Apply trade template to research category
2. Write 4 subskills
3. Update references

### Phase 3: Build

1. Apply template to build category
2. Write 4 subskills with corrected hook catalog and version info
3. Update references

### Phase 4: Create

1. Apply template to create category
2. Write 2 subskills (news-to-market, diagnose-resolution)
3. Update references with corrected API endpoints

### Phase 5: Cleanup & Onboarding

1. Delete all `prompts/` folders
2. Delete `install.sh`
3. Rewrite onboarding guides for agent consumption
4. Add `hermes.md`
5. Rewrite `README.md` as the package entry point
6. Clean up old docs
