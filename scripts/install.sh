#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — One-Liner Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/scripts/install.sh | sh
# ============================================================================

set -e

# --- Colors ---------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1)    GREEN=$(tput setaf 2)  YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)   BOLD=$(tput bold)       RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

# --- Constants ------------------------------------------------------------
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CLI_BIN="$HOME/.local/bin/bxploit"
CONFIG_FILE="$BXPLOIT_HOME/config.toml"
MARKER="# Bungul Exploit"
GITHUB_REPO="MoonshotAI/kimi-code"
BXPLOIT_REPO="kenxploitz/bxploit"

# --- Logging --------------------------------------------------------------
info()  { printf "%s[+]%s %s\n" "$GREEN" "$RESET" "$1"; }
warn()  { printf "%s[!]%s %s\n" "$YELLOW" "$RESET" "$1"; }
die()   { printf "%s[-]%s %s\n" "$RED" "$RESET" "$1"; exit 1; }

# --- Banner ---------------------------------------------------------------
banner() {
    printf '%s' "$CYAN"
    printf " ____  _____ _   _ ____  _     _____ ____ ___ _____ _\n"
    printf "| __ )|  ___| | | |  _ \\| |   | ____|  _ \\_ _|_   _|(_)___\n"
    printf "|  _ \\| |_  | | | | |_) | |   |  _| | |_) | |  | | | |/ __|\n"
    printf "| |_) |  _| | |_| |  __/| |___| |___|  __/| |  | | | |\\__ \\\n"
    printf "|____/|_|    \\___/|_|   |_____|_____|_|  |___| |_| |_| |___/\n"
    printf "${RESET}\n"
    printf "${BOLD}AI-Powered Penetration Testing Framework${RESET}\n"
    printf "${CYAN}No talk, all walk. Let's cook.${RESET}\n\n"
}

# --- Platform Detection ---------------------------------------------------
detect_platform() {
    PLATFORM="unknown"
    ARCH="$(uname -m)"

    if [ -n "$TERMUX_VERSION" ] || echo "$PREFIX" | grep -q "com.termux" 2>/dev/null; then
        PLATFORM="termux"
    else
        case "$(uname -s)" in
            Linux*) PLATFORM="linux" ;;
            Darwin*) PLATFORM="macos" ;;
            *) die "Unsupported platform: $(uname -s)" ;;
        esac
    fi

    case "$ARCH" in
        x86_64|amd64) ARCH_NAME="x64" ;;
        aarch64|arm64) ARCH_NAME="arm64" ;;
        *) die "Unsupported architecture: $ARCH" ;;
    esac

    info "Platform: $PLATFORM ($ARCH_NAME)"
}

# --- Shell RC Detection ---------------------------------------------------
detect_shell_rc() {
    SHELL_RC=""
    case "$(basename "${SHELL:-/bin/sh}")" in
        zsh)  [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc" ;;
        bash) [ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
              [ -z "$SHELL_RC" ] && [ -f "$HOME/.bash_profile" ] && SHELL_RC="$HOME/.bash_profile" ;;
    esac
    if [ -z "$SHELL_RC" ]; then
        for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
            [ -f "$rc" ] && SHELL_RC="$rc" && break
        done
    fi
    [ -z "$SHELL_RC" ] && SHELL_RC="$HOME/.profile" && touch "$SHELL_RC"
}

# --- Check Prerequisites --------------------------------------------------
check_prereqs() {
    command -v curl >/dev/null 2>&1 || die "curl not found. Install: sudo apt install curl"
    command -v unzip >/dev/null 2>&1 || { warn "unzip not found, installing..."; sudo apt-get install -y unzip 2>/dev/null || sudo apk add unzip 2>/dev/null || true; }
    command -v python3 >/dev/null 2>&1 || { warn "python3 not found, installing..."; sudo apt-get install -y python3 2>/dev/null || sudo apk add python3 2>/dev/null || true; }
    info "Prerequisites OK"
}

