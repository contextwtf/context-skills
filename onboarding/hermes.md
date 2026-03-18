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

## Step 4: Install Skills

**Primary method — clone the repo:**

```bash
git clone https://github.com/contextwtf/context-skills.git
```

Then load the SKILL.md files from the `skills/` directory. Each category router (`skills/trade/SKILL.md`, `skills/research/SKILL.md`, etc.) contains a routing table pointing to subskill workflows that you read on demand.

**Fallback — if git clone is unavailable:**

```bash
npx skills add contextwtf/context-skills
```

If Hermes is not auto-detected, specify the agent flag or use `--all` to install to all detected agents.

## Step 5: Verify

Call `context_list_markets` to confirm the MCP server is connected. You should discover 17 tools total across markets, orders, portfolio, account, and questions.

## Step 6: Fund the Wallet

- **Testnet:** Call `context_mint_test_usdc` then `context_account_setup`.
- **Mainnet:** User deposits USDC to the wallet, then call `context_account_setup`.
