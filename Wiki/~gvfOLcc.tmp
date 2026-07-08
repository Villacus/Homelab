# Pi-hole

Bloqueador de anuncios y rastreadores a nivel de red, combinado con Unbound como resolvedor DNS recursivo local para mejorar privacidad.

## Stack Docker
```yml
services:
  unbound:
    container_name: unbound
    image: klutchell/unbound:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    ports:
      - "5353:53/udp"
      - "5353:53/tcp"
    volumes:
      - /home/villacus/unbound/config:/etc/unbound/
    restart: unless-stopped

  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    network_mode: host
    environment:
      TZ: ${TZ}
      FTLCONF_webserver_api_password: ${PIHOLE_API_PASSWORD}
    volumes:
      - ${PIHOLE_PATH}:/etc/pihole
    cap_add:
      - NET_ADMIN
      - SYS_TIME
      - SYS_NICE
    depends_on:
      - unbound
    restart: unless-stopped
```

## Explicacion de la configuracion

### Servicio DNS recursivo: unbound
- **Imagen**: `klutchell/unbound:latest`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **Puertos**:
  - `5353:53/udp`
  - `5353:53/tcp`
- **Volumen**: `/home/villacus/unbound/config:/etc/unbound/`
- **Funcion**: resuelve DNS de forma recursiva local para que Pi-hole no dependa de DNS publicos externos

### Servicio principal: pihole
- **Imagen**: `pihole/pihole:latest`
- **Recursos**: 0.5 CPU y 256 MB de RAM
- **Modo de red**: `network_mode: host`
  - Pi-hole escucha directamente en la red del host, necesario para servir DNS a toda la LAN
- **URLs de acceso (panel web)**:
  - Local: `192.168.0.9/admin`
  - Tailscale: `pihole.tailf45616.ts.net/admin`

### Integracion Pi-hole -> Unbound
- Flujo DNS: Cliente -> Pi-hole -> Unbound -> root DNS/internet

### Volumenes de Pi-hole
- `${PIHOLE_PATH}:/etc/pihole`: persistencia de configuracion, listas y base de datos de Pi-hole

### Capacidades especiales
- `NET_ADMIN`: reglas de red necesarias para funciones DNS/DHCP
- `SYS_TIME`: permite ajustes de hora dentro del contenedor
- `SYS_NICE`: permite ajustar prioridades de procesos

### Variables de entorno
- `TZ`: zona horaria del servicio
- `FTLCONF_webserver_api_password`: contrasena del panel/API de Pi-hole
- `PIHOLE_PATH`: ruta de persistencia de Pi-hole
- `PIHOLE_API_PASSWORD`: contrasena del panel/API de Pi-hole

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico tras fallos o reinicio de Docker, salvo parada manual

