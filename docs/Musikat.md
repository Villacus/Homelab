Musikat es un servicio de descarga y organización musical desplegado desde `Compose/Musikat/`.

## Construcción y red

El stack usa el contexto Git oficial de [`soggy8/musikat`](https://github.com/soggy8/musikat), rama `main`:

```text
https://github.com/soggy8/musikat.git#main
```

Arcane necesita BuildKit habilitado para clonar ese contexto remoto. Musikat y Navidrome deben estar conectados a la red Docker externa `music-network`, que se crea una sola vez en la Pi:

```bash
ssh pilla "docker network inspect music-network >/dev/null 2>&1 || docker network create --driver bridge music-network"
```

Musikat publica `http://192.168.0.9:8010` (puerto del host `8010`, puerto interno `8000`) y su healthcheck consulta `/api/health`.

## NAS y permisos

Antes del primer despliegue, comprueba que el NAS está montado en `/mnt/nasdisk` y crea el directorio temporal:

```bash
ssh pilla "mkdir -p /home/villacus/musikat/downloads"
```

Verifica las tres rutas musicales y el directorio temporal antes de arrancar. El contenedor se ejecuta con UID/GID `1000:1000`, por lo que ese usuario debe poder escribir en las carpetas musicales. Musikat monta las bibliotecas en `rw` para guardar descargas; Navidrome las monta en `ro` para indexarlas.

| Destino | Ruta del host | Ruta dentro de Musikat |
|---|---|---|
| Música | `/mnt/nasdisk/privada/Musica` | `/music/main` |
| Itziar | `/mnt/nasdisk/compartida/Musica` | `/music/itziar` |
| Jonpa | `/mnt/nasdisk/privada/Musica_jon` | `/music/jonpa` |

`DOWNLOAD_DIR=/app/downloads` es el staging temporal del contenedor. El volumen persistente es `/home/villacus/musikat/downloads:/app/downloads`.

## Variables

Los valores no sensibles pueden configurarse en el `.env` del stack o en Arcane:

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

`NAVIDROME_MUSIC_PATHS` y `NAVIDROME_MUSIC_LABELS` deben conservar el mismo orden. El Compose fija `/music/jonpa` como ruta predeterminada mediante `NAVIDROME_MUSIC_PATH`; las variables plurales controlan los destinos visibles.

`NAVIDROME_API_URL` debe usar el DNS de la red Docker (`http://navidrome:4533`), no `localhost` ni el puerto publicado del host. Si se activa la sincronización periódica, configura `NAVIDROME_USERNAME` y `NAVIDROME_PASSWORD` como variables protegidas de Arcane y establece `NAVIDROME_SYNC_ENABLED=true`.

La sincronización con Navidrome no sustituye su escaneo de biblioteca. Las bibliotecas adicionales se configuran por separado en Navidrome, desde `Settings → Libraries`, usando `/music`, `/itziar_music` y `/jonpa_music`.

No guardes credenciales en Git ni en un `.env` versionado. Si alguna credencial real ya se publicó, retírala y rótala antes de continuar.

## Dependencias con Nginx Proxy Manager

Navidrome, Musikat y Nginx Proxy Manager comparten `music-network`. Despliega en este orden: Navidrome, Musikat y Nginx. Nginx debe reenviar a `musikat:8000`, que es el puerto interno; el puerto `8010` solo es el puerto publicado en el host. La configuración completa de la red, el proxy y el Funnel está en [[Despliegue]].

## Actualizaciones

Los cambios en `Compose/Musikat/**` activan el workflow de GitHub y llaman al secreto `WEBHOOK_MUSIKAT` cuando el administrador ya ha configurado Arcane y los secretos de Actions. El primer despliegue sigue siendo manual si esa configuración aún no existe. Consulta [[Despliegue]] para el flujo común y [[Convenciones]] para las reglas de Compose.
