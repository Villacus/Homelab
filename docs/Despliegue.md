# Despliegue de Servicios

Este documento detalla el flujo de trabajo estándar para desplegar nuevos servicios o actualizar servicios existentes en el entorno de homelab.

## Prerrequisitos
- Acceso SSH configurado a la Raspberry Pi (pilla).
- [Docker](https://docs.docker.com/) instalado y configurado en la Pi.
- [Tailscale](https://tailscale.com/kb/) instalado para conectividad segura.
- [Glance](https://glance.nhat.dev/) configurado para el dashboard de monitorización.

## Guías específicas

- [[Musikat]] — requisitos del stack musical, NAS, Navidrome y BuildKit.
- [[Glance]] — edición del dashboard que vive en la Pi.

## Documentación obligatoria

Cualquier cambio operativo, servicio, configuración, script, integración o
procedimiento que se cree o modifique y que necesite explicación debe quedar
documentado en este sistema de `docs/`. Crea o actualiza el documento
correspondiente, enlázalo mediante `[[wikilink]]` desde [[000 - Index]] y añade
enlaces cruzados desde las guías relacionadas. No dejes instrucciones
importantes únicamente en commits, chats, archivos de configuración o memoria
personal.

Los documentos nuevos deben seguir las convenciones de la vault: nombres
PascalCase, ubicación dentro de `docs/`, navegación mediante wikilinks y sin
secretos ni credenciales reales. Si el cambio afecta al despliegue, actualiza
también esta guía o enlaza desde ella el procedimiento específico.

## Nginx Proxy Manager en Oracle

Para la migración pública consulta [[NginxOracle]]. En Oracle, Pi-hole usa `network_mode: host`, pero Nginx Proxy Manager usa red bridge y publica `80/443`; no deben compartir `host mode`. El panel de Nginx permanece en `8181` y no se expone a Internet.

## Red compartida y Nginx Proxy Manager

Navidrome, Musikat y Nginx Proxy Manager comparten la red externa
`music-network`. Créala una sola vez en la Pi antes de desplegar los stacks:

```bash
ssh pilla "docker network inspect music-network >/dev/null 2>&1 || docker network create --driver bridge music-network"
ssh pilla "docker network inspect music-network"
```

Los tres `.env` deben conservar `MUSIC_NETWORK=music-network`. Comprueba la
red en la Pi con `docker network inspect music-network`; Compose no la crea ni
la elimina porque está declarada como `external: true`.

Crea los directorios persistentes de Nginx Proxy Manager y despliega en este
orden:

```bash
ssh pilla "mkdir -p /home/villacus/nginx/data /home/villacus/nginx/letsencrypt"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Navidrome/.env -f /home/villacus/Homelab/Compose/Navidrome/docker-compose.yml up -d"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Musikat/.env -f /home/villacus/Homelab/Compose/Musikat/docker-compose.yml up -d"
ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/Nginx/.env -f /home/villacus/Homelab/Compose/Nginx/docker-compose.yml up -d"
```

Nginx publica puertos alternativos porque Pi-hole conserva el puerto 80:

| Uso | Host | Contenedor |
|---|---:|---:|
| Proxy HTTP | 8084 | 80 |
| Proxy HTTPS | 8444 | 443 |
| Panel de administración | 8181 | 81 |

En la interfaz de Nginx Proxy Manager (`http://192.168.0.9:8181`) crea los
Proxy Hosts con estos destinos internos, que solo funcionan cuando los tres
contenedores están en `music-network`:

- Navidrome: `http://navidrome:4533`
- Musikat: `http://musikat:8000`

El panel administrativo no debe exponerse por Tailscale sin controles de
acceso adicionales. La exposición remota del proxy debe apuntar al puerto de
host elegido (8084 o 8444), no al puerto interno 443. Los puertos publicados
de Navidrome y Musikat se mantienen durante esta transición para no romper el
acceso directo existente; su cierre queda para una fase posterior.

### Funnel público y rutas protegidas

La exposición pública prevista utiliza un único Funnel para
`https://pilla.tailf45616.ts.net` y conserva los `tailscale serve` existentes de
los demás servicios. No se debe ejecutar el Funnel hasta terminar la
configuración del Proxy Host y su Access List: Funnel es público y, sin la ACL,
publicaría la respuesta predeterminada de Nginx Proxy Manager.

La configuración persistente de Proxy Hosts, Access Lists y certificados se
realiza en la interfaz de Nginx Proxy Manager y permanece en
`/home/villacus/nginx/data`; no se exporta al repositorio ni se guardan aquí
contraseñas. Desde `http://192.168.0.9:8181`:

1. Cambia la contraseña inicial de la cuenta administradora y activa una
   contraseña larga y única para la Access List. No reutilices la contraseña
   del administrador.
2. Crea una Access List de tipo autenticación HTTP, con un usuario dedicado al
   acceso remoto. No añadas reglas `allow all` ni publiques el panel `:8181`.
3. Crea un único Proxy Host para `pilla.tailf45616.ts.net`. Como el Proxy Host
   exige un destino base aunque el tráfico útil vaya por Custom Locations, usa
   `127.0.0.1` como **Forward Hostname / IP** y `9` como **Forward Port**. Así
   una petición a `/` termina en un puerto local no utilizado y no muestra el
   panel ni un servicio. Activa **Block Common Exploits**, **Websocket Support**
   y asocia la Access List. El Funnel puede entregar HTTP al puerto `8084`; no
   apuntes el Funnel al panel `8181`.
4. En ese Proxy Host añade las Custom Locations `/navidrome/` y `/musikat/`.
   La interfaz separa el host y el puerto: para eliminar el prefijo, termina
   el valor del **Forward Hostname / IP** en `/`:

   | Ruta | Forward Hostname / IP | Forward Port |
   |---|---|---:|
   | `/navidrome/` | `navidrome/` | `4533` |
   | `/musikat/` | `musikat/` | `8000` |

   El valor debe empezar por el nombre del servicio, **sin `/` inicial**. La
   barra va únicamente al final: `navidrome/` y `musikat/`. Usa los puertos
   internos `4533` y `8000`, no los puertos publicados del host (`4533` y
   `8010`). NPM generará `proxy_pass http://navidrome:4533/` y
   `proxy_pass http://musikat:8000/`; la barra final hace que Nginx elimine el
   prefijo antes de reenviar la petición. En la configuración avanzada de cada
   ubicación añade únicamente su prefijo correspondiente:

   ```nginx
   proxy_set_header X-Forwarded-Prefix /navidrome;
   ```

   ```nginx
   proxy_set_header X-Forwarded-Prefix /musikat;
   ```

   Las cabeceras `Host`, `X-Forwarded-Proto`, `X-Forwarded-For` y
   `X-Real-IP` ya las genera Nginx Proxy Manager. La Access List asociada al
   Proxy Host protege también ambas Custom Locations.
5. Navidrome debe tener `ND_BASEURL=/navidrome` (sin barra final) para que su
   redirección inicial sea `/navidrome/app/` en lugar de `/app/`. Esta variable
   está en `Compose/Navidrome/.env` y se inyecta desde el Compose; no pongas la
   URL completa ni una barra final. Musikat debe conservar su puerto local
   `http://192.168.0.9:8010`.
6. Después de cambiar `ND_BASEURL`, recrea Navidrome y comprueba el acceso
   directo local `http://192.168.0.9:4533` y el Serve
   `https://navidrome.tailf45616.ts.net`. El acceso directo puede mostrar ahora
   enlaces bajo `/navidrome/`, porque Navidrome tiene un único BaseURL global;
   si necesitas que el acceso local funcione en la raíz y el Funnel bajo un
   prefijo simultáneamente, habrá que separar los Proxy Hosts o usar un host
   público dedicado. No cambies el valor sin probar ambos accesos.

Después de comprobar que el Proxy Host responde y que la ACL exige credenciales,
configura en la Pi el Funnel hacia el HTTP de Nginx. En este host el estado
actual de Tailscale contiene únicamente `serve` y no hay todavía un Funnel
activo; conserva una copia de ambos estados antes de aplicar el cambio:

```bash
ssh pilla "tailscale serve status > /tmp/serve-antes.txt"
ssh pilla "tailscale funnel status --json > /tmp/funnel-antes.json"
ssh pilla "tailscale funnel --bg 8084"
ssh pilla "tailscale funnel status"
```

Compara entonces `tailscale serve status` con la copia anterior: el cambio no
debe eliminar ni reemplazar las entradas Serve existentes. Si la versión
instalada muestra una colisión de listeners, detén el cambio y ejecuta
`ssh pilla "tailscale funnel reset"` para volver al estado sin Funnel. Comprueba
desde una red externa que una petición sin credenciales a `/navidrome/` y
`/musikat/` recibe `401`, que una petición autenticada funciona, que `/` no
muestra el panel y que `:8181` no aparece en el Funnel.

### Redeploy automático

El workflow `.github/workflows/deploy-arcane.yml` se ejecuta cuando hay un
`push` a `main` con cambios bajo `Compose/**`. Detecta qué stacks cambiaron y,
si están configurados los secretos necesarios, el runner entra en la Tailnet
con `TAILSCALE_AUTHKEY` y hace `POST` al webhook correspondiente de Arcane.
Arcane vuelve a desplegar ese stack.

El workflow contempla actualmente estos secretos de webhook:

```text
WEBHOOK_GLANCE
WEBHOOK_IMMICH
WEBHOOK_JELLYFIN_ARR
WEBHOOK_NAVIDROME
WEBHOOK_NEXTCLOUD
WEBHOOK_PAPERLESS_NGX
WEBHOOK_PIHOLE
WEBHOOK_SAMBA
WEBHOOK_SPEEDTEST
WEBHOOK_VAULTWARDEN
WEBHOOK_MUSIKAT
WEBHOOK_NGINX
```

Para cada stack que se quiera actualizar automáticamente:

1. Crea o importa el stack en Arcane y confirma que sus rutas, red y variables
   son correctas.
2. Crea en Arcane su webhook de redeploy y copia la URL sin publicarla.
3. En GitHub, abre `Settings → Secrets and variables → Actions` y guarda la
   URL como `WEBHOOK_<STACK>` usando exactamente el nombre del workflow.
4. Configura también `TAILSCALE_AUTHKEY`.
5. Haz un cambio controlado bajo `Compose/<Stack>/`, súbelo a `main` y verifica
   la ejecución del workflow y el estado del stack en Arcane.

El workflow no incluye actualmente Arcane, Komodo, Homepage ni OmniRoute. Un
cambio en esos stacks no activa un redeploy mediante este flujo. Los webhooks,
las claves y las credenciales son configuración externa: nunca deben escribirse
en Git ni en esta vault.

## Primer despliegue

El primer deploy no se realiza automáticamente solo por hacer `push`. Antes de
que exista la configuración de Arcane y GitHub Actions, el administrador debe:

1. Preparar `docker-compose.yml` y las variables en `Compose/<Stack>/`. No
   versionar credenciales; usa un `.env.example` sin secretos y configura el
   `.env` real en Arcane o en el gestor que corresponda.
2. Crear en la Pi las rutas persistentes necesarias:
   `ssh pilla "mkdir -p /home/villacus/<service>/config"`.
3. Crear o importar el stack en Arcane y ejecutar manualmente el primer deploy.
   Si Arcane todavía no gestiona ese stack, puede hacerse por SSH:
   `ssh pilla "docker compose --env-file /home/villacus/Homelab/Compose/<Stack>/.env -f /home/villacus/Homelab/Compose/<Stack>/docker-compose.yml up -d"`.
4. Verificar contenedores, logs, healthchecks, volúmenes y conectividad antes
   de dar el servicio por publicado.
5. Configurar el webhook de Arcane y los secretos de Actions según [[#Redeploy automático]].
6. Si el servicio debe exponerse por Tailscale, añadir una línea al archivo
   `/home/villacus/tailscale`, siguiendo [[Convenciones]]:
   ```bash
   tailscale serve --bg --https 443 --service=svc:<nombre> 127.0.0.1:<puerto>
   ```
   Ejecuta el comando en `pilla` y aprueba el nuevo túnel en el panel de
   administración de Tailscale.
7. Entrar por SSH en `pilla`, revisar la estructura existente de
   `/home/villacus/glance/glance.yml` y añadir el servicio siguiendo [[Glance]].
   Ese archivo vive fuera de este repositorio; no se debe inventar su formato.

## Flujo de trabajo posterior

Una vez configurado el primer deploy, el flujo normal es:

1. Editar el Compose y las variables no sensibles del stack.
2. Revisar que no haya secretos y hacer `git add`, commit y `git push` a `main`.
3. Si el cambio está bajo `Compose/**` y el stack tiene sus secretos
   configurados, GitHub Actions llama al webhook y Arcane hace el redeploy.
4. Revisar la ejecución de Actions, el estado del stack y el servicio publicado.
5. Actualizar manualmente Tailscale o Glance solo cuando cambie la exposición o
   la presentación del servicio.
