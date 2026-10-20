#!/usr/bin/env bash
# Lance l'agent de résumé de mails (appelé à l'ouverture de session par install_autostart.sh)
set -u
DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$DIR"

PY="$DIR/.venv/bin/python"
[ -x "$PY" ] || PY="python3"

# Attendre que le réseau soit prêt (2 minutes maximum)
for _ in $(seq 1 24); do
  "$PY" -c "import socket; socket.create_connection(('imap.gmail.com', 993), 5)" 2>/dev/null && break
  sleep 5
done

echo "===== $(date '+%d/%m/%Y %H:%M')" >> resume.txt
# timeout : évite de rester bloqué si une reconnexion Microsoft est demandée
timeout 300 "$PY" -u agent_mails.py >> resume.txt 2>&1

command -v notify-send >/dev/null 2>&1 && notify-send "Résumé des mails" "Liste mise à jour dans resume.txt"
xdg-open resume.txt >/dev/null 2>&1 &
