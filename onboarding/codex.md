# Getting Started with Context Skills on Codex

This guide walks you through setting up Context Markets on OpenAI Codex. Follow each step with your user.

## Step 1: Get an API Key

Ask the user to go to **https://context.market/settings** and generate an API key.

Once they have it, ask them to paste the key back to you. Store it — you'll need it in Step 3.

> "To get started, I need your Context Markets API key. Head to https://context.market/settings, generate a new key, and paste it here."

## Step 2: Create an Agent Wallet

The agent needs its own wallet to sign orders on Context Markets. The user can create one at **https://context.market/settings** under the wallet section.

Ask the user to share the **wallet address** and **private key**. The private key is required for signing orders — it never leaves the local machine.

> "Now I need an agent wallet. You can create one at https://context.market/settings. Once it's ready, share the wallet address and private key with me. The private key stays local and is only used to sign orders."

## Step 3: Set Up the MCP Server

The quickest way to connect the Context Markets MCP server is via the CLI:

```bash
codex mcp add context-markets -- npx context-markets-mcp
```

To configure your API key and private key, add them to `~/.codex/config.toml`:

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

## Step 4: Install the CLI (Optional)

For quick market lookups and trading directly from the terminal:

```bash
npm install -g context-markets-cli
```

This is optional but handy for one-off commands outside of a Codex session.

## Step 5: Load Skills

Copy the contents of `prompts/openai.developer.md` (or `prompts/full.md`) from any skill folder into the project's `AGENTS.md` or your system prompt.

Available skills:

- **trade** — place and manage orders
- **research** — discover and analyze markets
- **build** — generate React components and frontend patterns
- **create** — create new markets from natural language

## Step 6: Verify Setup

Run a test MCP call to confirm everything is connected:

```
context_list_markets
```

If you get back a list of markets, the setup is working. You're ready to go.

If it fails, double-check that the API key and private key from Steps 1–2 are correct, and that the MCP server config in `~/.codex/config.toml` is valid.

## Step 7: Fund Your Wallet (Optional)

To trade, send USDC on Base to your agent wallet address. You can skip this for now and come back when you're ready to place real orders.
