services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    environment:
      - HOMEPAGE_ALLOWED_HOSTS=${HOMEPAGE_ALLOWED_HOSTS}
    volumes:
      - ${HOMEPAGE_DATA_PATH}:/app/config
      - ${DOCKER_SOCKET}:/var/run/docker.sock:ro
      - ${NAS_PATH}:/mnt/nasdisk:ro
    ports:
      - ${APP_PORT}:3000
    restart: unless-stopped


name: immich

services:
  immich-server:
    image: ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}
    container_name: immich_server
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
    image: docker.io/valkey/valkey:9@sha256:3b55fbaa0cd93cf0d9d961f405e4dfcc70efe325e2d84da207a0a8e6d8fde4f9
    container_name: immich_redis
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: redis-cli ping || exit 1
    restart: always

  database:
    image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
    container_name: immich_postgres
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


services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    environment:
      - TZ=${TZ}
      - NMUSICFOLDER=/music
      - DATAFOLDER=/data
    ports:
      - "${NAVIDROME_PORT}:4533"
    volumes:
      - ${NAVIDROME_DATA_PATH}:/data
      - ${NAVIDROME_MUSIC_PATH}:/music:ro
    user: ${NAVIDROME_UID}:${NAVIDROME_GID}
    restart: unless-stopped



services:
  db:
    image: postgres:16-alpine
    container_name: nextcloud_db
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    environment:
      - POSTGRES_DB=${NC_DB_NAME}
      - POSTGRES_USER=${NC_DB_USER}
      - POSTGRES_PASSWORD=${NC_DB_PASSWORD}
    volumes:
      - ${NEXTCLOUD_PATH}/db:/var/lib/postgresql/data
    restart: always


  redis:
    image: redis:alpine
    container_name: nextcloud_redis
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: always

  app:
    image: nextcloud:33.0.5-apache
    container_name: nextcloud_app
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
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
    volumes:
      - ${NEXTCLOUD_PATH}/html:/var/www/html
      - ${NAS_PATH}/privada:/mnt/privada:rw
      - ${NAS_PATH}/compartida:/mnt/compartida:rw
    ports:
      - ${NEXTCLOUD_PORT}:80
    depends_on:
      - db
      - redis
    restart: always


  cron:
    image: nextcloud:33.0.5-apache
    container_name: nextcloud_cron
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    volumes:
      - ${NEXTCLOUD_PATH}/html:/var/www/html
    entrypoint: /cron.sh
    depends_on:
      - db
    restart: always




services:
  unbound:
    container_name: unbound
    image: klutchell/unbound:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    volumes:
      - ${UNBOUND_PATH}/config:/etc/unbound/
    ports:
      - "5353:53/udp"
      - "5353:53/tcp"
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



services:
  samba:
    image: dperson/samba
    container_name: samba
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: unless-stopped
    stdin_open: true
    tty: true
    ports:
      - "137:137/udp"
      - "138:138/udp"
      - "139:139/tcp"
      - "445:445/tcp"
    volumes:
      - ${NAS_PATH}/privada:/mnt/privada
      - ${NAS_PATH}/compartida:/mnt/compartida
    command:
      - "-u"
      - "${SAMBA_USER1};${SAMBA_PASS1};${SAMBA_UID};users"
      - "-u"
      - "${SAMBA_USER2};${SAMBA_PASS2}"
      - "-s"
      - "Privada;/mnt/privada;yes;no;no;${SAMBA_USER1}"
      - "-s"
      - "Compartida;/mnt/compartida;yes;no;no;${SAMBA_USER2}"
      - "-p"
      - "-n"
    environment:
      - TZ=${TZ}
      - WORKGROUP=${WORKGROUP}



services:
  speedtest:
    image: openspeedtest/latest
    container_name: speedtest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    ports:
      - ${SPEEDTEST_PORT}:3000
    restart: unless-stopped


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