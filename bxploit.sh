#!/bin/sh
# ============================================================
# BXPLOIT — All-in-One Installer, Setup & Uninstaller
# ============================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/bxploit.sh | sh
#   ./bxploit.sh              # Install + Setup menu
#   ./bxploit.sh --uninstall  # Direct uninstall
#   ./bxploit.sh --update     # Update to latest version
#   ./bxploit.sh --help       # Show help
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

# ============================================================
# BANNER
# ============================================================
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

# ============================================================
# DETECT
# ============================================================
detect_arch() {
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64) ARCH_NAME="x64" ;;
        aarch64|arm64) ARCH_NAME="arm64" ;;
        *) fail "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

detect_shell_rc() {
    case "$SHELL" in
        *zsh*)  echo "$HOME/.zshrc" ;;
        *bash*) echo "$HOME/.bashrc" ;;
        *)
            if [ -f "$HOME/.zshrc" ]; then echo "$HOME/.zshrc"
            elif [ -f "$HOME/.bashrc" ]; then echo "$HOME/.bashrc"
            elif [ -f "$HOME/.profile" ]; then echo "$HOME/.profile"
            else echo "$HOME/.profile"
            fi
            ;;
    esac
}

is_installed() {
    [ -f "$BINARY" ] && [ -f "$CLI_BIN" ] && [ -f "$CONFIG_FILE" ]
}

# ============================================================
# INSTALL
# ============================================================
do_install() {
    banner
    printf "  ${BOLD}INSTALLING BXPLOIT...${NC}\n"
    printf "\n"

    # ── System Check ──
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "  ${BOLD}System Check${NC}\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "\n"

    detect_arch
    info "Platform: linux ($ARCH_NAME)"

    command -v curl >/dev/null 2>&1 || { fail "curl not found. Install: sudo apt install curl"; exit 1; }
    command -v unzip >/dev/null 2>&1 || { warn "unzip not found, installing..."; sudo apt-get install -y unzip 2>/dev/null || sudo apk add unzip 2>/dev/null || true; }
    command -v python3 >/dev/null 2>&1 || { warn "python3 not found, installing..."; sudo apt-get install -y python3 2>/dev/null || sudo apk add python3 2>/dev/null || true; }
    success "Prerequisites OK"

    # ── Download Binary ──
    printf "\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "  ${BOLD}Download Binary${NC}\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "\n"

    mkdir -p "$INSTALL_DIR/bin"

    if [ -f "$BINARY" ]; then
        success "Binary already exists"
    else
        info "Downloading Kimi Code binary..."
        TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
        [ -z "$TAG" ] && TAG="@moonshot-ai/kimi-code@0.31.1"
        ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || echo "%40moonshot-ai%2Fkimi-code%400.31.1")
        TMP=$(mktemp -d)
        curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || { fail "Download failed"; exit 1; }
        cd "$TMP" && unzip -o kimi.zip 2>/dev/null || { fail "Extract failed"; exit 1; }
        mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null || { fail "Binary not found in archive"; exit 1; }
        chmod +x "$BINARY"
        rm -rf "$TMP"


        success "Binary installed"
    fi

    # ── Download Assets ──
    printf "\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "  ${BOLD}Download Skills & Knowledge${NC}\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "\n"

    info "Downloading from GitHub..."
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
        for s in setup.sh update.sh uninstall.sh bxploit.sh; do [ -f "$SRC/scripts/$s" ] && cp "$SRC/scripts/$s" "$INSTALL_DIR/scripts/" 2>/dev/null; done
        [ -f "$SRC/bxploit.sh" ] && cp "$SRC/bxploit.sh" "$INSTALL_DIR/bxploit.sh" 2>/dev/null
        rm -rf "$TMP"
        SKILLS=$(find "$INSTALL_DIR/skills" -name "*.md" 2>/dev/null | wc -l)
        KNOWLEDGE=$(find "$INSTALL_DIR/knowledge" -name "*.md" 2>/dev/null | wc -l)
        success "Skills: $SKILLS files"
        success "Knowledge: $KNOWLEDGE files"
    fi

    # ── Create CLI Wrapper ──
    printf "\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "  ${BOLD}Setup CLI${NC}\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "\n"

    mkdir -p "$(dirname "$CLI_BIN")"
    cat > "$CLI_BIN" << 'WRAPPER'
