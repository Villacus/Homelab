# Servicios del Homelab

Este documento enumera los servicios desplegados en el homelab, detallando la asignación de puertos y los límites de recursos aplicados. Esta información es fundamental para mantener el orden y asegurar que el rendimiento del servidor se mantenga dentro de los límites físicos de la Raspberry Pi.

Para obtener información detallada sobre cómo se configuran estos servicios, consulta [[Convenciones]].

## Puertos asignados
| Puerto | Servicio                    | Documentación                                            |
| ------ | --------------------------- | -------------------------------------------------------- |
| 80     | Pi-hole                     | [Docs](https://docs.pi-hole.net/)                        |
| 3000   | Homepage                    | [Docs](https://gethomepage.dev/)                         |
| 3001   | Uptime Kuma                 | [Docs](https://github.com/louislam/uptime-kuma)          |
| 3002   | Speedtest                   | [Docs](https://github.com/librespeed/speedtest)          |
| 3003   | Obsidian (HTTP)             | [Docs](https://docs.linuxserver.io/images/docker-obsidian/) |
| 3004   | Obsidian (HTTPS)            | [Docs](https://docs.linuxserver.io/images/docker-obsidian/) |
| 4533   | Navidrome                   | [Docs](https://www.navidrome.org/)                       |
| 5335   | Unbound                     | [Docs](https://nlnetlabs.nl/projects/unbound/about/)     |
| 6767   | Bazarr                      | [Docs](https://www.bazarr.media/)                        |
| 6881   | qBittorrent (DHT)           | [Docs](https://www.qbittorrent.org/)                     |
| 7878   | Radarr                      | [Docs](https://radarr.video/)                            |
| 8000   | Paperless-ngx               | [Docs](https://docs.paperless-ngx.com/)                  |
| 8010   | Musikat                     | [Repositorio](https://github.com/soggy8/musikat)         |
| 8080   | Vaultwarden                 | [Docs](https://github.com/dani-garcia/vaultwarden)       |
| 8081   | Nextcloud                   | [Docs](https://nextcloud.com/)                           |
| 8082   | Glance                      | [Docs](https://glance.nhat.dev/)                         |
| 8083   | NUT Bridge                  | [Docs](https://networkupstools.org/)                     |
| 8084   | Nginx Proxy Manager (HTTP)  | [Docs](https://nginxproxymanager.com/)                   |
| 8085   | qBittorrent (WebUI)         | [Docs](https://www.qbittorrent.org/)                     |
| 8181   | Nginx Proxy Manager (panel) | [Docs](https://nginxproxymanager.com/)                   |
| 8096   | Jellyfin                    | [Docs](https://jellyfin.org/)                            |
| 8443   | qBittorrent (TLS)           | [Docs](https://www.qbittorrent.org/)                     |
| 8444   | Nginx Proxy Manager (HTTPS) | [Docs](https://nginxproxymanager.com/)                   |
| 8686   | Lidarr                      | [Docs](https://lidarr.audio/)                            |
| 8787   | Readarr                     | [Docs](https://readarr.com/)                             |
| 8989   | Sonarr                      | [Docs](https://sonarr.tv/)                               |
| 9696   | Prowlarr                    | [Docs](https://prowlarr.com/)                            |
| 3552   | Arcane                      | [Docs](https://getarcane.app/docs)                       |
| 2283   | Immich                      | [Docs](https://immich.app/)                              |
| 20128  | OmniRoute                   | [Repositorio](https://github.com/diegosouzapw/OmniRoute) |
| 5555   | NebulaSync                  | -                                                        |

## Estrategia de Asignación de Recursos

Los servicios están organizados en niveles (tiers) basados en su consumo típico de CPU y RAM. Esta clasificación permite equilibrar la carga del servidor de forma proactiva.

| Tier | CPU | Memoria | Servicios |
|------|-----|---------|-----------|
| Light | 0.25 | 128M | Redis, Unbound, Speedtest, Prowlarr, Bazarr, Glance, Immich Redis, Paperless Broker |
| Medium | 0.5 | 256M-512M | Sonarr, Radarr, Lidarr, Readarr, qBittorrent, Vaultwarden, Paperless, Navidrome, Musikat, Nginx Proxy Manager, Samba, Immich Postgres |
| Heavy | 1.0 | 512M-1G | Nextcloud, Immich Server |
| Heaviest | 2.0 | 2G | Jellyfin |

Consulta las [[Convenciones]] para ver cómo aplicar estos límites en los archivos `docker-compose.yml`.
