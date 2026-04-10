#!/usr/bin/env bash
#
# Claude Code Status Line — Uninstaller
# Restores original settings and removes the status line
#

set -e

CLAUDE_DIR="$HOME/.claude"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   🗑️  Claude Code Status Line — Uninstall    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# --- Restore original settings.json ---
if [ -f "$CLAUDE_DIR/settings.json.bkp-before-statusline" ]; then
  cp "$CLAUDE_DIR/settings.json.bkp-before-statusline" "$CLAUDE_DIR/settings.json"
  rm -f "$CLAUDE_DIR/settings.json.bkp-before-statusline"
  echo "  ✅ settings.json restaurado ao original"
else
  echo "  ⚠️  Backup nao encontrado — removendo statusLine manualmente..."
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    # Remove the statusLine key (simple sed approach)
    sed -i.tmp 's/,"statusLine":{[^}]*{[^}]*}}//;s/"statusLine":{[^}]*{[^}]*}},*//' "$CLAUDE_DIR/settings.json"
    rm -f "$CLAUDE_DIR/settings.json.tmp"
    echo "  ✅ statusLine removido do settings.json"
  fi
fi

# --- Remove the script ---
rm -f "$CLAUDE_DIR/statusline-command.sh"
echo "  ✅ statusline-command.sh removido"

# --- Remove self ---
rm -f "$CLAUDE_DIR/uninstall-statusline.sh"
echo "  ✅ Uninstaller removido"

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │  ✨ Desinstalacao completa!                  │"
echo "  │                                              │"
echo "  │  Reinicie o Claude Code para aplicar.        │"
echo "  └──────────────────────────────────────────────┘"
echo ""