# --- Download Binary -------------------------------------------------------
download_binary() {
    mkdir -p "$BXPLOIT_HOME/bin"
    BINARY_PATH="$BXPLOIT_HOME/bin/kimi-code"

    if [ -f "$BINARY_PATH" ] && [ -x "$BINARY_PATH" ]; then
        info "Binary already exists"
        return 0
    fi

    info "Downloading Bxploit binary..."

    # Get latest release tag
    TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
    [ -z "$TAG" ] && TAG="@moonshot-ai/kimi-code@0.31.1"

    # URL-encode the tag
    ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || echo "%40moonshot-ai%2Fkimi-code%400.31.1")

    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip"
    info "URL: $DOWNLOAD_URL"

    TMP_DIR=$(mktemp -d)
    curl -fsSL -o "$TMP_DIR/kimi-code.zip" "$DOWNLOAD_URL" || die "Download failed. Check internet."

    cd "$TMP_DIR" && unzip -o kimi-code.zip 2>/dev/null || die "Extraction failed"
    mv kimi "$BINARY_PATH" 2>/dev/null || mv kimi-code "$BINARY_PATH" 2>/dev/null || die "Binary not found in archive"
    chmod +x "$BINARY_PATH"
    rm -rf "$TMP_DIR"

    # Patch welcome message
    info "Patching..."
    python3 -c "
with open('$BINARY_PATH', 'rb') as f:
    data = f.read()
data = data.replace(b'Welcome to Kimi Code!', b'Welcome to Bxploit! ')
with open('$BINARY_PATH', 'wb') as f:
    f.write(data)
" 2>/dev/null || warn "Patch failed (non-critical)"

    info "Binary installed"
}

# --- Download Assets (skills, knowledge, plugins) -------------------------
download_assets() {
    info "Downloading skills & knowledge base..."

    TMP_DIR=$(mktemp -d)
    BXPLOIT_ZIP="$TMP_DIR/bxploit.zip"

    # Download bxploit repo as zip
    curl -fsSL -o "$BXPLOIT_ZIP" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null || {
        warn "Failed to download assets from GitHub. Skills/knowledge will be empty."
        rm -rf "$TMP_DIR"
        return 0
    }

    cd "$TMP_DIR" && unzip -o bxploit.zip 2>/dev/null || { warn "Extraction failed"; rm -rf "$TMP_DIR"; return 0; }

    BXPLOIT_SRC="$TMP_DIR/bxploit-main"

    # Copy skills
    if [ -d "$BXPLOIT_SRC/plugins/bxploit-pentest/skills" ]; then
        mkdir -p "$BXPLOIT_HOME/skills"
        cp -r "$BXPLOIT_SRC/plugins/bxploit-pentest/skills/"* "$BXPLOIT_HOME/skills/" 2>/dev/null
        info "Skills copied"
    fi

    # Copy knowledge
    if [ -d "$BXPLOIT_SRC/knowledge" ]; then
        mkdir -p "$BXPLOIT_HOME/knowledge"
        cp -r "$BXPLOIT_SRC/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
        info "Knowledge copied ($(find "$BXPLOIT_HOME/knowledge" -name "*.md" | wc -l) files)"
    fi

    # Copy plugin
    if [ -d "$BXPLOIT_SRC/plugins/bxploit-pentest" ]; then
        mkdir -p "$BXPLOIT_HOME/plugins"
        cp -r "$BXPLOIT_SRC/plugins/bxploit-pentest" "$BXPLOIT_HOME/plugins/" 2>/dev/null
        info "Plugin copied"
    fi

    # Copy SYSTEM.md (jailbreak)
    if [ -f "$BXPLOIT_SRC/plugins/bxploit-pentest/SYSTEM.md" ]; then
        cp "$BXPLOIT_SRC/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md"
    fi

    # Copy AGENTS.md
    if [ -f "$BXPLOIT_SRC/AGENTS.md" ]; then
        cp "$BXPLOIT_SRC/AGENTS.md" "$BXPLOIT_HOME/AGENTS.md"
    fi

    # Copy scripts
    mkdir -p "$BXPLOIT_HOME/scripts"
    for script in setup.sh update.sh uninstall.sh; do
        [ -f "$BXPLOIT_SRC/scripts/$script" ] && cp "$BXPLOIT_SRC/scripts/$script" "$BXPLOIT_HOME/scripts/"
    done

    rm -rf "$TMP_DIR"
    info "Assets downloaded"
}

