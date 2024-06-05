#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

CTRL_USERNAME="controle"
CTRL_GROUP="$CTRL_USERNAME"
CTRL_HOME="/home/${CTRL_USERNAME}"
CTRL_DESKTOP="${CTRL_HOME}/Bureau"
CTRL_RESULTS_DIR="${CTRL_DESKTOP}/Resultats"
SCRIPTS_ROOT="${CTRL_HOME}/script_data"

COOKIES_LIST_TAG_NAME=$(curl --silent "https://api.github.com/repos/LINCnil/CNIL-Cookies-List/releases/latest" | jq '.tag_name' | tr --delete '"')
COOKIES_LIST_VERSION=$(echo "COOKIES_LIST_TAG_NAME" | tr --delete 'v')
COOKIES_LIST_CHROME_ID="fejljjffnkkeabbgokmalgbamkdobekb"
COOKIES_LIST_DIR="${CTRL_HOME}/CNIL-Cookies-List"
COOKIES_LIST_BASE_URL="https://github.com/LINCnil/CNIL-Cookies-List/releases/download/${COOKIES_LIST_TAG_NAME}/"
COOKIES_LIST_NAME_CHECKSUM="SHA256SUMS"
COOKIES_LIST_NAME_CHROME="cnil-cookies-list_${COOKIES_LIST_VERSION}.chrome.signed.crx"
COOKIES_LIST_NAME_FIREFOX="cnil-cookies-list_${COOKIES_LIST_VERSION}.firefox.signed.xpi"

CHROMIUM_EXT_DIR="/usr/share/chromium/extensions/"

copy_file() {
	sudo install --verbose --group="$CTRL_GROUP" --owner="$CTRL_USERNAME" "$1" "$2"
}


#
# ------------------
# Agencement clavier
# ------------------
#

sudo localectl set-x11-keymap fr
sudo localectl set-keymap fr


#
# -----------------
# CNIL-Cookies-List
# -----------------
#

mkdir -p "$COOKIES_LIST_DIR"
cd "$COOKIES_LIST_DIR"
wget "${COOKIES_LIST_BASE_URL}${COOKIES_LIST_NAME_CHECKSUM}"
wget "${COOKIES_LIST_BASE_URL}${COOKIES_LIST_NAME_CHROME}"
wget "${COOKIES_LIST_BASE_URL}${COOKIES_LIST_NAME_FIREFOX}"
sha256sum --check "$COOKIES_LIST_NAME_CHECKSUM"
cd "$HOME"


#
# --------
# Chromium
# --------
#

cat >"${COOKIES_LIST_DIR}/${COOKIES_LIST_CHROME_ID}.json" << EOF
{
	"external_crx": "${COOKIES_LIST_DIR}/${COOKIES_LIST_NAME_CHROME}",
	"external_version": "${COOKIES_LIST_VERSION}"
}
EOF
sudo cp "${COOKIES_LIST_DIR}/${COOKIES_LIST_CHROME_ID}.json" "${CHROMIUM_EXT_DIR}/${COOKIES_LIST_CHROME_ID}.json"


#
# -------
# Firefox
# -------
#

# Installation de CNIL Cookies List
firefox "${COOKIES_LIST_DIR}/${COOKIES_LIST_NAME_FIREFOX}"

# Récupération du chemin vers le profil FireFox
CTRL_MOZ_HOME="${CTRL_HOME}/.mozilla/firefox"
PROFILE_NAME=$(grep Path= "$CTRL_MOZ_HOME/profiles.ini" | grep release | sed "s/Path=//")
CTRL_MOZ_PROFILE="${CTRL_MOZ_HOME}/${PROFILE_NAME}"

# Modification des moteurs de recherche
copy_file "${SCRIPTS_ROOT}/cnf/search.json.mozlz4" "${CTRL_MOZ_PROFILE}/search.json.mozlz4"

# Configuration des paramètres
# Le fichier user.js n'existe pas de base mais est géré par firefox.
# Il n'est jamais modifié et s'appliquera a chaque ouverture
# https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences#Changing_defaults
copy_file "${SCRIPTS_ROOT}/cnf/user.js" "${CTRL_MOZ_PROFILE}/user.js"

# Définition de Firefox comme navigateur par défaut
xdg-settings set default-web-browser "firefox.desktop"


#
# ------
# Plasma
# ------
#

kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockOnResume false
kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false


#
# -------------
# Anti-malwares
# -------------
#

mkdir -p "$CTRL_RESULTS_DIR"

# Rkhunter
# https://wiki.archlinux.org/title/Rkhunter
# TODO : remettre rkhunter (y compris dans le `pacstrap`) une fois le bug corrigé, si un jour il est corrigé (dernière version datant de 2018).
# https://bugs.archlinux.org/task/75898?tasks=&type=&sev=&due=&amp%3Bstatus=all&order2=&sort2=desc&date=0
# https://sourceforge.net/p/rkhunter/bugs/176/
#rkhunter --propupd
#rkhunter --update
#rkhunter --check --sk >"${CTRL_RESULTS_DIR}/Rkhunter.txt"

# ChkRootkit
# https://fr.wikipedia.org/wiki/Chkrootkit
# shellcheck disable=SC2024
sudo chkrootkit >"${CTRL_RESULTS_DIR}/ChkRootkit.txt"

# ClamAV
# https://wiki.archlinux.org/title/ClamAV
sudo freshclam
# shellcheck disable=SC2024
sudo clamscan >"${CTRL_RESULTS_DIR}/ClamScan.txt"

# Correction des droits sur le dossier de résultats et son contenu
sudo chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "$CTRL_RESULTS_DIR"


#
# ---------
# Nettoyage
# ---------
#

sudo rm -rf "/root/.bash_history" "$CTRL_HOME/.bash_history" "$CTRL_HOME/.config/autostart" "$SCRIPTS_ROOT"
echo "Installation terminée. Appuyez sur <Entrée> pour fermer."
read -r
