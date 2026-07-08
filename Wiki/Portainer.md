# Portainer

Panel web para administrar Docker (contenedores, imagenes, volumenes, redes y stacks) desde una interfaz grafica.

## Stack Docker
```yml
services:
  portainer:
    container_name: portainer
    image: portainer/portainer-ce:sts
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    ports:
      - 9000:9000

volumes:
  portainer_data:
    name: portainer_data

networks:
  default:
    name: portainer_network
```

## Explicacion de la configuracion

### Servicio principal: portainer
- **Imagen**: `portainer/portainer-ce:sts`
- **Contenedor**: `portainer`
- **Puerto**: `9000:9000`
- **URLs de acceso**:
  - Local: `192.168.0.9:9000`
  - Tailscale: `portainer.tailf45616.ts.net`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **Puertos internos adicionales**: `8000` y `9443` expuestos por la imagen, aunque no publicados en el host

### Volumenes
- `/var/run/docker.sock:/var/run/docker.sock`: permite a Portainer gestionar el Docker del host
- `portainer_data:/data`: persistencia de configuracion, usuarios y endpoints

### Volumen nombrado
- `portainer_data`: volumen dedicado para mantener datos entre reinicios y actualizaciones

### Red
- `portainer_network`: red por defecto del stack para aislamiento logico del servicio

### Estrategia de reinicio
- **restart: always**: reinicio automatico si el contenedor falla o cuando Docker se reinicia
