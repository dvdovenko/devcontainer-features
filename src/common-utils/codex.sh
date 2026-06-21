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

check_packages curl ca-certificates

echo "Installing Codex CLI using the official native installer..."
export CODEX_NON_INTERACTIVE=true
export CODEX_INSTALL_DIR="/usr/local/bin"
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Verify installation
echo "Verifying installation..."
if codex --version >/dev/null 2>&1; then
    codex --version
    echo "Codex CLI installation completed successfully!"
else
    echo "Warning: Codex CLI installed but version check failed. This might be expected behavior."
fi

echo "Done!"
