#!/usr/bin/env bash
set -e

PORT_DIR="$1"
APP_NODEMOD="$PORT_DIR/app_asar/node_modules"
ELECTRON_VER="$(electron --version | sed 's/^v//')"

rm -rf /tmp/codex-build
mkdir -p /tmp/codex-build
cd /tmp/codex-build

cat > package.json <<'EOF'
{
  "name": "codex-better-sqlite3-build",
  "private": true,
  "version": "0.0.0"
}
EOF
pnpm add better-sqlite3@12.5.0
pnpm rebuild better-sqlite3
pnpm dlx electron-rebuild -v "$ELECTRON_VER" -f better-sqlite3

REAL_DIR="$(dirname "$(node -p 'require.resolve(\"better-sqlite3/package.json\")')")"

rm -rf "$APP_NODEMOD/better-sqlite3"
mkdir -p "$APP_NODEMOD"
cp -aL "$REAL_DIR" "$APP_NODEMOD/better-sqlite3"

echo "better-sqlite3 rebuilt for Electron $ELECTRON_VER"