#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
export BXPLOIT_HOME="$BXPLOIT_HOME"
[ ! -d "$HOME/.kimi-code" ] && ln -sf "$BXPLOIT_HOME" "$HOME/.kimi-code" 2>/dev/null
BXPLOIT_BIN="$BXPLOIT_HOME/bin/kimi-code"
[ ! -f "$BXPLOIT_BIN" ] && echo "Error: bxploit not installed. Run: curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/bxploit.sh | sh" && exit 1
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

    # ── PATH ──
    SHELL_RC=$(detect_shell_rc)
    if ! echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/.local/bin$"; then
        grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null || printf "\n%s\nexport PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$MARKER" >> "$SHELL_RC"
        info "Added to PATH in $SHELL_RC"
    fi

    # ── Verify ──
    printf "\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "  ${BOLD}Verify${NC}\n"
    printf "  ${CYAN}─────────────────────────────────────────────${NC}\n"
    printf "\n"

    [ -f "$BINARY" ] && success "Binary OK" || fail "Binary missing"
    [ -f "$CLI_BIN" ] && success "CLI OK" || fail "CLI missing"
    [ -d "$INSTALL_DIR/skills" ] && success "Skills OK" || warn "Skills missing"
    [ -d "$INSTALL_DIR/knowledge" ] && success "Knowledge OK" || warn "Knowledge missing"

    # ── Done ──
    printf "\n"
    printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
    printf "  ${BOLD}  BXPLOIT Installed!${NC}\n"
    printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
    printf "\n"
    printf "  ${CYAN}Setup API:${NC}  bxploit --setup\n"
    printf "  ${CYAN}Run:${NC}        bxploit\n"
    printf "  ${CYAN}Update:${NC}     bxploit --update\n"
    printf "  ${CYAN}Uninstall:${NC}  bxploit --uninstall\n"
    printf "\n"
    printf "  ${YELLOW}source %s && bxploit --setup${NC}\n\n" "$SHELL_RC"
}

# ============================================================
# SETUP MENU
# ============================================================
do_setup() {
    banner
    printf "  ${BOLD}API CONFIGURATION${NC}\n"
    printf "\n"

    # Show current config
    if [ -f "$CONFIG_FILE" ]; then
        CUR_MODEL=$(grep 'default_model' "$CONFIG_FILE" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        CUR_BASE=$(grep 'base_url' "$CONFIG_FILE" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        CUR_KEY=$(grep 'api_key' "$CONFIG_FILE" 2>/dev/null | head -1 | sed 's/.*= *"\(.*\)"/\1/')
        MASKED=$(echo "$CUR_KEY" | cut -c1-8)"..."$(echo "$CUR_KEY" | rev | cut -c1-4 | rev 2>/dev/null)
        printf "  ${CYAN}Current:${NC}\n"
        printf "    Model: %s\n" "$CUR_MODEL"
        printf "    Base:  %s\n" "$CUR_BASE"
        printf "    Key:   %s\n" "$MASKED"
        printf "\n"
    fi

    printf "  ${GREEN}[1]${NC} Change API Base URL\n"
    printf "  ${GREEN}[2]${NC} Change API Key\n"
    printf "  ${GREEN}[3]${NC} Change Model\n"
    printf "  ${GREEN}[4]${NC} Change All (full reconfigure)\n"
    printf "  ${GREEN}[5]${NC} Test API Connection\n"
    printf "  ${GREEN}[6]${NC} Update Bxploit\n"
    printf "  ${GREEN}[7]${NC} Uninstall Bxploit\n"
    printf "  ${GREEN}[8]${NC} Exit\n"
    printf "\n"
    printf "  ${BOLD}Pilih [1-8]:${NC} "
    read -r choice

    case "$choice" in
        1)
            printf "\n  ${GREEN}New API Base URL:${NC} "
            read -r NEW_BASE
            sed -i "s|base_url = \".*\"|base_url = \"$NEW_BASE\"|" "$CONFIG_FILE"
            success "Updated"
            ;;
        2)
            printf "\n  ${GREEN}New API Key:${NC} "
            read -r NEW_KEY
            sed -i "s|api_key = \".*\"|api_key = \"$NEW_KEY\"|" "$CONFIG_FILE"
            success "Updated"
            ;;
        3)
            printf "\n  ${GREEN}New Model:${NC} "
            read -r NEW_MODEL
            sed -i "s|default_model = \".*\"|default_model = \"$NEW_MODEL\"|" "$CONFIG_FILE"
            success "Updated"
            ;;
        4)
            do_full_setup
            ;;
        5)
            do_test
            ;;
        6)
            do_update
            ;;
        7)
            do_uninstall
            ;;
        8)
            exit 0
            ;;
        *)
            warn "Invalid choice"
            ;;
    esac
}

