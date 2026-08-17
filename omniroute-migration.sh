#!/bin/bash
# Script para crear backup de OmniRoute y copiarlo al servidor Pi

set -e

echo "=== Backup y migración de OmniRoute a pilla ==="
echo

# Crear backup
BACKUP_FILE="omniroute-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "1. Creando backup en /home/villacus/$BACKUP_FILE..."
cd /home/villacus
tar czf "$BACKUP_FILE" .omniroute/
echo "   ✓ Backup creado ($(du -h "$BACKUP_FILE" | cut -f1))"
echo

# Copiar a Pi
echo "2. Copiando backup a pilla:/tmp/..."
scp "$BACKUP_FILE" villacus@pilla:/tmp/
echo "   ✓ Backup copiado"
echo

# Instrucciones para ejecutar en Pi
echo "3. Ahora ejecuta estos comandos en pilla:"
echo
echo "   ssh villacus@pilla"
echo "   mkdir -p /home/villacus/omniroute/data"
echo "   cd /home/villacus/omniroute/data"
echo "   tar xzf /tmp/$BACKUP_FILE --strip-components=1"
echo "   ls -lh storage.sqlite .env"
echo "   rm /tmp/$BACKUP_FILE"
echo
echo "4. Después, desde Arcane, despliega el stack OmniRoute"
echo
echo "✓ Backup local guardado en: /home/villacus/$BACKUP_FILE"
