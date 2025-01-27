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

check_packages vim neovim

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.backup
fi
rm -rf ~/.local/share/nvim

git clone --depth=1 https://github.com/NvChad/NvChad ~/.config/nvim

mkdir -p ~/.zsh
cat << EOF >> ~/.zsh/aliases.zsh
alias vim="nvim"
EOF