# --- Setup Wizard (auto-detect if env vars set) -------------------------
setup_wizard() {
    # Skip if config already exists
    if [ -f "$CONFIG_FILE" ]; then
        info "Config already exists, skipping setup"
        return 0
    fi

    # If API env vars set, auto-generate config
    if [ -n "$BXPLOIT_API_KEY" ]; then
        info "Using API key from env..."
        PROVIDER_TYPE="${BXPLOIT_PROVIDER:-openai}"
        BASE_URL="${BXPLOIT_BASE_URL:-https://api.openai.com/v1}"
        MODEL="${BXPLOIT_MODEL:-gpt-4o}"
        API_KEY="$BXPLOIT_API_KEY"

        mkdir -p "$BXPLOIT_HOME"
        cat > "$CONFIG_FILE" << EOF
default_model = "$MODEL"
default_permission_mode = "yolo"

[providers.custom]
type = "$PROVIDER_TYPE"
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
        info "Config auto-generated"
        return 0
    fi

    # Otherwise run interactive setup
    if [ -f "$BXPLOIT_HOME/scripts/setup.sh" ]; then
        sh "$BXPLOIT_HOME/scripts/setup.sh"
    else
        warn "Setup script not found. Run: bxploit --setup"
    fi
}

# --- Create CLI Wrapper ---------------------------------------------------
create_cli_wrapper() {
    mkdir -p "$(dirname "$CLI_BIN")"

    cat > "$CLI_BIN" << 'WRAPPER'
#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
export BXPLOIT_HOME="$BXPLOIT_HOME"
[ ! -d "$HOME/.kimi-code" ] && ln -sf "$BXPLOIT_HOME" "$HOME/.kimi-code" 2>/dev/null

BXPLOIT_BIN="$BXPLOIT_HOME/bin/kimi-code"
if [ ! -f "$BXPLOIT_BIN" ]; then
    echo "Error: bxploit binary not found. Run: ./scripts/install.sh"
    exit 1
fi

printf '\033]0;Bxploit\007'

case "$1" in
    --setup|-s) exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@" ;;
    --config|-c)
        if [ -f "$BXPLOIT_HOME/config.toml" ]; then cat "$BXPLOIT_HOME/config.toml"
        else echo "Config not found. Run: bxploit --setup"; fi
        exit 0 ;;
    --test|-t)
        if [ -f "$BXPLOIT_HOME/config.toml" ]; then
            BASE_URL=$(grep 'base_url' "$BXPLOIT_HOME/config.toml" | head -1 | sed 's/.*= *"\(.*\)"/\1/')
            API_KEY=$(grep 'api_key' "$BXPLOIT_HOME/config.toml" | head -1 | sed 's/.*= *"\(.*\)"/\1/')
            echo "Testing: $BASE_URL"
            curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'OK: {len(d.get(\"data\",[]))} models')" 2>/dev/null || echo "Connection failed"
        else echo "Config not found. Run: bxploit --setup"; fi
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
        echo "  bxploit --help       This help"
        exit 0 ;;
esac

if [ ! -f "$BXPLOIT_HOME/config.toml" ]; then
    echo "Config belum ada. Running setup..."
    exec sh "$BXPLOIT_HOME/scripts/setup.sh"
