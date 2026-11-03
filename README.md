# Proyecto Linux - Grupo 1

Proyecto final de Introducción al Software Libre, Ciclo II-2026.

## Requisitos
- Docker Desktop instalado y ejecutándose.
- Docker Desktop configurado para contenedores Linux.
- Windows PowerShell.

## 1. Crear el entorno Ubuntu

Desde PowerShell, situado en la carpeta del proyecto:

```powershell
docker build -f Dockerfile.entorno -t entorno-isl:1.0 .
docker run -d --name entorno-proyecto --hostname servidor-grupo1 `
  -v "${PWD}:/proyecto" `
  -v /var/run/docker.sock:/var/run/docker.sock `
  entorno-isl:1.0
```

Si el contenedor ya existe, no ejecutes de nuevo `docker run`; usa:
```powershell
docker start entorno-proyecto
docker exec -it entorno-proyecto bash
```

## 2. Preparar Linux

Dentro de Ubuntu:
```bash
cd /proyecto
chmod +x scripts/*.sh
./scripts/preparar_sistema.sh 1
hostname
getent passwd adminsys tecnico visitante
getent group soporte
getent group web
id adminsys
id tecnico
id visitante
ls -ld /proyecto/datos /proyecto/web
```

En un contenedor, `hostname` se establece al crear el contenedor. El nombre solicitado `servidor-grupo1` se asigna con `--hostname`.

## 3. Monitoreo y Cron

```bash
./scripts/reporte_sistema.sh
./scripts/configurar_cron.sh
```

Para comprobar:
```bash
crontab -l
service cron status
tail -n 50 /var/log/proyecto/reporte_sistema.log
```
La tarea se ejecuta en los minutos 00 y 30 de cada hora. Para probar sin esperar, ejecuta manualmente el reporte.

## 4. Git local

```bash
git init
git add .
git commit -m "Primer commit: estructura del proyecto Linux"
```
Crea en GitHub un repositorio vacío llamado `proyecto-linux-grupo1` y enlázalo:
```bash
git branch -M main
git remote add origin https://github.com/USUARIO/proyecto-linux-grupo1.git
git push -u origin main
```
Sustituye `USUARIO` por tu usuario real de GitHub. No agregues un README desde GitHub si ya usarás el de esta carpeta.

## 5. Docker y Nginx oficial con bind mount (puerto 8080)

Este paso se ejecuta en **otra ventana de Windows PowerShell**, no dentro de Ubuntu, porque el bind mount debe usar la ruta real de Windows que Docker Desktop comparte con el motor.

Desde la carpeta del proyecto en PowerShell:
```powershell
docker run -d --name nginx-oficial -p 8080:80 `
  --mount "type=bind,source=$((Resolve-Path .\\web).Path),target=/usr/share/nginx/html,readonly" `
  nginx:latest
docker ps
docker logs nginx-oficial
```
Abre `http://localhost:8080` en el navegador de Windows. Para comprobar con curl desde Ubuntu: `curl -I http://host.docker.internal:8080`.

## 6. Imagen personalizada (puerto 8081)

```bash
docker build -t servidor-grupo1:latest .
docker run -d --name nginx-personalizado -p 8081:80 servidor-grupo1:latest
docker ps
curl -I http://host.docker.internal:8081
docker logs nginx-personalizado
```
Abre `http://localhost:8081`.

## 7. Red personalizada (puerto 8082)

```bash
docker network create red-proyecto
docker run -d --name nginx-red --network red-proyecto -p 8082:80 nginx:latest
docker network inspect red-proyecto
```
Prueba desde Alpine:
```bash
docker run --rm --network red-proyecto alpine:latest sh -c \
  "apk add --no-cache iputils >/dev/null && ping -c 4 nginx-red"
```
Abre `http://localhost:8082`.

## 8. Volumen persistente (puerto 8083)

```bash
docker volume create volumen-web
docker run -d --name preparar-volumen -v volumen-web:/dest alpine:latest sleep 3600
docker cp /proyecto/web/. preparar-volumen:/dest/
docker rm -f preparar-volumen
docker run -d --name nginx-volumen -p 8083:80 \
  -v volumen-web:/usr/share/nginx/html nginx:latest
docker volume inspect volumen-web
```
Abre `http://localhost:8083`.

## 9. Verificación final

```bash
docker ps
docker network inspect red-proyecto
docker volume inspect volumen-web
curl -I http://host.docker.internal:8080
curl -I http://host.docker.internal:8081
curl -I http://host.docker.internal:8082
curl -I http://host.docker.internal:8083
git status
tail -n 30 /var/log/proyecto/reporte_sistema.log
```

## Notas importantes
- Los puertos 8080–8083 deben estar libres en Windows. El bind mount del puerto 8080 se lanza desde PowerShell de Windows; los demás comandos pueden ejecutarse desde Ubuntu.
- El socket `/var/run/docker.sock` da al contenedor Ubuntu capacidad de controlar el motor Docker del equipo. Úsalo únicamente en un entorno académico y de confianza.
- El grupo `docker` equivale prácticamente a privilegios administrativos sobre el motor Docker.
- Los usuarios Linux se crean dentro del contenedor Ubuntu y se pierden si eliminas ese contenedor. No uses `docker rm` hasta terminar y guardar tus evidencias.
- La ruta `/var/log/proyecto` está dentro del contenedor Ubuntu; no es una ruta de Windows.
- Para cambiar el grupo, reemplaza `1` por el número real en los comandos, nombres de imagen, host y repositorio.
