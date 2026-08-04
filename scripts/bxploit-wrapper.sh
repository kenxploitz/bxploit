#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export KIMI_CODE_HOME="$BXPLOIT_HOME"
export BXPLOIT_HOME="$BXPLOIT_HOME"
[ ! -d "$HOME/.kimi-code" ] && ln -sf "$BXPLOIT_HOME" "$HOME/.kimi-code" 2>/dev/null
BXPLOIT_BIN="$BXPLOIT_HOME/bin/kimi-code"
[ ! -f "$BXPLOIT_BIN" ] && echo "Error: bxploit not installed" && exit 1
clear
printf '\033]0;Bxploit\007'

# Block models.dev catalog fetch
export MODELS_DEV_URL="http://0.0.0.0:0"

case "$1" in
    --setup|-s) exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@" ;;
    --config|-c) cat "$BXPLOIT_HOME/config.toml" 2>/dev/null || echo "No config"; exit 0 ;;
    --test|-t) curl -s -m 10 "$(grep base_url "$BXPLOIT_HOME/config.toml"|sed 's/.*"//;s/".*//')/models" -H "Authorization: Bearer $(grep api_key "$BXPLOIT_HOME/config.toml"|sed 's/.*"//;s/".*//')"|python3 -c "import sys,json;print(f'OK: {len(json.load(sys.stdin).get(\"data\",[]))} models')" 2>/dev/null||echo "Failed";exit 0 ;;
    --uninstall) exec sh "$BXPLOIT_HOME/scripts/uninstall.sh" ;;
    --update|-u) exec sh "$BXPLOIT_HOME/scripts/update.sh" ;;
    --help|-h) echo "BXPLOIT — AI Pentest Framework"; echo "Usage: bxploit [-p query|--setup|--config|--test|--update|--uninstall|--help]"; exit 0 ;;
esac
[ ! -f "$BXPLOIT_HOME/config.toml" ] && echo "Run: bxploit --setup" && exit 1
HAS_PROMPT=0; for a in "$@"; do [ "$a" = "-p" ] && HAS_PROMPT=1; done
if [ "$HAS_PROMPT" = "1" ]; then exec "$BXPLOIT_BIN" "$@"; else exec "$BXPLOIT_BIN" --yolo "$@"; fi
