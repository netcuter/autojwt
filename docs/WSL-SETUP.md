# WSL Security Setup

## SSH Keys (Recommended)

```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519 -N ""

# 2. Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy i paste na: https://github.com/settings/keys

# 3. Test SSH
ssh -T git@github.com
```

## Token Storage

```bash
# NEVER do this:
export GITHUB_TOKEN='ghp_xxxxxx'  # Will be in history!

# INSTEAD:
echo "ghp_xxxxxx" > ~/.github-token-jwt-suite
chmod 600 ~/.github-token-jwt-suite

# Configure git
git config --global credential.helper store
```

## File Permissions

```bash
# Important for WSL security!
chmod 600 ~/.github-token-jwt-suite
chmod 700 ~/.ssh
ls -la ~/.ssh/
```

## Bash History Cleanup

```bash
# If you accidentally leaked a token
history -c
cat /dev/null > ~/.bash_history

# Check if token in history
grep -i "ghp_\|token\|secret" ~/.bash_history
```
EOF_EOF

echo "✅ Docs created (QUICK-START, WSL-SETUP)"
