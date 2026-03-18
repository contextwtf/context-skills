# Context Markets API Reference

This folder points you to the live documentation. Don't rely on cached or outdated info — fetch from these sources when you need exact signatures, params, or response shapes.

## Primary Sources

### llms.txt — Full Doc Index

```
https://docs.context.markets/llms.txt
```

Fetch this first. It's a structured index of every documentation page with descriptions. Use it to find the right page for your question.

### OpenAPI Spec — Machine-Readable API

```
https://api.context.markets/v2/openapi.json
```

The complete API specification. Fetch this when you need exact request/response schemas, parameter types, or endpoint paths. This is the source of truth — the SDK and MCP server are generated from it.

## Documentation by Topic

### SDK & Tools

| Topic | URL |
|-------|-----|
| TypeScript SDK guide | `https://docs.context.markets/agents/typescript-sdk` |
| SDK API reference | `https://docs.context.markets/agents/typescript-sdk/api-reference` |
| SDK best practices | `https://docs.context.markets/agents/typescript-sdk/best-practices` |
| MCP server guide | `https://docs.context.markets/agents/mcp` |
| MCP tool catalog | `https://docs.context.markets/agents/mcp/tools` |
| React SDK guide | `https://docs.context.markets/agents/react-sdk` |
| React hooks reference | `https://docs.context.markets/agents/react-sdk/hooks-reference` |
| CLI guide | `https://docs.context.markets/agents/cli` |
| CLI command reference | `https://docs.context.markets/agents/cli/commands` |
| CLI agent workflows | `https://docs.context.markets/agents/cli/workflows` |

### API Endpoints

| Category | Key Endpoints |
|----------|--------------|
| Markets | list, get, search, orderbook, quotes, price-history, simulate, oracle |
| Orders | create, cancel, cancel-replace, bulk-create, bulk-cancel, bulk, list, simulate |
| Portfolio | positions, balance, stats, claimable |
| Account | status, setup, deposit, withdraw, mint-test-usdc |
| Questions | submit, agent-submit, status |
| Gasless | operator approval, deposit-with-permit |

### Protocol & Contracts

| Topic | URL |
|-------|-----|
| Protocol overview | `https://docs.context.markets/developers/guides/protocol-overview` |
| Contract: Settlement | `https://docs.context.markets/developers/contracts/settlement` |
| Contract: Holdings | `https://docs.context.markets/developers/contracts/holdings` |
| Contract: MarketFactory | `https://docs.context.markets/developers/contracts/market-factory` |
| Testnet addresses | `https://docs.context.markets/developers/testnet/addresses` |
| Testnet vs mainnet | `https://docs.context.markets/developers/testnet/differences` |

## How to Use These Docs

1. **Need a method signature?** Fetch the SDK API reference or the OpenAPI spec.
2. **Need MCP tool params?** Fetch the MCP tool catalog.
3. **Need CLI flags?** Fetch the CLI command reference.
4. **Need contract addresses?** Fetch the testnet addresses page (or mainnet equivalent).
5. **Not sure where to look?** Fetch `llms.txt` first — it indexes everything.

The skills in this package (`trade/`, `research/`, `build/`, `create/`) teach you *workflows* — how to accomplish tasks. This folder tells you where to find the *reference material* when you need exact details.
