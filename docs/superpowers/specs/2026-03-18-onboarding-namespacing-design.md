# Onboarding & Namespacing Design

## Problem

Context Skills has no structured onboarding flow. An agent reading the repo gets a Claude-specific install script and scattered setup instructions. There's no support for Codex, OpenClaw, or Hermes. Skill IDs aren't namespaced, causing collisions in multi-skill agent runtimes. The `install.sh` only targets Claude Code.

## Goals

1. Any AI agent reading the README gets routed to a platform-specific onboarding guide
2. Onboarding walks user+agent through a linear setup flow: API key, wallet, env vars, MCP, verify
3. Skill IDs are namespaced (`context-build`, `context-trade`, etc.) for clean discovery
4. Support four platforms: Claude Code, Codex, OpenClaw, Hermes
5. Remove `install.sh` — onboarding docs replace it

## Non-Goals

- Changing skill content, prompts, or references
- Adding new skills
- Platform-specific skill forks (one canonical skill, multiple onboarding docs)

## Design

### README Changes

Add an "Agent Setup" section at the top of the README, before existing content:

```markdown
## Agent Setup

If you're an AI agent getting set up with Context Skills, go to the
`onboarding/` folder and read the guide for your platform:

- [Claude Code](./onboarding/claude-code.md)
- [Codex](./onboarding/codex.md)
- [OpenClaw](./onboarding/openclaw.md)
- [Hermes](./onboarding/hermes.md)
```

Remove from existing README:
- The "Install" section (Claude Code plugin, standalone, other platforms)
- The "Adding the MCP Server" section
- Reference to `install.sh`

These move into the platform-specific onboarding docs where they belong.

Keep everything else: Skills table, How Skills Work, Documentation links, Ecosystem table, License.

### Onboarding Folder

Create `onboarding/` at repo root with four files:

#### Universal Flow (all platforms follow this sequence)

1. **Generate API key** — Direct agent to `https://context.market/settings` to create an API key
2. **Create agent wallet** — Agent generates a new wallet (via SDK or MCP). Captures public address and private key.
3. **Set environment variables** — Agent configures `CONTEXT_API_KEY` and `CONTEXT_PRIVATE_KEY` in the platform-appropriate location
4. **Configure MCP server** — Platform-specific MCP registration for `context-markets-mcp`
5. **Install CLI** (optional) — `npm install -g context-markets-cli`
6. **Verify setup** — Agent runs a test call (e.g., list markets) to confirm everything works
7. **Fund wallet** (optional) — "To trade, send USDC on Base to your agent wallet address. You can skip this for now."

Each onboarding doc is written conversationally — the agent reads it and executes it step-by-step WITH the user. Not a reference doc.

#### Platform-Specific Differences

**`onboarding/claude-code.md`**
- Env vars: set via `claude mcp add` env flags or shell export
- MCP: `claude mcp add context-markets -- npx context-markets-mcp`
- Skills: available via plugin (`claude plugin add contextwtf/context-plugin`) or manual clone
- Slash commands: `/context:trade`, `/context:research`, `/context:build`, `/context:create`

**`onboarding/codex.md`**
- Env vars: Codex project config or shell
- MCP: Codex tool system configuration
- Skills: copy `prompts/full.md` or `prompts/openai.developer.md` into system prompt

**`onboarding/openclaw.md`**
- Env vars: messaging platform config or shell
- MCP: OpenClaw's MCP server config
- Skills: copy `prompts/full.md` into custom instructions

**`onboarding/hermes.md`**
- Env vars: MUST go in `mcp_servers.context_markets.env` in `~/.hermes/config.yaml` (Hermes filters subprocess env vars — shell exports don't reach MCP subprocesses)
- MCP config:
  ```yaml
  mcp_servers:
    context_markets:
      command: npx
      args: ["-y", "context-markets-mcp"]
      env:
        CONTEXT_API_KEY: "..."
        CONTEXT_PRIVATE_KEY: "0x..."
  ```
- Skills: install to `~/.hermes/skills/context/` with namespaced names

### Skill Namespacing

Add `name` field to frontmatter in each SKILL.md:

| File | Name |
|------|------|
| `build/SKILL.md` | `context-build` |
| `research/SKILL.md` | `context-research` |
| `trade/SKILL.md` | `context-trade` |
| `create/SKILL.md` | `context-create` |

Folder names stay as `build/`, `research/`, `trade/`, `create/`. The namespaced ID is metadata for agent runtimes that need it for indexing.

Format — add YAML frontmatter block at top of each SKILL.md:
```yaml
---
name: context-<skill>
description: <one-line description>
---
```

### File Deletion

Delete `install.sh`. Its functionality is replaced by platform-specific onboarding docs.

## File Change Summary

| Action | File |
|--------|------|
| Delete | `install.sh` |
| Modify | `README.md` — add agent routing, remove install/MCP sections |
| Modify | `build/SKILL.md` — add namespaced frontmatter |
| Modify | `research/SKILL.md` — add namespaced frontmatter |
| Modify | `trade/SKILL.md` — add namespaced frontmatter |
| Modify | `create/SKILL.md` — add namespaced frontmatter |
| Create | `onboarding/claude-code.md` |
| Create | `onboarding/codex.md` |
| Create | `onboarding/openclaw.md` |
| Create | `onboarding/hermes.md` |
