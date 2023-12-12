#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

CTRL_USERNAME="controle"
CTRL_GROUP="$CTRL_USERNAME"
CTRL_HOME="/home/${CTRL_USERNAME}"
CTRL_DESKTOP="${CTRL_HOME}/Bureau"
CTRL_RESULTS_DIR="${CTRL_DESKTOP}/Resultats"
SCRIPTS_ROOT="${CTRL_HOME}/script_data"

COOKIES_LIST_NAME="cnil_cookies_list-2.1.0-fx.xpi"
COOKIES_LIST_URL="https://github.com/LINCnil/CNIL-Cookies-List/raw/master/release/$COOKIES_LIST_NAME"

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
# -------
# Firefox
# -------
#

# Installation de CNIL Cookies List
wget "$COOKIES_LIST_URL" -O "${CTRL_HOME}/${COOKIES_LIST_NAME}"
firefox "${CTRL_HOME}/${COOKIES_LIST_NAME}"

# Récupération du chemin vers le profil FireFox
CTRL_MOZ_HOME="${CTRL_HOME}/.mozilla/firefox"
PROFILE_NAME=$(cat "$CTRL_MOZ_HOME/profiles.ini" | grep Path= | grep release | sed "s/Path=//")
CTRL_MOZ_PROFILE="${CTRL_MOZ_HOME}/${PROFILE_NAME}"

# Modification des moteurs de recherche
copy_file "${SCRIPTS_ROOT}/cnf/search.json.mozlz4" "${CTRL_MOZ_PROFILE}/search.json.mozlz4"

# Configuration des paramètres
# Le fichier user.js n'existe pas de base mais est géré par firefox.
# Il n'est jamais modifié et s'appliquera a chaque ouverture
# https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences#Changing_defaults
copy_file "${SCRIPTS_ROOT}/cnf/user.js" "${CTRL_MOZ_PROFILE}/user.js"


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
sudo chkrootkit >"${CTRL_RESULTS_DIR}/ChkRootkit.txt"

# ClamAV
# https://wiki.archlinux.org/title/ClamAV
sudo freshclam
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
read
