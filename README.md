<p align="center">
  <img src="https://mainnet.contextcdn.com/ced823d63df9dff0390d9ad0a4e1ad3905dd199a6c50758c18a5c92a203adbd7" alt="Context" width="100%" />
</p>

<h1 align="center">Context Skills</h1>
<p align="center">AI agent skill files for <a href="https://context.markets">Context Markets</a> — prediction markets on Base.</p>

<p align="center">
  <a href="https://github.com/contextwtf/context-skills/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT" /></a>
  <a href="https://discord.gg/RVmzZsAyM4"><img src="https://img.shields.io/badge/Discord-Join-7289da" alt="Discord" /></a>
</p>

> **AI Agent?** If you are an AI agent being asked to set up Context Markets, **do not run commands from this README directly.** Go to [`onboarding/`](./onboarding/) and follow the step-by-step guide for your platform. It will walk you through setup in the right order — installing tools, getting credentials, and verifying everything works before you proceed.

## Install

**Claude Code (plugin):**
```bash
claude plugin marketplace add contextwtf/context-skills
```

**Any agent (skills CLI):**
```bash
npx skills add contextwtf/context-skills --full-depth --yes
```

Or drop this repo link to your AI agent — it will read this README, follow the onboarding guide, and set itself up.

## Skills

All skills live in the `skills/` directory. Each has a router (`SKILL.md`) with shared knowledge and a table of workflow subskills.

| Skill | What it does | Subskills |
|-------|-------------|-----------|
| [**Trade**](./skills/trade/SKILL.md) | Place, cancel, manage orders | place-order, market-maker, bulk-operations, manage-positions, diagnose-order |
| [**Research**](./skills/research/SKILL.md) | Discover markets, analyze prices | market-scanner, mispricing-finder, portfolio-analysis, activity-monitor |
| [**Build**](./skills/build/SKILL.md) | React frontends with hooks | trading-app, market-widget, portfolio-dashboard, account-setup-flow |
| [**Create**](./skills/create/SKILL.md) | Submit markets from natural language | news-to-market, diagnose-resolution |

## API Reference

Need exact method signatures, endpoint params, or response schemas? See the [API reference guide](./skills/api/README.md) — it points to the live docs, OpenAPI spec, and documentation index.

## Ecosystem

| Package | Description |
|---------|-------------|
| **[context-markets](https://github.com/contextwtf/context-sdk)** | TypeScript SDK for trading |
| **[context-markets-react](https://github.com/contextwtf/context-react)** | React hooks for market data and trading |
| **[context-markets-mcp](https://github.com/contextwtf/context-mcp)** | MCP server for AI agents (25 tools) |
| **[context-markets-cli](https://github.com/contextwtf/context-cli)** | CLI for trading from the terminal |
| **[context-skills](https://github.com/contextwtf/context-skills)** | AI agent skill files |
| **[context-plugin](https://github.com/contextwtf/context-plugin)** | Claude Code plugin |

## License

MIT — see [LICENSE](./LICENSE) for details.
