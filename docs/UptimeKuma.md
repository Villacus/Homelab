Uptime Kuma se despliega en el servidor Oracle para monitorizar la disponibilidad del servidor de casa y sus servicios mediante la red Tailscale.

## Configuración

El stack está en `Compose/UptimeKuma/`. La configuración persistente se guarda en `/home/villacus/uptime-kuma/config` y el panel se publica mediante el puerto definido en `UPTIME_KUMA_PORT`.

Después del primer despliegue, configura en Uptime Kuma los monitores apuntando a las direcciones Tailscale del servidor de casa. No guardes credenciales ni tokens en este repositorio.

## Redeploy automático

El workflow `.github/workflows/deploy-arcane.yml` detecta cambios en `Compose/UptimeKuma/**` y ejecuta el webhook de Arcane guardado en el secreto `WEBHOOK_UPTIME_KUMA`.
