#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — Updater
# Usage: bxploit --update
#        sh update.sh
# ============================================================================

set -e

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6) BOLD=$(tput bold) RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
BINARY="$BXPLOIT_HOME/bin/kimi-code"
CLI_BIN="$HOME/.local/bin/bxploit"
GITHUB_REPO="MoonshotAI/kimi-code"
BXPLOIT_REPO="kenxploitz/bxploit"

info()  { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
warn()  { printf "  ${YELLOW}[!]${NC} %s\n" "$1"; }
fail()  { printf "  ${RED}[x]${NC} %s\n" "$1"; exit 1; }
success() { printf "  ${GREEN}[✓]${NC} %s\n" "$1"; }

# Banner
printf "\n"
printf "  ${RED}██████╗ ██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗${NC}\n"
printf "  ${RED}██╔══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝${NC}\n"
printf "  ${RED}██████╔╝ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║${NC}\n"
printf "  ${RED}██╔══██╗ ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║${NC}\n"
printf "  ${RED}██████╔╝██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║${NC}\n"
printf "  ${RED}╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝${NC}\n"
printf "\n"
printf "  ${BOLD}UPDATER${NC}\n\n"

# Check installation
[ ! -f "$BINARY" ] && fail "Bxploit not found. Run install.sh first."

# Get current version
CURRENT_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")
info "Current: $CURRENT_VER"

# Detect arch
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64) ARCH_NAME="x64" ;;
    aarch64|arm64) ARCH_NAME="arm64" ;;
    *) fail "Unsupported: $ARCH" ;;
esac

# ── Update Binary ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Update Binary${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

info "Checking latest release..."
TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
[ -z "$TAG" ] && fail "Failed to check latest release"
info "Latest: $TAG"

ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || fail "python3 required")

info "Downloading binary..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || fail "Download failed"
cd "$TMP" && unzip -o kimi.zip 2>/dev/null || fail "Extract failed"

# Backup
cp "$BINARY" "$BINARY.bak" 2>/dev/null

# Replace
mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null || fail "Binary not found"
chmod +x "$BINARY"
rm -rf "$TMP"
success "Binary updated"

# ── Update Assets ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Update Skills & Knowledge${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

info "Downloading assets..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/bxploit.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null || { warn "Assets download failed"; rm -rf "$TMP"; }
if [ -f "$TMP/bxploit.zip" ]; then
    cd "$TMP" && unzip -o bxploit.zip 2>/dev/null
    SRC="$TMP/bxploit-main"

    # Update skills
    if [ -d "$SRC/plugins/bxploit-pentest/skills" ]; then
        mkdir -p "$BXPLOIT_HOME/skills"
        cp -r "$SRC/plugins/bxploit-pentest/skills/"* "$BXPLOIT_HOME/skills/" 2>/dev/null
        success "Skills updated"
    fi

    # Update knowledge
    if [ -d "$SRC/knowledge" ]; then
        mkdir -p "$BXPLOIT_HOME/knowledge"
        cp -r "$SRC/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
        KNOWLEDGE=$(find "$BXPLOIT_HOME/knowledge" -name "*.md" 2>/dev/null | wc -l)
        success "Knowledge updated ($KNOWLEDGE files)"
    fi

    # Update plugin
    if [ -d "$SRC/plugins/bxploit-pentest" ]; then
        mkdir -p "$BXPLOIT_HOME/plugins"
        cp -r "$SRC/plugins/bxploit-pentest" "$BXPLOIT_HOME/plugins/" 2>/dev/null
        success "Plugin updated"
    fi

    # Update SYSTEM.md
    [ -f "$SRC/plugins/bxploit-pentest/SYSTEM.md" ] && cp "$SRC/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md"

    # Update scripts
    mkdir -p "$BXPLOIT_HOME/scripts"
    for s in bxploit.sh setup.sh update.sh uninstall.sh install.sh; do
        [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$BXPLOIT_HOME/scripts/" 2>/dev/null
    done

    # Update CLI wrapper
    if [ -f "$SRC/scripts/install.sh" ]; then
        # Re-create CLI wrapper from install.sh
        mkdir -p "$(dirname "$CLI_BIN")"
        cat > "$CLI_BIN" << 'WRAPPER'
#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
export BXPLOIT_HOME="$BXPLOIT_HOME"
[ ! -d "$HOME/.kimi-code" ] && ln -sf "$BXPLOIT_HOME" "$HOME/.kimi-code" 2>/dev/null
BXPLOIT_BIN="$BXPLOIT_HOME/bin/kimi-code"
[ ! -f "$BXPLOIT_BIN" ] && echo "Error: bxploit not installed" && exit 1
printf '\033]0;Bxploit\007'
case "$1" in
    --setup|-s) exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@" ;;
    --config|-c) cat "$BXPLOIT_HOME/config.toml" 2>/dev/null || echo "No config. Run: bxploit --setup"; exit 0 ;;
    --test|-t)
        BASE_URL=$(grep 'base_url' "$BXPLOIT_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        API_KEY=$(grep 'api_key' "$BXPLOIT_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'OK: {len(d.get(\"data\",[]))} models')" 2>/dev/null || echo "Failed"; exit 0 ;;
    --uninstall) exec sh "$BXPLOIT_HOME/scripts/uninstall.sh" ;;
    --update|-u) exec sh "$BXPLOIT_HOME/scripts/update.sh" ;;
    --help|-h) echo "BXPLOIT — AI Pentest Framework"; echo "Usage: bxploit [-p query|--setup|--config|--test|--update|--uninstall|--help]"; exit 0 ;;
esac
[ ! -f "$BXPLOIT_HOME/config.toml" ] && echo "Run: bxploit --setup" && exit 1
HAS_PROMPT=0; for a in "$@"; do [ "$a" = "-p" ] && HAS_PROMPT=1; done
if [ "$HAS_PROMPT" = "1" ]; then exec "$BXPLOIT_BIN" "$@"; else exec "$BXPLOIT_BIN" --yolo "$@"; fi
WRAPPER
        chmod +x "$CLI_BIN"
        success "CLI wrapper updated"
    fi

    rm -rf "$TMP"
fi

# ── Verify ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Verify${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

NEW_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")
[ -f "$BINARY" ] && success "Binary OK" || fail "Binary missing"
[ -f "$CLI_BIN" ] && success "CLI OK" || fail "CLI missing"

printf "\n  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  Updated: $CURRENT_VER → $NEW_VER${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"
printf "  ${CYAN}Run: bxploit${NC}\n\n"
