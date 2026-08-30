#!/bin/sh
set -eu

THEME_DIR="/boot/grub/themes/museebolo"

if [ "$(id -u)" -ne 0 ]; then
    echo "Exécutez ce script avec sudo."
    exit 1
fi

mkdir -p "$THEME_DIR"
cp "$(dirname "$0")/theme.txt" "$THEME_DIR/"
cp "$(dirname "$0")/logo.png" "$THEME_DIR/"

echo "Thème copié dans $THEME_DIR"
echo
echo "Ajoutez dans /etc/default/grub :"
echo 'GRUB_THEME="/boot/grub/themes/museebolo/theme.txt"'
echo 'GRUB_GFXMODE=auto'
echo 'GRUB_GFXPAYLOAD_LINUX=keep'
echo 'GRUB_TIMEOUT_STYLE=menu'
echo 'GRUB_TIMEOUT=3'
echo
echo "Puis exécutez : sudo update-grub"
