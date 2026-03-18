# Setting Up Context Markets on Codex

You are an AI agent setting up Context Markets for your user. Follow these steps in order.

## Step 1: Install CLI and MCP Server

Install both tools — they share credentials via `~/.config/context/config.env`.

**CLI** (interactive setup wizard + shell access):
```bash
npm install -g context-markets-cli
```

**MCP Server** (19 tools for markets, trading, portfolio, account, and questions):
```bash
codex mcp add context-markets -- npx context-markets-mcp
```

## Step 2: Run Setup Wizard

The CLI has an interactive setup wizard that walks the user through everything:

```bash
context setup
```

This will:
1. Ask for the user's API key (get one at **https://context.markets/settings**)
2. Generate a new wallet (or import an existing private key)
3. Save credentials to `~/.config/context/config.env` (shared with MCP)
4. Check ETH balance for gas fees — show the wallet address and wait for funding
5. Approve contracts for trading
6. Prompt for an optional USDC deposit

For non-interactive (agent-driven) setup:
```bash
context setup --output json --save
```

**Fallback — if the CLI isn't available**, use MCP tools directly:
```
context_generate_wallet({ apiKey: "<key>" })
context_account_setup()
context_deposit({ amount: <usdc_amount> })
```

## Step 3: Install Skills

```bash
npx skills add contextwtf/context-skills -a codex
```

This installs all Context skills to `.agents/skills/` where Codex discovers them automatically. Codex reads the `name` and `description` from each SKILL.md and loads the full content on demand.

Alternatively, install specific skills:

```bash
npx skills add contextwtf/context-skills -a codex --skill context-trade --skill context-research
```

## Step 4: Verify

Call `context_list_markets` to confirm the MCP server is connected. You should see active prediction markets.

Run `/skills` to confirm the Context skills are loaded.

Run `context account status` in the CLI to confirm the wallet is configured and ready to trade.
