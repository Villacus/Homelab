# Nextcloud

Plataforma **open-source** de nube privada para archivos, sincronizacion, colaboracion y acceso remoto. Esta instalacion usa PostgreSQL, Redis y un contenedor dedicado para tareas cron.

## Stack Docker
```yml
services:
  db:
    container_name: nextcloud_db
    image: postgres:16-alpine
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    restart: always
    volumes:
      - ${NEXTCLOUD_PATH}/db:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=${NC_DB_NAME}
      - POSTGRES_USER=${NC_DB_USER}
      - POSTGRES_PASSWORD=${NC_DB_PASSWORD}

  redis:
    container_name: nextcloud_redis
    image: redis:alpine
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: always

  app:
    container_name: nextcloud_app
    image: nextcloud:33.0.5-apache
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    restart: always
    ports:
      - 8081:80
    volumes:
      - ${NEXTCLOUD_PATH}/html:/var/www/html
      - ${NAS_PATH}/privada:/mnt/privada:rw
      - ${NAS_PATH}/compartida:/mnt/compartida:rw
    environment:
      - POSTGRES_HOST=db
      - POSTGRES_DB=${NC_DB_NAME}
      - POSTGRES_USER=${NC_DB_USER}
      - POSTGRES_PASSWORD=${NC_DB_PASSWORD}
      - REDIS_HOST=redis
      - NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
      - NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}
      - NEXTCLOUD_TRUSTED_DOMAINS=192.168.0.9 nextcloud.tailf45616.ts.net
      - OVERWRITEPROTOCOL=https
      - OVERWRITEHOST=nextcloud.tailf45616.ts.net
      - TRUSTED_PROXIES=192.168.0.0/24
      - PHP_UPLOAD_LIMIT=2G
      - PHP_MEMORY_LIMIT=512M
    depends_on:
      - db
      - redis

  cron:
    container_name: nextcloud_cron
    image: nextcloud:33.0.5-apache
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: always
    volumes:
      - ${NEXTCLOUD_PATH}/html:/var/www/html
    entrypoint: /cron.sh
    depends_on:
      - db
```

## Explicacion de la configuracion

### Servicio principal: app
- **Imagen**: `nextcloud:33.0.5-apache`
- **Puerto**: `8081:80`
- **URLs de acceso**:
  - Local: `192.168.0.9:8081`
  - Tailscale: `nextcloud.tailf45616.ts.net`
- **Recursos**: 1 CPU y 512 MB de RAM
- **Dependencias**: `db` y `redis`

### Base de datos: db (PostgreSQL)
- **Imagen**: `postgres:16-alpine`
- **Recursos**: 1 CPU y 512 MB de RAM
- **Volumen**: `${NEXTCLOUD_PATH}/db:/var/lib/postgresql/data`
- **Funcion**: guarda toda la informacion estructurada de Nextcloud (usuarios, configuracion, metadatos)

### Cache y bloqueo de archivos: redis
- **Imagen**: `redis:alpine`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **Funcion**: mejora rendimiento y evita conflictos de bloqueo en archivos

### Tareas programadas: cron
- **Imagen**: `nextcloud:33.0.5-apache`
- **EntryPoint**: `/cron.sh`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **Funcion**: ejecuta tareas de mantenimiento (limpieza, indices, avisos, trabajos en segundo plano)

### Volumenes de datos
- `${NEXTCLOUD_PATH}/html:/var/www/html`: configuracion y datos de la instancia
- `${NAS_PATH}/privada:/mnt/privada:rw`: almacenamiento montado para archivos privados
- `${NAS_PATH}/compartida:/mnt/compartida:rw`: almacenamiento montado para archivos compartidos

### Variables clave de Nextcloud
- `NC_DB_NAME`: nombre de la base de datos de Nextcloud
- `NC_DB_USER`: usuario de PostgreSQL para Nextcloud
- `NC_DB_PASSWORD`: contrasena de PostgreSQL para Nextcloud
- `NEXTCLOUD_PORT`: puerto publicado por la aplicacion
- `NEXTCLOUD_PATH`: ruta base de la instalacion de Nextcloud
- `NAS_PATH`: ruta base del NAS montado
- `NEXTCLOUD_ADMIN_USER`: usuario administrador inicial
- `NEXTCLOUD_ADMIN_PASSWORD`: definirla en `.env` o gestor de secretos; no guardarla en texto plano
- `NEXTCLOUD_TRUSTED_DOMAINS`: dominios permitidos para acceder sin error de host no confiable
- `OVERWRITEPROTOCOL=https`: fuerza generacion de enlaces HTTPS
- `OVERWRITEHOST=nextcloud.tailf45616.ts.net`: host publico usado en enlaces y redirecciones
- `TRUSTED_PROXIES=192.168.0.0/24`: red de proxy confiable en LAN
- `PHP_UPLOAD_LIMIT=2G`: limite maximo de subida por archivo
- `PHP_MEMORY_LIMIT=512M`: memoria disponible para procesos PHP

### Estrategia de reinicio
- **restart: always**: reinicia los contenedores automaticamente si se caen o cuando Docker se reinicia

### Ejemplo de archivo .env
```env
NC_DB_NAME=nextcloud
NC_DB_USER=nextcloud
NC_DB_PASSWORD=cambia_esta_contrasena
NEXTCLOUD_PORT=8081
NEXTCLOUD_PATH=/home/villacus/nextcloud
NAS_PATH=/mnt/nasdisk
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=cambia_esta_contrasena
```

### Buenas practicas de secretos
- Anade `.env` al `.gitignore`
- Usa permisos restringidos en `.env` (por ejemplo: `chmod 600 .env`)
- Manten un `.env.example` sin secretos reales

