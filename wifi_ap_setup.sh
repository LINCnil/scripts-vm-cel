#!/usr/bin/env bash

error_msg () {
	echo "$1" >&2
}

# Prévention du lancement en simple utilisateur
if [[ "$(whoami)" != "root" ]]; then
	error_msg "Le script doit être exécuté avec les droits d'administration"
	error_msg "Exemple: sudo wifi_ap_setup.sh"
	exit 1
fi

# Paramètres du point d'accès
# En cas de problème de connexion, utiliser un autre canal (de 1 à 11)
AP_CHANNEL="1"
AP_NAME="CNIL-CEL-AP-$(openssl rand -hex 4)"
AP_PASSWORD="cnil1978"
echo "Nom du point d'accès : ${AP_NAME}"
echo "Mot de passe du point d'accès : ${AP_PASSWORD}"

# Nom des interfaces réseau
OUT_INTERFACE="enp0s3"
AP_INTERFACE="$(ip -json address | jq -r '.[].ifname' | grep '^wl')"
NB_INTERFACES=$(echo "$AP_INTERFACE" | wc -l)
if [[ "$AP_INTERFACE" = "" ]]; then
	error_msg "Erreur: aucune interface détectée"
	exit 1
fi
if [[ "$NB_INTERFACES" != "1" ]]; then
	error_msg "Erreur: $NB_INTERFACES interfaces détectées"
	exit 1
fi

# Configuration de dnsmasq
cat <<EOF > /etc/dnsmasq.conf
log-facility=/var/log/dnsmasq.log
# adressage fait manuellement ensuite avec ifconfig :
#address=/#/10.0.0.1
interface=${AP_INTERFACE}
dhcp-range=10.0.0.10,10.0.0.250,48h
# définition de la route par défaut (3) et du serveur DNS (6) :
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
#no-resolv
log-queries
EOF
systemctl restart dnsmasq.service

# Configuration de l'interface réseau
ip link set dev "${AP_INTERFACE}" down
ip link set dev "${AP_INTERFACE}" up
ip a add 10.0.0.1/24 dev "${AP_INTERFACE}"

# Transfert des paquets IP
sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.all.forwarding=1
sysctl net.ipv6.conf.all.forwarding=1

systemctl restart nftables.service
nft add table inet nat
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule inet nat postrouting oifname "${OUT_INTERFACE}" masquerade

# Configuration du point d'access
cat <<EOF > /etc/hostapd/hostapd.conf
# vérifier le nom de l'interface wifi
interface=${AP_INTERFACE}
# laisser le driver par défaut
driver=nl80211
channel=${AP_CHANNEL}
ssid=${AP_NAME}
wpa=2
wpa_passphrase=${AP_PASSWORD}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
# Change the broadcasted/multicasted keys after this many seconds.
wpa_group_rekey=600
# Change the master key after this many seconds. Master key is used as a basis
wpa_gmk_rekey=86400
EOF
systemctl restart hostapd.service
