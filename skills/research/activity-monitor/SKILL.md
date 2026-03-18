---
name: context-research-activity-monitor
description: Track trading volume and market movements across Context Markets
---

# Activity Monitor

Monitor trading activity across all markets or for a specific market to track volume patterns and significant trades.

## When to Use

The user wants to see recent trades, track volume patterns, or identify markets with unusual activity.

## Steps

1. **Get global activity** — `context_global_activity` (MCP) or `ctx.markets.globalActivity()` for a cross-market feed of recent trades.
   - CLI: `context markets global-activity`

2. **Filter by market** — for a specific market, use `ctx.markets.activity(marketId, params?)`:
   - CLI: `context markets activity <marketId>`
   - Filter by time: `startTime`, `endTime` params
   - Filter by type: `types` param

3. **Analyze patterns:**
   - **Volume spikes** — sudden increase in activity may signal new information
   - **Large trades** — single large fills can move the price significantly
   - **Directional flow** — if activity is heavily one-sided (all buys or all sells), the market may be about to move

4. **Cross-reference with oracle** — if you see unusual activity, check `context_get_oracle` to see if the oracle supports the direction of the flow.

5. **Track over time** — use `context_price_history` to see how prices have moved alongside the activity.

## Gotchas

- **Activity feed is paginated.** Use the `cursor` from the response to fetch more. Default limit varies by endpoint.
- **Global activity shows all markets.** Filter by `marketId` if you're tracking a specific market.
- **Activity items include different types** — trades, order placements, cancellations. Filter by `types` param if you only want fills.
- **High-frequency activity doesn't always mean price movement.** Market makers constantly place and cancel orders — this is noise, not signal. Focus on fills, not order placements.

## Verification

- Activity feed should return recent items (check timestamps).
- Cross-check: significant activity should be reflected in price changes visible via `context_price_history`.

## See Also

- [Markets API](../references/markets.md) — Activity params, method signatures
- [Price Data](../references/price-data.md) — Price history for trend correlation
