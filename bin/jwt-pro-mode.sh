#!/bin/bash
# JWT PRO MODE - Integracja z Profesjonalnymi Narzędziami
# Używa: jwt_tool, jwtcat, hashcat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔥 JWT PRO MODE - Professional Tools Integration     ║${NC}"
echo -e "${CYAN}║     jwt_tool + jwtcat + hashcat                       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

# Check if professional tools are installed
TOOLS_DIR="$HOME/.jwt-tools"
JWT_TOOL="$TOOLS_DIR/jwt_tool/jwt_tool.py"
JWTCAT="$TOOLS_DIR/jwtcat/jwtcat"

check_and_install_tools() {
    echo -e "${BLUE}[*] Checking professional tools...${NC}\n"
    
    NEED_INSTALL=false
    
    # Check jwt_tool
    if [ ! -f "$JWT_TOOL" ]; then
        echo -e "${YELLOW}⚠️  jwt_tool not found${NC}"
        NEED_INSTALL=true
    else
        echo -e "${GREEN}✅ jwt_tool installed${NC}"
    fi
    
    # Check jwtcat
    if ! command -v jwtcat &> /dev/null; then
        echo -e "${YELLOW}⚠️  jwtcat not found${NC}"
        NEED_INSTALL=true
    else
        echo -e "${GREEN}✅ jwtcat installed${NC}"
    fi
    
    # Check hashcat (optional)
    if ! command -v hashcat &> /dev/null; then
        echo -e "${YELLOW}⚠️  hashcat not found (optional)${NC}"
    else
        echo -e "${GREEN}✅ hashcat installed${NC}"
    fi
    
    if [ "$NEED_INSTALL" = true ]; then
        echo -e "\n${YELLOW}Would you like to install missing tools? (y/n)${NC}"
        read -r install_choice
        
        if [ "$install_choice" = "y" ]; then
            install_pro_tools
        else
            echo -e "${RED}Cannot proceed without professional tools${NC}"
            exit 1
        fi
    fi
}

install_pro_tools() {
    echo -e "\n${BLUE}[*] Installing professional JWT tools...${NC}\n"
    
    mkdir -p "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    
    # Install jwt_tool
    if [ ! -f "$JWT_TOOL" ]; then
        echo -e "${CYAN}Installing jwt_tool...${NC}"
        git clone https://github.com/ticarpi/jwt_tool.git
        cd jwt_tool
        pip3 install -r requirements.txt --quiet
        chmod +x jwt_tool.py
        cd "$TOOLS_DIR"
        echo -e "${GREEN}✅ jwt_tool installed${NC}"
    fi
    
    # Install jwtcat
    if ! command -v jwtcat &> /dev/null; then
        echo -e "${CYAN}Installing jwtcat...${NC}"
        
        # Check if Go is installed
        if ! command -v go &> /dev/null; then
            echo -e "${YELLOW}Installing Go (required for jwtcat)...${NC}"
            wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
            export PATH=$PATH:/usr/local/go/bin
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            rm go1.21.5.linux-amd64.tar.gz
        fi
        
        # Install jwtcat
        go install github.com/aress31/jwtcat@latest
        export PATH=$PATH:$HOME/go/bin
        echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
        echo -e "${GREEN}✅ jwtcat installed${NC}"
    fi
    
    # Install hashcat (optional, large download)
    echo -e "${YELLOW}Install hashcat for GPU bruteforce? (y/n)${NC}"
    read -r hashcat_choice
    
    if [ "$hashcat_choice" = "y" ]; then
        sudo apt update -qq
        sudo apt install -y hashcat
        echo -e "${GREEN}✅ hashcat installed${NC}"
    fi
    
    echo -e "\n${GREEN}✅ Professional tools installed!${NC}\n"
}

# Main execution
check_and_install_tools

echo -e "\n${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}JWT PRO MODE - Select Test Type${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}\n"

echo "1. 🔥 JWT_TOOL - All Scan (10-15 requests, smart)"
echo "2. 🎯 JWT_TOOL - Tamper Mode (manual selection)"
echo "3. 💪 JWTCAT - Bruteforce Secret (wordlist)"
echo "4. ⚡ HASHCAT - GPU Bruteforce (fastest)"
echo "5. 📊 FULL SCAN - All tools (comprehensive)"
echo ""
echo -e "${YELLOW}Select option (1-5):${NC}"
read -r mode_choice

echo -e "\n${YELLOW}Paste JWT Token:${NC}"
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: No token provided${NC}"
    exit 1
fi

