Obsidian se despliega mediante el stack `Compose/Obsidian/` usando la imagen de LinuxServer.

## Persistencia

La configuración se guarda en `/home/villacus/obsidian` en la Raspberry Pi y se monta en `/config` dentro del contenedor. El directorio debe existir antes del primer despliegue:

```bash
ssh pilla "mkdir -p /home/villacus/obsidian"
```

## Puertos

- `3003`: interfaz HTTP.
- `3004`: interfaz HTTPS.

Los puertos del host se pueden cambiar en `Compose/Obsidian/.env` sin modificar el Compose.

## Despliegue

Desde la Raspberry Pi, ejecuta el stack con sus variables de entorno:

```bash
docker compose --env-file /home/villacus/Homelab/Compose/Obsidian/.env \
  -f /home/villacus/Homelab/Compose/Obsidian/docker-compose.yml up -d
```

Comprueba el estado con `docker compose ps` y consulta los logs si el contenedor no inicia correctamente.
