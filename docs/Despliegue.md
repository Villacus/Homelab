# Despliegue de Servicios

Este documento detalla el flujo de trabajo estándar para desplegar nuevos servicios o actualizar servicios existentes en el entorno de homelab.

## Prerrequisitos
- Acceso SSH configurado a la Raspberry Pi (pilla).
- [Docker](https://docs.docker.com/) instalado y configurado en la Pi.
- [Tailscale](https://tailscale.com/kb/) instalado para conectividad segura.
- [Glance](https://glance.nhat.dev/) configurado para el dashboard de monitorización.

## Musikat

Musikat se despliega desde el stack `Compose/Musikat/` usando el contexto de
build oficial de [`soggy8/musikat`](https://github.com/soggy8/musikat), rama
`main`: `https://github.com/soggy8/musikat.git#main`. Arcane debe tener
BuildKit habilitado para poder clonar el contexto Git remoto. El servicio
publica `http://192.168.0.9:8010` (puerto 8010 del host y 8000 dentro del
contenedor) y su healthcheck interno consulta `/api/health`.

Antes de desplegar, comprueba en la Pi que el NAS está montado en
`/mnt/nasdisk` y crea el directorio para los temporales de descarga:

```text
/home/villacus/musikat/downloads
```

Antes de arrancar, verifica que existen las tres rutas del NAS y el directorio
temporal, que el NAS sigue montado y que UID/GID `1000:1000` puede escribir en
ellos. Si el NAS no está montado, Docker podría crear directorios vacíos en el
punto de montaje equivocado. El contenedor se ejecuta con UID/GID `1000:1000`;
las tres carpetas musicales deben ser accesibles por ese usuario. Musikat
necesita montar las carpetas musicales en `rw` para guardar descargas; el
stack de Navidrome las monta en `ro` para indexarlas.

### Destinos de descarga

La interfaz de Musikat ofrece estos destinos, definidos en
`Compose/Musikat/.env` mediante `NAVIDROME_MUSIC_PATHS` y
`NAVIDROME_MUSIC_LABELS`:

| Destino | Ruta del host | Ruta dentro de Musikat |
|---|---|---|
| Musica | `/mnt/nasdisk/privada/Musica` | `/music/main` |
| Itziar | `/mnt/nasdisk/compartida/Musica` | `/music/itziar` |
| Jonpa | `/mnt/nasdisk/privada/Musica_jon` | `/music/jonpa` |

`DOWNLOAD_DIR=/app/downloads` es solo el staging temporal del contenedor; el
volumen persistente correspondiente es
`/home/villacus/musikat/downloads:/app/downloads`.

### Variables de Arcane

Los valores no sensibles del stack pueden configurarse en el `.env` del
proyecto o en Arcane:

```text
MUSIKAT_PORT=8010
MUSIKAT_DOWNLOADS_PATH=/home/villacus/musikat/downloads
MUSIKAT_MUSIC_PATH=/mnt/nasdisk/privada/Musica
MUSIKAT_ITZIAR_MUSIC_PATH=/mnt/nasdisk/compartida/Musica
MUSIKAT_JONPA_MUSIC_PATH=/mnt/nasdisk/privada/Musica_jon
NAVIDROME_API_URL=http://navidrome:4533
NAVIDROME_SYNC_ENABLED=false
DOWNLOAD_DIR=/app/downloads
DEFAULT_METADATA_PROVIDER=deezer
```

`NAVIDROME_MUSIC_PATHS` y `NAVIDROME_MUSIC_LABELS` deben conservar el mismo
orden: cada ruta interna se muestra con su etiqueta correspondiente. El
compose fija `NAVIDROME_MUSIC_PATH=/music/jonpa` como ruta predeterminada;
para cambiar los destinos visibles usa las variables plurales anteriores.

### Navidrome y sincronización

`NAVIDROME_API_URL` usa el DNS de la red Docker compartida
(`http://navidrome:4533`), no `localhost` ni el puerto publicado del host.
Navidrome y Musikat deben estar conectados a `music-network` para que ese
nombre se resuelva desde el contenedor.

Si se desea que Musikat ejecute su sincronización periódica, configura en
Arcane `NAVIDROME_USERNAME` y `NAVIDROME_PASSWORD` y activa
`NAVIDROME_SYNC_ENABLED=true`. La sincronización de Musikat es la
comunicación con la API de Navidrome; no sustituye el escaneo/indexado de la
biblioteca de Navidrome. Las bibliotecas adicionales se gestionan en
Navidrome desde `Settings → Libraries`, usando sus rutas internas
(`/music`, `/itziar_music` y `/jonpa_music`). No intentes configurar varias
raíces de Navidrome como una única lista separada por comas; cada biblioteca
se añade por separado.

No guardes las credenciales en Git ni en un `.env` versionado: introdúcelas
como variables protegidas del proyecto en Arcane. Si alguna credencial real
ha quedado en un archivo versionado, retírala y rótala antes de publicar los
cambios.

## Red compartida y Nginx Proxy Manager

Navidrome, Musikat y Nginx Proxy Manager comparten la red externa
`music-network`. Créala una sola vez en la Pi antes de desplegar los stacks:

```bash
ssh pilla "docker network inspect music-network >/dev/null 2>&1 || docker network create --driver bridge music-network"
ssh pilla "docker network inspect music-network"
```

Los tres `.env` deben conservar `MUSIC_NETWORK=music-network`. Comprueba la
red en la Pi con `docker network inspect music-network`; Compose no la crea ni
la elimina porque está declarada como `external: true`.

Crea los directorios persistentes de Nginx Proxy Manager y despliega en este
orden:

```bash
ssh pilla "mkdir -p /home/villacus/nginx/data /home/villacus/nginx/letsencrypt"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Navidrome/.env -f /home/villacus/Homelab/Compose/Navidrome/docker-compose.yml up -d"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Musikat/.env -f /home/villacus/Homelab/Compose/Musikat/docker-compose.yml up -d"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Nginx/.env -f /home/villacus/Homelab/Compose/Nginx/docker-compose.yml up -d"
```

Nginx publica puertos alternativos porque Pi-hole conserva el puerto 80:

| Uso | Host | Contenedor |
|---|---:|---:|
| Proxy HTTP | 8084 | 80 |
| Proxy HTTPS | 8444 | 443 |
| Panel de administración | 8181 | 81 |

En la interfaz de Nginx Proxy Manager (`http://192.168.0.9:8181`) crea los
Proxy Hosts con estos destinos internos, que solo funcionan cuando los tres
contenedores están en `music-network`:

- Navidrome: `http://navidrome:4533`
- Musikat: `http://musikat:8000`

El panel administrativo no debe exponerse por Tailscale sin controles de
acceso adicionales. La exposición remota del proxy debe apuntar al puerto de
host elegido (8084 o 8444), no al puerto interno 443. Los puertos publicados
de Navidrome y Musikat se mantienen durante esta transición para no romper el
acceso directo existente; su cierre queda para una fase posterior.

### Redeploy automático

El workflow `.github/workflows/deploy-arcane.yml` detecta cambios en
`Compose/Musikat/**` y `Compose/Nginx/**`. Para habilitar el redeploy
automático:

1. Crea en Arcane los webhooks de redeploy de los stacks `musikat` y `nginx` y
   copia sus URLs.
2. En GitHub, abre `Settings → Secrets and variables → Actions` y crea los
   secretos `WEBHOOK_MUSIKAT` y `WEBHOOK_NGINX` con esas URLs.
3. Comprueba que `TAILSCALE_AUTHKEY` también está configurado, porque el
   runner entra en la Tailnet antes de enviar los webhooks.

El webhook y sus URLs son configuración externa y no deben escribirse en el
repositorio.

## Flujo de Trabajo
1. **Preparación del Stack**: Crear o editar el archivo `docker-compose.yml` y el archivo de variables en `Compose/<StackName>/`. No versionar credenciales: usa un `.env.example` sin secretos y configura el `.env` real en el gestor del stack (Arcane, en el caso de Musikat).
2. **Preparación de Directorios**: Crear las carpetas de configuración necesarias en la Pi utilizando SSH:
   `ssh pilla "mkdir -p /home/villacus/<service>/config"`
3. **Sincronización**: Revisar que no haya secretos en los archivos antes de enviar los cambios al repositorio:
   `git add . && git commit -m "feat: ..." && git push`
4. **Despliegue**: Ejecutar el despliegue en la Pi:
   `ssh pilla "docker compose -f /home/villacus/Homelab/Compose/<StackName>/docker-compose.yml up -d"`
5. **Exposición (Tailscale)**: Si el servicio debe ser accesible externamente, configurar el túnel:
   - Añadir la siguiente línea al script `/home/villacus/tailscale`:
     ```bash
     tailscale serve --bg --https 443 --service=svc:<nombre> 127.0.0.1:<puerto>
     ```
   - Ejecutar el comando en la Pi.
   - Aprobar el nuevo túnel en el panel de administración de Tailscale.
6. **Monitorización**: Actualizar el dashboard de Glance si es un servicio nuevo.
