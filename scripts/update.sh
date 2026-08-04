#!/bin/sh
# ============================================================================
# Bungul Exploit (bxploit) — Standalone Updater
# Usage: sh update.sh
#        curl -sL https://raw.githubusercontent.com/.../update.sh | sh
# ============================================================================

set -e

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6) BOLD=$(tput bold) RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
BINARY_PATH="$BXPLOIT_HOME/bin/kimi-code"
GITHUB_REPO="MoonshotAI/kimi-code"

info()  { printf "%s[+]%s %s\n" "$GREEN" "$RESET" "$1"; }
warn()  { printf "%s[!]%s %s\n" "$YELLOW" "$RESET" "$1"; }
die()   { printf "%s[-]%s %s\n" "$RED" "$RESET" "$1"; exit 1; }

printf "%s%sBXPLOIT UPDATER%s\n\n" "$BOLD" "$CYAN" "$RESET"

# Check installation
if [ ! -f "$BINARY_PATH" ]; then
    die "Bxploit not found at $BINARY_PATH. Run install.sh first."
fi

# Get current version
CURRENT_VER=$("$BINARY_PATH" --version 2>/dev/null || echo "unknown")
info "Current version: $CURRENT_VER"

# Get latest release
info "Checking latest release..."
TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed 's/.*: *"//;s/".*//')
[ -z "$TAG" ] && die "Failed to check latest release"
info "Latest: $TAG"

# Download new binary
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64) ARCH_NAME="x64" ;;
    aarch64|arm64) ARCH_NAME="arm64" ;;
    *) die "Unsupported: $ARCH" ;;
esac

ENCODED_TAG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TAG'))" 2>/dev/null || die "python3 required")
DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/${ENCODED_TAG}/kimi-code-linux-${ARCH_NAME}.zip"

info "Downloading..."
TMP_DIR=$(mktemp -d)
curl -fsSL -o "$TMP_DIR/kimi-code.zip" "$DOWNLOAD_URL" || die "Download failed"

# Backup current
cp "$BINARY_PATH" "$BINARY_PATH.bak" 2>/dev/null

# Extract
cd "$TMP_DIR" && unzip -o kimi-code.zip 2>/dev/null || die "Extraction failed"
mv kimi "$BINARY_PATH" 2>/dev/null || mv kimi-code "$BINARY_PATH" 2>/dev/null || die "Binary not found"
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

# Copy skills/knowledge if source exists
for src_dir in "$HOME/bxploit" "$HOME/bxploit-source"; do
    if [ -d "$src_dir/plugins/bxploit-pentest" ]; then
        cp -r "$src_dir/plugins/bxploit-pentest/skills/"* "$BXPLOIT_HOME/skills/" 2>/dev/null
        cp -r "$src_dir/plugins/bxploit-pentest/"* "$BXPLOIT_HOME/plugins/bxploit-pentest/" 2>/dev/null
        cp -r "$src_dir/knowledge/"* "$BXPLOIT_HOME/knowledge/" 2>/dev/null
        cp "$src_dir/plugins/bxploit-pentest/SYSTEM.md" "$BXPLOIT_HOME/SYSTEM.md" 2>/dev/null
        info "Assets updated"
        break
    fi
done

# Verify
NEW_VER=$("$BINARY_PATH" --version 2>/dev/null || echo "unknown")
printf "\n"
info "Updated: $CURRENT_VER → $NEW_VER"
info "Done! Run: bxploit"
