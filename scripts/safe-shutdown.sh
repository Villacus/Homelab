#!/bin/bash

# 1. Comprobar si somos root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

# 2. Comprobar si Docker está funcionando
if systemctl is-active --quiet docker; then
    echo "[INFO] Docker está activo. Iniciando parada elegante..."
    
    # Obtener lista de contenedores corriendo
    CONTAINERS=$(docker ps -q)
    
    if [ -n "$CONTAINERS" ]; then
        echo "[INFO] Deteniendo contenedores con un timeout de 60 segundos..."
        # Intentar parar contenedores con 60s de gracia
        docker stop -t 60 $CONTAINERS > /dev/null
        
        # 3. VERIFICACIÓN: ¿Queda alguno vivo?
        REMAINING=$(docker ps -q)
        if [ -n "$REMAINING" ]; then
            echo "[WARNING] No se han detenido todos los contenedores."
            read -r -p "¿Quieres forzar la detención y continuar con el apagado? [s/N]: " ANSWER
            case "$ANSWER" in
                [sS]|[sS][iI])
                    echo "[INFO] Forzando detención..."
                    docker kill $REMAINING
                    sleep 2
                    ;;
                *)
                    echo "[INFO] Cancelado. No se apagará el sistema."
                    exit 0
                    ;;
            esac
        else
            echo "[SUCCESS] Todos los contenedores se detuvieron correctamente."
        fi
    else
        echo "[INFO] No hay contenedores activos."
    fi
else
    echo "[INFO] Docker no está ejecutándose. Procediendo directamente."
fi

# 4. Apagado del sistema
echo "[INFO] Apagando el sistema ahora."
/sbin/shutdown -h now
