#!/bin/bash

set -euo pipefail

THEME_NAME="museebolo"
THEME_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme"
THEME_DST="/boot/grub/themes/${THEME_NAME}"

GRUB_DEFAULT="/etc/default/grub"
GRUB_CUSTOM="/etc/grub.d/40_custom" 
GRUB_UNRESTRICTED="/etc/grub.d/09_museebolo_unrestricted"

GRUB_USER="museebolo"


if [[ $EUID -ne 0 ]]; then
    echo "Erreur : exécutez ce script avec sudo."
    exit 1
fi

echo "[1/5] Installation du thème GRUB..."

mkdir -p "${THEME_DST}"
cp -a "${THEME_SRC}/." "${THEME_DST}/"

echo
echo "[2/5] Configuration de GRUB..."

#
# Sauvegarde initiale de /etc/default/grub
#
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

echo
echo "[3/5] Configuration du mot de passe GRUB..."

#
# Sauvegrade initiale de 40_custom
#
if [[ ! -e "${GRUB_CUSTOM}.museebolo.bak" ]]; then
	cp -a "${GRUB_CUSTOM}" "${GRUB_CUSTOM}.museebolo.bak"
fi

#
# Ne demande  le mot de passe que si aucune configuration Musée Bolo
# n'est déjà présente.
#
if ! grep -q '^# BEGIN Musée Bolo GRUB authentication$' "${GRUB_CUSTOM}"; then 
	
	echo 
	echo "Création du mot de passe administrateur GRUB." 
	echo "Utilisateur GRUB : ${GRUB_USER}" 
	echo 
	
	GRUB_PASSWORD_HASH="$(
		LC_ALL=C grub-mkpasswd-pbkdf2 \
		| tee /dev/tty \
		| grep -o 'grub\.pbkdf2\.[^[:space:]]*' \
		| tail -n 1
	)"
	
	if [[ -z "${GRUB_PASSWORD_HASH}" ]]; then
		echo "Erreur : impossible de récupérer le hash du mot de passe GRUB."
		exit 1 
	fi 
	
	cat >> "${GRUB_CUSTOM}" <<EOF 
# BEGIN Musée Bolo GRUB authentication
set superusers="${GRUB_USER}"
export superusers
password_pbkdf2 ${GRUB_USER} ${GRUB_PASSWORD_HASH}
# END Musée Bolo GRUB authentication
EOF

else 
	echo "Configuration du mot de passe GRUB déjà présente." 
fi

echo
echo "[4/5] Autorisation du démarrage normal sans mot de passe..."

#
# Sans --unrestricted, la présence de "superusers" impose
# une authentification avant le démarrage d'une entrée.
#
# Nous voulons :
#
#  démarrage normal      : sans mot de passe
#  modification avec 'e' : mot de passe
#  console GRUB avec 'c' : mot de passe
#
# Le script est exécuté avant 10_linux et ajoute --unrestricted
# aux options utilisées pour générer les entrées Debian.
#

cat > "${GRUB_UNRESTRICTED}" <<'EOF'
#!/bin/sh

echo 'menuentry_id_option="--unrestricted $menuentry_id_option"'
EOF

chmod 755 "${GRUB_UNRESTRICTED}"

echo
echo "[5/5] Génération de grub.cfg..."
echo

update-grub

echo
echo "Vérification de la configuration..."
echo

if ! grep -q '^set superusers=' /boot/grub/grub.cfg; then
    echo "ERREUR : configuration superusers absente de grub.cfg."
    exit 1
fi

if ! grep -q '^export superusers' /boot/grub/grub.cfg; then
    echo "ERREUR : export de superusers absent de grub.cfg."
    exit 1
fi

if ! grep -q '^password_pbkdf2 ' /boot/grub/grub.cfg; then
    echo "ERREUR : mot de passe GRUB absent de grub.cfg."
    exit 1
fi

if ! grep -q '^menuentry .*--unrestricted' /boot/grub/grub.cfg; then
    echo "ERREUR : aucune entrée --unrestricted trouvée."
    echo
    echo "Entrées GRUB générées :"
    grep -E '^menuentry |^submenu ' /boot/grub/grub.cfg || true
    echo
    echo "Vérifiez /boot/grub/grub.cfg avant de redémarrer."
    exit 1
fi


echo
echo "Configuration GRUB Musée Bolo installée."
echo
echo "Thème : ${THEME_NAME}"
echo "Utilisateur GRUB : ${GRUB_USER}"
echo
echo "Le démarrage normal reste accessible sans mot de passe."
echo "L'édition des entrées GRUB et la console sont protégées."
