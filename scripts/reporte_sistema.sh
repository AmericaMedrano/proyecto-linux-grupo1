#!/usr/bin/env bash
set -u
echo "========================================"
echo "REPORTE DEL SISTEMA"
echo "Fecha y hora: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo "Usuarios conectados: $(who | wc -l)"
echo "Espacio libre en disco principal:"
df -h / | awk 'NR==2 {print "Disponible: "$4" (uso: "$5")"}'
echo "Memoria RAM disponible:"
free -h | awk '/Mem:/ {print "Disponible: "$7}'
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo "Contenedores Docker activos: $(docker ps -q | wc -l)"
else
  echo "Contenedores Docker activos: no se pudo consultar el motor Docker"
fi
echo "========================================"
