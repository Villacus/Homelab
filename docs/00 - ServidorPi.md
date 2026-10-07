# Servidor Raspberry Pi (pilla)

Este documento resume las especificaciones técnicas, la configuración básica y los métodos de acceso al servidor central del homelab, conocido como `pilla`.

## Especificaciones y Configuración

- **Hostname**: `pilla`
- **IP Local**: `192.168.0.9`
- **Tailscale**: [pilla.tailf45616.ts.net](https://tailscale.com/)
- **NAS**: Montado en `/mnt/nasdisk` (USB, ext4, ~916GB)
- **Gestión**: Docker Compose manual y Arcane
- **Acceso SSH**: `villacus@pilla`

## Acceso remoto

El acceso a los servicios alojados en `pilla` se realiza principalmente a través de [Tailscale](https://tailscale.com/). Los servicios están expuestos bajo el subdominio `*.tailf45616.ts.net` configurado mediante el comando `tailscale serve`.

Para gestionar la exposición de nuevos servicios, consulta el flujo de trabajo detallado en el documento de [[Despliegue]].

### Lista de Servicios Expuestos

Musikat está disponible localmente en `http://192.168.0.9:8010` y actualmente
se publica dentro de la Tailnet en `https://musikat.tailf45616.ts.net` mediante
Tailscale Serve. Esta entrada se conserva al configurar el Funnel unificado.

Nginx Proxy Manager comparte la red Docker `music-network` con Navidrome y
Musikat. Su panel local está en `http://192.168.0.9:8181`; el proxy HTTP y
HTTPS se publican inicialmente en `http://192.168.0.9:8084` y
`https://192.168.0.9:8444`, porque Pi-hole conserva el puerto 80. El panel de
administración no debe exponerse externamente sin protección adicional.

El acceso público unificado previsto es
`https://pilla.tailf45616.ts.net/navidrome/` y
`https://pilla.tailf45616.ts.net/musikat/`, a través de un único Tailscale
Funnel hacia el puerto `8084`. Ambas rutas deben estar protegidas por la misma
Access List de Nginx Proxy Manager. Se conservan los accesos locales
`http://192.168.0.9:4533` y `http://192.168.0.9:8010`, además de los `serve`
existentes; no publiques el panel `:8181` por Funnel. El procedimiento y las
pruebas están en [[Despliegue]].

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
