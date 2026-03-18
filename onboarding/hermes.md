# Setting Up Context Markets on Hermes

You are an AI agent setting up Context Markets for your user. Follow these steps in order. **Do not skip ahead** — complete each step and verify before moving on.

## Step 1: Install Tools

Install all three components — CLI, MCP server, and skills.

**CLI** (headless setup + shell access):
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

No env vars needed in the MCP config — credentials are loaded from `~/.config/context/config.env`.

**Skills — Primary method (clone the repo):**
```bash
git clone https://github.com/contextwtf/context-skills.git
```

Load the SKILL.md files from the `skills/` directory. Each category router (`skills/trade/SKILL.md`, `skills/research/SKILL.md`, etc.) contains a routing table pointing to subskill workflows you read on demand.

**Skills — Fallback (skills CLI):**
```bash
npx skills add contextwtf/context-skills -a hermes --full-depth --yes
```

## Step 2: Get API Key and Verify (Browse & Research)

1. Ask the user for their Context API key. They can get one at **https://context.markets/settings**.

2. Run the headless setup to save credentials:
```bash
context setup --output json --save --api-key <USER_API_KEY>
```
This saves the API key to `~/.config/context/config.env` and generates a wallet. The wallet is a harmless side effect — the user doesn't need to fund or use it unless they want to trade.

3. Verify the MCP server is working by calling `context_list_markets`. You should discover 19 tools total across markets, orders, portfolio, account, and questions.

4. **If MCP fails**, troubleshoot:
   - Check that `~/.config/context/config.env` exists and contains `CONTEXT_API_KEY`
   - Verify the MCP server block is in your Hermes runtime configuration
   - Try running `npx context-markets-mcp` directly to check for errors
   - Restart the Hermes runtime if needed

5. Tell the user:

> **You're set up to browse and research markets.** The skills are installed and the MCP server is connected. If you want to place trades, we need to set up your wallet for trading — want to do that now?

**STOP here and wait for the user's response.** Do not proceed to Step 3 unless the user says yes.

## Step 3: Trading Setup (Optional)

Only proceed if the user explicitly wants to trade. A wallet was already generated in Step 2 — this step is about funding and approving it.

1. Ask the user: **"Do you already have a private key or wallet you'd like to use, or do you want to use the one we just generated?"**
   - If they have an existing key: `context setup --output json --save --private-key <THEIR_KEY>`
   - If using the generated wallet: no action needed, it's already saved

2. Show the wallet address (from the Step 2 output) and tell the user to fund it with ETH on Base for gas fees. Even a small amount (0.001 ETH) is enough for many transactions.

3. Once funded, approve contracts:
```bash
context approve --output json
```

4. Ask the user if they want to deposit USDC to start trading. Explain this is optional — they can always deposit later with `context deposit <amount>`.

## Step 4: Verify

Only needed if you completed Step 3:

```bash
context account status --output json
```

Confirm the wallet is configured and contracts are approved.
