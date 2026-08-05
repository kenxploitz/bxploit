#!/bin/sh
set -e

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CLI_BIN="$HOME/.local/bin/bxploit"
BXPLOIT_REPO="kenxploitz/bxploit"
MARKER="# Bxploit"

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
printf "  ${BOLD}AI-Powered Penetration Testing Framework${NC}\n"
printf "  ${CYAN}No talk, all walk. Let's cook.${NC}\n\n"

ARCH="$(uname -m)"
case "$ARCH" in x86_64|amd64) ARCH_NAME="x64" ;; aarch64|arm64) ARCH_NAME="arm64" ;; *) fail "Unsupported: $ARCH" ;; esac
info "Platform: linux ($ARCH_NAME)"

command -v curl >/dev/null 2>&1 || fail "curl not found"
success "Prerequisites OK"

SHELL_RC=""
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do [ -f "$rc" ] && SHELL_RC="$rc" && break; done
[ -z "$SHELL_RC" ] && SHELL_RC="$HOME/.profile" && touch "$SHELL_RC"

# Download Binary
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Download Binary${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

mkdir -p "$BXPLOIT_HOME/bin"
BINARY="$BXPLOIT_HOME/bin/bxploit"

if [ -f "$BINARY" ] && [ -x "$BINARY" ]; then
    success "Binary exists"
else
    info "Downloading Bxploit binary..."
    curl -fsSL -o "$BINARY" "https://github.com/$BXPLOIT_REPO/releases/download/v1.0.0/bxploit-linux-${ARCH_NAME}" || fail "Download failed"
    chmod +x "$BINARY"
    success "Binary installed"
fi

# Download Assets
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Download Skills & Knowledge${NC}\n"
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
    [ -d "$SRC/plugins/bxploit-pentest" ] && cp -r "$SRC/plugins/bxploit-pentest" "$BXPLOIT_HOME/plugins/" 2>/dev/null
    [ -f "$SRC/plugins/bxploit-pentest/SYSTEM.md" ] && cp "$SRC/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md"
    [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$BXPLOIT_HOME/AGENTS.md"
    for s in setup.sh update.sh uninstall.sh; do [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$BXPLOIT_HOME/scripts/" 2>/dev/null; done
    rm -rf "$TMP"
    success "Skills: $(find "$BXPLOIT_HOME/skills" -name "*.md" 2>/dev/null | wc -l) files"
    success "Knowledge: $(find "$BXPLOIT_HOME/knowledge" -name "*.md" 2>/dev/null | wc -l) files"
fi

# Generate tui.toml
cat > "$BXPLOIT_HOME/tui.toml" << 'TUI'
theme = "auto"
TUI
success "tui.toml generated"

# Create CLI Wrapper
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Setup CLI${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

mkdir -p "$(dirname "$CLI_BIN")"
cat > "$CLI_BIN" << 'WRAPPER'
#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export BXPLOIT_HOME="$BXPLOIT_HOME"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
BXPLOIT_BIN="$BXPLOIT_HOME/bin/bxploit"
[ ! -f "$BXPLOIT_BIN" ] && echo "Error: bxploit not installed. Run install.sh" && exit 1
clear
printf '\033]0;Bxploit\007'

case "$1" in
    --setup|-s) exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@" ;;
    --config|-c) cat "$BXPLOIT_HOME/config.toml" 2>/dev/null || echo "No config. Run: bxploit --setup"; exit 0 ;;
    --test|-t)
        BASE_URL=$(grep 'base_url' "$BXPLOIT_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        API_KEY=$(grep 'api_key' "$BXPLOIT_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'OK: {len(d.get(\"data\",[]))} models')" 2>/dev/null || echo "Failed"
        exit 0 ;;
    --uninstall) exec sh "$BXPLOIT_HOME/scripts/uninstall.sh" ;;
    --update|-u) exec sh "$BXPLOIT_HOME/scripts/update.sh" ;;
    --help|-h)
        echo "BXPLOIT — AI-Powered Penetration Testing Framework"
        echo ""
        echo "Usage: bxploit [options]"
        echo "  bxploit              Interactive mode"
        echo "  bxploit -p \"query\"   Single query"
        echo "  bxploit --setup      Setup API"
        echo "  bxploit --config     Show config"
        echo "  bxploit --test       Test connection"
        echo "  bxploit --update     Update bxploit"
        echo "  bxploit --uninstall  Remove bxploit"
        exit 0 ;;
esac

# Auto-setup if config missing
if [ ! -f "$BXPLOIT_HOME/config.toml" ]; then
    echo "Config belum ada. Running setup..."
    exec sh "$BXPLOIT_HOME/scripts/setup.sh"
fi

[ ! -f "$BXPLOIT_HOME/tui.toml" ] && echo 'theme = "auto"' > "$BXPLOIT_HOME/tui.toml"

HAS_PROMPT=0; for a in "$@"; do [ "$a" = "-p" ] && HAS_PROMPT=1; done
if [ "$HAS_PROMPT" = "1" ]; then exec "$BXPLOIT_BIN" "$@"; else exec "$BXPLOIT_BIN" --yolo "$@"; fi
WRAPPER
chmod +x "$CLI_BIN"
success "CLI: $CLI_BIN"

if ! echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/.local/bin$"; then
    grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null || printf "\n%s\nexport PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$MARKER" >> "$SHELL_RC"
    info "Added to PATH"
fi

# Verify
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Verify${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

[ -f "$BINARY" ] && [ -x "$BINARY" ] && success "Binary OK" || fail "Binary missing"
[ -f "$CLI_BIN" ] && success "CLI OK" || fail "CLI missing"

printf "\n  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  BXPLOIT Installed!${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"

if [ ! -f "$BXPLOIT_HOME/config.toml" ]; then
    printf "  ${YELLOW}Setup API sekarang? [Y/n]:${NC} "
    read -r run_setup
    case "$run_setup" in
        n|N) printf "  ${CYAN}Jalankan manual: bxploit --setup${NC}\n" ;;
        *) exec sh "$BXPLOIT_HOME/scripts/setup.sh" ;;
    esac
else
    printf "  ${CYAN}Config sudah ada. Jalankan: bxploit${NC}\n"
fi

printf "\n  ${YELLOW}source %s${NC}\n\n" "$SHELL_RC"
