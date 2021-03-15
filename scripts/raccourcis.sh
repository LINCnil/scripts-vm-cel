#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

APPS_ROOT="/usr/share/applications"

shortcut() {
    install --group="$CTRL_GROUP" --owner="$CTRL_USERNAME" "$1" "$2"
}

cat >"$CTRL_DESKTOP/trash:⁄.desktop" << EOF
[Desktop Entry]
EmptyIcon=user-trash
Icon=user-trash-full
Name=Corbeille
Type=Link
URL[\$e]=trash:/
EOF

shortcut "$APPS_ROOT/wireshark.desktop" "$CTRL_DESKTOP/"
shortcut "$SCRIPTS_ROOT/cnf/firefox.desktop" "$CTRL_DESKTOP/"
shortcut "$APPS_ROOT/chromium.desktop" "$CTRL_DESKTOP/"
shortcut "$APPS_ROOT/org.kde.spectacle.desktop" "$CTRL_DESKTOP/"
shortcut "$APPS_ROOT/org.kde.konsole.desktop" "$CTRL_DESKTOP/konsole.desktop"
shortcut "$APPS_ROOT/org.kde.konsole.desktop" "$CTRL_DESKTOP/konsole_admin.desktop"
sed -i 's/^Exec=konsole/Exec=konsole -e "su -"/' "$CTRL_DESKTOP/konsole_admin.desktop"
sed -i 's/Konsole/KonsoleAdmin/' "$CTRL_DESKTOP/konsole_admin.desktop"
