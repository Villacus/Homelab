# Navidrome

Servidor de música **open-source** compatible con Subsonic. Permite transmitir música en streaming desde tu biblioteca privada con soporte para navegadores web y aplicaciones móviles. Alternativa privada a servicios como Spotify.

## Stack Docker
```yml
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    user: ${NAVIDROME_UID}:${NAVIDROME_GID}
    ports:
      - "${NAVIDROME_PORT}:4533"
    environment:
      - TZ=${TZ}
      - NMUSICFOLDER=/music
      - DATAFOLDER=/data
    restart: unless-stopped
    volumes:
      - ${NAVIDROME_DATA_PATH}:/data
      - ${NAVIDROME_MUSIC_PATH}:/music:ro

```

## Explicación de la configuración

### Servicio Principal: navidrome
- **Imagen**: `deluan/navidrome:latest` - Servidor de streaming de música open-source
- **Contenedor**: `navidrome`
- **Puerto**: `${NAVIDROME_PORT}` - API y interfaz web
- **URLs de acceso**:
  - Local: `192.168.0.9:${NAVIDROME_PORT}`
  - Tailscale: `navidrome.tailf45616.ts.net`

### Recursos
- **Límites**: 0.5 CPUs y 256 MB de RAM - Suficiente para servir música en streaming sin codificación pesada

### Usuario
- **user: ${NAVIDROME_UID}:${NAVIDROME_GID}** - Ejecuta el contenedor como usuario no root

### Volúmenes
- `${NAVIDROME_DATA_PATH}:/data` - Almacena configuración, base de datos de Navidrome y cache de portadas de álbumes
- `${NAVIDROME_MUSIC_PATH}:/music:ro` - Biblioteca de música en read-only (punto de montaje donde se escanean las canciones)

### Variables de entorno
- `NAVIDROME_PORT`: puerto publicado por la interfaz web
- `NAVIDROME_UID`: UID con el que corre el contenedor
- `NAVIDROME_GID`: GID con el que corre el contenedor
- `NAVIDROME_DATA_PATH`: ruta de datos persistentes
- `NAVIDROME_MUSIC_PATH`: ruta de la biblioteca musical
- `TZ`: zona horaria del servicio
- `NMUSICFOLDER`: carpeta interna de musica
- `DATAFOLDER`: carpeta interna de datos

### Ejemplo de archivo .env
```env
NAVIDROME_PORT=4533
NAVIDROME_UID=1000
NAVIDROME_GID=1000
NAVIDROME_DATA_PATH=/home/villacus/navidrome
NAVIDROME_MUSIC_PATH=/mnt/nasdisk/privada/Musica
TZ=Europe/Madrid
```

### Estrategia de Reinicio
- **restart: unless-stopped** - Se reinicia automáticamente si falla o si Docker se reinicia (excepto si fue detenido manualmente)
