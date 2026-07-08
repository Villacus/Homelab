# Odysseus

Servicio self-hosted para busqueda y consulta local de informacion, apoyado por ChromaDB como base vectorial.

## Stack Docker
```yml
services:
  odysseus:
    image: ghcr.io/pewdiepie-archdaemon/odysseus:latest
    container_name: odysseus
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    ports:
      - "7000:7000"
    volumes:
      - /home/villacus/odysseus/data:/app/data
      - /home/villacus:/home/villacus
      - /mnt/nasdisk:/mnt/nasdisk
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - AUTH_ENABLED=false
      - CHROMADB_HOST=chromadb
      - CHROMADB_PORT=8000
      - SEARXNG_INSTANCE=
    depends_on:
      chromadb:
        condition: service_started
    restart: unless-stopped

  chromadb:
    image: docker.io/chromadb/chroma:latest
    container_name: odysseus_chromadb
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    volumes:
      - /home/villacus/odysseus/data/chromadb:/chroma/chroma
    environment:
      - ANONYMIZED_TELEMETRY=FALSE
    restart: unless-stopped
```

## Explicacion de la configuracion

### Servicio principal: odysseus
- **Imagen**: `ghcr.io/pewdiepie-archdaemon/odysseus:latest`
- **Contenedor**: `odysseus`
- **Puerto**: `7000`
- **URLs de acceso**:
  - Local: `192.168.0.9:7000`
  - Tailscale: `odysseus.tailf45616.ts.net`
- **Recursos**: 1 CPU y 512 MB de RAM
- **Dependencia**: `chromadb`

### Base vectorial: chromadb
- **Imagen**: `docker.io/chromadb/chroma:latest`
- **Contenedor**: `odysseus_chromadb`
- **Recursos**: 0.5 CPU y 256 MB de RAM
- **Volumen**: `/home/villacus/odysseus/data/chromadb:/chroma/chroma`
- **Funcion**: almacena embeddings e indices para consultas semanticas

### Volumenes del servicio odysseus
- `/home/villacus/odysseus/data:/app/data`: datos persistentes del servicio
- `/home/villacus:/home/villacus`: acceso a contenido del usuario en el host
- `/mnt/nasdisk:/mnt/nasdisk`: acceso a contenido del NAS

### Variables de entorno
- `AUTH_ENABLED=false`: autenticacion deshabilitada en esta configuracion
- `CHROMADB_HOST=chromadb`: host interno del servicio ChromaDB
- `CHROMADB_PORT=8000`: puerto interno de ChromaDB
- `SEARXNG_INSTANCE=`: opcion para integrar un buscador SearXNG externo (actualmente vacio)
- `ANONYMIZED_TELEMETRY=FALSE`: desactiva telemetria anonimizada en ChromaDB

### Red y resolucion del host
- `extra_hosts: host.docker.internal:host-gateway`: permite que el contenedor alcance servicios del host usando `host.docker.internal`

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico tras fallos o reinicio de Docker, salvo parada manual
