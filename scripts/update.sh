#!/bin/sh
set -e

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
BINARY="$BXPLOIT_HOME/bin/kimi-code"
CLI_BIN="$HOME/.local/bin/bxploit"
GITHUB_REPO="MoonshotAI/kimi-code"
BXPLOIT_REPO="kenxploitz/bxploit"

info()    { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}[!]${NC} %s\n" "$1"; }
fail()    { printf "  ${RED}[x]${NC} %s\n" "$1"; exit 1; }
success() { printf "  ${GREEN}[✓]${NC} %s\n" "$1"; }

printf "\n"
printf "  ${RED}██████╗ ██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗${NC}\n"
printf "  ${RED}██╔══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝${NC}\n"
printf "  ${RED}██████╔╝ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║${NC}\n"
printf "  ${RED}██╔══██╗ ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║${NC}\n"
printf "  ${RED}██████╔╝██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║${NC}\n"
printf "  ${RED}╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝${NC}\n"
printf "\n"
printf "  ${BOLD}UPDATER${NC}\n\n"

[ ! -f "$BINARY" ] && fail "Bxploit not found. Run install.sh first."

CURRENT_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")
info "Current: $CURRENT_VER"

ARCH="$(uname -m)"
case "$ARCH" in x86_64|amd64) ARCH_NAME="x64" ;; aarch64|arm64) ARCH_NAME="arm64" ;; *) fail "Unsupported: $ARCH" ;; esac

# Update binary
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Update Binary${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

info "Checking latest..."
TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
[ -z "$TAG" ] && fail "Failed to check release"
info "Latest: $TAG"

ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || fail "python3 required")

info "Downloading..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || fail "Download failed"
cd "$TMP" && unzip -o kimi.zip 2>/dev/null || fail "Extract failed"
cp "$BINARY" "$BINARY.bak" 2>/dev/null
mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null || fail "Binary not found"
chmod +x "$BINARY"
rm -rf "$TMP"
success "Binary updated"

# Update assets
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Update Skills & Knowledge${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

info "Downloading assets..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/bxploit.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null || { warn "Assets failed"; rm -rf "$TMP"; }
if [ -f "$TMP/bxploit.zip" ]; then
    cd "$TMP" && unzip -o bxploit.zip 2>/dev/null
    SRC="$TMP/bxploit-main"
    mkdir -p "$BXPLOIT_HOME/skills" "$BXPLOIT_HOME/knowledge" "$BXPLOIT_HOME/plugins" "$BXPLOIT_HOME/scripts"
    [ -d "$SRC/plugins/bxploit-pentest/skills" ] && cp -r "$SRC/plugins/bxploit-pentest/skills/"* "$BXPLOIT_HOME/skills/" 2>/dev/null
    [ -d "$SRC/knowledge" ] && cp -r "$SRC/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
    [ -d "$SRC/plugins/bxploit-pentest" ] && cp -r "$SRC/plugins/bxploit-pentest/"* "$BXPLOIT_HOME/plugins/bxploit-pentest/" 2>/dev/null
    [ -f "$SRC/plugins/bxploit-pentest/SYSTEM.md" ] && cp "$SRC/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md"
    for s in bxploit.sh setup.sh update.sh uninstall.sh; do [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$BXPLOIT_HOME/scripts/" 2>/dev/null; done
    rm -rf "$TMP"
    success "Skills: $(find "$BXPLOIT_HOME/skills" -name "*.md" 2>/dev/null | wc -l) files"
    success "Knowledge: $(find "$BXPLOIT_HOME/knowledge" -name "*.md" 2>/dev/null | wc -l) files"
fi

NEW_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")

printf "\n  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  Updated: $CURRENT_VER → $NEW_VER${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"
printf "  ${CYAN}Run: bxploit${NC}\n\n"
