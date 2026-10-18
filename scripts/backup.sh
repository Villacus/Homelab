#!/bin/bash

# ==============================================================================
# Homelab Backup Script (Comprimido y Cifrado)
# ==============================================================================

BACKUP_ROOT="/mnt/nasdisk/backups/homelab"
PASS_FILE="/home/villacus/.backup_pass"
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$BACKUP_ROOT/$DATE"

mkdir -p "$BACKUP_DIR"

echo "Iniciando backup: $DATE"

# Función para backup cifrado y comprimido
# Se usa zstd -1 para minimizar el uso de CPU en la Raspberry Pi
encrypt_backup() {
    local outfile=$1
    zstd -1 | gpg --batch --passphrase-file "$PASS_FILE" -c > "$BACKUP_DIR/$outfile.zst.gpg"
}

# 1. Dumps de DB (Cifrados)
echo "Dumping DBs..."
docker exec "immich_postgres" pg_dump -U "postgres" "immich" | encrypt_backup "immich_dump"
docker exec "nextcloud_db" pg_dump -U "nextcloud" "nextcloud" | encrypt_backup "nextcloud_dump"

# 2. Configuraciones (Tar + Cifrado)
echo "Respaldando configuraciones..."
tar -cf - /home/villacus/vaultwarden /home/villacus/etc-pihole /home/villacus/unbound /home/villacus/nextcloud/config | encrypt_backup "configs.tar"

# 3. Sincronización volúmenes pesados (Rsync SIN CIFRAR para velocidad)
echo "Sincronizando Immich (Fotos)..."
rsync -av --delete /mnt/nasdisk/privada/Media/immich "$BACKUP_DIR/immich_data"

echo "Backup finalizado y cifrado en: $BACKUP_DIR"

# Subida a la nube
echo "Subiendo backups críticos a Oracle..."
rclone copy "$BACKUP_DIR" "oracle:homelab-backups/$DATE" \
    --include='*.zst.gpg' \
    --checkers=2 \
    --transfers=1 \
    --bwlimit=2M
