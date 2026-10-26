El reverse proxy público vive en la VPS Oracle (`pihole-vnic`) y reenvía por Tailscale a `pilla`. Pi-hole mantiene el modo `host`, por lo que Nginx Proxy Manager no debe usar `network_mode: host`: publica `80/443` directamente y deja el panel en `8181` privado.

## Compose

El stack está en `Compose/Nginx/`. En Oracle copia `.env.example` como `.env`, ajusta las rutas si el usuario de Docker no es `ubuntu` y crea los directorios persistentes:

```bash
mkdir -p /home/ubuntu/nginx/data /home/ubuntu/nginx/letsencrypt
```

La configuración espera que Pi-hole no esté usando `80/443`. Si el contenedor actual de Pi-hole escucha solo en `80`, hay que mover su interfaz web a otro puerto antes de levantar Nginx; no se debe resolver el conflicto usando `network_mode: host` para Nginx.

## Destinos hacia la Raspberry

En Nginx Proxy Manager crea Proxy Hosts con el dominio público y estos destinos:

| Servicio | Forward Hostname / IP | Forward Port |
|---|---|---:|
| Servicio web de `pilla` | IP Tailscale de `pilla` | Puerto Tailscale Serve o servicio |

Usa la IP estable de Tailscale de `pilla`, no su IP LAN. Si el servicio ya se publica mediante `tailscale serve`, apunta al puerto local que escuche en la Pi. Para servicios que no estén en Tailscale Serve, publica el puerto en la Pi solo dentro de la Tailnet y apunta a ese puerto.

Los servicios que viven en Oracle deben usar el nombre del contenedor y su puerto interno solamente si Nginx comparte una red Docker con ellos; no se añade esa red a este stack por defecto porque la red `music-network` pertenece a la Pi y no existe en Oracle.

## Seguridad y verificación

- Permite `80/tcp` y `443/tcp` en la Security List/NSG de Oracle y en el firewall local.
- Mantén `8181`, `9001`, `3001` y DNS fuera de Internet; adminístralos por Tailscale.
- Comprueba desde una red externa que cada dominio obtiene el certificado correcto y llega al servicio previsto.
- No guardes credenciales de Nginx Proxy Manager ni certificados privados en Git.
- Antes de cortar el Nginx de la Pi, prueba un dominio de bajo riesgo y conserva el compose anterior para rollback.

Enlaces: [[OracleVps]] · [[Despliegue]] · [[Convenciones]] · [[000 - Index]]
