#!/usr/bin/env bash
set -e
# El motor Docker vive en Docker Desktop; este contenedor usa su socket.
mkdir -p /proyecto /var/log/proyecto
touch /var/log/proyecto/reporte_sistema.log
cron
exec tail -f /dev/null
