<p align="center">
  <img src="https://mainnet.contextcdn.com/ced823d63df9dff0390d9ad0a4e1ad3905dd199a6c50758c18a5c92a203adbd7" alt="Context" width="100%" />
</p>

<h1 align="center">Context Skills</h1>
<p align="center">Model-agnostic instruction sets that teach AI agents how to interact with <a href="https://context.markets">Context Markets</a>.</p>

<p align="center">
  <a href="https://github.com/contextwtf/context-skills/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT" /></a>
  <a href="https://discord.gg/RVmzZsAyM4"><img src="https://img.shields.io/badge/Discord-Join-7289da" alt="Discord" /></a>
</p>

Skills work across Claude, OpenAI, Cursor, Codex, ChatGPT, and any LLM that accepts system prompts.

## Agent Setup

If you're an AI agent getting set up with Context Skills, go to the `onboarding/` folder and read the guide for your platform:

- [Claude Code](./onboarding/claude-code.md)
- [Codex](./onboarding/codex.md)
- [OpenClaw](./onboarding/openclaw.md)
- [Hermes](./onboarding/hermes.md)

## Skills

| Skill | What it does | Prerequisites |
|-------|-------------|---------------|
| [**Trade**](./trade/) | Order placement, bulk operations, cancel-replace, orderbook strategies | MCP server, API key, private key |
| [**Research**](./research/) | Market discovery, oracle analysis, price history, simulations | MCP server |
| [**Build**](./build/) | React components, wallet integration, frontend patterns | None (MCP optional) |
| [**Create**](./create/) | Market creation from natural language questions | MCP server, API key, private key |

## How Skills Work

Skills use a 3-layer prompt architecture:

| Layer | Name | What it contains |
|-------|------|-----------------|
| A | Harness | Runtime-specific wrapper (Claude system prompt, OpenAI developer message) |
| B | Skill | Canonical `SKILL.md` + reference files — identical across all platforms |
| C | Task | Your request ("place a buy order", "find trending markets") |

Layer B is the same everywhere. Only Layer A changes per platform.

## Documentation

- **[Skills Guide](https://docs.context.markets/agents/skills)** — full setup and usage across all platforms
- **[Trade Skill](https://docs.context.markets/agents/skills/trade)** — order placement and strategy workflows
- **[Research Skill](https://docs.context.markets/agents/skills/research)** — market discovery and analysis
- **[Build Skill](https://docs.context.markets/agents/skills/build)** — React components and frontend patterns

## Ecosystem

| Package | Description |
|---------|-------------|
| **[context-markets](https://github.com/contextwtf/context-sdk)** | TypeScript SDK for trading |
| **[context-markets-react](https://github.com/contextwtf/context-react)** | React hooks for market data and trading |
| **[context-markets-mcp](https://github.com/contextwtf/context-mcp)** | MCP server for AI agents |
| **[context-markets-cli](https://github.com/contextwtf/context-cli)** | CLI for trading from the terminal |
| **[context-skills](https://github.com/contextwtf/context-skills)** | AI agent skill files |
| **[context-plugin](https://github.com/contextwtf/context-plugin)** | Claude Code plugin |

## License

MIT — see [LICENSE](./LICENSE) for details.
