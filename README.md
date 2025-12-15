# 🔐 JWT Pentesting Suite Pro

Zaawansowana suite do penetration testingu JSON Web Tokens z **27+ kompleksowymi testami** i **500K+ wordlist'ami** do bruteforce'u.

## ✨ Features

- 🔴 **27 Zaawansowanych Testów** - CVE-2015-9235, Algorithm Confusion, Key Injection i więcej
- 💾 **500K+ Wordlist'ów** - SecLists + JWT-specific passwords
- 🌐 **Online + Offline Mode** - Web GUI + CLI
- 🔗 **Cross-Validation** - Integracja z jwt.io, jwtcat, hashcat, john
- 📊 **Risk Scoring** - CRITICAL/HIGH/MEDIUM/LOW
- 🚀 **GPU/CPU Support** - Bruteforce z hashcat/john
- 📖 **Dokumentacja** - 27 testów z przykładami

## 🚀 Quick Start

```bash
# 1. Instalacja
bash /home/nc/jwt-pentesting-suite/bin/install.sh

# 2. Sprawdzenie tokenów
bash /home/nc/jwt-pentesting-suite/bin/check-tokens.sh

# 3. Deploy na GitHub
bash /home/nc/jwt-pentesting-suite/bin/safe-deploy-wsl.sh
```

## 📋 27 Testów

### CRITICAL (5)
- None Algorithm (CVE-2015-9235)
- Empty Signature
- Missing Expiration
- JKU Injection (CVE-2016-5431)
- X5U Injection

### HIGH (8+)
- Algorithm Confusion
- Weak Secret Bruteforce
- Missing Claims (iss, aud, sub)
- KID Injection
- Signature Stripping
- + więcej...

## 💾 Wordlisty

```
wordlists/
├── SecLists/                    (10-15MB)
├── jwt-common-secrets.txt       (100+ JWT-specific)
└── merged-wordlist-unique.txt   (500K+ unique)
```

## 🛠️ Narzędzia

- **jwtcat** - Bruteforce secrets
- **hashcat** - GPU bruteforce (optional)
- **john** - CPU bruteforce
- **jwt.io** - Online decoder
- **Burp Suite** - Interception

## 📖 Dokumentacja

- [27 Testów Guide](./docs/27-TESTS.md)
- [Token Rotation](./docs/GITHUB-TOKEN-ROTATION.md)
- [Workflow](./docs/WORKFLOW.md)

## 📄 License

MIT - Free for commercial and open-source use

---

**Done !!!**

---

## 🎯 SMART MODE - Limited Requests (NEW!)

**For production environments with rate limiting - Maximum 10-15 requests**

```bash
bash bin/jwt-smart-mode.sh
```

### What Smart Mode Tests (10 Priority Tests):

1. **NONE Algorithm** (CVE-2015-9235) - 🔴 CRITICAL
2. **Algorithm Confusion** (HS256↔RS256) - 🟠 HIGH  
3. **Signature Stripping** - 🟠 HIGH
4. **Payload Tampering** (user_id, admin escalation) - 🔴 CRITICAL
5. **Expiration Bypass** - 🟡 MEDIUM
6. **Missing Standard Claims** (iss, aud, sub, nbf, jti) - 🟠 HIGH
7. **KID Injection** (Path traversal) - 🔴 CRITICAL
8. **Weak Secret** (Top 5 common) - 🔴 CRITICAL
9. **JKU/X5U Injection** - 🔴 CRITICAL
10. **Token Expiration Check** - Offline

### Features:

- ✅ **Offline Mode**: Generates test tokens without API calls
- ✅ **Online Mode**: Optional API testing (max 10-15 requests)
- ✅ **Request Counter**: Tracks number of requests used
- ✅ **Priority Testing**: Only CRITICAL + HIGH vulnerabilities
- ✅ **Smart Selection**: Skips tests if header params not present
- ✅ **Generated Payloads**: Ready-to-use tampered tokens

### Usage:

**Offline (0 requests):**
```bash
bash bin/jwt-smart-mode.sh
# Paste token
# Press Enter when asked for API URL (skip)
# Get test tokens to manually test
```

**Online (10-15 requests):**
```bash
bash bin/jwt-smart-mode.sh
# Paste token
# Enter API endpoint URL
# Automatic testing with request limit
```

### Perfect For:

- Production pentests with rate limiting
- WAF-protected applications  
- Quick vulnerability assessment
- Bug bounty programs with request limits
- Real-world scenarios where fuzzing is not allowed

---


---

## 🔥 PRO MODE - Professional Tools Integration (NEW!)

**Industry-standard tools used by real penetration testers!**

```bash
bash bin/jwt-pro-mode.sh
```

### Professional Tools Included:

1. **jwt_tool** (5.2k+ ⭐) - Most popular JWT pentesting tool
   - 27+ vulnerability tests
   - Playbook mode (smart scanning)
   - Interactive tampering
   - CVE scanning

2. **jwtcat** - High-speed secret bruteforce
   - Multi-threaded (Go)
   - 500K+ wordlist support
   - Fast dictionary attacks

3. **hashcat** - GPU-accelerated cracking
   - Billions of passwords/second
   - Mask attacks
   - Rule-based attacks

### 5 Modes Available:

1. **jwt_tool All Scan** - Comprehensive vulnerability scan (10-15 requests)
2. **jwt_tool Tamper** - Interactive token manipulation
3. **jwtcat Bruteforce** - CPU-based dictionary attack
4. **hashcat GPU** - Ultra-fast GPU cracking
5. **Full Scan** - Run all tools sequentially

### Quick Example:

```bash
bash bin/jwt-pro-mode.sh

Select: 1 (jwt_tool All Scan)
Paste token: eyJhbGciOiJIUzI1NiI...

[*] Running jwt_tool...
✓ Scanned 27 vulnerabilities
✓ Found: Algorithm confusion possible
✓ Found: Missing iss, aud claims
✓ Generated test tokens
```

**See [PRO-TOOLS.md](PRO-TOOLS.md) for complete documentation.**

---

## 🎯 Which Mode to Use?

| Scenario | Recommended Mode | Why |
|----------|-----------------|-----|
| **Production (rate limited)** | Smart Mode | Max 15 requests |
| **Lab/Comprehensive testing** | Pro Mode | Industry tools |
| **Quick vulnerability check** | Smart Mode | Fast, simple |
| **Unknown secret** | Pro Mode (hashcat) | GPU bruteforce |
| **Bug bounty** | Smart Mode | Respects limits |
| **Full audit** | Pro Mode (Full Scan) | All tools |

---

