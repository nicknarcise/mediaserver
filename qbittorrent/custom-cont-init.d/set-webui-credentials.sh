#!/bin/bash

CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "[custom-init] qBittorrent config not found, skipping credential setup"
    exit 0
fi

if [[ -n "${WEBUI_USERNAME}" ]]; then
    if grep -q "^WebUI\\\\Username=" "${CONFIG_FILE}"; then
        sed -i "s|^WebUI\\\\Username=.*|WebUI\\\\Username=${WEBUI_USERNAME}|" "${CONFIG_FILE}"
    else
        sed -i "/^\[Preferences\]/a WebUI\\\\Username=${WEBUI_USERNAME}" "${CONFIG_FILE}"
    fi
    echo "[custom-init] WebUI username set to: ${WEBUI_USERNAME}"
fi

if [[ -n "${WEBUI_PASSWORD}" ]]; then
    HASHED=$(python3 << 'PYEOF'
import hashlib, base64, os
salt = os.urandom(16)
password = os.environ['WEBUI_PASSWORD'].encode()
dk = hashlib.pbkdf2_hmac('sha512', password, salt, 100000, dklen=64)
print(f'{base64.b64encode(salt).decode()}:{base64.b64encode(dk).decode()}')
PYEOF
)

    if grep -q "^WebUI\\\\Password_PBKDF2=" "${CONFIG_FILE}"; then
        sed -i "s|^WebUI\\\\Password_PBKDF2=.*|WebUI\\\\Password_PBKDF2=\"@ByteArray(${HASHED})\"|" "${CONFIG_FILE}"
    else
        sed -i "/^\[Preferences\]/a WebUI\\\\Password_PBKDF2=\"@ByteArray(${HASHED})\"" "${CONFIG_FILE}"
    fi
    echo "[custom-init] WebUI password set from environment variable"
fi
