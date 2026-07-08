# Immich

Solución **open-source** de almacenamiento y gestión de fotos/videos. Proporciona una alternativa privada a servicios en la nube como Google Fotos.

## Stack Docker
```yml
name: immich

services:
  immich-server:
    container_name: immich_server
    image: ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    volumes:
      - ${UPLOAD_PATH}:/data
      - ${LOCALTIME}:/etc/localtime:ro
    ports:
      - '2283:2283'
    depends_on:
      - redis
      - database
    restart: always
    healthcheck:
      disable: false

  redis:
    container_name: immich_redis
    image: docker.io/valkey/valkey:9@sha256:3b55fbaa0cd93cf0d9d961f405e4dfcc70efe325e2d84da207a0a8e6d8fde4f9
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: redis-cli ping || exit 1
    restart: always

  database:
    container_name: immich_postgres
    image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_DB: ${DB_DATABASE_NAME}
      POSTGRES_INITDB_ARGS: '--data-checksums'
      DB_STORAGE_TYPE: 'HDD'
    volumes:
      - ${DB_DATA_PATH}:/var/lib/postgresql/data
    shm_size: 128mb
    restart: always
    healthcheck:
      disable: false

volumes:
  model-cache:
```

## Explicación de la configuración

### Servicio Principal: immich-server
- **Imagen**: `ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}` - Servidor principal de Immich
- **Puerto**: `2283` - API y interfaz web
- **Recursos**: 1 CPU y 512 MB de RAM
- **Volúmenes**:
  - `${UPLOAD_PATH}:/data` - Almacena las fotos y videos subidos
  - `${LOCALTIME}:/etc/localtime:ro` - Sincroniza zona horaria del contenedor con el host
- **Dependencias**: Requiere Redis y base de datos para funcionar
- **Healthcheck**: Habilitado para detectar fallos automáticamente

### Caché: redis (Valkey)
- **Imagen**: `valkey:9` (Valkey es un fork de Redis)
- **Recursos**: 0.25 CPUs y 128 MB de RAM
- **Función**: Cache de sesiones y datos en memoria para mejorar rendimiento
- **Healthcheck**: Verifica que el servicio responda correctamente con `redis-cli ping`

### Base de Datos: PostgreSQL
- **Imagen**: PostgreSQL 14 con extensiones vectoriales (`vectorchord` y `pgvectors`)
- **Recursos**: 0.5 CPU y 256 MB de RAM
- **Entorno**:
  - `POSTGRES_PASSWORD`, `POSTGRES_USER`, `POSTGRES_DB` - Credenciales de base de datos (desde variables de entorno)
  - `POSTGRES_INITDB_ARGS: '--data-checksums'` - Habilita verificación de integridad de datos
  - `DB_STORAGE_TYPE: 'HDD'` - Optimización para discos duros (mejor que SSD)
- **Volúmenes**: `${DB_DATA_PATH}:/var/lib/postgresql/data` - Almacena datos de la BD
- **SHM Size**: 128 MB de memoria compartida (necesaria para operaciones grandes de PostgreSQL)
- **Healthcheck**: Habilitado para monitorear estado de la BD

### Variables de Entorno Requeridas
- `IMMICH_VERSION` - Versión de Immich (por defecto: `release`)
- `UPLOAD_PATH` - Ruta donde se almacenan fotos/videos
- `LOCALTIME` - Enlace al fichero localtime del host
- `DB_PASSWORD` - Contraseña de PostgreSQL
- `DB_USERNAME` - Usuario de PostgreSQL
- `DB_DATABASE_NAME` - Nombre de la base de datos
- `DB_DATA_PATH` - Ruta de almacenamiento de datos de PostgreSQL

### Estrategia de Reinicio
- **restart: always** - Se reinicia automáticamente siempre que el contenedor se detiene o falla
