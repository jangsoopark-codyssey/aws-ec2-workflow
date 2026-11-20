#!/usr/bin/env bash
set -Eeuo pipefail

# Issue and apply a short-lived Let's Encrypt IP certificate to the Draft
# Nginx container. Supported layouts:
#   1) <project-root>/{Draft,docker} with this script in scripts/
#   2) ~/Draft and ~/docker, with this script anywhere under ~/scripts

readonly IMAGE_NAME="draft-web:1.0"
readonly CONTAINER_NAME="draft-web"
readonly BACKUP_NAME="draft-web-http-backup"
readonly MIN_CERTBOT_VERSION="5.4.0"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${PROJECT_ROOT}/docker/Dockerfile" && -f "${PROJECT_ROOT}/Draft/index.html" ]]; then
  BUILD_CONTEXT="${PROJECT_ROOT}"
elif [[ -f "${HOME}/docker/Dockerfile" && -f "${HOME}/Draft/index.html" ]]; then
  BUILD_CONTEXT="${HOME}"
else
  echo "Could not find docker/Dockerfile and Draft/index.html." >&2
  echo "Expected them in the project root or in ~/docker and ~/Draft." >&2
  exit 1
fi

readonly DOCKER_DIR="${BUILD_CONTEXT}/docker"
readonly DOCKERFILE="${DOCKER_DIR}/Dockerfile"
readonly NGINX_CONF="${DOCKER_DIR}/nginx.conf"
readonly DOCKER_BIN="$(command -v docker || true)"

if [[ -z "${DOCKER_BIN}" ]]; then
  echo "Docker CLI was not found. Install Docker before running this script." >&2
  exit 1
fi
if ! sudo -n true; then
  echo "This script needs passwordless sudo for Certbot and systemd." >&2
  exit 1
fi
if [[ ! -f "${DOCKERFILE}" || ! -f "${BUILD_CONTEXT}/Draft/index.html" ]]; then
  echo "Missing Dockerfile or Draft/index.html in ${BUILD_CONTEXT}." >&2
  exit 1
fi

install_certbot() {
  if ! command -v snap >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket
  fi

  if ! sudo snap list certbot >/dev/null 2>&1; then
    sudo snap install --classic certbot
  else
    sudo snap refresh certbot
  fi
  sudo ln -sf /snap/bin/certbot /usr/local/bin/certbot
}

install_certbot
readonly CERTBOT_BIN="/snap/bin/certbot"
CERTBOT_VERSION="$("${CERTBOT_BIN}" --version | awk '{print $2}')"
if [[ "$(printf '%s\n%s\n' "${MIN_CERTBOT_VERSION}" "${CERTBOT_VERSION}" | sort -V | head -n1)" != "${MIN_CERTBOT_VERSION}" ]]; then
  echo "Certbot ${MIN_CERTBOT_VERSION} or newer is required; found ${CERTBOT_VERSION}." >&2
  exit 1
fi

