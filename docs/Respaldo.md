El sistema de copias de seguridad del homelab sigue la estrategia 3-2-1, utilizando un almacenamiento secundario local (NAS montado en `/mnt/nasdisk`) y almacenamiento en la nube (Oracle Object Storage).

## Estrategia

- **Local (3-2-1)**: Se realiza un backup diario automático de bases de datos, configuraciones y datos mediante el script `backup.sh`. Todo se almacena en el NAS local.
- **Nube (3-2-1)**: Se realiza el upload cifrado de los archivos críticos (dumps de bases de datos y configuraciones) a Oracle Object Storage usando `rclone`.

## Ejecución

El script automatizado se encuentra en: `/home/villacus/Homelab/scripts/backup.sh`.

### Automatización

Se ejecuta diariamente a las 3:00 AM mediante cron en la Raspberry Pi (`pilla`):

```bash
0 3 * * * /home/villacus/Homelab/scripts/backup.sh
```

### Ejecución Manual

Para ejecutar el respaldo manualmente:

```bash
ssh pilla
/home/villacus/Homelab/scripts/backup.sh
```

## Nube (Oracle Object Storage)

Se utiliza `rclone` para sincronizar exclusivamente los archivos críticos cifrados (`*.zst.gpg`) al bucket `homelab-backups`.

### Configuración
1. Instalar `rclone` (`sudo apt install rclone`).
2. Configurar el remoto llamado `oracle` (`rclone config`) usando las credenciales S3 generadas en el panel de Oracle.
3. **Endpoint**: `https://<NAMESPACE>.compat.objectstorage.<REGION>.oraclecloud.com`.

### Automatización Cloud
La subida está integrada en el script `backup.sh`:

```bash
rclone copy "$BACKUP_DIR" "oracle:homelab-backups/$DATE" \
    --include='*.zst.gpg' \
    --checkers=2 \
    --transfers=1 \
    --bwlimit=2M
```

## Recuperación

1. Los archivos críticos están cifrados con `gpg` usando la contraseña guardada en `/home/villacus/.backup_pass`.
2. Para descifrar un archivo:
   ```bash
   gpg --batch --pinentry-mode loopback --passphrase-file /home/villacus/.backup_pass --decrypt archivo.zst.gpg | zstd -dc > archivo_descomprimido
   ```

## Estructura de Backup

Los backups se organizan por fecha en `/mnt/nasdisk/backups/homelab/YYYY-MM-DD/`.

