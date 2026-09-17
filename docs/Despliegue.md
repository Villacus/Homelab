# Despliegue de Servicios

Este documento detalla el flujo de trabajo estándar para desplegar nuevos servicios o actualizar servicios existentes en el entorno de homelab.

## Prerrequisitos
- Acceso SSH configurado a la Raspberry Pi (pilla).
- [Docker](https://docs.docker.com/) instalado y configurado en la Pi.
- [Tailscale](https://tailscale.com/kb/) instalado para conectividad segura.
- [Glance](https://glance.nhat.dev/) configurado para el dashboard de monitorización.

## Flujo de Trabajo
1. **Preparación del Stack**: Crear o editar el archivo `docker-compose.yml` y el archivo `.env` correspondiente en `Compose/<StackName>/`.
2. **Preparación de Directorios**: Crear las carpetas de configuración necesarias en la Pi utilizando SSH:
   `ssh pilla "mkdir -p /home/villacus/<service>/config"`
3. **Sincronización**: Enviar los cambios al repositorio:
   `git add . && git commit -m "feat: ..." && git push`
4. **Despliegue**: Ejecutar el despliegue en la Pi:
   `ssh pilla "docker compose -f /home/villacus/Homelab/Compose/<StackName>/docker-compose.yml up -d"`
5. **Exposición (Tailscale)**: Si el servicio debe ser accesible externamente, configurar el túnel:
   - Añadir la siguiente línea al script `/home/villacus/tailscale`:
     ```bash
     tailscale serve --bg --https 443 --service=svc:<nombre> 127.0.0.1:<puerto>
     ```
   - Ejecutar el comando en la Pi.
   - Aprobar el nuevo túnel en el panel de administración de Tailscale.
6. **Monitorización**: Actualizar el dashboard de Glance si es un servicio nuevo.
