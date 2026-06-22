#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# The sub-install scripts are invoked below via an explicit `bash` call, so
# bash must be installed first - notably Alpine doesn't ship it by default.
if command -v apk >/dev/null 2>&1; then
    apk add --no-cache \
        bash \
        bat \
        build-base \
        ca-certificates \
        curl \
        file \
        fontconfig \
        git \
        gnupg \
        jq \
        musl-locales \
        openssl \
        ripgrep \
        ruby-full \
        tmux \
        unzip \
        vim \
        vips-dev \
        wget \
        xz
else
    # Checks if packages are installed and installs them if not
    check_packages() {
        if ! dpkg -s "$@" > /dev/null 2>&1; then
            apt-get update -y
            apt-get -y install --no-install-recommends "$@"
        fi
    }

    check_packages apt-transport-https \
        bash \
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

    # Debian/Ubuntu's "bat" package installs the binary as "batcat" due to a
    # name collision with an unrelated package, so "bat" isn't on PATH.
    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        ln -s "$(command -v batcat)" /usr/local/bin/bat
    fi
fi

INSTALL_NEOVIM_EFFECTIVE=${INSTALLNEOVIM:-${INSTALL_NEOVIM:-true}}
INSTALL_WATCHMAN_EFFECTIVE=${INSTALLWATCHMAN:-${INSTALL_WATCHMAN:-true}}
INSTALL_CODEX_EFFECTIVE=${INSTALLCODEX:-${INSTALL_CODEX:-false}}
INSTALL_CLAUDE_EFFECTIVE=${INSTALLCLAUDE:-${INSTALL_CLAUDE:-false}}

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

if [ "${INSTALL_CODEX_EFFECTIVE}" = "true" ]; then
    bash ./codex.sh
else
    echo "Skipping Codex installation."
fi

if [ "${INSTALL_CLAUDE_EFFECTIVE}" = "true" ]; then
    bash ./claude.sh
else
    echo "Skipping Claude installation."
fi
