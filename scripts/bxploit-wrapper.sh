#!/bin/sh
BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
export BXPLOIT_HOME
export KIMI_CODE_HOME="$BXPLOIT_HOME"
BXPLOIT_BIN="$BXPLOIT_HOME/bin/bxploit"

if [ ! -f "$BXPLOIT_BIN" ]; then
    echo "Error: bxploit not installed at $BXPLOIT_BIN"
    exit 1
fi

CMD="$1"

if [ "$CMD" = "--setup" ] || [ "$CMD" = "-s" ]; then
    exec sh "$BXPLOIT_HOME/scripts/setup.sh" "$@"
elif [ "$CMD" = "--config" ] || [ "$CMD" = "-c" ]; then
    cat "$BXPLOIT_HOME/config.toml" 2>/dev/null || echo "No config"
    exit 0
elif [ "$CMD" = "--update" ] || [ "$CMD" = "-u" ]; then
    exec sh "$BXPLOIT_HOME/scripts/update.sh"
elif [ "$CMD" = "--uninstall" ]; then
    exec sh "$BXPLOIT_HOME/scripts/uninstall.sh"
elif [ "$CMD" = "--help" ] || [ "$CMD" = "-h" ]; then
    echo "BXPLOIT - AI Pentest Framework"
    echo "Usage: bxploit [-p query|--setup|--config|--test|--update|--uninstall|--help]"
    exit 0
elif [ "$CMD" = "--test" ] || [ "$CMD" = "-t" ]; then
    BASE_URL=$(grep base_url "$BXPLOIT_HOME/config.toml" 2>/dev/null | sed 's/.*"//;s/".*//')
    API_KEY=$(grep api_key "$BXPLOIT_HOME/config.toml" 2>/dev/null | sed 's/.*"//;s/".*//')
    curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" 2>/dev/null | python3 -c "import sys,json;print(f'OK: {len(json.load(sys.stdin).get(\"data\",[]))} models')" 2>/dev/null || echo "Failed"
    exit 0
fi

if [ ! -f "$BXPLOIT_HOME/config.toml" ]; then
    echo "Config belum ada. Running setup..."
    exec sh "$BXPLOIT_HOME/scripts/setup.sh"
fi

[ ! -f "$BXPLOIT_HOME/tui.toml" ] && echo 'theme = "auto"' > "$BXPLOIT_HOME/tui.toml"

HAS_PROMPT=0
for a in "$@"; do [ "$a" = "-p" ] && HAS_PROMPT=1; done

if [ "$HAS_PROMPT" = "1" ]; then
    exec "$BXPLOIT_BIN" "$@"
else
    exec "$BXPLOIT_BIN" --yolo "$@"
fi
