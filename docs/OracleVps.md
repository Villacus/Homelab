La VPS de Oracle funciona actualmente como nodo público independiente del homelab de `pilla`. No debe sustituir al NAS ni convertirse en la única copia de los datos.

## Inventario actual

**Estado comprobado el 20 de octubre de 2026 mediante SSH.**

| Recurso | Valor |
|---|---|
| Hostname | `pihole-vnic` |
| Sistema | Ubuntu 26.04.1 LTS |
| CPU | 4 vCPU |
| Memoria | 23 GiB |
| Disco raíz | 96 GiB, 64 GiB libres |
| Tailscale | `100.69.90.84`, ofrece exit node |
| Compose del host | `/home/ubuntu/Homelab/Compose/` |
| Gestión Docker | Arcane Agent en `9001` (contenedor `3553`) |

### Contenedores montados

| Servicio | Imagen | Puerto publicado | Persistencia observada |
|---|---|---:|---|
| Satisfactory | `satisfactory-satisfactory-server` | `7777/tcp`, `7777/udp`, `8888/tcp` | `/home/ubuntu/Homelab/Compose/Satisfactory/config` |
| Minecraft | `itzg/minecraft-server` | `25565/tcp` | `/home/ubuntu/Minecraft/data` |
| Uptime Kuma | `louislam/uptime-kuma:2` | `3001/tcp` | `/home/villacus/uptime-kuma/config` |
| Pi-hole | `pihole/pihole:latest` | `53/tcp`, `53/udp`, `80/tcp` | `/home/ubuntu/etc-pihole` |
| Arcane Agent | `ghcr.io/getarcaneapp/agent:latest` | `9001/tcp` | Volumen Docker `arcane-agent_arcane-data` |

La VPS también tiene SSH en `22` y HTTPS en `443`; esos listeners no se atribuyen aquí a un contenedor sin revisar su configuración concreta.

## Qué debe permanecer en la VPS

- **Satisfactory y Minecraft**: son el uso principal de la VPS y no dependen del NAS de `pilla`. Mantener solo los juegos que realmente estén en uso y vigilar RAM, CPU, disco y latencia de los guardados.
- **Uptime Kuma**: conservarlo como monitor externo de `pilla`. Es especialmente útil porque puede avisar cuando la conexión doméstica o la Raspberry deja de responder.
- **Arcane Agent**: mantenerlo únicamente para administración privada. El socket de Docker equivale a control total del host; no publicar su panel o API en Internet.
- **Pi-hole**: usarlo como resolver privado o dentro de Tailscale, no como DNS recursivo público. El Pi-hole principal de la LAN continúa siendo el de `pilla`.

## Qué no mover todavía

No desplegar aquí Immich, Nextcloud, Paperless, Jellyfin/ARR, Samba o qBittorrent. Dependen del NAS, tienen más estado y consumen almacenamiento o ancho de banda. Los 96 GiB de disco no son una base suficiente para fotos, medios o copias únicas.

Vaultwarden podría migrarse más adelante, pero solo después de probar un backup y una restauración completa, configurar HTTPS y conservar un rollback en `pilla`. No debe tratarse como un `docker compose up` normal.

## Exposición de red

La publicación Docker no equivale a una política de firewall. En Oracle y en el firewall del sistema:

- Permitir `25565/tcp` solo si Minecraft debe ser público.
- Permitir `7777/udp` (y únicamente los puertos adicionales necesarios) solo si Satisfactory debe ser público.
- Mantener `22` limitado a Tailscale o a una IP administrativa conocida; usar claves y desactivar el acceso por contraseña y de root.
- Cerrar `53/tcp` y `53/udp` hacia Internet. Un Pi-hole abierto puede convertirse en un resolver abusado para amplificación DNS.
- Cerrar `3001`, `8888` y `9001` hacia Internet. Acceder a monitorización y administración mediante Tailscale o un reverse proxy autenticado.
- Publicar `80/443` solo para el servicio web que se haya elegido explícitamente. No usar esos puertos para exponer paneles de administración.
- El reverse proxy público de Nginx Proxy Manager está documentado en [[NginxOracle]]; Pi-hole conserva `network_mode: host`, pero Nginx usa bridge y no debe reclamar ese modo.

No activar el exit node de Tailscale para más usuarios hasta definir ACLs y confirmar que se desea convertir la VPS en puerta de salida de la tailnet.

## Orden recomendado

1. Confirmar en Oracle la Security List/NSG y el firewall local; dejar una sesión SSH abierta y comprobar la consola de recuperación.
2. Reducir la superficie pública a los puertos de juego realmente necesarios.
3. Configurar Uptime Kuma para monitorizar `pilla` por Tailscale y añadir avisos de caída, disco, RAM y CPU.
4. Configurar backup externo de los mundos de Minecraft y Satisfactory; un snapshot de Oracle no sustituye un backup independiente.
5. Mantener `pilla` como nodo de datos y multimedia, y la VPS como nodo de juegos, monitorización y servicios públicos pequeños.
6. Antes de añadir otro servicio, comprobar compatibilidad de la imagen con la arquitectura de la VPS y reservar margen de disco.

## Relación con el homelab

- Nodo doméstico y datos: [[00 - ServidorPi]]
- Catálogo de servicios: [[Servicios]]
- Despliegue y verificación: [[Despliegue]]
- Backups y restauración: [[Respaldo]]
