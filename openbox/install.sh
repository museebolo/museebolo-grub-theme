
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPENBOX_CONFIG_DIR="/home/${USER_NAME}/.config/openbox"

echo "Configuration d'Openbox..."

install -d \
    -o "${USER_NAME}" \
    -g "${USER_NAME}" \
    -m 0755 \
    "${OPENBOX_CONFIG_DIR}"

install \
    -o "${USER_NAME}" \
    -g "${USER_NAME}" \
    -m 0644 \
    "${SCRIPT_DIR}/openbox/rc.xml" \
    "${OPENBOX_CONFIG_DIR}/rc.xml"
