#!/usr/bin/env python3
"""
VULNERABLE JWT API - For Pentesting Training ONLY!
Contains intentional vulnerabilities:
1. None algorithm accepted
2. Weak secret (bruteforceable)
3. Algorithm confusion (HS256/RS256)
4. No expiration validation
5. Missing audience/issuer validation
6. User enumeration via error messages

DO NOT USE IN PRODUCTION!
"""

from flask import Flask, request, jsonify
import jwt
import json
import base64
import hmac
import hashlib
from datetime import datetime, timedelta
from functools import wraps

app = Flask(__name__)

# VULNERABILITY 1: Weak secret (easily bruteforceable)
SECRET_KEY = "secret"  # Common weak secret

# VULNERABILITY 2: Fake RSA public key for algorithm confusion
FAKE_PUBLIC_KEY = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo
4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u
+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh
kd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ
0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg
cKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc
mwIDAQAB
-----END PUBLIC KEY-----"""

# Simulated user database
USERS = {
    "admin": {"password": "admin123", "role": "admin", "user_id": 1},
    "user": {"password": "user123", "role": "user", "user_id": 2},
    "guest": {"password": "guest", "role": "guest", "user_id": 3}
}

# Simulated protected data
PROTECTED_DATA = {
    "admin": {"secret": "FLAG{jwt_none_algorithm_bypass}", "api_keys": ["sk-admin-12345"]},
    "user": {"data": "Regular user data", "profile": "user_profile"},
    "guest": {"data": "Guest limited data"}
}

def decode_base64url(data):
    """Decode base64url without padding"""
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.urlsafe_b64decode(data)

def vulnerable_verify_token(token):
    """
    INTENTIONALLY VULNERABLE token verification!
    Contains multiple security flaws for testing.
    """
    try:
        parts = token.split('.')
        if len(parts) != 3:
            return None, "Invalid token format"
        
        header_b64, payload_b64, signature = parts
        
        # Decode header
        try:
            header = json.loads(decode_base64url(header_b64))
        except:
            return None, "Invalid header"
        
        # Decode payload
        try:
            payload = json.loads(decode_base64url(payload_b64))
        except:
            return None, "Invalid payload"
        
        alg = header.get('alg', 'HS256')
        
        # VULNERABILITY 1: None algorithm accepted!
        if alg.lower() == 'none' or alg == '':
            print(f"[VULN] None algorithm accepted!")
            return payload, None
        
        # VULNERABILITY 2: Algorithm confusion - accepts both HS256 and RS256
        if alg == 'HS256':
            # Normal verification with weak secret
            try:
                decoded = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
                return decoded, None
            except jwt.InvalidSignatureError:
                return None, "Invalid signature"
            except jwt.ExpiredSignatureError:
                # VULNERABILITY 3: Expired tokens still processed!
                print(f"[VULN] Expired token accepted!")
                decoded = jwt.decode(token, SECRET_KEY, algorithms=['HS256'], 
                                    options={"verify_exp": False})
                return decoded, None
        
        elif alg == 'RS256':
            # VULNERABILITY 4: Using public key as HMAC secret (algorithm confusion)
            try:
                decoded = jwt.decode(token, FAKE_PUBLIC_KEY, algorithms=['HS256', 'RS256'])
                return decoded, None
            except:
                # Try with public key as HMAC secret
                try:
                    decoded = jwt.decode(token, FAKE_PUBLIC_KEY.encode(), algorithms=['HS256'])
                    print(f"[VULN] Algorithm confusion exploited!")
                    return decoded, None
                except:
                    return None, "Invalid signature"
        
        # VULNERABILITY 5: Accept any algorithm
        try:
            decoded = jwt.decode(token, SECRET_KEY, algorithms=[alg])
            return decoded, None
        except:
            return None, "Token verification failed"
            
    except Exception as e:
        return None, str(e)

def require_auth(f):
    """Authentication decorator with vulnerabilities"""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        
        if not auth_header:
            return jsonify({"error": "No authorization header"}), 401
        
        if not auth_header.startswith('Bearer '):
            return jsonify({"error": "Invalid authorization format"}), 401
        
        token = auth_header[7:]  # Remove 'Bearer '
        
        payload, error = vulnerable_verify_token(token)
        
        if error:
            # VULNERABILITY 6: Detailed error messages (info disclosure)
            return jsonify({"error": error, "token_received": token[:50] + "..."}), 401
        
        request.user = payload
        return f(*args, **kwargs)
    
    return decorated

# ============ ROUTES ============

@app.route('/')
def index():
    return jsonify({
        "app": "Vulnerable JWT API",
        "version": "1.0.0",
        "warning": "INTENTIONALLY VULNERABLE - FOR TESTING ONLY!",
        "endpoints": {
            "POST /login": "Get JWT token (username, password)",
            "GET /api/profile": "Get user profile (requires JWT)",
            "GET /api/admin": "Admin only endpoint (requires admin JWT)",
            "GET /api/secret": "Secret data (requires valid JWT)",
            "GET /api/users": "List users (admin only)",
            "GET /health": "Health check"
        },
        "vulnerabilities": [
            "None algorithm bypass",
            "Weak secret (bruteforceable)",
            "Algorithm confusion",
            "Expired token acceptance",
            "User enumeration",
            "Missing claims validation"
        ],
        "test_credentials": {
            "admin": "admin123",
            "user": "user123", 
            "guest": "guest"
        }
    })

@app.route('/health')
def health():
    return jsonify({"status": "ok", "timestamp": datetime.utcnow().isoformat()})

@app.route('/login', methods=['POST'])
def login():
    """Login endpoint - returns JWT token"""
    data = request.get_json() or {}
    username = data.get('username', '')
    password = data.get('password', '')
    
    # VULNERABILITY: User enumeration
    if username not in USERS:
        return jsonify({"error": f"User '{username}' not found"}), 404
    
    if USERS[username]['password'] != password:
        return jsonify({"error": "Invalid password for user"}), 401
    
    user = USERS[username]
    
    # Create JWT with intentional weaknesses
    payload = {
        "sub": username,
        "user_id": user['user_id'],
        "role": user['role'],
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=1)
        # VULNERABILITY: Missing 'iss', 'aud', 'jti' claims
    }
    
    # Sign with weak secret
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    
    return jsonify({
        "token": token,
        "type": "Bearer",
        "expires_in": 3600,
        "user": {
            "username": username,
            "role": user['role']
        }
    })

@app.route('/api/profile')
@require_auth
def profile():
    """Get user profile - requires authentication"""
    user = request.user
    username = user.get('sub', 'unknown')
    
    return jsonify({
        "username": username,
        "role": user.get('role', 'unknown'),
        "user_id": user.get('user_id'),
        "token_claims": user
    })

@app.route('/api/admin')
@require_auth
def admin_endpoint():
    """Admin only endpoint"""
    user = request.user
    role = user.get('role', '')
    
    # VULNERABILITY: Role checked but easily bypassed via JWT tampering
    if role != 'admin':
        return jsonify({
            "error": "Admin access required",
            "your_role": role,
            "hint": "Try changing your role in the JWT payload..."
        }), 403
    
    return jsonify({
        "message": "Welcome Admin!",
        "flag": "FLAG{jwt_role_escalation_success}",
        "admin_data": PROTECTED_DATA.get('admin', {}),
        "all_users": list(USERS.keys())
    })

@app.route('/api/secret')
@require_auth
def secret():
    """Secret endpoint - demonstrates none algorithm bypass"""
    user = request.user
    username = user.get('sub', 'unknown')
    
    return jsonify({
        "message": f"Hello {username}! You accessed the secret endpoint.",
        "secret_data": PROTECTED_DATA.get(username, {"data": "No data for this user"}),
        "your_claims": user,
        "flag_if_admin": "FLAG{jwt_claims_verified}" if user.get('role') == 'admin' else "Become admin to see flag"
    })

@app.route('/api/users')
@require_auth
def list_users():
    """List all users - admin only"""
    user = request.user
    
    if user.get('role') != 'admin':
        return jsonify({"error": "Admin required", "your_role": user.get('role')}), 403
    
    # Return user list (without passwords)
    return jsonify({
        "users": [
            {"username": u, "role": d["role"], "user_id": d["user_id"]} 
            for u, d in USERS.items()
        ]
    })

@app.route('/debug/token', methods=['POST'])
def debug_token():
    """Debug endpoint - decodes and validates token (DANGEROUS!)"""
    data = request.get_json() or {}
    token = data.get('token', '')
    
    if not token:
        return jsonify({"error": "No token provided"}), 400
    
    payload, error = vulnerable_verify_token(token)
    
    return jsonify({
        "valid": payload is not None,
        "payload": payload,
        "error": error,
        "hint": "This endpoint helps you debug your exploit tokens!"
    })

if __name__ == '__main__':
    print("""
╔════════════════════════════════════════════════════════════╗
║  🔓 VULNERABLE JWT API - FOR PENTESTING ONLY!              ║
║                                                            ║
║  Vulnerabilities:                                          ║
║  • None algorithm bypass (CVE-2015-9235)                   ║
║  • Weak secret: "secret"                                   ║
║  • Algorithm confusion (HS256/RS256)                       ║
║  • Expired tokens accepted                                 ║
║  • Missing claims validation                               ║
║  • User enumeration                                        ║
║                                                            ║
║  Test credentials: admin/admin123, user/user123            ║
╚════════════════════════════════════════════════════════════╝
    """)
    app.run(host='0.0.0.0', port=5000, debug=True)
