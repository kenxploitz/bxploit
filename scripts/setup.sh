#!/bin/sh
# Bxploit Setup Wizard

BXPLOIT_HOME="${BXPLOIT_HOME:-$HOME/.bxploit}"
CONFIG_FILE="$BXPLOIT_HOME/config.toml"

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'

printf "${CYAN}"
printf " ____  _____ _   _ ____  _     _____ ____ ___ _____ _\n"
printf "| __ )|  ___| | | |  _ \\| |   | ____|  _ \\_ _|_   _|(_)___\n"
printf "|  _ \\| |_  | | | | |_) | |   |  _| | |_) | |  | | | |/ __|\n"
printf "| |_) |  _| | |_| |  __/| |___| |___|  __/| |  | | | |\\__ \\\n"
printf "|____/|_|    \\___/|_|   |_____|_____|_|  |___| |_| |_| |___/\n"
printf "${NC}"
printf "${BOLD}API Configuration Wizard${NC}\n\n"

# API Base URL
printf "${GREEN}[?] API Base URL:${NC}\n"
printf "  1) 9router Local  (http://localhost:20128/v1)\n"
printf "  2) OpenAI         (https://api.openai.com/v1)\n"
printf "  3) Anthropic      (https://api.anthropic.com/v1)\n"
printf "  4) DeepSeek       (https://api.deepseek.com/v1)\n"
printf "  5) Ollama         (http://localhost:11434/v1)\n"
printf "  6) Custom\n"
printf "\n${GREEN}Pilih [1-6]: ${NC}"
read -r choice

case "$choice" in
    1) BASE_URL="http://localhost:20128/v1" ;;
    2) BASE_URL="https://api.openai.com/v1" ;;
    3) BASE_URL="https://api.anthropic.com/v1" ;;
    4) BASE_URL="https://api.deepseek.com/v1" ;;
    5) BASE_URL="http://localhost:11434/v1" ;;
    6)
        printf "${GREEN}Masukin API Base URL: ${NC}"
        read -r BASE_URL
        ;;
    *) BASE_URL="http://localhost:20128/v1" ;;
esac

if [ -z "$BASE_URL" ]; then
    BASE_URL="http://localhost:20128/v1"
    printf "${YELLOW}[!] Default ke 9router: $BASE_URL${NC}\n"
fi

# API Key
printf "\n${GREEN}[?] API Key: ${NC}"
read -r API_KEY

if [ -z "$API_KEY" ]; then
    printf "${RED}[!] API Key gak boleh kosong!${NC}\n"
    exit 1
fi

# Auto-detect provider type
printf "\n${YELLOW}[*] Detecting provider...${NC}\n"

PROVIDER_TYPE="openai"
if echo "$BASE_URL" | grep -q "anthropic"; then
    PROVIDER_TYPE="anthropic"
elif echo "$BASE_URL" | grep -q "googleapis\|vertexai"; then
    PROVIDER_TYPE="google-genai"
fi

printf "${GREEN}[+] Provider type: $PROVIDER_TYPE${NC}\n"

# Fetch models
printf "${YELLOW}[*] Fetching available models...${NC}\n"

MODELS_RESPONSE=$(curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" 2>/dev/null)

MODEL=""
if echo "$MODELS_RESPONSE" | grep -q '"data"'; then
    printf "${GREEN}[+] Models found!${NC}\n"
    MODEL_LIST=$(echo "$MODELS_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = [m['id'] for m in data.get('data', [])][:20]
    for i, m in enumerate(models, 1):
        print(f'{i}) {m}')
except:
    print('')
" 2>/dev/null)

    if [ -n "$MODEL_LIST" ]; then
        printf "\n${GREEN}Available models:${NC}\n"
        echo "$MODEL_LIST"
        printf "\n${GREEN}Pilih model (nomor atau nama): ${NC}"
        read -r MODEL_CHOICE

        if [ -n "$MODEL_CHOICE" ]; then
            if echo "$MODEL_CHOICE" | grep -q '^[0-9]\+$'; then
                MODEL=$(echo "$MODEL_LIST" | sed -n "${MODEL_CHOICE}p" | sed 's/^[0-9]*) //')
            else
                MODEL="$MODEL_CHOICE"
            fi
        fi
    fi
fi

# Fallback: manual input or default
if [ -z "$MODEL" ]; then
    printf "${YELLOW}[!] Gagal fetch models atau gak ada pilihan.${NC}\n"
    printf "${GREEN}Model name (contoh: mimo-v2.5-pro, gpt-4o): ${NC}"
    read -r MODEL
fi

# Final fallback: default model
if [ -z "$MODEL" ]; then
    MODEL="mimo-v2.5-pro"
    printf "${YELLOW}[!] Pake default: $MODEL${NC}\n"
fi

printf "\n${GREEN}[+] Selected model: $MODEL${NC}\n"

# Generate config
mkdir -p "$BXPLOIT_HOME"

# Sanitize model name for TOML key (replace / with -)
MODEL_KEY=$(echo "$MODEL" | sed 's|/|-|g')

cat > "$CONFIG_FILE" << EOF
default_model = "$MODEL_KEY"
default_permission_mode = "yolo"

[providers.custom]
type = "$PROVIDER_TYPE"
base_url = "$BASE_URL"
api_key = "$API_KEY"

[models."$MODEL_KEY"]
provider = "custom"
model = "$MODEL"
max_context_size = 999999999
max_input_size = 999999999
max_output_size = 999999999
capabilities = ["thinking", "tool_use"]
EOF

chmod 600 "$CONFIG_FILE"

# Generate tui.toml
cat > "$BXPLOIT_HOME/tui.toml" << 'TUI'
theme = "auto"
TUI

# Copy setup script
mkdir -p "$BXPLOIT_HOME/scripts"
cp "$0" "$BXPLOIT_HOME/scripts/setup.sh" 2>/dev/null

# Mask API key
MASKED=$(echo "$API_KEY" | cut -c1-8)"..."$(echo "$API_KEY" | rev | cut -c1-4 | rev)

printf "\n${GREEN}[✓] Config saved${NC}\n"
printf "${GREEN}[✓] Provider: $PROVIDER_TYPE${NC}\n"
printf "${GREEN}[✓] Model: $MODEL${NC}\n"
printf "${GREEN}[✓] Base URL: $BASE_URL${NC}\n"
printf "${GREEN}[✓] API Key: $MASKED${NC}\n"

# Test connection
printf "\n${YELLOW}[*] Testing connection...${NC}\n"
TEST_RESULT=$(curl -s -m 10 "$BASE_URL/models" -H "Authorization: Bearer $API_KEY" 2>/dev/null)
if echo "$TEST_RESULT" | grep -q '"data"'; then
    COUNT=$(echo "$TEST_RESULT" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',[])))" 2>/dev/null)
    printf "${GREEN}[✓] Connected! $COUNT models available${NC}\n"
else
    printf "${YELLOW}[!] Connection test failed (config saved anyway)${NC}\n"
fi

printf "\n${CYAN}Jalankan: bxploit${NC}\n"
