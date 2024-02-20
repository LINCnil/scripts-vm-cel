#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

APPS_ROOT="/usr/share/applications"

CTRL_USERNAME="controle"
CTRL_GROUP="$CTRL_USERNAME"
CTRL_HOME="/home/${CTRL_USERNAME}"
CTRL_DESKTOP="${CTRL_HOME}/Bureau"
CTRL_AUR_BUILD_DIR="$CTRL_HOME"
CTRL_SCRIPT_DATA="/root/script_data"
CTRL_LOCAL_DATA="${CTRL_HOME}/.local"
CTRL_BIN_DATA="${CTRL_LOCAL_DATA}/bin"

# Ce mot de passe n’étant utilisé que pour une machine virtuelle devant pouvoir être reproduite par les organismes contrôlés,
# il est nécessaire de le publier au même titre que le reste des scripts de créations de la machine.
# Le mot de passe est donc « Cnil1978! ».
DEFAULT_PASSWORD='$y$j9T$0W6iUary2QbdF3qyu4Tzh0$XokZXEWnFqXzIXfwprSo9zuP1fFeEW6B9pRFnpgtNO1'


#
# --------------------------------------------------------
# Configuration du système
#
# https://wiki.archlinux.org/title/Installation_guide
# https://wiki.archlinux.org/title/General_recommendations
# --------------------------------------------------------
#

# Réglage du temps
# https://wiki.archlinux.org/title/System_time
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# Langues
# https://wiki.archlinux.org/title/Locale
sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
sed -i "s/#fr_FR.UTF-8/fr_FR.UTF-8/" /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" >/etc/locale.conf
echo "KEYMAP=fr-latin1" >/etc/vconsole.conf

# Nom de la machine
echo "$CTRL_USERNAME" >/etc/hostname

# Utilisateurs
# https://wiki.archlinux.org/title/Users_and_groups
# https://man.archlinux.org/man/useradd.8
# Le mot de passe doit être passé sous forme hachée.
useradd --create-home --user-group --groups="vboxsf,wheel,wireshark" --password="$DEFAULT_PASSWORD" --shell="/usr/bin/bash" "$CTRL_USERNAME"

# Sudo
# Ce fichier de configuration permet aux utilisateurs membres du groupe `wheel` d'utiliser `sudo` afin d'effectuer des actions d'administration.
# https://wiki.archlinux.org/title/Sudo
echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/01_wheel

# Bootloader
# https://wiki.archlinux.org/title/GRUB
grub-install --target="i386-pc" "/dev/sda"
grub-mkconfig -o "/boot/grub/grub.cfg"

# Display manager
# https://wiki.archlinux.org/title/SDDM
# https://wiki.archlinux.org/title/Display_manager#Loading_the_display_manager
# Le service ne peut pas être activé avec la commande `systemctl enable sddm.service` car nous sommes dans un chroot.
ln -s '/usr/lib/systemd/system/sddm.service' '/etc/systemd/system/multi-user.target.wants/sddm.service'

# Réseau
# https://wiki.archlinux.org/title/Network_configuration
# https://wiki.archlinux.org/title/Dhcpcd
# Le service ne peut pas être activé avec la commande `systemctl enable dhcpcd.service` car nous sommes dans un chroot.
ln -s '/usr/lib/systemd/system/dhcpcd.service' '/etc/systemd/system/multi-user.target.wants/dhcpcd.service'

# Virtualbox
# https://wiki.archlinux.org/title/VirtualBox/Install_Arch_Linux_as_a_guest
# Le service ne peut pas être activé avec la commande `systemctl enable dhcpcd.service` car nous sommes dans un chroot.
ln -s '/usr/lib/systemd/system/vboxservice.service' '/etc/systemd/system/multi-user.target.wants/vboxservice.service'


#
# -------------------------------------
# Configuration de l'espace utilisateur
# -------------------------------------
#

