<p align="center">
  <img src="https://mainnet.contextcdn.com/ced823d63df9dff0390d9ad0a4e1ad3905dd199a6c50758c18a5c92a203adbd7" alt="Context" width="100%" />
</p>

<h1 align="center">Context Skills</h1>
<p align="center">Model-agnostic instruction sets that teach AI agents how to interact with <a href="https://context.markets">Context Markets</a>.</p>

<p align="center">
  <a href="https://github.com/contextwtf/context-skills/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT" /></a>
  <a href="https://discord.gg/RVmzZsAyM4"><img src="https://img.shields.io/badge/Discord-Join-7289da" alt="Discord" /></a>
</p>

Skills provide structured workflows and domain knowledge on top of the [Context MCP server](https://www.npmjs.com/package/@contextwtf/mcp). They work across Claude, OpenAI, Cursor, Codex, ChatGPT, and any LLM that accepts system prompts.

## Skills

| Skill | What it does | Prerequisites |
|-------|-------------|---------------|
| [**Trade**](./trade/) | Order placement, bulk operations, cancel-replace, orderbook strategies | MCP server, API key, private key |
| [**Research**](./research/) | Market discovery, oracle analysis, price history, simulations | MCP server |
| [**Build**](./build/) | React components, wallet integration, frontend patterns | None (MCP optional) |
| [**Create**](./create/) | Market creation from natural language questions | MCP server, API key, private key |

## Installation

### Claude Code Plugin

```bash
claude plugin add contextwtf/context-plugin
```

Skills are available as `/context:trade`, `/context:research`, `/context:build`, `/context:create`.

### Claude Code (standalone)

```bash
git clone https://github.com/contextwtf/context-skills.git
cd context-skills && ./install.sh
```

### Codex

Place skill files in `.agents/skills/` for auto-discovery:

```
.agents/skills/context-trade/SKILL.md
.agents/skills/context-research/SKILL.md
.agents/skills/context-build/SKILL.md
```

### OpenAI API

```python
with open("trade/prompts/openai.developer.md") as f:
    skill_prompt = f.read()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "developer", "content": skill_prompt},
        {"role": "user", "content": "Place a buy order..."}
    ]
)
```

### Claude API

```python
with open("trade/prompts/claude.system.md") as f:
    skill_prompt = f.read()

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    system=skill_prompt,
    messages=[{"role": "user", "content": "Place a buy order..."}]
)
```

### Cursor / ChatGPT

Copy the contents of `full.md` from any skill's `prompts/` directory into your system prompt or custom instructions.

## How Skills Work

Skills use a 3-layer prompt architecture:

| Layer | Name | What it contains |
|-------|------|-----------------|
| A | Harness | Runtime-specific wrapper (Claude system prompt, OpenAI developer message) |
| B | Skill | Canonical `SKILL.md` + reference files — identical across all platforms |
| C | Task | Your request ("place a buy order", "find trending markets") |

Layer B is the same everywhere. Only Layer A changes per platform.

## Adding the MCP Server

Most skills require the Context MCP server:

```bash
claude mcp add context-markets -- npx @contextwtf/mcp
```

Set environment variables as needed:

```bash
export CONTEXT_API_KEY="your-api-key"       # Required for Trade
export CONTEXT_PRIVATE_KEY="0x..."          # Required for Trade
```

## Structure

Each skill follows the same layout:

```
skill-name/
├── SKILL.md                    # Entry point — domain knowledge and critical rules
├── prompts/
│   ├── openai.developer.md     # OpenAI-formatted system prompt
│   ├── claude.system.md        # Claude-formatted system prompt
│   └── full.md                 # Universal format for Cursor/ChatGPT
└── references/
    └── *.md                    # Domain-specific API reference docs
```

## Documentation

Full skill documentation and usage guides at **[docs.context.markets](https://docs.context.markets/agents/skills)**.

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
