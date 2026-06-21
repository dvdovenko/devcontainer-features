#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install git-delta (not available in Debian bullseye repos)
DELTA_VERSION=0.18.2

case "$(uname -m)" in
    x86_64) RUST_ARCH="x86_64" ;;
    aarch64|arm64) RUST_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

if command -v apk >/dev/null 2>&1; then
    # Upstream only ships glibc builds for Alpine's architectures, so run the
    # gnu build through gcompat (musl's glibc-compatibility shim) instead.
    apk add --no-cache gcompat libgcc libstdc++ curl

    curl -Lo /tmp/git-delta.tar.gz "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${RUST_ARCH}-unknown-linux-gnu.tar.gz"

    mkdir -p /tmp/git-delta
    tar -xzf /tmp/git-delta.tar.gz -C /tmp/git-delta --strip-components=1
    install -m 755 /tmp/git-delta/delta /usr/local/bin/delta
    rm -rf /tmp/git-delta /tmp/git-delta.tar.gz
else
    DEB_ARCH=$(dpkg --print-architecture)

    curl -Lo /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${DEB_ARCH}.deb"

    dpkg -i /tmp/git-delta.deb

    rm /tmp/git-delta.deb
fi
