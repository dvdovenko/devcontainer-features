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

check_packages bat

mkdir -p ~/.zsh

cat << EOF > ~/.zsh/aliases.zsh
#! /bin/zsh
# Alias
# ---
#
alias cat="bat"
alias grep='grep --color'

alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"
alias guid="uuid"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias gensalt32="xxd -g 2 -l 32 -p /dev/random | tr -d '\n'"
alias gensalt16="xxd -g 2 -l 16 -p /dev/random | tr -d '\n'"
alias gensalt8="xxd -g 2 -l 8 -p /dev/random | tr -d '\n'
EOF