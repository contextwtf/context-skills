<p align="center">
  <img src="https://mainnet.contextcdn.com/ced823d63df9dff0390d9ad0a4e1ad3905dd199a6c50758c18a5c92a203adbd7" alt="Context" width="100%" />
</p>

<h1 align="center">Context Skills</h1>
<p align="center">AI agent skill files for <a href="https://context.markets">Context Markets</a> — prediction markets on Base.</p>

<p align="center">
  <a href="https://github.com/contextwtf/context-skills/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT" /></a>
  <a href="https://discord.gg/RVmzZsAyM4"><img src="https://img.shields.io/badge/Discord-Join-7289da" alt="Discord" /></a>
</p>

## Quick Start

Drop this repo link to your AI agent. It will read this README, follow the onboarding guide for its platform, and set itself up.

### Agent Setup

Go to `onboarding/` and follow the guide for your platform:

- [Claude Code](./onboarding/claude-code.md)
- [Codex](./onboarding/codex.md)
- [OpenClaw](./onboarding/openclaw.md)
- [Hermes](./onboarding/hermes.md)

## Skills

Each skill has a router (`SKILL.md`) with shared knowledge and a table of workflow subskills. Read the router first, then the subskill that matches your task.

| Skill | What it does | Subskills |
|-------|-------------|-----------|
| [**Trade**](./trade/SKILL.md) | Place, cancel, manage orders | place-order, market-maker, bulk-operations, manage-positions, diagnose-order |
| [**Research**](./research/SKILL.md) | Discover markets, analyze prices | market-scanner, mispricing-finder, portfolio-analysis, activity-monitor |
| [**Build**](./build/SKILL.md) | React frontends with hooks | trading-app, market-widget, portfolio-dashboard, account-setup-flow |
| [**Create**](./create/SKILL.md) | Submit markets from natural language | news-to-market, diagnose-resolution |

## Ecosystem

| Package | Description |
|---------|-------------|
| **[context-markets](https://github.com/contextwtf/context-sdk)** | TypeScript SDK for trading |
| **[context-markets-react](https://github.com/contextwtf/context-react)** | React hooks for market data and trading |
| **[context-markets-mcp](https://github.com/contextwtf/context-mcp)** | MCP server for AI agents (17 tools) |
| **[context-markets-cli](https://github.com/contextwtf/context-cli)** | CLI for trading from the terminal |
| **[context-plugin](https://github.com/contextwtf/context-plugin)** | Claude Code plugin |

## License

MIT — see [LICENSE](./LICENSE) for details.
