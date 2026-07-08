# Vaultwarden

Gestor de contrasenas self-hosted compatible con clientes Bitwarden.

## Stack Docker
```yml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    restart: unless-stopped
    volumes:
      - ./vw-data:/data
    environment:
      - DOMAIN=https://vaultwarden.${TS_TAILNET}.ts.net
      - SIGNUPS_ALLOWED=true
      - ADMIN_TOKEN=${ADMIN_TOKEN}
    ports:
      - "127.0.0.1:8080:80"
```

## Explicacion de la configuracion

### Servicio principal: vaultwarden
- **Imagen**: `vaultwarden/server:latest`
- **Contenedor**: `vaultwarden`
- **Recursos**: 0.5 CPU y 256 MB de RAM
- **URLs de acceso**:
  - Local: `192.168.0.9:8080`
  - Tailscale: `vaultwarden.tailf45616.ts.net`

### Puertos y exposicion
- `127.0.0.1:8080:80`: el servicio se publica solo en loopback del host
- Esto reduce superficie de ataque, pero requiere proxy/reenvio para acceso desde otros equipos

### Volumen persistente
- `./vw-data:/data`: guarda base de datos, adjuntos y configuracion de Vaultwarden

### Variables de entorno
- `DOMAIN=https://vaultwarden.${TS_TAILNET}.ts.net`: dominio canonico de la instancia
- `SIGNUPS_ALLOWED=true`: permite registro de nuevas cuentas
- `ADMIN_TOKEN=${ADMIN_TOKEN}`: token de administracion (debe venir desde `.env`)

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico tras fallo o reinicio de Docker, salvo parada manual
