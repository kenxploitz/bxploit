#!/bin/sh
set -e

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CLI_BIN="$HOME/.local/bin/bxploit"
GITHUB_REPO="MoonshotAI/kimi-code"
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
command -v unzip >/dev/null 2>&1 || { apt-get install -y unzip 2>/dev/null || apk add unzip 2>/dev/null || true; }
command -v python3 >/dev/null 2>&1 || { apt-get install -y python3 2>/dev/null || apk add python3 2>/dev/null || true; }
success "Prerequisites OK"

SHELL_RC=""
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do [ -f "$rc" ] && SHELL_RC="$rc" && break; done
[ -z "$SHELL_RC" ] && SHELL_RC="$HOME/.profile" && touch "$SHELL_RC"

mkdir -p "$BXPLOIT_HOME/bin"
BINARY="$BXPLOIT_HOME/bin/kimi-code"

if [ ! -f "$BINARY" ]; then
    info "Downloading binary..."
    TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
    [ -z "$TAG" ] && TAG="@moonshot-ai/kimi-code@0.31.1"
    ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || echo "%40moonshot-ai%2Fkimi-code%400.31.1")
    TMP=$(mktemp -d)
    curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || fail "Download failed"
    cd "$TMP" && unzip -o kimi.zip 2>/dev/null || fail "Extract failed"
    mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null || fail "Binary not found"
    chmod +x "$BINARY"
    rm -rf "$TMP"
    python3 -c "
with open('$BINARY','rb') as f: d=f.read()
d=d.replace(b'Welcome to Kimi Code!',b'Welcome to Bxploit! ')
with open('$BINARY','wb') as f: f.write(d)
" 2>/dev/null || true
    success "Binary installed"
else
    success "Binary exists"
fi

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
    for s in bxploit.sh setup.sh update.sh uninstall.sh; do [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$BXPLOIT_HOME/scripts/" 2>/dev/null; done
    rm -rf "$TMP"
    success "Skills: $(find "$BXPLOIT_HOME/skills" -name "*.md" 2>/dev/null | wc -l) files"
    success "Knowledge: $(find "$BXPLOIT_HOME/knowledge" -name "*.md" 2>/dev/null | wc -l) files"
fi

mkdir -p "$(dirname "$CLI_BIN")"
cat > "$CLI_BIN" << 'WRAPPER'
#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
export BXPLOIT_HOME="$BXPLOIT_HOME"
[ ! -d "$HOME/.kimi-code" ] && ln -sf "$BXPLOIT_HOME" "$HOME/.kimi-code" 2>/dev/null
BXPLOIT_BIN="$BXPLOIT_HOME/bin/kimi-code"
[ ! -f "$BXPLOIT_BIN" ] && echo "Error: bxploit not installed" && exit 1
clear
printf '\033]0;Bxploit\007'
case "$1" in
    --setup|-s) exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@" ;;
    --config|-c) cat "$BXPLOIT_HOME/config.toml" 2>/dev/null || echo "No config"; exit 0 ;;
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

if ! echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/.local/bin$"; then
    grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null || printf "\n%s\nexport PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$MARKER" >> "$SHELL_RC"
    info "Added to PATH"
fi

[ -f "$BINARY" ] && success "Binary OK" || fail "Binary missing"
[ -f "$CLI_BIN" ] && success "CLI OK" || fail "CLI missing"

printf "\n  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  BXPLOIT Installed!${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"
printf "  ${CYAN}Setup API:${NC}  bxploit --setup\n"
printf "  ${CYAN}Run:${NC}        bxploit\n"
printf "  ${CYAN}Update:${NC}     bxploit --update\n"
printf "  ${CYAN}Uninstall:${NC}  bxploit --uninstall\n\n"
printf "  ${YELLOW}source %s && bxploit --setup${NC}\n\n" "$SHELL_RC"
