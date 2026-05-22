#!/bin/bash

CONFIG_DIR="/config/qBittorrent"
CONFIG_FILE="${CONFIG_DIR}/qBittorrent.conf"

# Create config with [Preferences] section if it doesn't exist yet
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "[custom-init] qBittorrent config not found, creating initial config"
    mkdir -p "${CONFIG_DIR}"
    printf '[Preferences]\n' > "${CONFIG_FILE}"
fi

# Ensure [Preferences] section exists in existing config
if ! grep -q '^\[Preferences\]' "${CONFIG_FILE}"; then
    echo "[custom-init] Adding [Preferences] section to config"
    printf '\n[Preferences]\n' >> "${CONFIG_FILE}"
fi

if [[ -n "${WEBUI_USERNAME}" ]]; then
    if grep -qF 'WebUI\Username=' "${CONFIG_FILE}"; then
        sed -i 's|^WebUI\\Username=.*|WebUI\\Username='"${WEBUI_USERNAME}"'|' "${CONFIG_FILE}"
    else
        sed -i '/^\[Preferences\]/a WebUI\\Username='"${WEBUI_USERNAME}" "${CONFIG_FILE}"
    fi
    echo "[custom-init] WebUI username set to: ${WEBUI_USERNAME}"
fi

if [[ -n "${WEBUI_PASSWORD}" ]]; then
    HASHED=$(python3 -c "import hashlib, base64, os; salt = os.urandom(16); password = os.environ['WEBUI_PASSWORD'].encode(); dk = hashlib.pbkdf2_hmac('sha512', password, salt, 100000, dklen=64); print(f'{base64.b64encode(salt).decode()}:{base64.b64encode(dk).decode()}')")
    if grep -qF 'WebUI\Password_PBKDF2=' "${CONFIG_FILE}"; then
        sed -i 's|^WebUI\\Password_PBKDF2=.*|WebUI\\Password_PBKDF2="@ByteArray('"${HASHED}"')"|' "${CONFIG_FILE}"
    else
        sed -i '/^\[Preferences\]/a WebUI\\Password_PBKDF2="@ByteArray('"${HASHED}"')"' "${CONFIG_FILE}"
    fi
    echo "[custom-init] WebUI password set from environment variable"
else
    echo "[custom-init] WARNING: WEBUI_PASSWORD is not set, qBittorrent will generate a random password"
fi