do_full_setup() {
    printf "\n  ${GREEN}API Base URL:${NC}\n"
    printf "    1) OpenAI     (https://api.openai.com/v1)\n"
    printf "    2) Anthropic  (https://api.anthropic.com/v1)\n"
    printf "    3) DeepSeek   (https://api.deepseek.com/v1)\n"
    printf "    4) Ollama     (http://localhost:11434/v1)\n"
    printf "    5) Custom\n"
    printf "\n  ${BOLD}Pilih [1-5]:${NC} "
    read -r url_choice
    case "$url_choice" in
        1) BASE_URL="https://api.openai.com/v1" ;;
        2) BASE_URL="https://api.anthropic.com/v1" ;;
        3) BASE_URL="https://api.deepseek.com/v1" ;;
        4) BASE_URL="http://localhost:11434/v1" ;;
        5) printf "  ${GREEN}URL:${NC} "; read -r BASE_URL ;;
        *) BASE_URL="https://api.openai.com/v1" ;;
    esac

    printf "\n  ${GREEN}API Key:${NC} "
    read -r API_KEY
    [ -z "$API_KEY" ] && { fail "API Key required"; return 1; }

    # Auto-detect
    PROVIDER="openai"
    echo "$BASE_URL" | grep -q "anthropic" && PROVIDER="anthropic"
    echo "$BASE_URL" | grep -q "googleapis" && PROVIDER="google-genai"

    # Fetch models
    printf "\n  ${CYAN}Fetching models...${NC}\n"
    MODELS=$(curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" 2>/dev/null)
    if echo "$MODELS" | grep -q '"data"'; then
        echo "$MODELS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [m['id'] for m in data.get('data', [])][:20]
for i, m in enumerate(models, 1):
    print(f'    {i}) {m}')
" 2>/dev/null
        printf "\n  ${GREEN}Pilih model (nomor):${NC} "
        read -r model_num
        MODEL=$(echo "$MODELS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [m['id'] for m in data.get('data', [])][:20]
idx = int('$model_num') - 1
print(models[idx] if 0 <= idx < len(models) else models[0])
" 2>/dev/null)
    else
        printf "  ${GREEN}Model name:${NC} "
        read -r MODEL
    fi
    [ -z "$MODEL" ] && MODEL="gpt-4o"

    # Save config
    mkdir -p "$INSTALL_DIR"
    cat > "$CONFIG_FILE" << EOF
default_model = "$MODEL"
default_permission_mode = "yolo"

[providers.custom]
type = "$PROVIDER"
base_url = "$BASE_URL"
api_key = "$API_KEY"

[models."$MODEL"]
provider = "custom"
model = "$MODEL"
max_context_size = 999999999
max_input_size = 999999999
max_output_size = 999999999
capabilities = ["thinking", "tool_use"]
EOF
    chmod 600 "$CONFIG_FILE"
    success "Config saved"
    printf "\n  ${CYAN}Run: bxploit${NC}\n"
}

# ============================================================
# TEST
# ============================================================
do_test() {
    if [ ! -f "$CONFIG_FILE" ]; then fail "No config. Run: bxploit --setup"; return 1; fi
    BASE_URL=$(grep 'base_url' "$CONFIG_FILE" | head -1 | sed 's/.*= *"\(.*\)"/\1/')
    API_KEY=$(grep 'api_key' "$CONFIG_FILE" | head -1 | sed 's/.*= *"\(.*\)"/\1/')
    printf "\n  ${CYAN}Testing: %s${NC}\n" "$BASE_URL"
    RESULT=$(curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" 2>/dev/null)
    if echo "$RESULT" | grep -q '"data"'; then
        COUNT=$(echo "$RESULT" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',[])))" 2>/dev/null)
        success "Connected! $COUNT models available"
    else
        fail "Connection failed"
    fi
}

# ============================================================
# UPDATE
# ============================================================
do_update() {
    banner
    printf "  ${BOLD}UPDATING BXPLOIT...${NC}\n\n"

    # Get current version
    CUR_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")
    info "Current: $CUR_VER"

    # Download latest
    info "Downloading latest..."
    TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
    [ -z "$TAG" ] && TAG="@moonshot-ai/kimi-code@0.31.1"
    ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null)
    detect_arch
    TMP=$(mktemp -d)
    curl -fsSL -o "$TMP/kimi.zip" "https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip" || { fail "Download failed"; exit 1; }
    cd "$TMP" && unzip -o kimi.zip 2>/dev/null || { fail "Extract failed"; exit 1; }
    cp "$BINARY" "$BINARY.bak" 2>/dev/null
    mv kimi "$BINARY" 2>/dev/null || mv kimi-code "$BINARY" 2>/dev/null
    chmod +x "$BINARY"
    rm -rf "$TMP"

    # Patch
    python3 -c "
with open('$BINARY','rb') as f: d=f.read()
d=d.replace(b'Welcome to Kimi Code!',b'Welcome to Bxploit! ')
with open('$BINARY','wb') as f: f.write(d)
" 2>/dev/null || true

    # Update assets
    info "Updating assets..."
    TMP=$(mktemp -d)
    curl -fsSL -o "$TMP/bxploit.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null
    if [ -f "$TMP/bxploit.zip" ]; then
        cd "$TMP" && unzip -o bxploit.zip 2>/dev/null
        SRC="$TMP/bxploit-main"
        [ -d "$SRC/plugins/bxploit-pentest/skills" ] && cp -r "$SRC/plugins/bxploit-pentest/skills/"* "$INSTALL_DIR/skills/" 2>/dev/null
        [ -d "$SRC/knowledge" ] && cp -r "$SRC/knowledge/"* "$INSTALL_DIR/knowledge/" 2>/dev/null
        [ -d "$SRC/plugins/bxploit-pentest" ] && cp -r "$SRC/plugins/bxploit-pentest/"* "$INSTALL_DIR/plugins/bxploit-pentest/" 2>/dev/null
        rm -rf "$TMP"
    fi

    NEW_VER=$("$BINARY" --version 2>/dev/null || echo "unknown")
    success "Updated: $CUR_VER → $NEW_VER"
}

# ============================================================
# UNINSTALL
# ============================================================
do_uninstall() {
    banner
    printf "  ${BOLD}UNINSTALL BXPLOIT${NC}\n\n"
    printf "  Yang akan dihapus:\n"
    printf "    1. %s/\n" "$INSTALL_DIR"
    printf "    2. %s\n" "$CLI_BIN"
    printf "    3. PATH entries\n"
    printf "\n"
    printf "  ${BOLD}Yakin? [y/N]:${NC} "
    read -r confirm
    case "$confirm" in
        y|Y|yes|YES) ;;
        *) printf "  Batal.\n"; exit 0 ;;
    esac

    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR" && success "Removed $INSTALL_DIR"
    [ -f "$CLI_BIN" ] && rm -f "$CLI_BIN" && success "Removed $CLI_BIN"

    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$rc" ] && grep -qF "$MARKER" "$rc" 2>/dev/null; then
            tmp=$(mktemp)
            grep -vF "$MARKER" "$rc" | grep -vi "bxploit" > "$tmp" 2>/dev/null
            sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmp" > "$rc" 2>/dev/null || cp "$tmp" "$rc"
            rm -f "$tmp"
            success "Cleaned $rc"
        fi
    done

    printf "\n  ${GREEN}Bxploit uninstalled.${NC}\n"
    printf "  ${YELLOW}source %s${NC}\n\n" "$(detect_shell_rc)"
}

# ============================================================
# HELP
# ============================================================
do_help() {
    banner
    printf "  ${BOLD}USAGE:${NC}\n"
    printf "    bxploit                  Interactive mode\n"
    printf "    bxploit -p \"query\"        Single query\n"
    printf "    bxploit --setup           Setup API\n"
    printf "    bxploit --config          Show config\n"
    printf "    bxploit --test            Test connection\n"
    printf "    bxploit --update          Update bxploit\n"
    printf "    bxploit --uninstall       Remove bxploit\n"
    printf "    bxploit --help            This help\n"
    printf "\n"
    printf "  ${BOLD}ONE-LINER INSTALL:${NC}\n"
    printf "    curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/bxploit.sh | sh\n"
    printf "\n"
}

# ============================================================
# MAIN
# ============================================================
case "$1" in
    --uninstall)  do_uninstall ;;
    --update)     do_update ;;
    --help|-h)    do_help ;;
    *)
        if is_installed; then
            do_setup
        else
            do_install
        fi
        ;;
esac
