#!/usr/bin/env bash

set -euo pipefail

#
# Musée Bolo - Docker installation
#
# Installs the official Docker Engine packages from Docker's
# APT repository.
#

APP_USER="museebolo"

#
# Check root
#

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: this script must be run as root."
    exit 1
fi

#
# Check Debian
#

if [ ! -f /etc/os-release ]; then
    echo "ERROR: /etc/os-release not found."
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [ "${ID:-}" != "debian" ]; then
    echo "ERROR: this script is intended for Debian."
    exit 1
fi

if [ -z "${VERSION_CODENAME:-}" ]; then
    echo "ERROR: unable to determine Debian codename."
    exit 1
fi

ARCH="$(dpkg --print-architecture)"

echo
echo "============================================================"
echo " Docker installation"
echo "============================================================"
echo
echo "Debian : ${VERSION_CODENAME}"
echo "Arch   : ${ARCH}"
echo

#
# Remove conflicting packages
#

echo "Removing conflicting Docker packages..."

CONFLICTING_PACKAGES=(
    docker.io
    docker-compose
    docker-doc
    docker-buildx
    podman-docker
    containerd
    runc
)

for package in "${CONFLICTING_PACKAGES[@]}"; do
    if dpkg -s "${package}" >/dev/null 2>&1; then
        apt-get remove -y "${package}"
    fi
done

#
# Install prerequisites
#

echo
echo "Installing prerequisites..."

apt-get update

apt-get install -y \
    ca-certificates \
    curl

#
# Install Docker repository key
#

echo
echo "Installing Docker repository key..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL \
    https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

#
# Install Docker APT repository
#

echo
echo "Installing Docker APT repository..."

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

#
# Install Docker
#

echo
echo "Installing Docker Engine..."

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

#
# Enable Docker
#

echo
echo "Enabling Docker..."

systemctl enable --now docker

#
# Add demo user to docker group
#

if id "${APP_USER}" >/dev/null 2>&1; then
    echo
    echo "Adding '${APP_USER}' to docker group..."

    usermod -aG docker "${APP_USER}"
else
    echo
    echo "WARNING: user '${APP_USER}' does not exist."
    echo "         Docker group membership was not configured."
fi

#
# Verify installation
#

echo
echo "Docker version:"
docker --version

echo
echo "Docker Compose version:"
docker compose version

echo
echo "============================================================"
echo " Docker installation completed"
echo "============================================================"
echo
echo "NOTE:"
echo "  User '${APP_USER}' must log out and log in again"
echo "  before Docker can be used without sudo."
echo
