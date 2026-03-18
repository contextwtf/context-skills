# Setting Up Context Markets on Codex

You are an AI agent setting up Context Markets for your user. Follow these steps in order.

## Step 1: Get an API Key

Ask the user to go to **https://context.markets/settings** and generate an API key. Store it as `CONTEXT_API_KEY`.

## Step 2: Generate a Wallet

Generate an Ethereum private key for signing orders:

```bash
node -e "console.log('0x' + require('crypto').randomBytes(32).toString('hex'))"
```

Store as `CONTEXT_PRIVATE_KEY`. Tell the user to save it securely.

## Step 3: Add the MCP Server

```bash
codex mcp add context-markets -- npx context-markets-mcp
```

## Step 4: Set Environment Variables

Add to `~/.codex/config.toml`:

```toml
[env]
CONTEXT_API_KEY = "<key>"
CONTEXT_PRIVATE_KEY = "<key>"
```

## Step 5: Install Skills

```bash
npx skills add contextwtf/context-skills -a codex
```

This installs all Context skills to `.agents/skills/` where Codex discovers them automatically. Codex reads the `name` and `description` from each SKILL.md and loads the full content on demand.

Alternatively, install specific skills:

```bash
npx skills add contextwtf/context-skills -a codex --skill context-trade --skill context-research
```

## Step 6: Verify

Call `context_list_markets` to confirm the MCP server is connected. You should see active prediction markets.

Run `/skills` to confirm the Context skills are loaded.

## Step 7: Fund the Wallet

- **Testnet:** Call `context_mint_test_usdc` then `context_account_setup`.
- **Mainnet:** User deposits USDC to the wallet, then call `context_account_setup`.
