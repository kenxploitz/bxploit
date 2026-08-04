#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — Full Uninstaller
# Usage: bxploit --uninstall
#        sh uninstall.sh
# ============================================================================

set -e

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6) BOLD=$(tput bold) RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CLI_BIN="$HOME/.local/bin/bxploit"
KIMI_SYMLINK="$HOME/.kimi-code"
MARKER="# Bxploit"

info()    { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}[!]${NC} %s\n" "$1"; }
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
printf "  ${BOLD}FULL UNINSTALLER${NC}\n\n"

# List what will be removed
printf "  ${CYAN}Yang akan dihapus:${NC}\n\n"
printf "  ${YELLOW}[1]${NC} $BXPLOIT_HOME/              (config, binary, skills, knowledge, plugins)\n"
printf "  ${YELLOW}[2]${NC} $CLI_BIN                    (CLI wrapper)\n"
printf "  ${YELLOW}[3]${NC} $KIMI_SYMLINK               (symlink)\n"
printf "  ${YELLOW}[4]${NC} /tmp/bxploit*               (temp files)\n"
printf "  ${YELLOW}[5]${NC} PATH entries in shell RC    (.bashrc, .zshrc, .profile)\n"
printf "  ${YELLOW}[6]${NC} Source repos (optional)     (~/bxploit, ~/bxploit-source)\n"
printf "\n"

# Confirm
printf "  ${BOLD}Yakin mau hapus SEMUA? [y/N]:${NC} "
read -r confirm
case "$confirm" in
    y|Y|yes|YES) ;;
    *) printf "  Batal.\n"; exit 0 ;;
esac

# ── Remove bxploit home ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Remove Files${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

if [ -d "$BXPLOIT_HOME" ]; then
    rm -rf "$BXPLOIT_HOME"
    success "Removed $BXPLOIT_HOME"
else
    warn "$BXPLOIT_HOME not found"
fi

# ── Remove CLI wrapper ──
if [ -f "$CLI_BIN" ]; then
    rm -f "$CLI_BIN"
    success "Removed $CLI_BIN"
else
    warn "$CLI_BIN not found"
fi

# ── Remove symlink ──
if [ -L "$KIMI_SYMLINK" ]; then
    rm -f "$KIMI_SYMLINK"
    success "Removed symlink $KIMI_SYMLINK"
elif [ -d "$KIMI_SYMLINK" ]; then
    warn "$KIMI_SYMLINK is a real directory (not symlink), skipping"
fi

# ── Remove temp files ──
if ls /tmp/bxploit* 2>/dev/null; then
    rm -rf /tmp/bxploit*
    success "Removed /tmp/bxploit*"
fi

# ── Clean Shell RC Files ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Clean Shell RC${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ ! -f "$rc" ]; then
        continue
    fi

    if grep -qF "$MARKER" "$rc" 2>/dev/null || grep -qi "bxploit" "$rc" 2>/dev/null || grep -qi "BXPLOIT_HOME" "$rc" 2>/dev/null; then
        tmpfile=$(mktemp)
        grep -vF "$MARKER" "$rc" 2>/dev/null | \
        grep -vi "bxploit" | \
        grep -vi "BXPLOIT_HOME" | \
        grep -vi "# Bungul Exploit" > "$tmpfile" 2>/dev/null || true
        sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmpfile" > "$rc" 2>/dev/null || cp "$tmpfile" "$rc"
        rm -f "$tmpfile"
        success "Cleaned $rc"
    else
        printf "  ${GREEN}[✓]${NC} %s (clean)\n" "$rc"
    fi
done

# ── Remove Source Repos ──
printf "\n  ${CYAN}─────────────────────────────────────────────${NC}\n"
printf "  ${BOLD}Source Repos${NC}\n"
printf "  ${CYAN}─────────────────────────────────────────────${NC}\n\n"

FOUND_REPOS=""
for dir in "$HOME/bxploit" "$HOME/bxploit-source" "$HOME/bxploit-agent" "$HOME/bungul-exploit" "$HOME/bxploit-src" "/tmp/bxploit-release"; do
    if [ -d "$dir" ]; then
        FOUND_REPOS="$FOUND_REPOS $dir"
    fi
done

if [ -n "$FOUND_REPOS" ]; then
    printf "  ${YELLOW}Ditemukan:${NC}\n"
    for repo in $FOUND_REPOS; do
        printf "    - %s\n" "$repo"
    done
    printf "\n  ${BOLD}Hapus semua source repo? [y/N]:${NC} "
    read -r rm_src
    case "$rm_src" in
        y|Y|yes|YES)
            for repo in $FOUND_REPOS; do
                rm -rf "$repo"
                success "Removed $repo"
            done
            ;;
        *)
            info "Source repos kept"
            ;;
    esac
else
    info "No source repos found"
fi

# ── Kill any running processes ──
if pgrep -f "kimi-code" >/dev/null 2>&1; then
    printf "\n  ${YELLOW}[!]${NC} Killing running bxploit processes...\n"
    pkill -9 -f "kimi-code" 2>/dev/null || true
    success "Processes killed"
fi

# ── Done ──
printf "\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n"
printf "  ${BOLD}  BXPLOIT Fully Uninstalled!${NC}\n"
printf "  ${GREEN}═══════════════════════════════════════════════════${NC}\n\n"

CURRENT_SHELL="$(basename "${SHELL:-/bin/sh}")"
printf "  ${YELLOW}Source RC file lo:${NC}\n"
case "$CURRENT_SHELL" in
    zsh)  printf "    source ~/.zshrc\n" ;;
    bash) printf "    source ~/.bashrc\n" ;;
    *)    printf "    source ~/.profile\n" ;;
esac

printf "\n  ${CYAN}Reinstall:${NC}\n"
printf "    curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/scripts/install.sh -o /tmp/bxploit.sh && sh /tmp/bxploit.sh\n"
printf "\n"
