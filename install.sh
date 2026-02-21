#!/usr/bin/env bash
set -e

REPO_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
PORT_DIR="$HOME/.local/opt/codex"
WRAPPER="$HOME/.local/bin/codex-desktop"
DESKTOP_FILE="$HOME/.local/share/applications/codex.desktop"

echo "Installing dependencies (sudo required)..."
sudo pacman -S --needed --noconfirm \
  bash curl p7zip git base-devel nodejs python electron pnpm patch

echo "Installing Codex CLI..."
pnpm add -g @openai/codex

if [ ! -x "$PNPM_HOME/codex" ]; then
echo "Codex CLI not found after install."
  exit 1
fi

echo "Building codex-app from AUR..."
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"
git clone https://aur.archlinux.org/codex-app-bin.git
cd codex-app-bin
makepkg -si --noconfirm

echo "Running codex-app..."
codex-app

if [ -d "$HOME/apps/codex-port" ]; then
  mkdir -p "$(dirname "$PORT_DIR")"
  rm -rf "$PORT_DIR"
  mv "$HOME/apps/codex-port" "$PORT_DIR"
fi

if [ ! -d "$PORT_DIR/app_asar" ]; then
  echo "Port directory not found."
  exit 1
fi

echo "Fixing native module..."
bash "$REPO_DIR/scripts/fix-better-sqlite3.sh" "$PORT_DIR"
echo "Installing launcher..."
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

install -m 0755 "$REPO_DIR/desktop/codex-desktop" "$WRAPPER"
cp "$REPO_DIR/desktop/codex.desktop" "$DESKTOP_FILE"
sed -i "s|Exec=.*|Exec=$WRAPPER|" "$DESKTOP_FILE"

echo "Done."
echo "Launch from your app menu or run:"
echo "$WRAPPER"
