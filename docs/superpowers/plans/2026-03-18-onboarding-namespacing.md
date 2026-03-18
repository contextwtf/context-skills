# Onboarding & Namespacing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add platform-specific onboarding docs and namespaced skill IDs so any AI agent can self-setup from the README.

**Architecture:** `onboarding/` folder at repo root with one markdown file per platform (Claude Code, Codex, OpenClaw, Hermes). Each follows a universal linear flow adapted to platform specifics. SKILL.md files get YAML frontmatter with namespaced IDs. README routes agents to onboarding, keeps existing human-readable content.

**Tech Stack:** Markdown only. No code, no tests, no dependencies.

**Spec:** `docs/superpowers/specs/2026-03-18-onboarding-namespacing-design.md`

---

### Task 1: Add namespaced frontmatter to all SKILL.md files

**Files:**
- Modify: `build/SKILL.md` (line 1 — prepend frontmatter)
- Modify: `research/SKILL.md` (line 1 — prepend frontmatter)
- Modify: `trade/SKILL.md` (line 1 — prepend frontmatter)
- Modify: `create/SKILL.md` (line 1 — prepend frontmatter)

- [ ] **Step 1: Add frontmatter to build/SKILL.md**

Prepend before existing line 1 (`# Build Skill`):

```yaml
---
name: context-build
description: Build prediction market frontends with React
---

```

Do NOT change any existing content below the frontmatter.

- [ ] **Step 2: Add frontmatter to research/SKILL.md**

Prepend before existing line 1 (`# Research Skill`):

```yaml
---
name: context-research
description: Discover and analyze prediction markets
---

```

- [ ] **Step 3: Add frontmatter to trade/SKILL.md**

Prepend before existing line 1 (`# Trade Skill`):

```yaml
---
name: context-trade
description: Place and manage prediction market orders
---

```

- [ ] **Step 4: Add frontmatter to create/SKILL.md**

Prepend before existing line 1 (`# Create Skill`):

```yaml
---
name: context-create
description: Create prediction markets from natural language
---

```

- [ ] **Step 5: Verify all four files have frontmatter**

Run: `head -5 build/SKILL.md research/SKILL.md trade/SKILL.md create/SKILL.md`

Expected: Each file starts with `---`, has `name:` and `description:`, closes with `---`, then the original `# <Skill> Skill` heading.

- [ ] **Step 6: Commit**

```bash
git add build/SKILL.md research/SKILL.md trade/SKILL.md create/SKILL.md
git commit -m "feat: add namespaced frontmatter to all SKILL.md files"
```

---

### Task 2: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Agent Setup section after the badges block**

Insert after the line `Skills work across Claude, OpenAI, Cursor...`, before `## Skills`:

```markdown

## Agent Setup

If you're an AI agent getting set up with Context Skills, go to the `onboarding/` folder and read the guide for your platform:

- [Claude Code](./onboarding/claude-code.md)
- [Codex](./onboarding/codex.md)
- [OpenClaw](./onboarding/openclaw.md)
- [Hermes](./onboarding/hermes.md)

```

- [ ] **Step 2: Remove the Install section**

Delete the entire `## Install` section — from the `## Install` heading through the line before `## Adding the MCP Server`. This includes all three subsections (Claude Code Plugin, Claude Code standalone, Other Platforms) and the "See the full installation guide" link.

- [ ] **Step 3: Remove the Adding the MCP Server section**

Delete the entire `## Adding the MCP Server` section — from the `## Adding the MCP Server` heading through the line before `## How Skills Work`. This includes both code blocks (the `claude mcp add` command and the env var exports).

- [ ] **Step 4: Verify README structure**

