#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — Swiss Army Knife Launcher
# Usage: bxploit.sh [--uninstall|--update|--help|--config|--test|--setup]
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
CONFIG_FILE="$BXPLOIT_HOME/config.toml"
VENV_DIR="$BXPLOIT_HOME/venv"
CLI_BIN="$HOME/.local/bin/bxploit"
INSTALL_DIR="$BXPLOIT_HOME/bxploit-agent"
SKILLS_DIR="$BXPLOIT_HOME/skills"
REPO_URL="https://github.com/bungul-exploit/bxploit-agent.git"
MARKER="# Bungul Exploit"

# --- Logging --------------------------------------------------------------
info()  { printf "%s[INFO]%s  %s\n" "$CYAN" "$RESET" "$1"; }
ok()    { printf "%s[OK]%s    %s\n" "$GREEN" "$RESET" "$1"; }
warn()  { printf "%s[WARN]%s  %s\n" "$YELLOW" "$RESET" "$1"; }
die()   { printf "%s[ERR]%s   %s\n" "$RED" "$RESET" "$1"; exit 1; }

# --- Banner ---------------------------------------------------------------
banner() {
    printf '%s' "$GREEN"
    cat << 'BANNER'

 ██████╗ ██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗
 ██╔══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝
 ██████╔╝ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║
 ██╔══██╗ ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║
 ██████╔╝██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝
                B U N G U L   E X P L O I T

BANNER
    printf '%s' "$RESET"
}

# --- Installation Check ---------------------------------------------------
is_installed() {
    [ -f "$CONFIG_FILE" ] && \
    [ -f "$VENV_DIR/bin/activate" ] && \
    [ -f "$CLI_BIN" ]
}

ensure_installed() {
    if ! is_installed; then
        die "bxploit belum terinstall. Jalankan installer dulu."
    fi
}

# --- Config Parser (simple TOML reader) -----------------------------------
read_config() {
    local key="$1"
    local section="${2:-api}"
    local in_section=0

    if [ ! -f "$CONFIG_FILE" ]; then
        echo ""
        return
    fi

    while IFS= read -r line; do
        # Skip comments and empty lines
        case "$line" in
            \#*|"") continue ;;
        esac

        # Section headers
        case "$line" in
            \[*\])
                sec=$(printf '%s' "$line" | tr -d '[]')
                if [ "$sec" = "$section" ]; then
                    in_section=1
                else
                    in_section=0
                fi
                continue
                ;;
        esac

        # Key-value pairs
        if [ $in_section -eq 1 ]; then
            k=$(printf '%s' "$line" | cut -d'=' -f1 | tr -d ' ')
            v=$(printf '%s' "$line" | cut -d'=' -f2- | tr -d '"' | sed 's/^ *//;s/ *$//')
            if [ "$k" = "$key" ]; then
                echo "$v"
                return
            fi
        fi
    done < "$CONFIG_FILE"
    echo ""
}

