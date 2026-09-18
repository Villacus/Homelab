# Convenciones de Configuración

Este documento establece las normas estándar para la configuración de servicios en el homelab. Seguir estas convenciones asegura la consistencia, facilita el despliegue automático y mejora la mantenibilidad de los stacks definidos en la [[Estructura]].

## Nombre del proyecto
```yaml
name: nombre-en-minusculas
```

## Variables de entorno (.env)

La configuración de cada servicio debe externalizarse mediante un archivo `.env` en el directorio del stack. Esto permite parametrizar comportamientos sin modificar el código fuente del `docker-compose.yml`.

```env
# General
TZ=Europe/Madrid
PUID=1000
PGID=1000

# Paths
SERVICE_CONFIG=/home/villacus/<service>/config

# Ports
SERVICE_PORT=XXXX
```

- `TZ`: Configurado obligatoriamente como `Europe/Madrid`.
- `PUID`/`PGID`: Se utilizan los valores `1000` para mantener consistencia con los permisos del host.
- Paths de configuración: Deben apuntar a `/home/villacus/<service>/`.
- Almacenamiento de datos/media: Deben residir en `/mnt/nasdisk/`.
- Puertos: Deben utilizar variables `<SERVICE>_PORT` para evitar conflictos.

## Nombres de Contenedores
Se deben definir nombres explícitos usando la directiva `container_name:` en el `docker-compose.yml`. Los nombres deben ser siempre en minúsculas, sin espacios. Para servicios que incluyen múltiples contenedores, se utiliza el guion bajo como separador (ej. `nextcloud_db`, `immich_server`).

## Límites de Recursos
Para garantizar la estabilidad del sistema, cada servicio debe tener definidos límites de recursos utilizando la directiva `deploy.resources`.

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```
Puedes consultar los niveles de recursos recomendados para cada servicio en [[Servicios]].

## Redes
- Por defecto, los servicios utilizan el *Default Project Bridge*.
- Para stacks complejos que requieren aislamiento o comunicación específica, se definen redes de tipo *bridge custom* (ej. `arrnet`, `paperless`).
- Cuando varios stacks necesitan comunicarse, se utiliza una red `bridge` externa con un nombre físico fijo. Debe crearse una sola vez antes del despliegue y declararse con `external: true`; todos los stacks deben usar exactamente el mismo valor en `name:`.
- Una red externa no la crea ni la elimina Compose. Los contenedores se descubren por su nombre de servicio (por ejemplo, `navidrome:4533` y `musikat:8000`), no por el puerto publicado en el host.
- Servicios que requieren acceso directo a la red del host, como `Pi-hole`, deben utilizar `network_mode: host`.

### Nginx Proxy Manager
- Nginx Proxy Manager utiliza el stack `Compose/Nginx/` y la red externa compartida con Navidrome y Musikat.
- Los puertos del host deben parametrizarse en `.env`. En la configuración actual son `8084` (HTTP), `8444` (HTTPS) y `8181` (panel); dentro del contenedor siguen siendo `80`, `443` y `81` respectivamente.
- El panel se configura desde la interfaz de Nginx Proxy Manager. Los Proxy Hosts de Navidrome y Musikat deben apuntar a `http://navidrome:4533` y `http://musikat:8000`.

## Volúmenes
- Se prefieren los *bind mounts* definidos con variables del archivo `.env` para facilitar la gestión.
- Los volúmenes nombrados deben limitarse exclusivamente a persistencia de bases de datos, como en el caso de `Redis`.
- Se debe aplicar el flag `:ro` para volúmenes que solo requieran acceso de lectura, como los de medios, `/etc/localtime` o el *Docker socket*.

## Políticas de Reinicio y Parada
- Se utiliza `unless-stopped` para la mayoría de los servicios para asegurar que se reinicien automáticamente si el contenedor se detiene, a menos que se apaguen manualmente.
- Para servicios críticos como `Vaultwarden`, `Immich` o `Pi-hole`, se utiliza la política `always` para garantizar su disponibilidad constante.
- Se debe definir un `stop_grace_period` de `30s` para servicios que manejan bases de datos, permitiendo una parada limpia y evitando la corrupción de datos.
