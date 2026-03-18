---
name: context-research
description: Discover and analyze prediction markets on Context Markets
---

# Research Skill

Discover markets, analyze prices, interpret oracle signals, simulate trades, and monitor activity — all read-only.

## Prerequisites

- **Context MCP server** running (`npx context-markets-mcp`)
- **No API key or private key needed** for read-only tools
- Portfolio analysis requires API key + private key

## Shared Foundations

### Market Basics

- Markets are binary YES/NO contracts priced 1–99 cents. Price = implied probability (65c YES = 65% chance).
- **Statuses:** `active` (trading open), `pending` (awaiting resolution), `resolved` (outcome determined), `closed` (no longer trading).
- YES price + NO price ≈ 100 cents.

### Oracle

The AI oracle evaluates markets independently of trading. It analyzes evidence (social media, web sources) and produces a probability estimate. When the oracle estimate diverges from the market price, that's the primary mispricing signal.

- **Divergence < 5 cents** — noise, ignore
- **Divergence 5–10 cents** — monitor, may be opportunity
- **Divergence > 10 cents** — significant, likely mispricing

### Read-Only MCP Tools (8)

`context_list_markets` · `context_get_market` · `context_get_quotes` · `context_get_orderbook` · `context_simulate_trade` · `context_price_history` · `context_get_oracle` · `context_global_activity`

### Portfolio MCP Tools (requires auth)

`context_get_portfolio` · `context_get_balance`

### SDK Methods

```ts
const ctx = new ContextClient();  // no auth needed for reads

// Discovery
ctx.markets.list(params?: SearchMarketsParams)
ctx.markets.get(id: string)

// Price data
ctx.markets.quotes(marketId)
ctx.markets.orderbook(marketId, params?)
ctx.markets.fullOrderbook(marketId, params?)  // both YES and NO sides
ctx.markets.priceHistory(marketId, params?)

// Oracle
ctx.markets.oracle(marketId)
ctx.markets.oracleQuotes(marketId)
ctx.markets.requestOracleQuote(marketId)

// Simulation
ctx.markets.simulate(marketId, { side, amount, amountType })

// Activity
ctx.markets.activity(marketId, params?)
ctx.markets.globalActivity(params?)
```

### CLI Commands

```
context markets list             Search and filter markets
context markets get <id>         Market details
context markets quotes <id>      Current bid/ask/last
context markets orderbook <id>   Orderbook depth
context markets simulate <id>    Preview a trade
context markets price-history    Historical prices
context markets oracle <id>      Oracle probability
context markets oracle-quotes    Oracle quote history
context markets activity <id>    Market activity feed
context markets global-activity  Cross-market activity
```

## Available Workflows

| Workflow | When to use |
|----------|-------------|
| [market-scanner](./market-scanner/SKILL.md) | Find interesting markets by volume, trend, or liquidity |
| [mispricing-finder](./mispricing-finder/SKILL.md) | Identify oracle vs market price divergence |
| [portfolio-analysis](./portfolio-analysis/SKILL.md) | Review positions, P&L, and claimable winnings |
| [activity-monitor](./activity-monitor/SKILL.md) | Track trading volume and market movements |

## References

- [Markets API](./references/markets.md) — Search params, method signatures, return types
- [Oracle System](./references/oracle.md) — Oracle resolution, quotes, mispricing detection
- [Price Data](./references/price-data.md) — Quote structure, spread analysis, price history
- [Simulation](./references/simulation.md) — Trade simulation parameters and interpretation