# --- Mask API Key ---------------------------------------------------------
mask_key() {
    local key="$1"
    local len=${#key}

    if [ $len -le 16 ]; then
        echo "****...****"
        return
    fi

    first8=$(printf '%s' "$key" | cut -c1-8)
    last4=$(printf '%s' "$key" | rev | cut -c1-4 | rev)
    echo "${first8}...${last4}"
}

# --- Version Extraction ---------------------------------------------------
get_version() {
    if [ -f "$INSTALL_DIR/package.json" ]; then
        python3 -c "
import json, sys
try:
    v = json.load(open('$INSTALL_DIR/package.json')).get('version', 'unknown')
    print(v)
except:
    print('unknown')
" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# --- Test API Connection --------------------------------------------------
test_api_connection() {
    printf "\n%sTesting API Connection ...%s\n\n" "$BOLD" "$RESET"

    base_url=$(read_config "base_url")
    api_key=$(read_config "api_key")
    provider=$(read_config "provider")
    model=$(read_config "model")

    if [ -z "$base_url" ] || [ -z "$api_key" ]; then
        die "Config tidak lengkap. Jalankan: bxploit --setup"
    fi

    printf "  %sBase URL:%s  %s\n" "$CYAN" "$RESET" "$base_url"
    printf "  %sProvider:%s  %s\n" "$CYAN" "$RESET" "$provider"
    printf "  %sAPI Key:%s   %s\n" "$CYAN" "$RESET" "$(mask_key "$api_key")"
    printf "  %sModel:%s     %s\n\n" "$CYAN" "$RESET" "$model"

    # Fetch models
    printf "%sFetching /models ...%s\n" "$CYAN" "$RESET"

    models_url="${base_url}/models"
    response=$(curl -sL --max-time 15 \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        "$models_url" 2>/dev/null || echo "")

    if [ -z "$response" ]; then
        die "Tidak bisa connect ke $models_url. Cek URL & API key."
    fi

    # Check for error
    error=$(printf '%s' "$response" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    if 'error' in d:
        print(d['error'].get('message', str(d['error'])))
    else:
        print('')
except:
    print('PARSE_ERROR')
" 2>/dev/null || echo "PARSE_ERROR")

    if [ -n "$error" ] && [ "$error" != "PARSE_ERROR" ]; then
        die "API Error: $error"
    fi

    # Parse and display models
    printf "\n%sAvailable Models (first 10):%s\n" "$BOLD" "$RESET"
    printf '%s' "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = data.get('data', data) if isinstance(data, dict) else data
    if isinstance(models, list):
        for i, m in enumerate(models[:10]):
            name = m.get('id', m.get('name', str(m))) if isinstance(m, dict) else str(m)
            print(f'  {i+1:2d}) {name}')
        if len(models) > 10:
            print(f'  ... and {len(models)-10} more')
        print(f'\n  Total: {len(models)} models')
    else:
        print('  (unexpected response format)')
except Exception as e:
    print(f'  (parse error: {e})')
" 2>/dev/null

    printf "\n%s✓ API connection OK!%s\n" "$GREEN" "$RESET"
}

# --- Change API Base URL ---------------------------------------------------
change_base_url() {
    printf "\n%sPilih API Provider:%s\n" "$BOLD" "$RESET"
    printf "  %s1)%s OpenAI      (https://api.openai.com/v1)\n" "$CYAN" "$RESET"
    printf "  %s2)%s Anthropic   (https://api.anthropic.com/v1)\n" "$CYAN" "$RESET"
    printf "  %s3)%s OpenRouter  (https://openrouter.ai/api/v1)\n" "$CYAN" "$RESET"
    printf "  %s4)%s Custom\n" "$CYAN" "$RESET"
    printf "\nPilih [1-4]: "
    read -r choice

    case "$choice" in
        1) url="https://api.openai.com/v1" ;;
        2) url="https://api.anthropic.com/v1" ;;
        3) url="https://openrouter.ai/api/v1" ;;
        4)
            printf "Masukin API Base URL: "
            read -r url
            ;;
        *)
            warn "Invalid choice"
            return 1
            ;;
    esac

    url="${url%/}"

    # Detect provider
    case "$url" in
        *anthropic*) provider="anthropic" ;;
        *openrouter*) provider="openrouter" ;;
        *) provider="openai" ;;
    esac

    # Update config
    update_config "api" "base_url" "$url"
    update_config "api" "provider" "$provider"
    ok "Base URL updated: $url"
}

# --- Change API Key -------------------------------------------------------
change_api_key() {
    printf "\nMasukin API Key baru: "
    read -rs new_key
    printf "\n"

    if [ -z "$new_key" ]; then
        warn "API Key kosong, tidak diubah"
        return 1
    fi

    update_config "api" "api_key" "$new_key"
    ok "API Key updated ($(mask_key "$new_key"))"
}

