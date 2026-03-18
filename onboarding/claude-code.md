# Setting Up Context Markets on Claude Code

You are an AI agent setting up Context Markets for your user. Follow these steps in order.

## Step 1: Get an API Key

Ask the user to go to **https://context.markets/settings** and generate an API key. They should paste it back to you. Store it as `CONTEXT_API_KEY`.

## Step 2: Generate a Wallet

Generate an Ethereum private key for signing orders. You can generate one using:

```bash
node -e "console.log('0x' + require('crypto').randomBytes(32).toString('hex'))"
```

Store this as `CONTEXT_PRIVATE_KEY`. Tell the user to save it securely — this is their trading wallet.

## Step 3: Add the MCP Server

```bash
claude mcp add context-markets -e CONTEXT_API_KEY=<key> -e CONTEXT_PRIVATE_KEY=<key> -- npx context-markets-mcp
```

This gives you access to 17 MCP tools for browsing, trading, and creating markets.

## Step 4: Install the Plugin (recommended)

```bash
claude plugin add contextwtf/context-plugin
```

This installs the MCP server, skills, and reference files as a package. If you installed the MCP server manually in Step 3, the plugin will use that configuration.

## Step 5: Load Skills

If you installed the plugin, skills are loaded automatically. If not, read the SKILL.md files from this repo directly:

- `skills/trade/SKILL.md` — order management
- `skills/research/SKILL.md` — market analysis
- `skills/build/SKILL.md` — React frontends
- `skills/create/SKILL.md` — market creation

Each SKILL.md has a routing table pointing to subskill workflows.

## Step 6: Verify

Call `context_list_markets` to confirm the MCP server is working. You should see a list of active prediction markets.

## Step 7: Fund the Wallet

- **Testnet:** Call `context_mint_test_usdc` to mint test USDC, then `context_account_setup` to approve contracts.
- **Mainnet:** The user needs to deposit USDC to the wallet address and call `context_account_setup`.

Once setup is complete, you're ready to trade.
