#!/bin/sh
set -e

echo "Activating feature 'watchman'"

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

# Facebook only publishes glibc Linux builds, and the current builds depend
# on glibc symbols newer than what musl's gcompat shim implements, so there
# is no working install path on Alpine. Skip rather than fail the build.
if command -v apk >/dev/null 2>&1; then
    echo "Warning: Watchman has no Alpine/musl build available upstream. Skipping installation."
    exit 0
fi

check_packages curl unzip

echo "Fetching latest Watchman release information..."

RELEASE_TAG="${WATCHMAN_RELEASE_TAG:-v2025.12.22.00}"

# Get the latest release data
RELEASE_DATA=$(curl -sL https://api.github.com/repos/facebook/watchman/releases/tags/${RELEASE_TAG})

# Extract the download URL for the Linux zip file
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep -o '"browser_download_url":[[:space:]]*"[^"]*linux\.zip"' | sed 's/"browser_download_url":[[:space:]]*"\(.*\)"/\1/')

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find Linux zip download URL"
    exit 1
fi

# Extract the filename from the URL
FILENAME=$(basename "$DOWNLOAD_URL")

echo "Downloading $FILENAME..."
mkdir -p /tmp/watchman
cd /tmp/watchman
curl -L -o "$FILENAME" "$DOWNLOAD_URL"
echo "Download complete: $FILENAME"

unzip "$FILENAME"
echo "Unzipped $FILENAME"

echo "Installing Watchman..."
cd watchman-v*.00-linux
mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman
cp bin/* /usr/local/bin
cp lib/* /usr/local/lib
chmod 755 /usr/local/bin/watchman
chmod 2777 /usr/local/var/run/watchman

echo "Cleaning up..."
cd
rm -rf /tmp/watchman

echo "Watchman installation complete."