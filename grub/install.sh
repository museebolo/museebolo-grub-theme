#!/bin/bash

set -euo pipefail

THEME_NAME="museebolo"
THEME_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme"
THEME_DST="/boot/grub/themes/${THEME_NAME}"
GRUB_DEFAULT="/etc/default/grub"

if [[ $EUID -ne 0 ]]; then
    echo "Erreur : exécutez ce script avec sudo."
    exit 1
fi

echo "[1/3] Installation du thème GRUB..."

mkdir -p "${THEME_DST}"
cp -a "${THEME_SRC}/." "${THEME_DST}/"

echo "[2/3] Configuration de GRUB..."

# Sauvegarde initiale
if [[ ! -e "${GRUB_DEFAULT}.museebolo.bak" ]]; then
    cp -a "${GRUB_DEFAULT}" "${GRUB_DEFAULT}.museebolo.bak"
fi

set_grub_option()
{
    local name="$1"
    local value="$2"

    if grep -q "^${name}=" "${GRUB_DEFAULT}"; then
        sed -i "s|^${name}=.*|${name}=\"${value}\"|" "${GRUB_DEFAULT}"
    else
        printf '%s="%s"\n' "${name}" "${value}" >> "${GRUB_DEFAULT}"
    fi
}

set_grub_option \
    GRUB_THEME \
    "/boot/grub/themes/${THEME_NAME}/theme.txt"

set_grub_option \
    GRUB_GFXMODE \
    "auto"

set_grub_option \
    GRUB_GFXPAYLOAD_LINUX \
    "keep"

# Empêche le fond Debian de prendre la place du thème personnalisé.
set_grub_option \
    GRUB_BACKGROUND \
    ""

set_grub_option \
	GRUB_COLOR_NORMAL \
	"black/white"
	
set_grub_option \
	GRUB_COLOR_HIGHLIGHT \
	"white/black"

echo "[3/3] Génération de grub.cfg..."

update-grub

echo
echo "Thème GRUB '${THEME_NAME}' installé."
