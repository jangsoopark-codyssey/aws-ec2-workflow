#!/usr/bin/env bash
set -Eeuo pipefail

# Install Docker Engine and the Compose plugin on Ubuntu, then add the
# invoking non-root user to the docker group.

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this script as the Ubuntu login user, without sudo." >&2
  echo "Example: bash install_docker_ubuntu.sh" >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required. Log in with an account that has sudo privileges." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify the operating system." >&2
  exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "This script is for Ubuntu. Detected: ${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

if ! sudo -n true; then
  echo "Could not obtain sudo privileges." >&2
  exit 1
fi

LOGIN_USER="$(id -un)"
ARCH="$(dpkg --print-architecture)"
UBUNTU_CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
if [[ -z "$UBUNTU_CODENAME" ]]; then
  echo "Could not determine the Ubuntu release codename." >&2
  exit 1
fi

echo "Installing Docker Engine for Ubuntu ${UBUNTU_CODENAME} (${ARCH})..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<REPO
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
REPO

sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable --now docker

# The package normally creates this group. Ensure it exists, then add the
# account that ran this script. Re-running the script is safe.
sudo groupadd --force docker
sudo usermod -aG docker "$LOGIN_USER"

# Verify the daemon and installation. Use sudo here because the current SSH
# session does not receive new group membership until it is refreshed.
sudo systemctl is-active --quiet docker || {
  echo "Docker service is not active." >&2
  sudo systemctl status docker --no-pager || true
  exit 1
}
sudo docker run --rm hello-world

echo
echo "Docker Engine: $(sudo docker --version)"
echo "Docker Compose: $(sudo docker compose version)"
echo "Docker service: active"
echo "Added ${LOGIN_USER} to the docker group."
echo "Reconnect your SSH session, then verify with: docker run --rm hello-world"
echo "Note: membership in the docker group grants root-level privileges."
