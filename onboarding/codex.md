# Getting Started with Context Skills on Codex

This guide walks you through setting up Context Markets on OpenAI Codex. Follow each step with your user.

## Step 1: Get an API Key

Ask the user to go to **https://context.market/settings** and generate an API key.

Once they have it, ask them to paste the key back to you. Store it — you'll need it in Step 3.

> "To get started, I need your Context Markets API key. Head to https://context.market/settings, generate a new key, and paste it here."

## Step 2: Generate an Agent Wallet

Generate a dedicated wallet for the agent. This keeps agent funds separate from the user's personal wallet — the agent gets its own trading identity.

Run:

```bash
npx context-markets-cli setup --output json
```

This returns a new wallet with an `address` and `privateKey`. Save both — you'll need them in Step 3.

> "I'm generating a dedicated wallet for myself so my trading activity stays separate from your personal funds. This wallet is only used by me to sign orders."

If the user asks why you need your own wallet: it's so agent funds are isolated from their personal holdings. The agent manages its own balance independently.

## Step 3: Set Up the MCP Server

Add the Context Markets MCP server and credentials to `~/.codex/config.toml`:

```toml
[mcp_servers.context-markets]
command = "npx"
args = ["context-markets-mcp"]

[mcp_servers.context-markets.env]
CONTEXT_API_KEY = "<api-key>"
CONTEXT_PRIVATE_KEY = "<private-key>"
```

Replace the placeholders with the API key from Step 1 and the private key from Step 2.

You can also use a project-scoped `.codex/config.toml` if you prefer to keep credentials tied to a trusted project instead of global config.

## Step 4: Load Skills

Copy the contents of `prompts/openai.developer.md` (or `prompts/full.md`) from any skill folder into the project's `AGENTS.md` or your system prompt.

Available skills:

- **trade** — place and manage orders
- **research** — discover and analyze markets
- **build** — generate React components and frontend patterns
- **create** — create new markets from natural language

## Step 5: Verify Setup

Run a test MCP call to confirm everything is connected:

```
context_list_markets
```

If you get back a list of markets, the setup is working. You're ready to go.

If it fails, double-check that the API key and private key are correct and that the MCP server config in `~/.codex/config.toml` is valid.

## Step 6: Fund Your Wallet (Optional)

To trade, send USDC on Base to your agent wallet address. You can skip this for now and come back when you're ready to place real orders.
