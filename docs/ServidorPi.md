# Servidor Raspberry Pi (pilla)

Este documento resume las especificaciones técnicas, la configuración básica y los métodos de acceso al servidor central del homelab, conocido como `pilla`.

## Especificaciones y Configuración

- **Hostname**: `pilla`
- **IP Local**: `192.168.0.9`
- **Tailscale**: [pilla.tailf45616.ts.net](https://tailscale.com/)
- **NAS**: Montado en `/mnt/nasdisk` (USB, ext4, ~916GB)
- **Gestión**: Docker Compose manual
- **Acceso SSH**: `villacus@pilla`

## Acceso remoto

El acceso a los servicios alojados en `pilla` se realiza principalmente a través de [Tailscale](https://tailscale.com/). Los servicios están expuestos bajo el subdominio `*.tailf45616.ts.net` configurado mediante el comando `tailscale serve`.

Para gestionar la exposición de nuevos servicios, consulta el flujo de trabajo detallado en el documento de [[Despliegue]].

### Lista de Servicios Expuestos

Musikat también está disponible localmente en `http://192.168.0.9:8010`.
La URL Tailscale prevista para Musikat es
`https://musikat.tailf45616.ts.net`, pero solo estará disponible después de
añadir su comando `tailscale serve` en la Pi.

Nginx Proxy Manager comparte la red Docker `music-network` con Navidrome y
Musikat. Su panel local está en `http://192.168.0.9:8181`; el proxy HTTP y
HTTPS se publican inicialmente en `http://192.168.0.9:8084` y
`https://192.168.0.9:8444`, porque Pi-hole conserva el puerto 80. El panel de
administración no debe exponerse externamente sin protección adicional.

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
https://paperless-ngx.tailf45616.ts.net
https://arcane.tailf45616.ts.net
https://omniroute.tailf45616.ts.net
```

El script encargado de gestionar estos túneles se encuentra en el host en: `/home/villacus/tailscale`.
