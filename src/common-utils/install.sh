#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt-get update -y
        apt-get -y install --no-install-recommends "$@"
    fi
}

check_packages apt-transport-https \
    bat \
    build-essential \
    ca-certificates \
    curl \
    file \
    fontconfig \
    git \
    gnupg \
    jq \
    libvips-dev \
    locales \
    openssl \
    ripgrep \
    ruby-full \
    tmux \
    unzip \
    vim \
    wget \
    xz-utils

INSTALL_NEOVIM_EFFECTIVE=${INSTALLNEOVIM:-${INSTALL_NEOVIM:-true}}
INSTALL_WATCHMAN_EFFECTIVE=${INSTALLWATCHMAN:-${INSTALL_WATCHMAN:-true}}
INSTALL_OPENCODE_EFFECTIVE=${INSTALLOPENCODE:-${INSTALL_OPENCODE:-false}}
INSTALL_CODEX_EFFECTIVE=${INSTALLCODEX:-${INSTALL_CODEX:-false}}

bash ./git-delta.sh

if [ "${INSTALL_NEOVIM_EFFECTIVE}" = "true" ]; then
    bash ./neovim.sh
else
    echo "Skipping Neovim installation."
fi

if [ "${INSTALL_WATCHMAN_EFFECTIVE}" = "true" ]; then
    bash ./watchman.sh
else
    echo "Skipping Watchman installation."
fi

if [ "${INSTALL_OPENCODE_EFFECTIVE}" = "true" ]; then
    bash ./opencode.sh
else
    echo "Skipping OpenCode installation."
fi

if [ "${INSTALL_CODEX_EFFECTIVE}" = "true" ]; then
    bash ./codex.sh
else
    echo "Skipping Codex installation."
fi
