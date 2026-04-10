#!/usr/bin/env bash
#
# Claude Code Status Line — Installer
# One-command setup for the custom status line
#

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   🐙 Claude Code Status Line — Installer    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# --- Create ~/.claude if needed ---
mkdir -p "$CLAUDE_DIR"

# --- Backup existing settings ---
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bkp-before-statusline"
  echo "  ✅ Backup criado: ~/.claude/settings.json.bkp-before-statusline"
fi

# --- Copy the script ---
cp "$SCRIPT_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"
echo "  ✅ Script instalado: ~/.claude/statusline-command.sh"

# --- Copy the uninstaller ---
cp "$SCRIPT_DIR/uninstall.sh" "$CLAUDE_DIR/uninstall-statusline.sh"
chmod +x "$CLAUDE_DIR/uninstall-statusline.sh"
echo "  ✅ Uninstaller copiado: ~/.claude/uninstall-statusline.sh"

# --- Update settings.json ---
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  # Check if statusLine already exists
  if grep -q '"statusLine"' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    echo "  ⚠️  statusLine ja existe no settings.json — pulando"
  else
    # Insert statusLine before the last closing brace
    sed -i.tmp 's/}$/,"statusLine":{"type":"command","command":"bash ~\/.claude\/statusline-command.sh"}}/' "$CLAUDE_DIR/settings.json"
    rm -f "$CLAUDE_DIR/settings.json.tmp"
    echo "  ✅ settings.json atualizado com statusLine"
  fi
else
  # Create fresh settings.json
  cat > "$CLAUDE_DIR/settings.json" << 'SETTINGS'
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
SETTINGS
  echo "  ✅ settings.json criado com statusLine"
fi

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │  🎉 Instalacao completa!                     │"
echo "  │                                              │"
echo "  │  Reinicie o Claude Code para ver a barra.    │"
echo "  │                                              │"
echo "  │  Para desinstalar:                           │"
echo "  │  bash ~/.claude/uninstall-statusline.sh      │"
echo "  └──────────────────────────────────────────────┘"
echo ""
