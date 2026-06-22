#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Checks if packages are installed and installs them if not.
# This script asserts it is already running as root above, so none of these
# need (or, on minimal images like Alpine, even have) sudo available.
check_packages() {
    if command -v brew >/dev/null 2>&1; then
        brew install "$@"
    elif command -v apt-get >/dev/null 2>&1; then
        if ! dpkg -s "$@" >/dev/null 2>&1; then
            if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
                echo "Running apt-get update..."
                apt-get update -y
            fi
            apt-get -y install --no-install-recommends "$@"
        fi
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache "$@"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y "$@"
    elif command -v pacman >/dev/null 2>&1; then
        pacman -S --noconfirm "$@"
    else
        echo "Could not find a package manager to install $@. Please install it manually."
        exit 1
    fi
}

# bash is required because the official installer below is piped into bash,
# and Alpine-based images don't ship bash by default.
check_packages bash curl ca-certificates

echo "Installing Claude Code using the official native installer..."

# The native installer always installs under $HOME (a symlink at
# ~/.local/bin/claude pointing at a versioned binary under
# ~/.local/share/claude/versions/<version>). During a root-run feature
# install that resolves to /root, which non-root container users can't
# traverse, leaving the /usr/local/bin/claude symlink dangling for them.
# Point HOME at a world-readable location for the duration of the install.
export HOME="/usr/local/share/claude-home"
mkdir -p "$HOME"

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
