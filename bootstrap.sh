#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

DISK_NAME="/dev/sda"
PART_NB="1"
PART_NAME="${DISK_NAME}${PART_NB}"
SHARED_DIR="/media/sf_PiecesNumeriques"
INSTALL_MOUNT_POINT_ROOT="/mnt"
CHROOT_DATA_DEST_PATH="/root/script_data"
DATA_DEST_PATH="${INSTALL_MOUNT_POINT_ROOT}${CHROOT_DATA_DEST_PATH}"

#
# Guide d'installation :
# https://wiki.archlinux.org/title/Installation_guide
#

# Réglage du clavier
loadkeys "fr-latin1"

# Réglage du temps
timedatectl

# Préparation de la partition
echo "type=83" | sfdisk "$DISK_NAME"
sfdisk --activate "$DISK_NAME" "$PART_NB"
mkfs.ext4 "$PART_NAME"
mount "$PART_NAME" "$INSTALL_MOUNT_POINT_ROOT"

# Installation des paquets
# https://man.archlinux.org/man/reflector.1
# https://man.archlinux.org/man/pacstrap.8
# https://archlinux.org/packages/
reflector --country "France" --protocol "https" --sort "rate" --save "/etc/pacman.d/mirrorlist"
pacstrap -K "$INSTALL_MOUNT_POINT_ROOT" \
	base base-devel linux linux-firmware linux-headers \
	grub \
	man-db man-pages man-pages-fr texinfo \
	dosfstools mtools \
	bash \
	vim neovim \
	sudo \
	dhcpcd \
	git jq usbutils \
	plasma-meta kde-applications-meta sddm \
	noto-fonts noto-fonts-emoji noto-fonts-extra ttf-dejavu ttf-inconsolata ttf-liberation ttf-roboto \
	virtualbox-guest-utils \
	clamav \
	bind inetutils nmap wget whois \
	chromium firefox firefox-i18n-fr \
	dnsmasq hostapd iw \
	mitmproxy mkcert \
	obs-studio \
	ssh-audit sqlmap \
	wipe \
	wireshark-qt

# Génération du fichier de configuration du montage des systèmes de fichier
genfstab -U "$INSTALL_MOUNT_POINT_ROOT" >>"${INSTALL_MOUNT_POINT_ROOT}/etc/fstab"

# Paramétrage du système
# https://man.archlinux.org/man/arch-chroot.8
mkdir -p "${DATA_DEST_PATH}/cnf"
cp -vr "${SHARED_DIR}/cnf" "$DATA_DEST_PATH"
cp -v "${SHARED_DIR}/configure.sh" "$DATA_DEST_PATH"
cp -v "${SHARED_DIR}/finalize_install.sh" "$DATA_DEST_PATH"
cp -v "${SHARED_DIR}/wifi_ap_setup.sh" "$DATA_DEST_PATH"
arch-chroot "$INSTALL_MOUNT_POINT_ROOT" /bin/bash "${CHROOT_DATA_DEST_PATH}/configure.sh"
rm -rf "${DATA_DEST_PATH}/cnf" "${DATA_DEST_PATH}/configure.sh" "${DATA_DEST_PATH}/finalize_install.sh" "${DATA_DEST_PATH}/wifi_ap_setup.sh"

# Finalisation
umount -R /mnt
reboot