
#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install git-delta (not available in Debian bullseye repos)
DELTA_VERSION=0.18.2
ARCH=$(dpkg --print-architecture)

curl -Lo /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb"

dpkg -i /tmp/git-delta.deb

rm /tmp/git-delta.deb