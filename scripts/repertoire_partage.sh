#!/bin/bash

ISO_MOUNT_DIR="/media/vbox_guest_additions"

# Montage automatique du dossier partagé
echo "PiecesNumeriques $CTRL_DESKTOP/PartagePiecesNumeriques vboxsf defaults,_netdev 0 0" >>"/etc/fstab"

# Installation des paquets
# apt install -y virtualbox-guest-additions-iso

# Création des répertoires
mkdir -p "$ISO_MOUNT_DIR"
mkdir -p "$CTRL_DESKTOP/PartagePiecesNumeriques"
chown -R "$CTRL_USERNAME:$CTRL_GROUP" "$CTRL_DESKTOP/PartagePiecesNumeriques"

# Montage du CD des extensions VirtualBox
#mount -o ro "/usr/share/virtualbox/VBoxGuestAdditions.iso" "$ISO_MOUNT_DIR"
mount "/dev/sr0" "$ISO_MOUNT_DIR"

# Installation des extensions VirtualBox
"$ISO_MOUNT_DIR/autorun.sh"
