[Tailscale](https://tailscale.com/) es una solución de VPN basada en WireGuard que permite crear redes privadas seguras y fáciles de administrar entre dispositivos y servidores. Además, facilita la publicación de servicios internos de forma segura mediante Tailscale Serve y Tailscale Funnel.
[Tailscale Admin](https://login.tailscale.com/admin/machines)

## Comandos utiles

Estos son los comandos que ya has usado en la maquina y que conviene guardar como referencia rapida.

### Instalacion y estado
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
sudo tailscale down
sudo tailscale logout
tailscale status
tailscale status --self
tailscale ping 100.98.5.83
sudo tailscale set --operator=$USER
```

### Publicar servicios con Serve
```bash
sudo tailscale serve --bg --https 443 --service=svc:vaultwarden 127.0.0.1:8080
sudo tailscale serve --bg --https 443 --service=svc:portainer 127.0.0.1:9000
sudo tailscale serve --bg --https 443 --service=svc:homepage 127.0.0.1:3000
sudo tailscale serve --bg --https 443 --service=svc:nextcloud 127.0.0.1:8081
sudo tailscale serve --bg --https 443 --service=svc:speedtest 127.0.0.1:3002
sudo tailscale serve --bg --https 443 --service=svc:odysseus 127.0.0.1:7000
sudo tailscale serve --bg --https 443 --service=svc:navidrome 127.0.0.1:4533
sudo tailscale serve --bg --https 443 --service=svc:pihole 127.0.0.1:80
```

### Limpiar o cambiar publicaciones
```bash
tailscale serve clear svc:odysseus
tailscale serve reset svc:nombre-servicio
tailscale funnel off
```

### Notas de uso
- `tailscale serve --bg` deja el servicio publicado en segundo plano.
- `--service=svc:nombre-servicio` ayuda a identificar cada servicio por nombre en Tailscale.
- Para servicios que ya exponen un puerto claro en localhost, publica siempre `127.0.0.1:PUERTO`.
- `tailscale funnel` solo tiene sentido si quieres exponer el servicio hacia Internet, no solo dentro de tu tailnet.

## Especificaciones

- Basado en WireGuard
- Cifrado extremo a extremo
- Acceso remoto seguro
- Publicación de servicios internos (Serve/Funnel)
- Multi-plataforma
## Detalles de despliegue [](#detalles_de_despliegue)
- **Rutas de datos:**
    - `/dev/net/tun` → `/dev/net/tun`
    - `/var/lib/tailscale` → `/var/lib/tailscale`

1. **Publicar un servicio externo (Funnel):**
```bash
docker exec -it tailscale tailscale funnel --bg --https=443 http://192.168.0.9:port
```

2. **Apagar Funnel:**
```bash
docker exec tailscale tailscale funnel off 
```

3. **Resetear un servicio publicado:**
```bash
docker exec -it tailscale tailscale serve reset svc:nombre-servicio
```