# --- Change Model ----------------------------------------------------------
change_model() {
    printf "\nFetching models ...\n"
    base_url=$(read_config "base_url")
    api_key=$(read_config "api_key")

    models_url="${base_url}/models"
    response=$(curl -sL --max-time 10 \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        "$models_url" 2>/dev/null || echo "")

    if [ -z "$response" ]; then
        printf "Masukin model name: "
        read -r model
        [ -n "$model" ] && update_config "api" "model" "$model" && ok "Model updated: $model"
        return
    fi

    # Parse models
    models=$(printf '%s' "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = data.get('data', data) if isinstance(data, dict) else data
    if isinstance(models, list):
        names = [m.get('id', m.get('name', str(m))) if isinstance(m, dict) else str(m) for m in models]
        print('|'.join(names[:10]))
except:
    print('')
" 2>/dev/null || echo "")

    if [ -n "$models" ]; then
        printf "\n%sModels:%s\n" "$BOLD" "$RESET"
        i=1
        OLD_IFS="$IFS"
        IFS='|'
        for m in $models; do
            printf "  %s%d)%s %s\n" "$CYAN" "$i" "$RESET" "$m"
            i=$((i + 1))
        done
        IFS="$OLD_IFS"

        printf "\nPilih [1-%d]: " "$((i - 1))"
        read -r choice

        i=1
        OLD_IFS="$IFS"
        IFS='|'
        for m in $models; do
            if [ "$i" = "$choice" ]; then
                update_config "api" "model" "$m"
                ok "Model updated: $m"
                break
            fi
            i=$((i + 1))
        done
        IFS="$OLD_IFS"
    else
        printf "Masukin model name: "
        read -r model
        [ -n "$model" ] && update_config "api" "model" "$model" && ok "Model updated: $model"
    fi
}

# --- Update Config --------------------------------------------------------
update_config() {
    local section="$1"
    local key="$2"
    local value="$3"

    python3 -c "
import re, sys

config_file = '$CONFIG_FILE'
section = '[$section]'
key = '$key'
value = '\"' + '''$value''' + '\"'

with open(config_file, 'r') as f:
    content = f.read()

# Find section, then update key
lines = content.split('\n')
in_section = False
updated = False
result = []

for line in lines:
    stripped = line.strip()
    if stripped == section:
        in_section = True
        result.append(line)
        continue
    if in_section and stripped.startswith('[') and stripped.endswith(']'):
        if not updated:
            result.append(f'{key} = {value}')
            updated = True
        in_section = False
        result.append(line)
        continue
    if in_section and stripped.startswith(key + ' ='):
        result.append(f'{key} = {value}')
        updated = True
        continue
    result.append(line)

if not updated:
    # Append to section
    final = []
    for line in result:
        final.append(line)
        if line.strip() == section:
            final.append(f'{key} = {value}')
    result = final

with open(config_file, 'w') as f:
    f.write('\n'.join(result))
" 2>/dev/null
}

# --- Full Reconfigure (Setup Wizard) --------------------------------------
full_reconfigure() {
    info "Running full reconfigure ..."
    sh "$INSTALL_DIR/scripts/install.sh" --reconfigure 2>/dev/null || {
        # Inline reconfigure if install.sh doesn't support --reconfigure
        change_base_url
        change_api_key
        change_model
    }
}

# --- Update bxploit -------------------------------------------------------
update_bxploit() {
    printf "\n%sUpdating Bxploit ...%s\n" "$BOLD" "$RESET"

    if [ ! -d "$INSTALL_DIR/.git" ]; then
        die "Source repo not found at $INSTALL_DIR"
    fi

    # Get current version
    ver_before=$(get_version)
    info "Current version: $ver_before"

    # Pull
    cd "$INSTALL_DIR"
    if ! git pull --ff-only 2>/dev/null; then
        warn "Fast-forward failed, doing hard reset ..."
        git fetch --all
        git reset --hard origin/main
    fi
    ok "Repository updated"

    # Build (if build script exists)
    if [ -f "$INSTALL_DIR/package.json" ]; then
        if command -v npm >/dev/null 2>&1; then
            info "Building ..."
            npm install --silent 2>/dev/null || warn "npm install failed (non-critical)"
            npm run build --silent 2>/dev/null || warn "npm build not available (non-critical)"
        fi
    fi

    # Copy skills/knowledge/plugins
    if [ -d "$INSTALL_DIR/skills" ]; then
        mkdir -p "$SKILLS_DIR"
        cp -r "$INSTALL_DIR/skills/"* "$SKILLS_DIR/" 2>/dev/null
    fi
    if [ -d "$INSTALL_DIR/knowledge" ]; then
        mkdir -p "$BXPLOIT_HOME/knowledge"
        cp -r "$INSTALL_DIR/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
    fi
    if [ -d "$INSTALL_DIR/plugins" ]; then
        mkdir -p "$BXPLOIT_HOME/plugins"
        cp -r "$INSTALL_DIR/plugins/"* "$BXPLOIT_HOME/plugins/" 2>/dev/null
    fi

    # Verify
    ver_after=$(get_version)
    if [ "$ver_before" != "$ver_after" ]; then
        ok "Updated: $ver_before → $ver_after"
    else
        ok "Already up to date ($ver_after)"
    fi
}

# --- Uninstall -------------------------------------------------------------
uninstall_bxploit() {
    if [ -f "$BXPLOIT_HOME/uninstall.sh" ]; then
        sh "$BXPLOIT_HOME/uninstall.sh"
    else
        die "Uninstaller not found. Remove manually: rm -rf $BXPLOIT_HOME"
    fi
}

# --- Show Current Config --------------------------------------------------
show_config() {
    if ! is_installed; then
        warn "bxploit belum terinstall"
        return
    fi

    base_url=$(read_config "base_url")
    api_key=$(read_config "api_key")
    provider=$(read_config "provider")
    model=$(read_config "model")
    version=$(get_version)

    printf "\n%sCurrent Configuration:%s\n" "$BOLD" "$RESET"
    printf "  %sVersion:%s    %s\n" "$CYAN" "$RESET" "$version"
    printf "  %sBase URL:%s  %s\n" "$CYAN" "$RESET" "$base_url"
    printf "  %sProvider:%s  %s\n" "$CYAN" "$RESET" "$provider"
    printf "  %sModel:%s     %s\n" "$CYAN" "$RESET" "$model"
    printf "  %sAPI Key:%s   %s\n" "$CYAN" "$RESET" "$(mask_key "$api_key")"
    printf "  %sConfig:%s    %s\n" "$CYAN" "$RESET" "$CONFIG_FILE"
    printf "  %sSkills:%s    %s\n\n" "$CYAN" "$RESET" "$SKILLS_DIR"
}

# --- Interactive Menu ------------------------------------------------------
interactive_menu() {
    banner

    if is_installed; then
        version=$(get_version)
        model=$(read_config "model")
        printf "  %sVersion:%s %s | %sModel:%s %s\n\n" "$CYAN" "$RESET" "$version" "$CYAN" "$RESET" "$model"
    else
        printf "  %sStatus:%s Not installed\n\n" "$YELLOW" "$RESET"
    fi

    printf "  %s1)%s Change API Base URL\n" "$CYAN" "$RESET"
    printf "  %s2)%s Change API Key\n" "$CYAN" "$RESET"
    printf "  %s3)%s Change Model\n" "$CYAN" "$RESET"
    printf "  %s4)%s Change All (full reconfigure)\n" "$CYAN" "$RESET"
    printf "  %s5)%s Test API Connection\n" "$CYAN" "$RESET"
    printf "  %s6)%s Update Bxploit\n" "$CYAN" "$RESET"
    printf "  %s7)%s Uninstall Bxploit\n" "$CYAN" "$RESET"
    printf "  %s8)%s Exit\n" "$CYAN" "$RESET"
    printf "\n%sPilih [1-8]:%s " "$BOLD" "$RESET"
    read -r choice

    case "$choice" in
        1) ensure_installed; change_base_url ;;
        2) ensure_installed; change_api_key ;;
        3) ensure_installed; change_model ;;
        4) full_reconfigure ;;
        5) ensure_installed; test_api_connection ;;
        6) update_bxploit ;;
        7) uninstall_bxploit ;;
        8) printf "Mantap. Gas terus.\n"; exit 0 ;;
        *) warn "Pilihan tidak valid" ;;
    esac
}

