#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "git" git --version
check "delta" delta --version
check "bat" bat --version
check "jq" jq --version
check "ripgrep" rg --version
check "tmux" tmux -V
check "vim" vim --version
check "wget" wget --version
check "unzip" unzip -v
check "gnupg" gpg --version
check "ruby" ruby --version

# Installed by default (installNeovim/installWatchman default to true)
check "neovim" nvim --version

# Watchman has no Alpine/musl build upstream, so the feature skips it there.
if ! grep -qi '^ID=alpine' /etc/os-release 2>/dev/null; then
    check "watchman" watchman --version
fi
