# Homelab - Guía de estructura

Repositorio de configuraciones Docker para el homelab desplegado en la Pi (`pilla`).

## Estructura del repo

```
Homelab/
├── Compose/
│   ├── <StackName>/
│   │   ├── docker-compose.yml
│   │   └── .env
│   └── ...
└── AGENTS.md
```

Cada stack es un directorio autocontenido con su `docker-compose.yml` y `.env`.

## Convenciones de los compose

### Nombre del proyecto
```yaml
name: nombre-en-minusculas
```

### Variables de entorno (.env)
```env
# General
TZ=Europe/Madrid
PUID=1000
PGID=1000

# Paths
SERVICE_CONFIG=/home/villacus/<service>/config

# Ports
SERVICE_PORT=XXXX
```

- `TZ` siempre `Europe/Madrid`
- `PUID`/`PGID` siempre `1000`
- Paths de config en `/home/villacus/<service>/`
- Datos/media en `/mnt/nasdisk/`
- Puertos en variables `<SERVICE>_PORT`

### Puertos asignados
| Puerto | Servicio |
|--------|----------|
| 80 | Pi-hole |
| 3000 | Homepage |
| 3001 | Uptime Kuma |
| 3002 | Speedtest |
| 4533 | Navidrome |
| 5335 | Unbound |
| 6767 | Bazarr |
| 6881 | qBittorrent (DHT) |
| 7000 | Komodo Discord Alerter |
| 7878 | Radarr |
| 8000 | Paperless-ngx |
| 8080 | Vaultwarden |
| 8081 | Nextcloud |
| 8082 | Glance |
| 8085 | qBittorrent (WebUI) |
| 8096 | Jellyfin |
| 8120 | Komodo Periphery |
| 8443 | qBittorrent (TLS) |
| 8686 | Lidarr |
| 8787 | Readarr |
| 8989 | Sonarr |
| 9120 | Komodo Core |
| 9696 | Prowlarr |
| 3552 | Arcane |
| 2283 | Immich |

### Container names
- Siempre explícitos (`container_name:`)
- En minúsculas, sin espacios
- Multi-servicio: guion bajo para separar (`nextcloud_db`, `immich_server`)

### Resource limits
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

| Tier | CPU | Memoria | Servicios |
|------|-----|---------|-----------|
| Light | 0.25 | 128M | Redis, Unbound, Speedtest, Prowlarr, Bazarr, Glance, Immich Redis, Paperless Broker, Komodo DB/Periphery |
| Medium | 0.5 | 256M-512M | Sonarr, Radarr, Lidarr, Readarr, qBittorrent, Vaultwarden, Paperless, Navidrome, Samba, Komodo Core, Immich Postgres |
| Heavy | 1.0 | 512M-1G | Nextcloud, Immich Server |
| Heaviest | 2.0 | 2G | Jellyfin |

### Redes
- Por defecto: Defffault Projetc Bridge
- Stacks complejos: bridge custom (`arrnet`, `paperless`)
- Pi-hole: `network_mode: host`

### Volúmenes
- Bind mounts con variables de `.env`
- Named volumes solo para Redis
- `:ro` para media read-only, `/etc/localtime`, Docker socket

### Restart policy
- `unless-stopped` para la mayoría
- `always` para servicios críticos (Vaultwarden, Nextcloud, Immich, Pi-hole)

### Stop grace period
- `30s` para servicios con base de datos

## Servidor Pi
- Hostname: `pilla`
- IP local: `192.168.0.9`
- Tailscale: `pilla.tailf45616.ts.net`
- NAS montado en `/mnt/nasdisk` (USB, ext4, ~916GB)
- Gestión de stacks: Komodo
- SSH: `villacus@pilla`

## Acceso remoto
Tailscale con servicios bajo `*.tailf45616.ts.net`:
```
https://jellyfin.tailf45616.ts.net
https://sonarr.tailf45616.ts.net
https://radarr.tailf45616.ts.net
https://prowlarr.tailf45616.ts.net
https://qbittorrent.tailf45616.ts.net
https://bazarr.tailf45616.ts.net
https://lidarr.tailf45616.ts.net
https://readarr.tailf45616.ts.net
https://navidrome.tailf45616.ts.net
https://nextcloud.tailf45616.ts.net
https://vaultwarden.tailf45616.ts.net
https://immich.tailf45616.ts.net
https://pihole.tailf45616.ts.net
https://glance.tailf45616.ts.net
https://komodo.tailf45616.ts.net
https://paperless-ngx.tailf45616.ts.net
https://arcane.tailf45616.ts.net
```

Script de serve: `/home/villacus/tailscale`

## Discord - Alerting

### Estructura de canales
```
📋 INFORMACIÓN
├── #reglas
├── #anuncios
└── #status              ← Uptime Kuma + alertas de servidor

🏗️ HOMELAB
├── #deploys             ← GitHub webhook + Komodo deploys
├── #logs
└── #backups

📱 SERVICIOS
├── #jellyfin
├── #arr-stack
├── #nextcloud
├── #immich
├── #paperless
└── #navidrome

💻 DOTFILES
├── #commits             ← GitHub webhook
└── #ideas

🔊 VOZ
├── 🔈 General
└── 🔈 Lab Session
```

### Webhooks de Discord (crear uno por canal)
En cada canal → Editar canal → Integraciones → Webhooks → Nuevo webhook:
- `#status` → "Komodo Status"
- `#deploys` → "Komodo Deploys"
- `#monitor` → "Komodo Monitor"

### Alerters en Komodo (Settings → Alerters)
Un Alerter por cada webhook de Discord:

**Alerter 1 - Status**
- URL: webhook de `#status`
- Alert Types: `ServerCpu`, `ServerMem`, `ServerDisk`, `ServerUnreachable`
- Resource Whitelist: `pilla`

**Alerter 2 - Deploys**
- URL: webhook de `#deploys`
- Alert Types: `StackStateChange`, `DeploymentStateChange`, `BuildComplete`, `BuildFailed`

**Alerter 3 - Monitor**
- URL: webhook de `#monitor`
- Alert Types: `ContainerStateChange`

### GitHub → Discord
En GitHub repo `Homelab`:
1. Settings → Webhooks → Add webhook
2. Payload URL: webhook de Discord
3. Content type: `application/json`
4. Events: Push
5. Secret: configurar en Komodo si se usa auto-redeploy

## Despliegue
1. Crear/ editar compose y .env en `Compose/<StackName>/`
2. Crear carpetas de config en la Pi: `ssh pilla "mkdir -p /home/villacus/<service>/config"`
3. Git push: `git add . && git commit -m "feat: ..." && git push`
4. Desplegar en Komodo
5. Registrar en Tailscale si aplica:
   - Añadir línea al script `/home/villacus/tailscale`:
     ```bash
     sudo tailscale serve --bg --https 443 --service=svc:<nombre> 127.0.0.1:<puerto>
     ```
   - Ejecutar el comando en la Pi
   - Aprobar en Tailscale Admin
6. Actualizar Glance si es un servicio nuevo
7. Configurar webhooks en Discord si aplica:
   - Crear webhook en el canal correspondiente
   - Añadir Alerter en Komodo (Settings → Alerters)
   - Test Alerter para verificar
