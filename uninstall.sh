#!/usr/bin/env bash
set -e

rm -rf "$HOME/.local/opt/codex"
rm -f "$HOME/.local/bin/codex-desktop"
rm -f "$HOME/.local/share/applications/codex.desktop"

echo "Removed Codex desktop install."
