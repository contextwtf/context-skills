# Getting Started with Context Skills on Claude Code

This guide walks you through setting up Context Markets on Claude Code. Follow each step with your user.

## Step 1: Get an API Key

Ask the user to go to **https://context.market/settings** and generate an API key.

Once they have it, ask them to paste the key back to you. Store it — you'll need it in Step 3.

> "To get started, I need your Context Markets API key. Head to https://context.market/settings, generate a new key, and paste it here."

## Step 2: Create an Agent Wallet

The agent needs its own wallet to sign orders on Context Markets. The user can create one at **https://context.market/settings** under the wallet section.

Ask the user to share the **wallet address** and **private key**. The private key is required for signing orders — it never leaves the local machine.

> "Now I need an agent wallet. You can create one at https://context.market/settings. Once it's ready, share the wallet address and private key with me. The private key stays local and is only used to sign orders."

## Step 3: Set Up the MCP Server

Run the following command to connect the Context Markets MCP server. Replace the placeholders with the API key from Step 1 and the private key from Step 2:

```bash
claude mcp add context-markets \
  --env CONTEXT_API_KEY=<api-key> \
  --env CONTEXT_PRIVATE_KEY=<private-key> \
  -- npx context-markets-mcp
```

This gives the agent access to all Context Markets tools — listing markets, getting quotes, placing orders, and more.

## Step 4: Install the CLI (Optional)

For quick market lookups and trading directly from the terminal:

```bash
npm install -g context-markets-cli
```

This is optional but handy for one-off commands outside of a Claude session.

## Step 5: Install Skills

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

## Step 6: Verify Setup

Run a test MCP call to confirm everything is connected:

```
context_list_markets
```

If you get back a list of markets, the setup is working. You're ready to go.

If it fails, double-check that the API key and private key from Steps 1–2 are correct, and that the MCP server was added successfully in Step 3.

## Step 7: Fund Your Wallet (Optional)

To trade, send USDC on Base to your agent wallet address. You can skip this for now and come back when you're ready to place real orders.