fi

HAS_PROMPT=0
for arg in "$@"; do [ "$arg" = "-p" ] && HAS_PROMPT=1; [ "$arg" = "--prompt" ] && HAS_PROMPT=1; done

if [ "$HAS_PROMPT" = "1" ]; then exec "$BXPLOIT_BIN" "$@"
else exec "$BXPLOIT_BIN" --yolo "$@"
fi
WRAPPER

    chmod +x "$CLI_BIN"
    info "CLI wrapper: $CLI_BIN"
}

# --- Add to PATH ----------------------------------------------------------
add_to_path() {
    if ! echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/.local/bin$"; then
        if ! grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
            printf "\n%s\nexport PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$MARKER" >> "$SHELL_RC"
            info "Added ~/.local/bin to PATH in $SHELL_RC"
        fi
    fi
}

# --- Verify ---------------------------------------------------------------
verify() {
    errors=0
    [ -f "$BXPLOIT_HOME/bin/kimi-code" ] && [ -x "$BXPLOIT_HOME/bin/kimi-code" ] || { printf "%s[-]%s Binary missing\n" "$RED" "$RESET"; errors=$((errors+1)); }
    [ -f "$CLI_BIN" ] && [ -x "$CLI_BIN" ] || { printf "%s[-]%s CLI wrapper missing\n" "$RED" "$RESET"; errors=$((errors+1)); }
    [ -f "$CONFIG_FILE" ] || { printf "%s[-]%s Config missing\n" "$RED" "$RESET"; errors=$((errors+1)); }
    [ -d "$BXPLOIT_HOME/skills" ] && [ "$(ls -A "$BXPLOIT_HOME/skills" 2>/dev/null)" ] || warn "Skills empty"
    [ -d "$BXPLOIT_HOME/knowledge" ] && [ "$(ls -A "$BXPLOIT_HOME/knowledge" 2>/dev/null)" ] || warn "Knowledge empty"
    [ -f "$BXPLOIT_HOME/SYSTEM.md" ] || warn "SYSTEM.md (jailbreak) missing"

    if [ $errors -gt 0 ]; then
        die "$errors verification errors. Try reinstalling."
    fi
}

# --- Summary --------------------------------------------------------------
summary() {
    printf "\n%s═══════════════════════════════════════════════════%s\n" "$GREEN" "$RESET"
    printf "%s           Instalasi Selesai!%s\n" "$BOLD" "$RESET"
    printf "%s═══════════════════════════════════════════════════%s\n\n" "$GREEN" "$RESET"
    printf "  %sConfig:%s    %s\n" "$CYAN" "$RESET" "$CONFIG_FILE"
    printf "  %sBinary:%s    %s/bin/kimi-code\n" "$CYAN" "$RESET" "$BXPLOIT_HOME"
    printf "  %sSkills:%s    %s/skills/\n" "$CYAN" "$RESET" "$BXPLOIT_HOME"
    printf "  %sKnowledge:%s %s/knowledge/\n" "$CYAN" "$RESET" "$BXPLOIT_HOME"
    printf "  %sCLI:%s       %s\n" "$CYAN" "$RESET" "$CLI_BIN"
    printf "\n"
    printf "  %sJalankan:%s  source %s && bxploit\n" "$BOLD" "$RESET" "$SHELL_RC"
    printf "  %sSetup:%s     bxploit --setup\n" "$YELLOW" "$RESET"
    printf "  %sUpdate:%s    bxploit --update\n" "$YELLOW" "$RESET"
    printf "  %sUninstall:%s bxploit --uninstall\n\n" "$YELLOW" "$RESET"
}

# --- Main -----------------------------------------------------------------
main() {
    banner
    detect_platform
    detect_shell_rc
    check_prereqs
    download_binary
    download_assets
    setup_wizard
    create_cli_wrapper
    add_to_path
    verify
    summary
}

main "$@"
