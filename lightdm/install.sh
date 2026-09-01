#!/bin/bash

set -euo pipefail

USER_NAME="museebolo"
AUTOLOGIN_TIMEOUT=5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKGROUND_SRC="${SCRIPT_DIR}/background.png"
BACKGROUND_DIR="/usr/share/backgrounds/museebolo"
BACKGROUND_DST="${BACKGROUND_DIR}/background.png"

GREETER_CONFIG_SRC="${SCRIPT_DIR}/lightdm-gtk-greeter.conf"
GREETER_CONFIG_DST="/etc/lightdm/lightdm-gtk-greeter.conf"

AUTOLOGIN_CONFIG="/etc/lightdm/lightdm.conf.d/50-museebolo-autologin.conf"

if [[ $EUID -ne 0 ]]; then
    echo "Erreur : ce script doit être exécuté avec sudo."
    echo "Usage : sudo ./install.sh"
    exit 1
fi

if ! command -v lightdm >/dev/null 2>&1; then
	echo "Erreur : LightDM n'est pas installé."
	exit 1
fi

if ! dpkg-query -W -f='${Status}' lightdm-gtk-greeter 2>/dev/null \
	| grep -q "install ok installed"; then
	echo "Erreur : lightdm-gtk-greeter n'est pas installé."
	exit 1
fi

if [[ ! -f "${BACKGROUND_SRC}" ]]; then
    echo "Erreur : background.png introuvable."
    exit 1
fi

if [[ ! -f "${GREETER_CONFIG_SRC}" ]]; then
    echo "Erreur : lightdm-gtk-greeter.conf introuvable."
    exit 1
fi

echo "[1/5] Vérification de l'utilisateur museebolo..."

if id "${USER_NAME}" >/dev/null 2>&1; then
    echo "L'utilisateur '${USER_NAME}' existe déjà."
else
    echo "Création de l'utilisateur '${USER_NAME}'..."

    useradd \
        --create-home \
        --shell /bin/bash \
        --comment "Musée Bolo" \
        "${USER_NAME}"

    # Pas de mot de passe pour ce compte de borne.
    passwd --delete "${USER_NAME}"

    echo "Utilisateur '${USER_NAME}' créé."
fi

echo
echo "[2/5] Installation du fond LightDM..."

mkdir -p "${BACKGROUND_DIR}"
chmod 0755 "${BACKGROUND_DIR}"

install -m 0644 "${BACKGROUND_SRC}" "${BACKGROUND_DST}"

echo
echo "[3/5] Installation de la configuration du greeter..."

if [[ -f "${GREETER_CONFIG_DST}" && ! -f "${GREETER_CONFIG_DST}.museebolo.bak" ]]; then
    cp -a "${GREETER_CONFIG_DST}" "${GREETER_CONFIG_DST}.museebolo.bak"
fi

install -m 0644 "${GREETER_CONFIG_SRC}" "${GREETER_CONFIG_DST}"

echo
echo "[4/5] Configuration de l'autologin..."

mkdir -p /etc/lightdm/lightdm.conf.d

cat > "${AUTOLOGIN_CONFIG}" <<EOF
[Seat:*]
autologin-user=${USER_NAME}
autologin-user-timeout=${AUTOLOGIN_TIMEOUT}
EOF

chmod 0644 "${AUTOLOGIN_CONFIG}"

echo
echo "[5/5] Vérification..."

echo
echo "Utilisateur :"
id "${USER_NAME}"

echo
echo "Configuration du greeter :"
grep -E '^(background|theme-name|icon-theme-name|font-name)=' \
    "${GREETER_CONFIG_DST}" || true

echo
echo "Configuration autologin :"
cat "${AUTOLOGIN_CONFIG}"

echo
echo "Installation terminée."
echo
echo "L'utilisateur '${USER_NAME}' sera connecté automatiquement"
echo "après un délai de ${AUTOLOGIN_TIMEOUT} secondes."
