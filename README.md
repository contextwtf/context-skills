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

## Skills

| Skill | What it does | Prerequisites |
|-------|-------------|---------------|
| [**Trade**](./trade/) | Order placement, bulk operations, cancel-replace, orderbook strategies | MCP server, API key, private key |
| [**Research**](./research/) | Market discovery, oracle analysis, price history, simulations | MCP server |
| [**Build**](./build/) | React components, wallet integration, frontend patterns | None (MCP optional) |
| [**Create**](./create/) | Market creation from natural language questions | MCP server, API key, private key |

## Install

### Claude Code Plugin (recommended)

```bash
claude plugin add contextwtf/context-plugin
```

Skills are available as `/context:trade`, `/context:research`, `/context:build`, `/context:create`.

### Claude Code (standalone)

```bash
git clone https://github.com/contextwtf/context-skills.git
cd context-skills && ./install.sh
```

### Other Platforms

See the [full installation guide](https://docs.context.markets/agents/skills) for Codex, OpenAI API, Claude API, Cursor, and ChatGPT.

## Adding the MCP Server

Most skills require the Context MCP server:

```bash
claude mcp add context-markets -- npx @contextwtf/mcp
```

## Documentation

- **[Skills Guide](https://docs.context.markets/agents/skills)** — full setup and usage across all platforms
- **[Trade Skill](https://docs.context.markets/agents/skills/trade)** — order placement and strategy workflows
- **[Research Skill](https://docs.context.markets/agents/skills/research)** — market discovery and analysis
- **[Build Skill](https://docs.context.markets/agents/skills/build)** — React components and frontend patterns

## Ecosystem

| Package | Description |
|---------|-------------|
| **[context-markets](https://github.com/contextwtf/context-sdk)** | TypeScript SDK for trading |
| **[@contextwtf/react](https://github.com/contextwtf/context-react)** | React hooks for market data and trading |
| **[@contextwtf/mcp](https://github.com/contextwtf/context-mcp)** | MCP server for AI agents |
| **[@contextwtf/cli](https://github.com/contextwtf/context-cli)** | CLI for trading from the terminal |
| **[context-skills](https://github.com/contextwtf/context-skills)** | AI agent skill files |
| **[context-plugin](https://github.com/contextwtf/context-plugin)** | Claude Code plugin |

## License

MIT — see [LICENSE](./LICENSE) for details.
