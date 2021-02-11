#!/bin/bash

IFS=$'\n\t'

# Mise à jour du système
apt update
apt -y dist-upgrade
apt clean

# WireShark
dpkg-reconfigure wireshark-common
usermod -a -G wireshark controle

# Bash
sed -i 's/^#if/if/' /etc/bash.bashrc
sed -i 's/^#  if/  if/' /etc/bash.bashrc
sed -i 's/^#    . \/us/    . \/us/' /etc/bash.bashrc
sed -i 's/^#  elif/  elif/' /etc/bash.bashrc
sed -i 's/^#    . \/et/    . \/et/' /etc/bash.bashrc
sed -i 's/^#  fi/  fi/' /etc/bash.bashrc
sed -i 's/^#fi/fi/' /etc/bash.bashrc

# Anti-malwares
mkdir -m777 -p "$CTRL_DESKTOP/Resultats"
systemctl stop clamav-freshclam
rkhunter -c -sk >> "$CTRL_DESKTOP/Resultats/Rkhunter.txt"
chkrootkit >> "$CTRL_DESKTOP/Resultats/ChkRootkit.txt"
systemctl stop clamav-freshclam.service
freshclam
touch /etc/clamav/clamd.conf
clamscan -r >> "$CTRL_DESKTOP/Resultats/ClamScan.txt"
systemctl disable clamav-freshclam.service
