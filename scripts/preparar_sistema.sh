#!/usr/bin/env bash
set -euo pipefail

GRUPO="${1:-1}"
HOST="servidor-grupo${GRUPO}"

# El hostname se fija al crear el contenedor con docker run --hostname.
# Los usuarios y grupos se crean solo si todavía no existen.
getent group soporte >/dev/null || groupadd soporte
getent group web >/dev/null || groupadd web
id adminsys >/dev/null 2>&1 || useradd -m -s /bin/bash adminsys
id tecnico >/dev/null 2>&1 || useradd -m -s /bin/bash tecnico
id visitante >/dev/null 2>&1 || useradd -m -s /bin/bash visitante

usermod -aG sudo adminsys
usermod -aG soporte tecnico
usermod -aG web visitante
# Se agrega al grupo docker solicitado por la guía.
getent group docker >/dev/null || groupadd docker
usermod -aG docker adminsys
usermod -aG docker tecnico

mkdir -p /proyecto/{datos,web,scripts,capturas}
chown root:soporte /proyecto/datos
chmod 2775 /proyecto/datos
chown root:web /proyecto/web
chmod 2775 /proyecto/web
chmod 755 /proyecto/scripts /proyecto/capturas
echo "Configuración aplicada. Host actual: $(hostname). Host esperado: $HOST"
