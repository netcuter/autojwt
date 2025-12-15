#!/bin/bash
# JWT Pentesting Suite - Instalacja + 50MB+ Wordlist'ów
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔐 JWT Pentesting Suite - Instalacja                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}[1/4] Instalacja zależności...${NC}"
if command -v apt &> /dev/null; then
    sudo apt update -qq && sudo apt install -y curl wget git jq python3 python3-pip nodejs npm > /dev/null 2>&1
fi
echo -e "${GREEN}✅ Zależności zainstalowane${NC}"

echo -e "\n${BLUE}[2/4] Instalacja JWT tools...${NC}"
pip3 install jwtcat -q 2>/dev/null || true
echo -e "${GREEN}✅ jwtcat zainstalowany${NC}"

echo -e "\n${BLUE}[3/4] Pobieranie wordlist'ów...${NC}"
WORDLIST_DIR=/home/nc/jwt-pentesting-suite/wordlists
cd "$WORDLIST_DIR"

if [ ! -d "SecLists" ]; then
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git 2>&1 | tail -1
fi

cat > jwt-common-secrets.txt << 'SECRETS'
secret
password
123456
admin
key
jwt
test
token
mykey
mysecret
verysecret
1234567890
admin123
password123
secret123
JWT_SECRET
JWT_KEY
your-256-bit-secret
your-secret-key
long-secret-key-here
super-secret
my-secret-key
top-secret
secretpassword
jwttoken
tokensecret
authorization
credentials
apikey
api_secret
auth_secret
SECRETS

echo -e "${GREEN}✅ JWT secrets created${NC}"

echo -e "\n${BLUE}[4/4] Merge'owanie wordlist'ów...${NC}"
> merged-wordlist-all.txt

if [ -d "SecLists/Passwords" ]; then
    find SecLists/Passwords -name "*.txt" -type f 2>/dev/null | while read f; do
        cat "$f" >> merged-wordlist-all.txt 2>/dev/null || true
    done
fi

cat jwt-common-secrets.txt >> merged-wordlist-all.txt 2>/dev/null || true
sort -u merged-wordlist-all.txt > merged-wordlist-unique.txt 2>/dev/null || true

WORDCOUNT=$(wc -l < merged-wordlist-unique.txt 2>/dev/null || echo "0")
SIZE=$(du -h merged-wordlist-unique.txt 2>/dev/null | cut -f1 || echo "unknown")

echo -e "${GREEN}✅ Merged: ${WORDCOUNT} unique haseł${NC}"

echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Instalacja Ukończona!                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}\n"
