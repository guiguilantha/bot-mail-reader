#!/usr/bin/env bash
# Installe le lancement automatique de l'agent à chaque ouverture de session (Ubuntu / GNOME).
set -e
DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
chmod +x "$DIR/run_agent.sh"

mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/agent-mails.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Résumé des mails
Exec="$DIR/run_agent.sh"
X-GNOME-Autostart-Delay=20
Terminal=false
EOF

echo "OK : l'agent se lancera à chaque ouverture de session."
echo "Pour désinstaller : rm ~/.config/autostart/agent-mails.desktop"