The README should now have these sections in order:
1. Banner image + title + badges
2. `## Agent Setup` (NEW)
3. `## Skills` (table — unchanged)
4. `## How Skills Work` (unchanged)
5. `## Documentation` (unchanged)
6. `## Ecosystem` (unchanged)
7. `## License` (unchanged)

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "feat: add agent routing to README, remove install sections"
```

---

### Task 3: Create onboarding/claude-code.md

**Files:**
- Create: `onboarding/claude-code.md`

- [ ] **Step 0: Create the onboarding directory**

```bash
mkdir -p onboarding
```

- [ ] **Step 1: Write the Claude Code onboarding doc**

The doc should follow this structure (write conversationally — the agent executes this with the user):

1. **Header** — "Getting Started with Context Skills on Claude Code"
2. **Step 1: Get an API Key** — Tell the user to go to https://context.market/settings and generate an API key. The agent should ask the user to paste it back.
3. **Step 2: Create an Agent Wallet** — The agent generates a new wallet. Explain that this gives the agent its own trading identity. Capture the address and private key.
4. **Step 3: Set Up the MCP Server** — `claude mcp add context-markets --env CONTEXT_API_KEY=<key> --env CONTEXT_PRIVATE_KEY=<key> -- npx context-markets-mcp`
5. **Step 4: Install the CLI** (optional) — `npm install -g context-markets-cli`
6. **Step 5: Install Skills** — Two paths: plugin (`claude plugin add contextwtf/context-plugin`, gives `/context:trade`, `/context:research`, `/context:build`, `/context:create`) or manual (clone repo, copy `prompts/claude.system.md` or `prompts/full.md` into custom instructions).
7. **Step 6: Verify** — Run a test MCP call like `context_list_markets` to confirm connectivity.
8. **Step 7: Fund Your Wallet** (optional) — "To trade, send USDC on Base to your agent wallet address: `<address>`. You can skip this for now and come back when you're ready to trade."

Important: never suggest creating `.env` files. Use `claude mcp add` env flags or shell exports.

- [ ] **Step 2: Commit**

```bash
git add onboarding/claude-code.md
git commit -m "feat: add Claude Code onboarding guide"
```

---

### Task 4: Create onboarding/codex.md

**Files:**
- Create: `onboarding/codex.md`

- [ ] **Step 1: Write the Codex onboarding doc**

Same universal flow, Codex-specific mechanics:

1. **Header** — "Getting Started with Context Skills on Codex"
2. **Step 1: Get an API Key** — Same as Claude Code (context.market/settings).
3. **Step 2: Create an Agent Wallet** — Same wallet generation flow.
4. **Step 3: Set Up the MCP Server** — `codex mcp add context-markets -- npx context-markets-mcp`. For env vars, add to `~/.codex/config.toml`:
   ```toml
   [mcp_servers.context-markets]
   command = "npx"
   args = ["context-markets-mcp"]

   [mcp_servers.context-markets.env]
   CONTEXT_API_KEY = "..."
   CONTEXT_PRIVATE_KEY = "0x..."
   ```
5. **Step 4: Install the CLI** (optional) — same.
6. **Step 5: Load Skills** — Copy contents of `prompts/openai.developer.md` (or `prompts/full.md`) from any skill folder into the project's `AGENTS.md` or system prompt.
7. **Step 6: Verify** — Run a test MCP call.
8. **Step 7: Fund Your Wallet** (optional) — Same USDC on Base flow.

- [ ] **Step 2: Commit**

```bash
git add onboarding/codex.md
git commit -m "feat: add Codex onboarding guide"
```

---

### Task 5: Create onboarding/openclaw.md

**Files:**
- Create: `onboarding/openclaw.md`

- [ ] **Step 1: Write the OpenClaw onboarding doc**

Same universal flow, OpenClaw-specific mechanics:

1. **Header** — "Getting Started with Context Skills on OpenClaw"
2. **Step 1: Get an API Key** — Same flow.
3. **Step 2: Create an Agent Wallet** — Same flow.
4. **Step 3: Set Up the MCP Server** — Add to `~/.openclaw/openclaw.json`:
   ```json
   {
     "mcpServers": {
       "context-markets": {
         "command": "npx",
         "args": ["-y", "context-markets-mcp"],
         "env": {
           "CONTEXT_API_KEY": "...",
           "CONTEXT_PRIVATE_KEY": "0x..."
         }
       }
     }
   }
   ```
   Reminder: restart the OpenClaw gateway after config changes. Keep secrets in env vars or system config, not plaintext in the config file if possible.
5. **Step 4: Install the CLI** (optional) — same.
6. **Step 5: Load Skills** — Copy contents of `prompts/full.md` from any skill folder into custom instructions.
7. **Step 6: Verify** — Confirm MCP tools are available (should see `context_list_markets` etc.).
8. **Step 7: Fund Your Wallet** (optional) — Same.

- [ ] **Step 2: Commit**

```bash
git add onboarding/openclaw.md
git commit -m "feat: add OpenClaw onboarding guide"
```

---

### Task 6: Create onboarding/hermes.md

**Files:**
- Create: `onboarding/hermes.md`

- [ ] **Step 1: Write the Hermes onboarding doc**

Same universal flow, Hermes-specific mechanics:

1. **Header** — "Getting Started with Context Skills on Hermes"
2. **Step 1: Get an API Key** — Same flow.
3. **Step 2: Create an Agent Wallet** — Same flow.
4. **Step 3: Set Up the MCP Server** — Add to `~/.hermes/config.yaml`:
   ```yaml
   mcp_servers:
     context_markets:
       command: npx
       args: ["-y", "context-markets-mcp"]
       timeout: 120
       connect_timeout: 60
       env:
         CONTEXT_API_KEY: "..."
         CONTEXT_PRIVATE_KEY: "0x..."
   ```
   **Critical:** Hermes filters subprocess environment variables. Shell exports do NOT reach MCP subprocesses. You MUST put credentials in the `env` block above, not in your shell profile.
5. **Step 4: Install the CLI** (optional) — same.
6. **Step 5: Install Skills** — Copy skill folders to `~/.hermes/skills/context/` using namespaced names (`context-build`, `context-research`, `context-trade`, `context-create`). Add Hermes-compatible frontmatter if needed.
7. **Step 6: Verify** — Confirm tools like `mcp_context_markets_context_list_markets` appear in Hermes tool discovery.
8. **Step 7: Fund Your Wallet** (optional) — Same.

- [ ] **Step 2: Commit**

```bash
git add onboarding/hermes.md
git commit -m "feat: add Hermes onboarding guide"
```

---

### Task 7: Delete install.sh

**Files:**
- Delete: `install.sh`

- [ ] **Step 1: Delete install.sh**

```bash
git rm install.sh
```

- [ ] **Step 2: Verify no remaining references to install.sh**

Run: `grep -r "install.sh" . --include="*.md" | grep -v docs/superpowers`

Expected: No results (the README reference was already removed in Task 2).

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove install.sh, replaced by onboarding docs"
```

---

### Task 8: Final verification

- [ ] **Step 1: Verify repo structure**

Run: `ls onboarding/ && head -5 build/SKILL.md research/SKILL.md trade/SKILL.md create/SKILL.md && test ! -f install.sh && echo "OK"`

Expected: Four onboarding files listed, all SKILL.md files show frontmatter, install.sh absent, "OK" printed.

- [ ] **Step 2: Verify README sections**

Run: `grep "^## " README.md`

Expected output:
```
## Agent Setup
## Skills
## How Skills Work
## Documentation
## Ecosystem
## License
```

- [ ] **Step 3: Read through each onboarding doc**

Skim each doc to confirm it follows the universal flow, has platform-specific config, and doesn't reference `.env` files or `install.sh`.
