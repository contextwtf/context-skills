# Onboarding Flow Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure README and onboarding guides so agents follow a tiered setup flow (browse-only → optional trading) instead of barreling through wallet/deposit setup.

**Architecture:** Pure documentation changes across 5 markdown files. No code changes. Each onboarding guide follows an identical 4-step tiered flow with platform-specific commands swapped in.

**Tech Stack:** Markdown

**Spec:** `docs/superpowers/specs/2026-03-18-onboarding-flow-redesign.md`

---

### Task 1: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add agent callout blockquote after badges, before `## Install`**

Insert this block between line 11 (closing `</p>` of badges) and line 13 (`## Install`):

```markdown

> **AI Agent?** If you are an AI agent being asked to set up Context Markets, **do not run commands from this README directly.** Go to [`onboarding/`](./onboarding/) and follow the step-by-step guide for your platform. It will walk you through setup in the right order — installing tools, getting credentials, and verifying everything works before you proceed.

```

- [ ] **Step 2: Add `--yes` flag to npx install command**

Change line 22 from:
```bash
npx skills add contextwtf/context-skills --full-depth
```
to:
```bash
npx skills add contextwtf/context-skills --full-depth --yes
```

The plugin marketplace command on line 17 stays unchanged.

- [ ] **Step 3: Remove the "Agent Setup" subsection**

Delete the entire `### Agent Setup` block (lines 27-34):
```markdown
### Agent Setup

Go to `onboarding/` and follow the guide for your platform:

- [Claude Code](./onboarding/claude-code.md)
- [Codex](./onboarding/codex.md)
- [OpenClaw](./onboarding/openclaw.md)
- [Hermes](./onboarding/hermes.md)
```

This is now redundant — the agent callout blockquote replaces it.

- [ ] **Step 4: Verify README renders correctly**

Read the file back and confirm:
- Agent callout appears between badges and `## Install`
- npx command has `--full-depth --yes`
- No `### Agent Setup` section remains
- The `## Skills` section follows `## Install` directly

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add agent callout, --yes flag, remove redundant Agent Setup section"
```

---

### Task 2: Rewrite onboarding/claude-code.md

**Files:**
- Modify: `onboarding/claude-code.md`

- [ ] **Step 1: Replace entire file with tiered flow**

Write the following content to `onboarding/claude-code.md`:

```markdown
# Setting Up Context Markets on Claude Code

You are an AI agent setting up Context Markets for your user. Follow these steps in order. **Do not skip ahead** — complete each step and verify before moving on.

## Step 1: Install Tools

Install all three components — CLI, MCP server, and skills.

**CLI** (headless setup + shell access):
```bash
npm install -g context-markets-cli
```

**MCP Server** (19 tools for markets, trading, portfolio, account, and questions):
```bash
claude mcp add context-markets -- npx context-markets-mcp
```

**Skills — Option A (plugin, recommended):**
```bash
claude plugin marketplace add contextwtf/context-skills
```

**Skills — Option B (skills CLI):**
```bash
npx skills add contextwtf/context-skills -a claude-code --full-depth --yes
```

## Step 2: Get API Key and Verify (Browse & Research)

1. Ask the user for their Context API key. They can get one at **https://context.markets/settings**.

2. Run the headless setup to save credentials:
```bash
context setup --output json --save --api-key <USER_API_KEY>
```
This saves the API key to `~/.config/context/config.env` and generates a wallet. The wallet is a harmless side effect — the user doesn't need to fund or use it unless they want to trade.

3. Verify the MCP server is working by calling `context_list_markets`. You should see a list of active prediction markets.

4. **If MCP fails**, troubleshoot:
   - Check that `~/.config/context/config.env` exists and contains `CONTEXT_API_KEY`
   - Verify the MCP server is registered: run `claude mcp list` and look for `context-markets`
   - Try running `npx context-markets-mcp` directly to check for errors
   - Restart Claude Code if needed

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
```

- [ ] **Step 2: Read back and verify**

Read the file back and confirm:
- Title matches platform
- Step 1 has all three installs (CLI, MCP, skills with `--full-depth --yes`)
- Step 2 uses `--output json --save --api-key` (headless)
- Step 2 has MCP troubleshooting
- Step 2 ends with STOP checkpoint
- Step 3 asks about existing key
- Step 3 is explicitly optional

- [ ] **Step 3: Commit**

```bash
git add onboarding/claude-code.md
git commit -m "docs: rewrite claude-code onboarding with tiered flow"
```

---

### Task 3: Rewrite onboarding/codex.md

**Files:**
- Modify: `onboarding/codex.md`

- [ ] **Step 1: Replace entire file with tiered flow**

Write the following content to `onboarding/codex.md`:

```markdown
# Setting Up Context Markets on Codex

