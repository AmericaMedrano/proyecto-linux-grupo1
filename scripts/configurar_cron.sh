#!/usr/bin/env bash
set -euo pipefail
mkdir -p /var/log/proyecto
touch /var/log/proyecto/reporte_sistema.log
chmod 664 /var/log/proyecto/reporte_sistema.log
chmod +x /proyecto/scripts/reporte_sistema.sh
CRON_LINE="*/30 * * * * /proyecto/scripts/reporte_sistema.sh >> /var/log/proyecto/reporte_sistema.log 2>&1"
( crontab -l 2>/dev/null | grep -vF "/proyecto/scripts/reporte_sistema.sh" || true
  echo "$CRON_LINE" ) | crontab -
service cron start
echo "Cron configurado:"
crontab -l
