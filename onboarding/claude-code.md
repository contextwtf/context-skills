# Getting Started with Context Skills on Claude Code

This guide walks you through setting up Context Markets on Claude Code. Follow each step with your user.

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

Run the following command to connect the Context Markets MCP server. Replace the placeholders with the API key from Step 1 and the private key from Step 2:

```bash
claude mcp add context-markets \
  --env CONTEXT_API_KEY=<api-key> \
  --env CONTEXT_PRIVATE_KEY=<private-key> \
  -- npx context-markets-mcp
```

This gives the agent access to all Context Markets tools — listing markets, getting quotes, placing orders, and more.

## Step 4: Install Skills

### Plugin (recommended)

```bash
claude plugin add contextwtf/context-plugin
```

This gives you slash commands out of the box:

- `/context:trade` — place and manage orders
- `/context:research` — discover and analyze markets
- `/context:build` — generate React components and frontend patterns
- `/context:create` — create new markets from natural language

### Manual

Clone this repo and copy the prompt files into your custom instructions:

- `prompts/claude.system.md` from any skill folder (e.g., `trade/prompts/claude.system.md`)
- Or use `prompts/full.md` for the complete skill prompt including references

## Step 5: Verify Setup

Run a test MCP call to confirm everything is connected:

```
context_list_markets
```

If you get back a list of markets, the setup is working. You're ready to go.

If it fails, double-check that the API key and private key are correct and that the MCP server was added successfully in Step 3.

## Step 6: Fund Your Wallet (Optional)

To trade, send USDC on Base to your agent wallet address. You can skip this for now and come back when you're ready to place real orders.
