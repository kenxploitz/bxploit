#!/bin/sh
set -e

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
BINARY="$BXPLOIT_HOME/bin/bxploit"
BXPLOIT_REPO="kenxploitz/bxploit"

info()    { printf "  ${GREEN}[+]${NC} %s\n" "$1"; }
fail()    { printf "  ${RED}[x]${NC} %s\n" "$1"; exit 1; }
success() { printf "  ${GREEN}[✓]${NC} %s\n" "$1"; }

printf "\n  ${BOLD}BXPLOIT UPDATER${NC}\n\n"

[ ! -f "$BINARY" ] && fail "Bxploit not found"

info "Updating SYSTEM.md (jailbreak)..."
curl -fsSL "https://raw.githubusercontent.com/$BXPLOIT_REPO/main/plugins/bxploit-pentest/SYSTEM.md" -o "$BXPLOIT_HOME/SYSTEM.md" 2>/dev/null && success "SYSTEM.md updated" || info "SYSTEM.md unchanged"

info "Updating skills..."
mkdir -p "$BXPLOIT_HOME/skills"
for skill in pentest-core exploit-range osint-deep waf-bypass; do
    curl -fsSL "https://raw.githubusercontent.com/$BXPLOIT_REPO/main/plugins/bxploit-pentest/skills/$skill.md" -o "$BXPLOIT_HOME/skills/$skill.md" 2>/dev/null && success "  $skill.md" || true
done

info "Updating knowledge base..."
mkdir -p "$BXPLOIT_HOME/knowledge"
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/main.zip" "https://github.com/$BXPLOIT_REPO/archive/refs/heads/main.zip" 2>/dev/null
if [ -f "$TMP/main.zip" ]; then
    cd "$TMP" && unzip -o main.zip 2>/dev/null
    [ -d "$TMP/bxploit-main/knowledge" ] && cp -r "$TMP/bxploit-main/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
    rm -rf "$TMP"
    success "Knowledge base updated"
fi

printf "\n  ${GREEN}Update Complete!${NC}\n\n"
printf "  Run ${CYAN}bxploit --update-binary${NC} to update the binary\n\n"
