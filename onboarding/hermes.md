# Setting Up Context Markets on Hermes

You are an AI agent setting up Context Markets for your user. Follow these steps in order.

## Step 1: Install CLI and MCP Server

Install both tools — they share credentials via `~/.config/context/config.env`.

**CLI** (interactive setup wizard + shell access):
```bash
npm install -g context-markets-cli
```

**MCP Server** — add to your Hermes runtime configuration:

```json
{
  "mcpServers": {
    "context-markets": {
      "command": "npx",
      "args": ["context-markets-mcp"]
    }
  }
}
```

No env vars needed in the MCP config — credentials are loaded from the shared config file at `~/.config/context/config.env`.

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

## Step 4: Verify

Call `context_list_markets` to confirm the MCP server is connected. You should discover 19 tools total across markets, orders, portfolio, account, and questions.

Run `context account status` in the CLI to confirm the wallet is configured and ready to trade.