You are an AI agent setting up Context Markets for your user. Follow these steps in order. **Do not skip ahead** — complete each step and verify before moving on.

## Step 1: Install Tools

Install all three components — CLI, MCP server, and skills.

**CLI** (headless setup + shell access):
```bash
npm install -g context-markets-cli
```

**MCP Server** (19 tools for markets, trading, portfolio, account, and questions):
```bash
codex mcp add context-markets -- npx context-markets-mcp
```

**Skills (full install):**
```bash
npx skills add contextwtf/context-skills -a codex --full-depth --yes
```

This installs all Context skills to `.agents/skills/` where Codex discovers them automatically.

Alternatively, install specific skills:
```bash
npx skills add contextwtf/context-skills -a codex --skill context-trade --skill context-research --full-depth --yes
```

## Step 2: Get API Key and Verify (Browse & Research)

1. Ask the user for their Context API key. They can get one at **https://context.markets/settings**.

2. Run the headless setup to save credentials:
```bash
context setup --output json --save --api-key <USER_API_KEY>
```
This saves the API key to `~/.config/context/config.env` and generates a wallet. The wallet is a harmless side effect — the user doesn't need to fund or use it unless they want to trade.

3. Verify the MCP server is working by calling `context_list_markets`. You should see a list of active prediction markets.

4. **If MCP fails**, troubleshoot:
   - Check that `~/.config/context/config.env` exists and contains `CONTEXT_API_KEY`
   - Verify the MCP server is registered with Codex
   - Try running `npx context-markets-mcp` directly to check for errors

5. Run `/skills` to confirm the Context skills are loaded.

6. Tell the user:

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
```

- [ ] **Step 2: Read back and verify**

Same checks as Task 2, plus: selective install command includes `--full-depth --yes`.

- [ ] **Step 3: Commit**

```bash
git add onboarding/codex.md
git commit -m "docs: rewrite codex onboarding with tiered flow"
```

---

### Task 4: Rewrite onboarding/hermes.md

**Files:**
- Modify: `onboarding/hermes.md`

- [ ] **Step 1: Replace entire file with tiered flow**

Write the following content to `onboarding/hermes.md`:

```markdown
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
```

- [ ] **Step 2: Read back and verify**

Same checks as Task 2, plus: git clone is primary skills method, npx fallback includes `-a hermes --full-depth --yes`.

- [ ] **Step 3: Commit**

```bash
git add onboarding/hermes.md
git commit -m "docs: rewrite hermes onboarding with tiered flow"
```

---

### Task 5: Rewrite onboarding/openclaw.md

**Files:**
- Modify: `onboarding/openclaw.md`

- [ ] **Step 1: Replace entire file with tiered flow**

Write the following content to `onboarding/openclaw.md`:

```markdown
# Setting Up Context Markets on OpenClaw

You are an AI agent setting up Context Markets for your user. Follow these steps in order. **Do not skip ahead** — complete each step and verify before moving on.

## Step 1: Install Tools

Install all three components — CLI, MCP server, and skills.

**CLI** (headless setup + shell access):
```bash
npm install -g context-markets-cli
```

**MCP Server** — add to `~/.openclaw/openclaw.json`:
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

**Restart the OpenClaw gateway** after editing the config.

**Skills:**
```bash
npx skills add contextwtf/context-skills -a openclaw --full-depth --yes
```

This installs skills to OpenClaw's skill directory where they're discovered automatically.

## Step 2: Get API Key and Verify (Browse & Research)

1. Ask the user for their Context API key. They can get one at **https://context.markets/settings**.

2. Run the headless setup to save credentials:
```bash
context setup --output json --save --api-key <USER_API_KEY>
```
This saves the API key to `~/.config/context/config.env` and generates a wallet. The wallet is a harmless side effect — the user doesn't need to fund or use it unless they want to trade.

3. Verify the MCP server is working by calling `context_list_markets`. You should see a list of active prediction markets.

4. **If MCP fails**, troubleshoot:
   - Check that `~/.config/context/config.env` exists and contains `CONTEXT_API_KEY`
   - Verify the MCP server block is in `~/.openclaw/openclaw.json`
   - Try running `npx context-markets-mcp` directly to check for errors
   - Restart the OpenClaw gateway

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
```

- [ ] **Step 2: Read back and verify**

Same checks as Task 2, plus: MCP config goes in `~/.openclaw/openclaw.json`, gateway restart is noted.

- [ ] **Step 3: Commit**

```bash
git add onboarding/openclaw.md
git commit -m "docs: rewrite openclaw onboarding with tiered flow"
```
