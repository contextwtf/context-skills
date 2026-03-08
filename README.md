# Context Skills

Model-agnostic instruction sets that teach AI agents how to interact with [Context Markets](https://context.wtf).

Skills provide structured workflows and domain knowledge on top of the [Context MCP server](https://www.npmjs.com/package/@contextwtf/mcp). They work across Claude, OpenAI, Cursor, Codex, ChatGPT, and any LLM that accepts system prompts.

## Skills

| Skill | What it does | Prerequisites |
|-------|-------------|---------------|
| [**Trade**](./trade/) | Order placement, bulk operations, cancel-replace, orderbook strategies | MCP server, API key, private key |
| [**Research**](./research/) | Market discovery, oracle analysis, price history, simulations | MCP server |
| [**Build**](./build/) | React components, wallet integration, frontend patterns | None (MCP optional) |

## Installation

### Claude Code Plugin

```bash
claude plugin add contextwtf/context-plugin
```

Skills are available as `/context:trade`, `/context:research`, `/context:build`.

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

## License

MIT
