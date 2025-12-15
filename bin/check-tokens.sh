#!/bin/bash
# GitHub Token Security Checker
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔐 GitHub Token Security Checker                      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}[1/3] Szukanie tokenów w systemie...${NC}\n"

if [ ! -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}❓ GITHUB_TOKEN env var znaleziona${NC}"
fi

if [ -f ~/.github-token-jwt-suite ]; then
    echo -e "${YELLOW}❓ ~/.github-token-jwt-suite znaleziona${NC}"
fi

if [ -f ~/.github-token ]; then
    echo -e "${YELLOW}❓ ~/.github-token znaleziona${NC}"
fi

echo -e "\n${BLUE}[2/3] Testowanie tokenów...${NC}\n"

test_token() {
    local TOKEN="$1"
    local TOKEN_NAME="${2:-Unknown}"
    
    if [ -z "$TOKEN" ]; then
        echo -e "${RED}  ❌ Token pusty${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Testowanie: ${TOKEN_NAME}${NC}"
    
    RESPONSE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user)
    
    if echo "$RESPONSE" | grep -q '"login"'; then
        USERNAME=$(echo "$RESPONSE" | grep -oP '"login":"?\K[^"]*')
        echo -e "${GREEN}  ✅ VALID - User: ${USERNAME}${NC}\n"
        return 0
    elif echo "$RESPONSE" | grep -q '"message".*"Bad credentials"'; then
        echo -e "${RED}  ❌ INVALID - Bad credentials${NC}\n"
        return 1
    else
        echo -e "${YELLOW}  ⚠️  UNKNOWN - Sprawdzić${NC}\n"
        return 1
    fi
}

read -p "Wklej token do testowania (lub Enter aby pominąć): " TOKEN_INPUT

if [ ! -z "$TOKEN_INPUT" ]; then
    test_token "$TOKEN_INPUT" "Manual token"
fi

if [ ! -z "$GITHUB_TOKEN" ]; then
    test_token "$GITHUB_TOKEN" "GITHUB_TOKEN env var"
fi

if [ -f ~/.github-token-jwt-suite ]; then
    TOKEN=$(cat ~/.github-token-jwt-suite | tr -d '\n')
    test_token "$TOKEN" "~/.github-token-jwt-suite"
fi

echo -e "\n${BLUE}[3/3] Security Audit...${NC}\n"

if grep -i "ghp_\|github_token" ~/.bash_history 2>/dev/null; then
    echo -e "${RED}❌ Tokeny znalezione w ~/.bash_history${NC}"
else
    echo -e "${GREEN}✅ Bash history safe${NC}"
fi

if [ -f ~/.git-credentials ]; then
    PERMS=$(stat -c %a ~/.git-credentials 2>/dev/null || echo "600")
    if [ "$PERMS" != "600" ]; then
        echo -e "${YELLOW}⚠️  .git-credentials permissions: $PERMS (powinno: 600)${NC}"
        chmod 600 ~/.git-credentials
    else
        echo -e "${GREEN}✅ File permissions OK${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Token check completed!${NC}"
