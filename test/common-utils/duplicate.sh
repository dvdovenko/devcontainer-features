#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# The values of the randomized options will be set as environment variables,
# alongside the default-Feature install's values with a __DEFAULT suffix.
for var in INSTALLNEOVIM INSTALLWATCHMAN INSTALLCODEX INSTALLCLAUDE \
           INSTALLNEOVIM__DEFAULT INSTALLWATCHMAN__DEFAULT INSTALLCODEX__DEFAULT INSTALLCLAUDE__DEFAULT; do
	eval "value=\${${var}}"
	if [ -z "${value}" ]; then
		echo "Expected option variable ${var} to be set!"
		exit 1
	fi
done

# Tools always installed regardless of options.
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

# install.sh never uninstalls a tool once it's there, so when the Feature is
# installed twice with different option values, a tool ends up present if
# *either* install requested it.
should_be_present() {
	[ "$1" = "true" ] || [ "$2" = "true" ]
}

if should_be_present "${INSTALLNEOVIM}" "${INSTALLNEOVIM__DEFAULT}"; then
	check "neovim" nvim --version
fi

# Watchman has no Alpine/musl build upstream, so the Feature skips it there
# regardless of the installWatchman option.
if ! grep -qi '^ID=alpine' /etc/os-release 2>/dev/null; then
	if should_be_present "${INSTALLWATCHMAN}" "${INSTALLWATCHMAN__DEFAULT}"; then
		check "watchman" watchman --version
	fi
fi

if should_be_present "${INSTALLCODEX}" "${INSTALLCODEX__DEFAULT}"; then
	check "codex" codex --version
fi

if should_be_present "${INSTALLCLAUDE}" "${INSTALLCLAUDE__DEFAULT}"; then
	check "claude" claude --version
fi

# Report result
reportResults