# --- Help ------------------------------------------------------------------
show_help() {
    banner
    cat << 'HELP'
Usage: bxploit [options]

Options:
  (no args)     Interactive menu
  --config      Show current configuration
  --test        Test API connection
  --setup       Run full setup wizard
  --update      Update bxploit to latest
  --uninstall   Uninstall bxploit
  --help        Show this help message
  --version     Show version

Examples:
  bxploit                  # Interactive menu
  bxploit --test           # Test API connection
  bxploit --config         # Show config
  bxploit --update         # Update
  bxploit --uninstall      # Uninstall

Environment:
  BXPLOIT_HOME    Override home dir (default: ~/.bxploit)
HELP
}

# --- Dispatch -------------------------------------------------------------
dispatch() {
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --version|-v)
            if is_installed; then
                get_version
            else
                echo "Not installed"
            fi
            ;;
        --config|-c)
            show_config
            ;;
        --test|-t)
            test_api_connection
            ;;
        --setup|-s)
            if [ -f "$INSTALL_DIR/scripts/install.sh" ]; then
                sh "$INSTALL_DIR/scripts/install.sh"
            else
                die "Installer not found. Reclone repo."
            fi
            ;;
        --update|-u)
            update_bxploit
            ;;
        --uninstall)
            uninstall_bxploit
            ;;
        "")
            interactive_menu
            ;;
        *)
            warn "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# --- Main -----------------------------------------------------------------
dispatch "$@"
