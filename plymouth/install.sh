#!/bin/bash

set -euo pipefail

THEME_NAME="museebolo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="/usr/share/plymouth/themes/${THEME_NAME}"

if [[ $EUID -ne 0 ]]; then
    echo "Erreur : ce script doit être exécuté avec sudo."
    echo "Usage : sudo ./install.sh"
    exit 1
fi

if ! command -v plymouth-set-default-theme >/dev/null 2>&1; then
    echo "Erreur : Plymouth n'est pas installé."
    exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/${THEME_NAME}.plymouth" ]]; then
    echo "Erreur : ${THEME_NAME}.plymouth introuvable."
    exit 1
fi

echo "[1/3] Installation du thème..."

rm -rf "${THEME_DIR}"
mkdir -p "${THEME_DIR}"

cp "${SCRIPT_DIR}/${THEME_NAME}.plymouth" "${THEME_DIR}/"
cp "${SCRIPT_DIR}/${THEME_NAME}.script"   "${THEME_DIR}/"
cp "${SCRIPT_DIR}/splash.png"             "${THEME_DIR}/"

echo "[2/3] Sélection du thème..."

plymouth-set-default-theme "${THEME_NAME}"

echo "[3/3] Reconstruction de l'initramfs..."

update-initramfs -u

echo
echo "Installation terminée."
echo "Thème Plymouth : ${THEME_NAME}"
