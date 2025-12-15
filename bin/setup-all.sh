#!/bin/bash
# 🚀 JWT Pentesting Suite - FULL SETUP (Everything in One!)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🚀 JWT Pentesting Suite - FULL SETUP                  ║${NC}"
echo -e "${CYAN}║     Instalacja + Security Check + Deploy                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

PROJECT_DIR="/home/nc/jwt-pentesting-suite"
cd "$PROJECT_DIR"

# STEP 1: Install
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[1/3] INSTALACJA (Dependencies + Wordlisty)${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

bash bin/install.sh || true

# STEP 2: Security Check
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[2/3] SECURITY CHECK (Token Validation)${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Sprawdzanie bezpieczeństwa...${NC}\n"
bash bin/check-tokens.sh || true

# STEP 3: Deploy
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[3/3] DEPLOY NA GITHUB${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

bash bin/safe-deploy-wsl.sh || true

# FINAL
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ FULL SETUP COMPLETED!                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}Status:${NC}"
echo -e "  ✅ Dependencies installed"
echo -e "  ✅ Wordlisty pobrane"
echo -e "  ✅ Tokeny sprawdzony"
echo -e "  ✅ Projekt na GitHub"
echo ""
echo -e "${CYAN}Lokalizacja: ${PROJECT_DIR}${NC}"
echo ""
echo -e "${YELLOW}Co Dalej?${NC}"
echo "  1. cd /home/nc/jwt-pentesting-suite"
echo "  2. Dodaj description w GitHub repo"
echo "  3. Dziel się projektem! 🚀"

