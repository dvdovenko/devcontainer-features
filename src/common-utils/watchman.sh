#!/bin/sh
set -e

echo "Activating feature 'watchman'"

# Check if curl is installed, install if not
if ! command -v curl >/dev/null 2>&1; then
    echo "curl is not installed. Installing curl..."
    apt-get update -y
    apt-get install -y curl
fi

# Check if unzip is installed, install if not
if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is not installed. Installing unzip..."
    apt-get update -y
    apt-get install -y unzip
fi

echo "Fetching latest Watchman release information..."

# Get the latest release data
RELEASE_DATA=$(curl -sL https://api.github.com/repos/facebook/watchman/releases/tags/v2025.12.22.00)

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