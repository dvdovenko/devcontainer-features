#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

check_packages curl ca-certificates

echo "Installing Claude Code using the official native installer..."
curl -fsSL https://claude.ai/install.sh | bash

# Locate the installed binary (native installer places it under ~/.local/bin or ~/.claude/bin)
CLAUDE_BIN=$(find "${HOME}/.local/bin" "${HOME}/.claude" -maxdepth 3 -type f -name claude 2>/dev/null | head -n 1)

if [ -z "$CLAUDE_BIN" ]; then
    echo "ERROR: Could not find the installed claude binary"
    exit 1
fi

chmod +x "$CLAUDE_BIN"
ln -sf "$CLAUDE_BIN" /usr/local/bin/claude

# Verify installation
echo "Verifying installation..."
if claude --version >/dev/null 2>&1; then
    claude --version
    echo "Claude Code installation completed successfully!"
else
    echo "Warning: Claude Code installed but version check failed. This might be expected behavior."
fi

echo "Done!"
