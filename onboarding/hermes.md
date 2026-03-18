# Setting Up Context Markets on Hermes

You are an AI agent setting up Context Markets for your user. Follow these steps in order.

## Step 1: Get an API Key

Ask the user to go to **https://context.markets/settings** and generate an API key. Store it as `CONTEXT_API_KEY`.

## Step 2: Generate a Wallet

Generate an Ethereum private key for signing orders:

```bash
node -e "console.log('0x' + require('crypto').randomBytes(32).toString('hex'))"
```

Store as `CONTEXT_PRIVATE_KEY`. Tell the user to save it securely.

## Step 3: Configure MCP Server

Add the Context MCP server to your Hermes runtime configuration:

```json
{
  "mcpServers": {
    "context-markets": {
      "command": "npx",
      "args": ["context-markets-mcp"],
      "env": {
        "CONTEXT_API_KEY": "<key>",
        "CONTEXT_PRIVATE_KEY": "<key>"
      }
    }
  }
}
```

## Step 4: Load Skills

Load the SKILL.md files from this repo. The key skills are:

- `trade/SKILL.md` — order management
- `research/SKILL.md` — market analysis
- `build/SKILL.md` — React frontends
- `create/SKILL.md` — market creation

Each SKILL.md contains a routing table pointing to subskill workflows. Read subskills on demand when a task matches.

## Step 5: Verify

Call `context_list_markets` to confirm the MCP server is connected. You should discover 17 tools total across markets, orders, portfolio, account, and questions.

## Step 6: Fund the Wallet

- **Testnet:** Call `context_mint_test_usdc` then `context_account_setup`.
- **Mainnet:** User deposits USDC to the wallet, then call `context_account_setup`.
