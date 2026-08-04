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
    print('0) (gagal parse models)')
" 2>/dev/null)

    if [ -n "$MODEL_LIST" ]; then
        printf "\n${GREEN}Available models:${NC}\n"
        echo "$MODEL_LIST"
        printf "\n${GREEN}Pilih model (nomor atau nama): ${NC}"
        read -r MODEL_CHOICE

        if echo "$MODEL_CHOICE" | grep -q '^[0-9]\+$'; then
            MODEL=$(echo "$MODEL_LIST" | sed -n "${MODEL_CHOICE}p" | sed 's/^[0-9]*) //')
        else
            MODEL="$MODEL_CHOICE"
        fi
    else
        printf "${YELLOW}[!] Gagal parse models. Masukin manual.${NC}\n"
        printf "${GREEN}Model name: ${NC}"
        read -r MODEL
    fi
else
    printf "${YELLOW}[!] Gagal fetch models. Masukin manual.${NC}\n"
    printf "${GREEN}Model name (contoh: combo/combo/deepseek-v4-pro): ${NC}"
    read -r MODEL
fi

if [ -z "$MODEL" ]; then
    MODEL="tumpuk/mimo-v2.5-pro"
fi

printf "\n${GREEN}[+] Selected model: $MODEL${NC}\n"

# Save config in Kimi Code TOML format
mkdir -p "$BXPLOIT_HOME"

# Generate provider name (sanitize for TOML)
PROVIDER_NAME="custom"

cat > "$CONFIG_FILE" << EOF
default_model = "$MODEL"
default_permission_mode = "yolo"

[providers.$PROVIDER_NAME]
type = "$PROVIDER_TYPE"
base_url = "$BASE_URL"
api_key = "$API_KEY"

[models."$MODEL"]
provider = "$PROVIDER_NAME"
model = "$MODEL"
max_context_size = 999999999
max_input_size = 999999999
max_output_size = 999999999
capabilities = ["thinking", "tool_use"]
EOF

chmod 600 "$CONFIG_FILE"

# Copy setup script for later use
mkdir -p "$BXPLOIT_HOME/scripts"
cp "$0" "$BXPLOIT_HOME/scripts/setup.sh" 2>/dev/null

# Mask API key for display
MASKED=$(echo "$API_KEY" | cut -c1-8)"..."$(echo "$API_KEY" | rev | cut -c1-4 | rev)

printf "\n${GREEN}[✓] Config saved to: $CONFIG_FILE${NC}\n"
printf "${GREEN}[✓] Provider: $PROVIDER_TYPE${NC}\n"
printf "${GREEN}[✓] Model: $MODEL${NC}\n"
printf "${GREEN}[✓] Base URL: $BASE_URL${NC}\n"
printf "${GREEN}[✓] API Key: $MASKED${NC}\n"
printf "\n${CYAN}Jalankan: bxploit${NC}\n"