# Création du dossier de configuration, d'autostart et des données permettant de finaliser l'installation
mkdir -p "${CTRL_HOME}/script_data/cnf"
mkdir -p "${CTRL_HOME}/.config/autostart"
cp -vr "${CTRL_SCRIPT_DATA}/cnf" "${CTRL_HOME}/script_data"
cp -v "${CTRL_SCRIPT_DATA}/finalize_install.sh" "${CTRL_HOME}/script_data"
cp -v "${CTRL_SCRIPT_DATA}/cnf/auto_install.desktop" "${CTRL_HOME}/.config/autostart"
chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "${CTRL_HOME}/script_data"
chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "${CTRL_HOME}/.config/autostart"
chmod 755 "${CTRL_HOME}/script_data/finalize_install.sh"
chmod 755 "${CTRL_HOME}/.config/autostart/auto_install.desktop"

# Répertoire des exécutables
mkdir -p "${CTRL_BIN_DATA}"
cp -v "${CTRL_SCRIPT_DATA}/wifi_ap_setup.sh" "${CTRL_BIN_DATA}"
chmod 755 "${CTRL_BIN_DATA}/wifi_ap_setup.sh"
chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "${CTRL_LOCAL_DATA}"
echo 'export PATH="$PATH:$HOME/.local/bin"' >>"${CTRL_HOME}/.bashrc"

# Agencement clavier
cat >"${CTRL_HOME}/.config/kxkbrc" << EOF
[\$Version]
update_info=kxkb.upd:remove-empty-lists,kxkb.upd:add-back-resetoptions,kxkb_variants.upd:split-variants

[Layout]
LayoutList=fr
Use=true
EOF

# Double click pour ouvrir les fichiers
cat >>"${CTRL_HOME}/.config/kdeglobals" << EOF

[KDE]
SingleClick=false
EOF

# Correction des droits sur le dossier de configuration et son contenu
chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "${CTRL_HOME}/.config"


#
# ----------
# Raccourcis
# ----------
#

create_shortcut() {
    install --verbose --group="$CTRL_GROUP" --owner="$CTRL_USERNAME" "$1" "$2"
}

mkdir -p "$CTRL_DESKTOP"
cat >"${CTRL_DESKTOP}/trash.desktop" << EOF
[Desktop Entry]
EmptyIcon=user-trash
Icon=user-trash-full
Name=Corbeille
Type=Link
URL[\$e]=trash:/
EOF

create_shortcut "$APPS_ROOT/org.wireshark.Wireshark.desktop" "${CTRL_DESKTOP}/"
create_shortcut "$APPS_ROOT/firefox.desktop" "${CTRL_DESKTOP}/"
create_shortcut "$APPS_ROOT/chromium.desktop" "${CTRL_DESKTOP}/"
create_shortcut "$APPS_ROOT/org.kde.spectacle.desktop" "${CTRL_DESKTOP}/"
create_shortcut "$APPS_ROOT/org.kde.konsole.desktop" "${CTRL_DESKTOP}/konsole.desktop"
ln -s "/media/sf_PiecesNumeriques" "${CTRL_DESKTOP}/PiecesNumeriques"

chown --recursive "${CTRL_USERNAME}:${CTRL_GROUP}" "${CTRL_DESKTOP}"


#
# --------------------
# Arch User Repository
# --------------------
#

aur_install() {
	pkg_name="$1"
	pkg_build_dir="${CTRL_AUR_BUILD_DIR}/${pkg_name}"
	rm -rf "$pkg_build_dir"
	sudo --user="$CTRL_USERNAME" git clone "https://aur.archlinux.org/${pkg_name}.git" "$pkg_build_dir"
	# Il n'est pas possible d'utiliser `sudo --chdir` avec `makepkg`
	cd "$pkg_build_dir"
	sudo --user="$CTRL_USERNAME" makepkg --noconfirm
	cd -
	find "$pkg_build_dir" -maxdepth 1 -name "${pkg_name}-*-x86_64\.pkg\.tar\.zst" -exec pacman --noconfirm --upgrade {} \;
	rm -rf "$pkg_build_dir"
}

# yay
# https://wiki.archlinux.org/title/Arch_User_Repository
# https://wiki.archlinux.org/title/AUR_helpers
# https://aur.archlinux.org/packages/yay-bin
aur_install "yay-bin"

# ChkRootkit
# https://aur.archlinux.org/packages/chkrootkit
aur_install "chkrootkit"