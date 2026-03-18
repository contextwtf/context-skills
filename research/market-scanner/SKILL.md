---
name: context-research-market-scanner
description: Find interesting prediction markets by volume, trend, liquidity, or topic
---

# Market Scanner

Discover and rank active markets by trading interest, liquidity, and momentum.

## When to Use

The user wants to find interesting markets to research or trade — by topic, volume, trend, or liquidity.

## Steps

1. **List markets with filters** — `context_list_markets` with params:
   - `query`: keyword search (e.g., "bitcoin", "election")
   - `status: "active"`: only tradeable markets
   - `sortBy`: `"volume"` (most traded), `"trending"` (gaining momentum), `"new"` (recently created), `"ending"` (closing soon), `"chance"` (highest probability)
   - `limit`: number of results (default varies)
   - SDK: `ctx.markets.list({ query: "bitcoin", status: "active", sortBy: "volume", limit: 10 })`
   - CLI: `context markets list --status active --sort-by volume --limit 10`

2. **Get quotes for each market** — `context_get_quotes` to check bid-ask spreads:
   - Tight spread (1–3c) = liquid, easy to trade
   - Wide spread (9c+) = illiquid, use limit orders

3. **Rank by your criteria:**
   - **High volume + tight spread** = most liquid, best for trading
   - **Trending + wide spread** = gaining interest but still illiquid, potential early opportunity
   - **Ending soon + active** = markets approaching resolution, prices should converge to outcome

4. **Cross-reference with oracle** — `context_get_oracle` for markets of interest to see if the oracle agrees with the market price.

## Gotchas

- **`sortBy: "trending"` is relative.** A market can be "trending" with very low absolute volume. Always check volume alongside trend.
- **Results are paginated.** Use the `cursor` from the response to fetch the next page. SDK: pass `cursor` in params.
- **Market categories may be broad.** Use `query` for specific topics rather than relying on `category` alone.
- **Stale quotes.** If a market has very low activity, bid/ask may be from hours ago. Check `last` trade price and `context_price_history` for recency.

## Verification

- Confirm you got results: check that the returned `markets` array is non-empty.
- For each market of interest, verify it has `status: "active"` and reasonable quotes (bid and ask both present).

## See Also

- [Markets API](../references/markets.md) — SearchMarketsParams, sorting options
- [Price Data](../references/price-data.md) — Spread analysis, quote structure
