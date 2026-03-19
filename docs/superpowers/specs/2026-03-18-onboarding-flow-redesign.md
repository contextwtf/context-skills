# Onboarding Flow Redesign

**Date:** 2026-03-18
**Status:** Approved

## Problem

When an AI agent is given the Context Skills GitHub repo link, it reads the README and onboarding guides but:

1. The README doesn't clearly direct agents to the onboarding guides — agents run install commands directly and miss setup steps
2. The onboarding guides barrel through the full setup (wallet, funding, approvals, deposit) without asking if the user even wants to trade
3. Skills install commands are missing `--full-depth --yes` flags
4. The interactive `context setup` is shown as the primary command, but agents should use the headless `--output json --save` version
5. There's no "bring your own wallet/key" option surfaced
6. MCP verification is an afterthought — agents don't know to troubleshoot when it fails

## Design

### README changes

**Agent callout** — add a prominent blockquote right after the title/badges, before `## Install`:

```markdown
> **AI Agent?** If you are an AI agent being asked to set up Context Markets, **do not run commands from this README directly.** Go to [`onboarding/`](./onboarding/) and follow the step-by-step guide for your platform. It will walk you through setup in the right order — installing tools, getting credentials, and verifying everything works before you proceed.
```

**`--yes` flag** — update the `npx skills add` command in the Install section to include `--yes`:

```bash
npx skills add contextwtf/context-skills --full-depth --yes
```

**Plugin marketplace command** — the `claude plugin marketplace add contextwtf/context-skills` command remains unchanged (it doesn't take `--full-depth` or `--yes` flags).

**Existing "Agent Setup" section** — remove the existing `## Agent Setup` section from the README. The new agent callout blockquote replaces it.

### Onboarding guides: Tiered flow

Restructure all four platform guides (`claude-code.md`, `codex.md`, `hermes.md`, `openclaw.md`) to follow this tiered flow:

#### Step 1: Install Tools

Install CLI, MCP server, and skills in one step. Platform-specific commands:

| Platform | MCP install | Skills install |
|----------|------------|----------------|
| Claude Code | `claude mcp add context-markets -- npx context-markets-mcp` | Plugin marketplace (Option A) or `npx skills add contextwtf/context-skills -a claude-code --full-depth --yes` (Option B) |
| Codex | `codex mcp add context-markets -- npx context-markets-mcp` | `npx skills add contextwtf/context-skills -a codex --full-depth --yes` |
| Hermes | JSON config block in runtime config | Git clone (primary) or `npx skills add contextwtf/context-skills -a hermes --full-depth --yes` (fallback) |
| OpenClaw | JSON config block in `~/.openclaw/openclaw.json` + restart gateway | `npx skills add contextwtf/context-skills -a openclaw --full-depth --yes` |

CLI install is the same for all: `npm install -g context-markets-cli`

#### Step 2: Get API Key and Verify (Browse & Research)

1. Tell the user to get an API key at `https://context.markets/settings`
2. Run: `context setup --output json --save --api-key <key>` — this saves the API key to `~/.config/context/config.env` and generates a wallet (the wallet is a harmless side effect; the user doesn't need to fund or use it unless they want to trade)
3. Call `context_list_markets` via MCP to confirm the server is working
4. **Troubleshoot if MCP fails:**
   - Verify `~/.config/context/config.env` exists and contains `CONTEXT_API_KEY`
   - Verify the MCP server is registered (platform-specific: `claude mcp list`, check JSON config, etc.)
   - Try running `npx context-markets-mcp` in a standalone terminal to check for errors
   - Restart the agent/gateway if needed
5. Tell the user: **"You're set up to browse and research markets. The skills are installed and the MCP server is connected. If you want to place trades, we need to set up a wallet — want to do that now?"**

The agent STOPS here and waits for the user's response. Do not proceed to Step 3 unless the user says yes.

#### Step 3: Trading Setup (Optional)

Only proceed if the user explicitly wants to trade. A wallet was already generated in Step 2, so this step is about funding and approving it.

1. Ask: "Do you already have a private key or wallet you'd like to use, or do you want to use the one we just generated?"
   - If existing key: `context setup --output json --save --private-key <key>` (overwrites the generated one)
   - If using the generated wallet: no action needed, it's already saved
2. Show the wallet address (from the Step 2 output) and tell user to fund with ETH on Base for gas fees (even a small amount like 0.001 ETH is enough)
3. Run contract approvals: `context approve --output json`
4. Ask about USDC deposit — explain it's optional and they can always deposit later with `context deposit <amount>`

#### Step 4: Verify

Only needed if Step 3 was completed:
- `context account status` (or `context account status --output json`) to confirm wallet is configured and contracts are approved

`context_list_markets` verification already happened in Step 2, so no need to repeat it.

### Key principles across all guides

- **Headless first:** `--output json --save` is the primary command for agents. Interactive `context setup` is mentioned as a fallback the user can run themselves.
- **Agent stops and asks:** Between Step 2 and Step 3, the agent must pause and ask the user if they want trading setup. No barreling through.
- **Bring your own key:** The agent explicitly asks if the user has an existing private key before generating a new wallet.
- **Verify early:** MCP verification happens right after API key setup, not at the end.
- **`--full-depth --yes`:** Every `npx skills add` command includes both flags.

### Platform-specific notes

- **Codex:** Preserve the selective-install option (`--skill context-trade --skill context-research --full-depth --yes`) as an alternative to full install.
- **Hermes:** Git clone remains the primary skills install method; `npx skills add` is the fallback. `--full-depth --yes` only applies to the npx fallback (git clone always gets full depth).
- **OpenClaw:** Note the gateway restart requirement after editing MCP config.

## Files to change

1. `README.md` — Add agent callout after title/badges; add `--yes` to npx install command
2. `onboarding/claude-code.md` — Full rewrite with tiered flow
3. `onboarding/codex.md` — Full rewrite with tiered flow
4. `onboarding/hermes.md` — Full rewrite with tiered flow
5. `onboarding/openclaw.md` — Full rewrite with tiered flow

## CLI flags confirmed

These flags already exist in the CLI (verified against `src/commands/setup.ts`):
- `--api-key <key>` — saves API key to config when used with `--save`
- `--private-key <key>` — uses an existing private key instead of generating one
- `--output json` — non-interactive JSON output mode
- `--save` — persists to `~/.config/context/config.env`
- `context approve --output json` — approve contracts non-interactively

## Out of scope

- MCP server code changes (separate repo)
- CLI code changes (separate repo)
- Skills content changes (skills themselves are fine)
