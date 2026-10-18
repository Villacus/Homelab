#!/bin/bash

# Configuración
API_URL="http://172.17.0.1:8083/"
MIN_CHARGE=20 # Umbral de batería en % para apagar

# Obtener el JSON de la API de forma silenciosa
DATA=$(curl -s "$API_URL")

# Si la API no responde, salimos para evitar falsos positivos
if [ -z "$DATA" ]; then
  exit 0
fi

# Extraemos los valores usando jq (las claves con puntos van entre comillas)
STATUS=$(echo "$DATA" | jq -r '."ups.status"')
CHARGE=$(echo "$DATA" | jq -r '."battery.charge"')

# Comprobamos si el estado NO contiene "OL" (Online) Y la batería es igual o menor al umbral
if [[ ! "$STATUS" =~ "OL" ]] && [ "$CHARGE" -le "$MIN_CHARGE" ]; then
    # Registramos el evento en el log del sistema
    logger "ALERTA UPS: Batería al ${CHARGE}%. Apagando el servidor..."
    
    # Lanzamos el apagado con 1 minuto de margen
    /sbin/shutdown -h +1 "Batería del UPS crítica. Apagado en 1 minuto."
fi
