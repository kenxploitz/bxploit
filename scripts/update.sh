#!/bin/sh
set -e

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
BINARY="$BXPLOIT_HOME/bin/bxploit"
BXPLOIT_REPO="kenxploitz/bxploit"

info()    { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
fail()    { printf "  ${RED}[x]${NC} %s\n" "$1"; exit 1; }
success() { printf "  ${GREEN}[✓]${NC} %s\n" "$1"; }

printf "\n  ${BOLD}BXPLOIT UPDATER${NC}\n\n"

[ ! -f "$BINARY" ] && fail "Bxploit not found"

ARCH="$(uname -m)"
case "$ARCH" in x86_64|amd64) ARCH_NAME="x64" ;; aarch64|arm64) ARCH_NAME="arm64" ;; *) fail "Unsupported" ;; esac

info "Downloading latest binary..."
cp "$BINARY" "$BINARY.bak" 2>/dev/null
TMP_DIR=$(mktemp -d)
curl -fsSL -o "$TMP_DIR/bxploit.zip" "https://github.com/$BXPLOIT_REPO/releases/download/v1.0.0/bxploit-linux-${ARCH_NAME}.zip" || fail "Download failed"
cd "$TMP_DIR" && unzip -o bxploit.zip 2>/dev/null || fail "Extract failed"
mv kimi "$BINARY" 2>/dev/null || fail "Binary not found"
chmod +x "$BINARY"
rm -rf "$TMP_DIR"
success "Binary updated"

info "Updating assets..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/bxploit.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null
if [ -f "$TMP/bxploit.zip" ]; then
    cd "$TMP" && unzip -o bxploit.zip 2>/dev/null
    SRC="$TMP/bxploit-main"
    mkdir -p "$BXPLOIT_HOME/skills" "$BXPLOIT_HOME/knowledge" "$BXPLOIT_HOME/plugins"
    [ -d "$SRC/plugins/bxploit-pentest/skills" ] && cp -r "$SRC/plugins/bxploit-pentest/skills/"* "$BXPLOIT_HOME/skills/" 2>/dev/null
    [ -d "$SRC/knowledge" ] && cp -r "$SRC/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
    [ -f "$SRC/plugins/bxploit-pentest/SYSTEM.md" ] && cp "$SRC/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md"
    rm -rf "$TMP"
    success "Assets updated"
fi

printf "\n  ${GREEN}Update Complete!${NC}\n\n"
