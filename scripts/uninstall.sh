#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — Standalone Uninstaller
# Usage: sh uninstall.sh
# ============================================================================

set -e

# --- Colors ---------------------------------------------------------------
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6) BOLD=$(tput bold) RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CLI_BIN="$HOME/.local/bin/bxploit"
SKILLS_DIR="$BXPLOIT_HOME/skills"
KNOWLEDGE_DIR="$BXPLOIT_HOME/knowledge"
PLUGINS_DIR="$BXPLOIT_HOME/plugins"
MARKER="# Bungul Exploit"

info()  { printf "%s[INFO]%s  %s\n" "$CYAN" "$RESET" "$1"; }
ok()    { printf "%s[OK]%s    %s\n" "$GREEN" "$RESET" "$1"; }
warn()  { printf "%s[WARN]%s  %s\n" "$YELLOW" "$RESET" "$1"; }

# --- Banner ---------------------------------------------------------------
printf '%s' "$RED"
cat << 'BANNER'

 ██████╗ ██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗
 ██╔══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝
 ██████╔╝ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║
 ██╔══██╗ ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║
 ██████╔╝██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝
              U N I N S T A L L E R

BANNER
printf '%s\n' "$RESET"

# --- List What Will Be Removed --------------------------------------------
printf "%sYang akan dihapus:%s\n" "$BOLD" "$RESET"
printf "  1. %s%s/%s                 (config, venv, agent)\n" "$YELLOW" "$BXPLOIT_HOME" "$RESET"
printf "  2. %s%s%s           (CLI wrapper)\n" "$YELLOW" "$CLI_BIN" "$RESET"
printf "  3. %s%s%s       (skills)\n" "$YELLOW" "$SKILLS_DIR" "$RESET"
printf "  4. %s%s%s   (knowledge)\n" "$YELLOW" "$KNOWLEDGE_DIR" "$RESET"
printf "  5. %s%s%s      (plugins)\n" "$YELLOW" "$PLUGINS_DIR" "$RESET"
printf "  6. PATH entries in shell RC files\n"
printf "\n"

# --- Confirm --------------------------------------------------------------
printf "%sYakin mau uninstall Bungul Exploit? [y/N]:%s " "$BOLD" "$RESET"
read -r confirm
case "$confirm" in
    y|Y|yes|YES) ;;
    *) printf "Batal. Bxploit tetap terinstall.\n"; exit 0 ;;
esac

# --- Remove bxploit home directory ----------------------------------------
if [ -d "$BXPLOIT_HOME" ]; then
    rm -rf "$BXPLOIT_HOME"
    ok "Removed $BXPLOIT_HOME"
else
    warn "$BXPLOIT_HOME not found"
fi

# --- Remove CLI wrapper ---------------------------------------------------
if [ -f "$CLI_BIN" ]; then
    rm -f "$CLI_BIN"
    ok "Removed $CLI_BIN"
else
    warn "$CLI_BIN not found"
fi

# --- Clean Shell RC Files -------------------------------------------------
info "Cleaning shell RC files ..."

for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ ! -f "$rc" ]; then
        continue
    fi

    if grep -qF "# Bungul Exploit" "$rc" 2>/dev/null || grep -qi "bxploit" "$rc" 2>/dev/null; then
        tmpfile=$(mktemp)

        # Remove lines containing our marker or bxploit references
        grep -vF "# Bungul Exploit" "$rc" 2>/dev/null | \
        grep -vi "bxploit" | \
        grep -vi "BXPLOIT_HOME" > "$tmpfile" 2>/dev/null || true

        # Remove trailing blank lines
        sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmpfile" > "$rc" 2>/dev/null || cp "$tmpfile" "$rc"
        rm -f "$tmpfile"

        ok "Cleaned $rc"
    else
        printf "  %s✓%s %s (no bxploit entries)\n" "$GREEN" "$RESET" "$rc"
    fi
done

# --- Optional: Remove Source Repository -----------------------------------
SOURCE_DIR=""
for dir in "$HOME/bxploit" "$HOME/bxploit-agent" "$HOME/bungul-exploit" "$HOME/bxploit-src"; do
    if [ -d "$dir/.git" ] || [ -d "$dir/scripts" ]; then
        SOURCE_DIR="$dir"
        break
    fi
done

if [ -n "$SOURCE_DIR" ]; then
    printf "\n%sHapus source repo (%s)? [y/N]:%s " "$YELLOW" "$SOURCE_DIR" "$RESET"
    read -r rm_src
    case "$rm_src" in
        y|Y|yes|YES)
            rm -rf "$SOURCE_DIR"
            ok "Removed source repo: $SOURCE_DIR"
            ;;
        *)
            info "Source repo kept at $SOURCE_DIR"
            ;;
    esac
fi

# --- Done -----------------------------------------------------------------
printf "\n"
printf "%s═══════════════════════════════════════════════════%s\n" "$GREEN" "$RESET"
printf "%s✓ Bungul Exploit berhasil di-uninstall!%s\n" "$GREEN" "$RESET"
printf "%s═══════════════════════════════════════════════════%s\n" "$GREEN" "$RESET"
printf "\n"
printf "%sJangan lupa source RC file lo:%s\n" "$YELLOW" "$RESET"

CURRENT_SHELL="$(basename "${SHELL:-/bin/sh}")"
case "$CURRENT_SHELL" in
    zsh)  printf "  source ~/.zshrc\n" ;;
    bash) printf "  source ~/.bashrc\n" ;;
    *)    printf "  source ~/.profile\n" ;;
esac

printf "\nMantap. Sampai jumpa lagi.\n"
