---
name: context-research-mispricing-finder
description: Identify markets where the oracle probability diverges from the market price
---

# Mispricing Finder

Find markets where the AI oracle's probability estimate diverges significantly from the market price — the primary signal for trading opportunities.

## When to Use

The user wants to find markets where the oracle disagrees with the market, suggesting the price is wrong.

## Steps

1. **List active markets** — `context_list_markets({ status: "active", sortBy: "volume", limit: 20 })` to get liquid markets worth analyzing.

2. **For each market, get the oracle estimate** — `context_get_oracle` returns the oracle's probability and confidence.

3. **Get the market price** — `context_get_quotes` returns the current YES last/bid/ask.

4. **Compare** — calculate divergence: `|oracle_probability - yes_last_price|`
   - **< 5 cents** — noise, oracle and market agree
   - **5–10 cents** — monitor, possible developing opportunity
   - **> 10 cents** — significant, likely mispricing worth investigating

5. **Simulate before acting** — for divergences > 10c, call `context_simulate_trade` to check if the opportunity survives slippage at a realistic trade size.
   - If oracle says 70% but market trades at 55c, simulate buying YES at $50–$100
   - If slippage eats most of the edge, the opportunity isn't real at that size

6. **Check the oracle's reasoning** — the oracle response includes a summary of its evidence and confidence. If confidence is low or the reasoning seems stale, the divergence may not be actionable.

## Gotchas

- **Oracle updates lag the market.** The oracle re-evaluates periodically, not on every trade. A divergence may exist because the oracle hasn't caught up to new information.
- **Divergence direction matters.** Oracle above market = market underpricing YES (buy opportunity). Oracle below market = market overpricing YES (sell opportunity, but selling requires SDK or CLI).
- **Slippage kills small edges.** A 10-cent divergence that costs 5 cents in slippage is only a 5-cent edge. Always simulate.
- **Low-volume markets can have large divergences** that are real but untradeable — not enough liquidity to capture the edge.
- **Oracle confidence varies.** Weight high-confidence estimates more heavily than low-confidence ones.

## Verification

- Divergence calculation: confirm oracle probability and market price are in the same units (both in cents / percentage points).
- Simulation: confirm the simulated fill price still preserves a meaningful edge after slippage.

## See Also

- [Oracle System](../references/oracle.md) — How the oracle works, quote vs market distinction
- [Simulation](../references/simulation.md) — Interpreting slippage results
- [Price Data](../references/price-data.md) — Quote structure, spread analysis
