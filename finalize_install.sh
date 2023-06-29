#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Configuration des scripts
export CTRL_USERNAME="controle"
export CTRL_GROUP="$CTRL_USERNAME"
export CTRL_HOME="/home/$CTRL_USERNAME"
export CTRL_DESKTOP="$CTRL_HOME/Bureau"
export SCRIPTS_ROOT="$CTRL_HOME/post_install"
export COOKIES_LIST_NAME="cnil_cookies_list-2.1.0-fx.xpi"
export COOKIES_LIST_URL="https://github.com/LINCnil/CNIL-Cookies-List/raw/master/release/$COOKIES_LIST_NAME"

# Lancement des scripts
sudo --preserve-env="CTRL_USERNAME,CTRL_GROUP,CTRL_DESKTOP" bash "$SCRIPTS_ROOT/scripts/repertoire_partage.sh"
bash "$SCRIPTS_ROOT/scripts/firefox.sh"
bash "$SCRIPTS_ROOT/scripts/raccourcis.sh"
sudo --preserve-env="CTRL_DESKTOP" bash "$SCRIPTS_ROOT/scripts/misc.sh"

# Nettoyage
sudo rm -rf "$SCRIPTS_ROOT" "/root/.bash_history" "$CTRL_HOME/.bash_history" "$CTRL_HOME/.config/autostart"
echo "Installation terminée. Appuyez sur <Entrée> pour fermer."
read
