#!/bin/sh
# ============================================================
# BXPLOIT — One-Liner Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/scripts/install.sh -o /tmp/bxploit-install.sh && chmod +x /tmp/bxploit-install.sh && /tmp/bxploit-install.sh
# ============================================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/.bxploit"
CONFIG_FILE="$INSTALL_DIR/config.toml"
BINARY="$INSTALL_DIR/bin/kimi-code"
CLI_BIN="$HOME/.local/bin/bxploit"
GITHUB_REPO="MoonshotAI/kimi-code"
BXPLOIT_REPO="kenxploitz/bxploit"
MARKER="# Bxploit"

banner() {
    printf "\n"
    printf "${RED}  ██████╗ ██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗${NC}\n"
    printf "${RED}  ██╔══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝${NC}\n"
    printf "${RED}  ██████╔╝ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║${NC}\n"
    printf "${RED}  ██╔══██╗ ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║${NC}\n"
    printf "${RED}  ██████╔╝██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║${NC}\n"
    printf "${RED}  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝${NC}\n"
    printf "\n"
    printf "  ${BOLD}AI-Powered Penetration Testing Framework${NC}\n"
    printf "  ${CYAN}No talk, all walk. Let's cook.${NC}\n"
    printf "\n"
}

info()    { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}[!]${NC} %s\n" "$1"; }
fail()    { printf "  ${RED}[x]${NC} %s\n" "$1"; }
success() { printf "  ${GREEN}[✓]${NC} %s\n" "$1"; }

detect_arch() {
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64) ARCH_NAME="x64" ;;
        aarch64|arm64) ARCH_NAME="arm64" ;;
        *) fail "Unsupported: $ARCH"; exit 1 ;;
    esac
}

detect_shell_rc() {
    case "$SHELL" in
        *zsh*)  echo "$HOME/.zshrc" ;;
        *bash*) echo "$HOME/.bashrc" ;;
        *)
            for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
                [ -f "$rc" ] && echo "$rc" && return
            done
            echo "$HOME/.profile"
            ;;
    esac
}

# ============================================================
# MAIN
# ============================================================
banner
printf "  ${BOLD}INSTALLING BXPLOIT...${NC}\n\n"

# System Check
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}System Check${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

detect_arch
info "Platform: linux ($ARCH_NAME)"

command -v curl >/dev/null 2>&1 || { fail "curl not found"; exit 1; }
command -v unzip >/dev/null 2>&1 || { warn "unzip not found"; apt-get install -y unzip 2>/dev/null || apk add unzip 2>/dev/null || true; }
command -v python3 >/dev/null 2>&1 || { warn "python3 not found"; apt-get install -y python3 2>/dev/null || apk add python3 2>/dev/null || true; }
success "Prerequisites OK"

# Download Binary
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Download Binary${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

mkdir -p "$INSTALL_DIR/bin"

if [ -f "$BINARY" ]; then
    success "Binary exists"
else
    info "Downloading..."
    TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
    [ -z "$TAG" ] && TAG="@moonshot-ai/kimi-code@0.31.1"
    ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || echo "%40moonshot-ai%2Fkimi-code%400.31.1")
    TMP=$(mktemp -d)
    curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || { fail "Download failed"; exit 1; }
    cd "$TMP" && unzip -o kimi.zip 2>/dev/null || { fail "Extract failed"; exit 1; }
    mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null || { fail "Binary not found"; exit 1; }
    chmod +x "$BINARY"
    rm -rf "$TMP"
    success "Binary installed"
fi

# Download Assets
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Download Skills & Knowledge${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

info "Downloading assets..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/bxploit.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null || { warn "Assets download failed"; rm -rf "$TMP"; }
if [ -f "$TMP/bxploit.zip" ]; then
    cd "$TMP" && unzip -o bxploit.zip 2>/dev/null
    SRC="$TMP/bxploit-main"
    mkdir -p "$INSTALL_DIR/skills" "$INSTALL_DIR/knowledge" "$INSTALL_DIR/plugins" "$INSTALL_DIR/scripts"
    [ -d "$SRC/plugins/bxploit-pentest/skills" ] && cp -r "$SRC/plugins/bxploit-pentest/skills/"* "$INSTALL_DIR/skills/" 2>/dev/null
    [ -d "$SRC/knowledge" ] && cp -r "$SRC/knowledge/"* "$INSTALL_DIR/knowledge/" 2>/dev/null
    [ -d "$SRC/plugins/bxploit-pentest" ] && cp -r "$SRC/plugins/bxploit-pentest" "$INSTALL_DIR/plugins/" 2>/dev/null
    [ -f "$SRC/plugins/bxploit-pentest/SYSTEM.md" ] && cp "$SRC/plugins/bxploit-pentest/SYSTEM.md" "$INSTALL_DIR/SYSTEM.md"
    [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$INSTALL_DIR/AGENTS.md"
    for s in bxploit.sh setup.sh update.sh uninstall.sh; do [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$INSTALL_DIR/scripts/" 2>/dev/null; done
    [ -f "$SRC/bxploit.sh" ] && cp "$SRC/bxploit.sh" "$INSTALL_DIR/bxploit.sh" 2>/dev/null
    rm -rf "$TMP"
    SKILLS=$(find "$INSTALL_DIR/skills" -name "*.md" 2>/dev/null | wc -l)
    KNOWLEDGE=$(find "$INSTALL_DIR/knowledge" -name "*.md" 2>/dev/null | wc -l)
    success "Skills: $SKILLS files"
    success "Knowledge: $KNOWLEDGE files"
fi

# Create CLI Wrapper
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Setup CLI${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

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
success "CLI: $CLI_BIN"

# PATH
SHELL_RC=$(detect_shell_rc)
if ! echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/.local/bin$"; then
    grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null || printf "\n%s\nexport PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$MARKER" >> "$SHELL_RC"
    info "Added to PATH in $SHELL_RC"
fi

# Verify
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Verify${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

[ -f "$BINARY" ] && success "Binary OK" || fail "Binary missing"
[ -f "$CLI_BIN" ] && success "CLI OK" || fail "CLI missing"
[ -d "$INSTALL_DIR/skills" ] && success "Skills OK" || warn "Skills missing"
[ -d "$INSTALL_DIR/knowledge" ] && success "Knowledge OK" || warn "Knowledge missing"

# Done
printf "\n  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  BXPLOIT Installed!${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"
printf "  ${CYAN}Setup API:${NC}  bxploit --setup\n"
printf "  ${CYAN}Run:${NC}        bxploit\n"
printf "  ${CYAN}Update:${NC}     bxploit --update\n"
printf "  ${CYAN}Uninstall:${NC}  bxploit --uninstall\n\n"
printf "  ${YELLOW}source %s && bxploit --setup${NC}\n\n" "$SHELL_RC"