EC2_PUBLIC_IP="$(curl -4fsS https://checkip.amazonaws.com | tr -d '[:space:]')"
if [[ ! "${EC2_PUBLIC_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Could not determine the EC2 public IPv4 address: ${EC2_PUBLIC_IP}" >&2
  exit 1
fi

readonly CERT_DIR="/etc/letsencrypt/live/${EC2_PUBLIC_IP}"
readonly CERT_FILE="${CERT_DIR}/fullchain.pem"
readonly KEY_FILE="${CERT_DIR}/privkey.pem"

cat <<INFO
Using EC2 public IP: ${EC2_PUBLIC_IP}
Build context: ${BUILD_CONTEXT}
Dockerfile: ${DOCKERFILE}

Before continuing, ensure the EC2 security group allows inbound TCP 80 and
TCP 443 from the intended clients. Keep the instance running; its public IP
can change after a stop/start unless a static IP is assigned.
INFO

CERTBOT_EMAIL="${CERTBOT_EMAIL:-}"
if [[ ! -s "${CERT_FILE}" || ! -s "${KEY_FILE}" ]]; then
  if [[ -z "${CERTBOT_EMAIL}" ]]; then
    read -r -p "Email for Let's Encrypt renewal notices: " CERTBOT_EMAIL
  fi
  if [[ -z "${CERTBOT_EMAIL}" ]]; then
    echo "A contact email is required for the initial certificate request." >&2
    exit 1
  fi

  CONTAINER_WAS_RUNNING="false"
  if sudo docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
    if [[ "$(sudo docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}")" == "true" ]]; then
      CONTAINER_WAS_RUNNING="true"
      sudo docker stop "${CONTAINER_NAME}" >/dev/null
    fi
  fi

  restore_http_container() {
    if [[ "${CONTAINER_WAS_RUNNING}" == "true" ]]; then
      sudo docker start "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    fi
  }
  trap restore_http_container ERR

  sudo "${CERTBOT_BIN}" certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --no-eff-email \
    --email "${CERTBOT_EMAIL}" \
    --preferred-profile shortlived \
    --ip-address "${EC2_PUBLIC_IP}"

  restore_http_container
  trap - ERR
else
  echo "A certificate for ${EC2_PUBLIC_IP} already exists; reusing it."
fi

cat > "${NGINX_CONF}" <<NGINX
server {
    listen 80;
    server_name _;

    location = /health {
        access_log off;
        default_type text/plain;
        return 200 "healthy\\n";
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name _;

    ssl_certificate ${CERT_FILE};
    ssl_certificate_key ${KEY_FILE};
    ssl_protocols TLSv1.2 TLSv1.3;

    root /usr/share/nginx/html;
    index index.html;

    location = /health {
        access_log off;
        default_type text/plain;
        return 200 "healthy\\n";
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

sudo docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}" "${BUILD_CONTEXT}"
sudo docker run --rm \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  --entrypoint nginx \
  "${IMAGE_NAME}" -t

OLD_CONTAINER_EXISTS="false"
OLD_CONTAINER_WAS_RUNNING="false"
BACKUP_CREATED="false"
NEW_CONTAINER_STARTED="false"

rollback_on_error() {
  local exit_code=$?
  if [[ "${exit_code}" -ne 0 ]]; then
    if [[ "${NEW_CONTAINER_STARTED}" == "true" ]]; then
      sudo docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    fi
    if [[ "${BACKUP_CREATED}" == "true" ]] && sudo docker inspect "${BACKUP_NAME}" >/dev/null 2>&1; then
      sudo docker rename "${BACKUP_NAME}" "${CONTAINER_NAME}" >/dev/null 2>&1 || true
      if [[ "${OLD_CONTAINER_WAS_RUNNING}" == "true" ]]; then
        sudo docker start "${CONTAINER_NAME}" >/dev/null 2>&1 || true
      fi
    elif [[ "${OLD_CONTAINER_WAS_RUNNING}" == "true" ]] && sudo docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
      sudo docker start "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    fi
  fi
}
trap rollback_on_error EXIT

if sudo docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
  OLD_CONTAINER_EXISTS="true"
  if [[ "$(sudo docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}")" == "true" ]]; then
    OLD_CONTAINER_WAS_RUNNING="true"
    sudo docker stop "${CONTAINER_NAME}" >/dev/null
  fi
  if sudo docker inspect "${BACKUP_NAME}" >/dev/null 2>&1; then
    sudo docker rm -f "${BACKUP_NAME}" >/dev/null
  fi
  sudo docker rename "${CONTAINER_NAME}" "${BACKUP_NAME}"
  BACKUP_CREATED="true"
fi

sudo docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  "${IMAGE_NAME}"
NEW_CONTAINER_STARTED="true"

HOOK_DIR="/etc/letsencrypt/renewal-hooks"
sudo install -d -m 0755 "${HOOK_DIR}/pre" "${HOOK_DIR}/post"
sudo tee "${HOOK_DIR}/pre/10-stop-draft-web" >/dev/null <<HOOK
#!/bin/sh
${DOCKER_BIN} stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
HOOK
sudo tee "${HOOK_DIR}/post/90-start-draft-web" >/dev/null <<HOOK
#!/bin/sh
${DOCKER_BIN} start ${CONTAINER_NAME} >/dev/null 2>&1 || true
HOOK
sudo chmod 0755 "${HOOK_DIR}/pre/10-stop-draft-web" "${HOOK_DIR}/post/90-start-draft-web"

# Use one renewal timer. The pre/post hooks free port 80 for standalone
# validation and restart Nginx so it loads any renewed certificate.
sudo systemctl disable --now snap.certbot.renew.timer >/dev/null 2>&1 || true
sudo tee /etc/systemd/system/draft-certbot-renew.service >/dev/null <<'UNIT'
[Unit]
Description=Renew the Draft IP TLS certificate

[Service]
Type=oneshot
ExecStart=/snap/bin/certbot renew --quiet
UNIT
sudo tee /etc/systemd/system/draft-certbot-renew.timer >/dev/null <<'UNIT'
[Unit]
Description=Check the Draft IP TLS certificate for renewal twice daily

[Timer]
OnBootSec=10min
OnUnitActiveSec=12h
Persistent=true

[Install]
WantedBy=timers.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable --now draft-certbot-renew.timer
sudo "${CERTBOT_BIN}" renew --dry-run --cert-name "${EC2_PUBLIC_IP}"

if [[ "${BACKUP_CREATED}" == "true" ]]; then
  sudo docker rm -f "${BACKUP_NAME}" >/dev/null
  BACKUP_CREATED="false"
fi

NEW_CONTAINER_STARTED="false"
trap - EXIT

echo
echo "HTTPS container is running."
echo "Certificate: ${CERT_FILE}"
echo "Renewal timer: draft-certbot-renew.timer"
echo "Check: https://${EC2_PUBLIC_IP}/Draft/#/notes"
echo "HTTP health check remains available at http://${EC2_PUBLIC_IP}/health"
echo "The IP certificate is short-lived; keep this renewal timer enabled."
