#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Checks if packages are installed and installs them if not
check_packages() {
    if command -v brew >/dev/null 2>&1; then
        sudo brew install "$@"
    elif ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            sudo apt-get update -y
        fi
        sudo apt-get -y install --no-install-recommends "$@"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install "$@"
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache "$@"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S "$@"
    else
        echo "Could not find a package manager to install $@. Please install it manually."
    fi
}

# bash is required because the official installer below is piped into bash,
# and Alpine-based images don't ship bash by default.
check_packages bash curl ca-certificates

echo "Installing Claude Code using the official native installer..."
curl -fsSL https://claude.ai/install.sh | bash

export PATH="${HOME}/.local/bin:${PATH}"

# The native installer always places a symlink here pointing at a versioned
# binary under ~/.local/share/claude/versions/<version>.
CLAUDE_BIN="${HOME}/.local/bin/claude"

if [ ! -e "$CLAUDE_BIN" ]; then
    echo "ERROR: Could not find the installed claude binary"
    exit 1
fi

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
