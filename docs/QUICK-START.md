# 🚀 Quick Start - JWT Pentesting Suite

## Instalacja (5 min)

```bash
# 1. Instalacja dependencies + wordlisty
bash /home/nc/jwt-pentesting-suite/bin/install.sh

# Czekaj aż się skończy (~5-10 minut)
```

## Security Check (WAŻNE!)

```bash
# 2. Sprawdzenie czy masz bezpieczne tokeny
bash /home/nc/jwt-pentesting-suite/bin/check-tokens.sh

# Jeśli znajdzie stare tokeny:
# - Wejdź na https://github.com/settings/tokens
# - Deletuj tokeny >3 miesiące
# - Wygeneruj nowy token (90 days expiration)
```

## Deploy na GitHub

```bash
# 3. Deploy projektu
bash /home/nc/jwt-pentesting-suite/bin/safe-deploy-wsl.sh

# Odpowiadasz na pytania:
# Username: (twój GitHub nick)
# Repo name: jwt-pentesting-suite
# Git email: (twój email)
```

## Verify

```bash
# 4. Sprawdzenie czy wszystko działa
cd /home/nc/jwt-pentesting-suite
git status
git log --oneline -3

# Sprawdzić na GitHub
# https://github.com/YOUR_USERNAME/jwt-pentesting-suite
```

## Co Dalej?

```bash
# Testowanie JWT token'ów
node bin/jwt-pentester.js

# Bruteforce secret'u
jwtcat -t "YOUR_TOKEN" -w wordlists/merged-wordlist-unique.txt

# Sprawdzenie na jwt.io
https://jwt.io/#debugger
```

---

**Done !!!**