case $mode_choice in
    1)
        # JWT_TOOL - All Scan
        echo -e "\n${BLUE}[*] Running jwt_tool All Scan...${NC}\n"
        
        # Run with mode 'pb' (playbook) - tests all common vulnerabilities
        python3 "$JWT_TOOL" "$TOKEN" -M pb
        
        echo -e "\n${GREEN}✅ jwt_tool scan complete!${NC}"
        echo -e "${YELLOW}Check output above for vulnerabilities${NC}"
        ;;
        
    2)
        # JWT_TOOL - Tamper Mode
        echo -e "\n${BLUE}[*] Running jwt_tool Tamper Mode...${NC}\n"
        
        echo "Select tamper option:"
        echo "  a) None algorithm (alg=none)"
        echo "  b) Algorithm confusion (RS256)"
        echo "  c) Change claims (manual)"
        echo "  d) All tampering tests"
        read -r tamper_choice
        
        case $tamper_choice in
            a)
                python3 "$JWT_TOOL" "$TOKEN" -X a
                ;;
            b)
                python3 "$JWT_TOOL" "$TOKEN" -X k
                ;;
            c)
                python3 "$JWT_TOOL" "$TOKEN" -T
                ;;
            d)
                python3 "$JWT_TOOL" "$TOKEN" -X a -X k -T
                ;;
        esac
        
        echo -e "\n${GREEN}✅ Tampering complete!${NC}"
        ;;
        
    3)
        # JWTCAT - Bruteforce
        echo -e "\n${BLUE}[*] Running jwtcat bruteforce...${NC}\n"
        
        WORDLIST="$HOME/jwt-pentesting-suite/wordlists/merged-wordlist-unique.txt"
        
        if [ ! -f "$WORDLIST" ]; then
            echo -e "${YELLOW}Wordlist not found. Using small test list...${NC}"
            WORDLIST="/tmp/jwt-test-wordlist.txt"
            cat > "$WORDLIST" << 'WORDLIST_EOF'
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
your-256-bit-secret
WORDLIST_EOF
        fi
        
        echo "Wordlist: $WORDLIST"
        echo "Testing... (This may take a while)"
        
        jwtcat -t "$TOKEN" -w "$WORDLIST"
        
        echo -e "\n${GREEN}✅ Bruteforce complete!${NC}"
        ;;
        
    4)
        # HASHCAT - GPU Bruteforce
        echo -e "\n${BLUE}[*] Running hashcat GPU bruteforce...${NC}\n"
        
        if ! command -v hashcat &> /dev/null; then
            echo -e "${RED}Hashcat not installed!${NC}"
            exit 1
        fi
        
        # Extract header.payload for hashcat
        IFS='.' read -r header payload signature <<< "$TOKEN"
        HASH_INPUT="${header}.${payload}.${signature}"
        
        echo "$HASH_INPUT" > /tmp/jwt_hash.txt
        
        echo "Select hashcat mode:"
        echo "  1) Dictionary attack (wordlist)"
        echo "  2) Brute force (mask)"
        read -r hashcat_choice
        
        case $hashcat_choice in
            1)
                WORDLIST="$HOME/jwt-pentesting-suite/wordlists/merged-wordlist-unique.txt"
                if [ ! -f "$WORDLIST" ]; then
                    echo -e "${YELLOW}Using rockyou.txt...${NC}"
                    WORDLIST="/usr/share/wordlists/rockyou.txt"
                fi
                
                hashcat -m 16500 /tmp/jwt_hash.txt "$WORDLIST"
                ;;
            2)
                echo "Mask (e.g., ?l?l?l?l?l?l for 6 lowercase):"
                read -r mask
                hashcat -m 16500 /tmp/jwt_hash.txt -a 3 "$mask"
                ;;
        esac
        
        echo -e "\n${GREEN}✅ Hashcat complete!${NC}"
        ;;
        
    5)
        # FULL SCAN - All tools
        echo -e "\n${BLUE}[*] Running FULL SCAN with all tools...${NC}\n"
        
        echo -e "${CYAN}[1/3] jwt_tool - Vulnerability scan${NC}"
        python3 "$JWT_TOOL" "$TOKEN" -M pb
        
        echo -e "\n${CYAN}[2/3] jwtcat - Quick secret test${NC}"
        cat > /tmp/quick-secrets.txt << 'QUICK_EOF'
secret
password
123456
admin
QUICK_EOF
        jwtcat -t "$TOKEN" -w /tmp/quick-secrets.txt
        
        echo -e "\n${CYAN}[3/3] jwt_tool - Tamper tests${NC}"
        python3 "$JWT_TOOL" "$TOKEN" -X a
        
        echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✅ FULL SCAN COMPLETE!                               ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        ;;
        
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Next Steps:${NC}"
echo "  • Review findings above"
echo "  • Test generated tokens against API"
echo "  • Document vulnerabilities"
echo "  • Run additional scans if needed"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}\n"

