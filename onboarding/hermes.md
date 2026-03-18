# Getting Started with Context Skills on Hermes

This guide walks you through setting up Context Markets on Hermes. Follow each step with your user.

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

Add the Context Markets MCP server to `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  context_markets:
    command: npx
    args: ["-y", "context-markets-mcp"]
    timeout: 120
    connect_timeout: 60
    env:
      CONTEXT_API_KEY: "<api-key>"
      CONTEXT_PRIVATE_KEY: "0x<private-key>"
```

Replace the placeholders with the API key from Step 1 and the private key from Step 2.

---

> **WARNING — Read this carefully.**
>
> Hermes filters subprocess environment variables. Shell exports (`export CONTEXT_API_KEY=...` in `.bashrc`, `.zshrc`, etc.) do **NOT** reach MCP subprocesses. You **must** put your credentials directly in the `env` block above inside `config.yaml`. This is the single most common setup mistake on Hermes. If your tools return authentication errors, this is almost certainly the reason.

---

## Step 4: Install Skills

Copy the skill folders into `~/.hermes/skills/context/` using these namespaced names:

- `context-build` — generate React components and frontend patterns
- `context-research` — discover and analyze markets
- `context-trade` — place and manage orders
- `context-create` — create new markets from natural language

The SKILL.md files already include Hermes-compatible frontmatter with `name` and `description` fields, so no extra configuration is needed.

## Step 5: Verify Setup

Confirm the tools appear in Hermes tool discovery. Look for tools prefixed with `mcp_context_markets_`, for example:

```
mcp_context_markets_context_list_markets
```

The `context_markets` prefix comes from the server name you set in `config.yaml`. If the tools don't appear, revisit Step 3 — especially the env var warning.

## Step 6: Fund Your Wallet (Optional)

To trade, send USDC on Base to your agent wallet address. You can skip this for now and come back when you're ready to place real orders.
