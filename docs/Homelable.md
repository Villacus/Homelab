# Homelable

Homelable es una herramienta para desplegar y gestionar aplicaciones y servicios en el homelab. Su stack está configurado bajo la ruta `Compose/Homelable/`.

## Configuración y Despliegue

Sigue los estándares definidos en [[Convenciones]] y [[Despliegue]].

- **Puerto:** `3000` (definido en `.env` mediante `HOMELABLE_PORT`)
- **Ruta de configuración:** `/home/villacus/homelable/config`
- **Red:** Por defecto, bridge del proyecto.

Para desplegar manualmente:
```bash
ssh pilla "mkdir -p /home/villacus/homelable/config"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Homelable/.env -f /home/villacus/Homelab/Compose/Homelable/docker-compose.yml up -d"
```

Enlaces: [[Servicios]] · [[Despliegue]] · [[Convenciones]] · [[000 - Index]]
