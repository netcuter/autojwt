#!/bin/bash
# Bezpieczny GitHub Deploy dla WSL
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔐 Bezpieczny GitHub Deploy - WSL                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}⚠️  BEZPIECZEŃSTWO:${NC}"
echo -e "  🔴 NIGDY nie wklejaj tokenu w public repo!"
echo -e "  🟢 Używaj SSH keys - są bezpieczniejsze!"
echo ""

read -p "GitHub username: " GITHUB_USER
read -p "Repo name (jwt-pentesting-suite): " REPO_NAME
REPO_NAME=${REPO_NAME:-jwt-pentesting-suite}

echo -e "\n${YELLOW}Konfiguracja Git...${NC}"
read -p "Git username (full name): " GIT_USER
read -p "Git email: " GIT_EMAIL

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

PROJECT_DIR="/home/nc/jwt-pentesting-suite"
cd "$PROJECT_DIR"

echo -e "\n${YELLOW}Inicjalizacja repo...${NC}"

if [ ! -d ".git" ]; then
    git init
    git add . || true
    git commit -m "🚀 Initial commit: JWT Pentesting Suite Pro" || true
fi

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
git branch -M main

echo -e "\n${YELLOW}Push'owanie na GitHub...${NC}"
echo -e "${CYAN}URL: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}\n"

if git push -u origin main; then
    echo -e "\n${GREEN}✅ Push SUCCESSFUL!${NC}"
    echo -e "\nRepo: https://github.com/${GITHUB_USER}/${REPO_NAME}"
else
    echo -e "\n${RED}❌ Push FAILED${NC}"
    echo "Sprawdź czy repo istnieje: https://github.com/new"
    exit 1
fi
