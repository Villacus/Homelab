# Speedtest

Servicio self-hosted para medir velocidad de red (descarga, subida y latencia) desde navegador, dentro de la infraestructura local.

## Stack Docker
```yml
services:
  speedtest:
    image: openspeedtest/latest
    container_name: speedtest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: unless-stopped
    ports:
      - ${SPEEDTEST_PORT}:3000
```

## Explicacion de la configuracion

### Servicio principal: speedtest
- **Imagen**: `openspeedtest/latest`
- **Contenedor**: `speedtest`
- **Puerto**: `${SPEEDTEST_PORT}:3000`
- **URLs de acceso**:
  - Local: `192.168.0.9:${SPEEDTEST_PORT}`
  - Tailscale: `speedtest.tailf45616.ts.net`

### Recursos
- **Limites**: 0.5 CPU y 128 MB de RAM
- Es suficiente para pruebas puntuales desde navegador en un homelab

### Variables de entorno
- `SPEEDTEST_PORT`: puerto publicado del servicio

### Uso recomendado
- Usarlo para validar rendimiento LAN/Wi-Fi y detectar cuellos de botella internos
- Si se usa remotamente por Tailscale, el resultado refleja tambien la calidad del enlace VPN

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico tras fallo o reinicio de Docker, salvo parada manual
