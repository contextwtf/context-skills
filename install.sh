#!/bin/bash
set -e

SKILLS=("trade" "research" "build" "create")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# If specific skill requested, only install that one
if [ -n "$1" ]; then
  if [[ ! " ${SKILLS[*]} " =~ " $1 " ]]; then
    echo "Unknown skill: $1"
    echo "Available skills: ${SKILLS[*]}"
    exit 1
  fi
  SKILLS=("$1")
fi

# Claude Code installation
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  target="$CLAUDE_SKILLS_DIR/context-$skill"
  if [ -L "$target" ] || [ -d "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$SCRIPT_DIR/$skill" "$target"
  echo "Installed context-$skill -> $target"
done

echo ""
echo "Done. Add the Context MCP server if you haven't already:"
echo ""
echo "  claude mcp add context-markets -- npx @contextwtf/mcp"
echo ""

if [[ " ${SKILLS[*]} " =~ " trade " ]] || [[ " ${SKILLS[*]} " =~ " create " ]]; then
  echo "Trade and Create skills require environment variables:"
  echo "  export CONTEXT_API_KEY=\"your-api-key\""
  echo "  export CONTEXT_PRIVATE_KEY=\"0x...\""
  echo ""
fi
