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

check_packages curl ca-certificates

echo "Installing Codex CLI using the official native installer..."
export CODEX_NON_INTERACTIVE=true
export CODEX_INSTALL_DIR="/usr/local/bin"

# The installer stores the actual versioned binaries under
# $CODEX_HOME/packages/standalone and only symlinks them into
# CODEX_INSTALL_DIR. It defaults CODEX_HOME to $HOME/.codex, which during a
# root-run feature install resolves to /root/.codex - a directory non-root
# container users can't traverse, leaving the symlink dangling for them.
# Use a world-readable location instead.
export CODEX_HOME="/usr/local/share/codex"

# The installer resolves "latest" via the GitHub API, which is rate-limited
# for unauthenticated requests and can intermittently return 403 during
# image builds. Pin a known-good release to avoid that lookup, but allow it
# to be overridden via CODEX_RELEASE.
export CODEX_RELEASE="${CODEX_RELEASE:-0.141.0}"

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
