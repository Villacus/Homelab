Lista de proyectos técnicos para enriquecer conocimientos en administración de sistemas, redes, DevOps y seguridad, aprovechando la infraestructura actual.

---

## 🛠️ 1. Automatización e Infraestructura como Código (IaC)
*Conceptos clave: Idempotencia, aprovisionamiento, Configuration Management.*

- [ ] **Despliegue de la Pi con Ansible:**
  - Crear un playbook de Ansible que automatice la configuración inicial de `pilla`.
  - Debe automatizar: instalación de Docker, configuración del montaje de `/mnt/nasdisk`, creación de usuarios (`villacus`) y despliegue del agente de Komodo.
  - *Objetivo:* Poder replicar todo tu entorno en otra Pi (o si se corrompe la tarjeta SD) en un solo comando.

- [ ] **Copias de Seguridad Automatizadas (3-2-1):**
  - Implementar un sistema de backups automáticos para los directorios `config/` y las bases de datos de los stacks (`nextcloud_db`, `immich_postgres`) usando herramientas como **Restic** o **BorgBackup**.
  - *Objetivo:* Encriptar los datos, deduplicar y subirlos automáticamente a un almacenamiento externo (ej. una cuenta de la universidad o nube barata) mediante un cron job o script en Bash.

---

## 📊 2. Observabilidad y Monitorización Avanzada
*Conceptos clave: Telemetría, Logs centralizados, Series temporales.*

- [ ] **Stack Prometheus + Grafana:**
  - Desplegar **Node Exporter** en la Pi para extraer métricas de hardware (temperatura, CPU, I/O de disco del NAS).
  - Configurar un contenedor de **Prometheus** para raspar (*scrape*) esas métricas y diseñar un Dashboard en **Grafana** para ver el estado de la Pi de un vistazo.
  - *Objetivo:* Dejar de depender solo de las alertas de Komodo y entender cómo muta el rendimiento del servidor bajo carga real (por ejemplo, cuando Jellyfin transcodifica).

- [ ] **Monitorización de Docker con cAdvisor:**
  - Integrar **cAdvisor** (Container Advisor) de Google en tu stack de monitorización.
  - *Objetivo:* Ver cuánta RAM y CPU consume de forma exacta cada stack aislado (`immich_server` vs `nextcloud_app`), validando si los `resource limits` que configuraste en tu `AGENTS.md` se están quedando cortos o largos.

---

## 🔒 3. Seguridad, Gestión de Tráfico y Redes Internas
*Conceptos clave: Reverse Proxy, Capa de Transporte (TLS), DNS Interception.*

- [ ] **Base del reverse proxy local (Nginx Proxy Manager):**
  - Nginx Proxy Manager está preparado en `Compose/Nginx/` y comparte `music-network` con Navidrome y Musikat.
  - *Completado:* El proxy dispone de persistencia y puertos alternativos porque Pi-hole conserva el puerto 80.
  - [ ] Configurar el Proxy Host unificado, la Access List y el acceso público mediante Tailscale Funnel en `pilla.tailf45616.ts.net`.
  - [ ] Validar desde una red externa las rutas `/navidrome/` y `/musikat/`, y decidir si se necesita `ND_BASEURL` sin romper el acceso directo local.
  - *Estado actual:* Nginx Proxy Manager, Navidrome y Musikat están levantados en `music-network`, pero todavía no hay Proxy Host ni Access List configurados; el Funnel aún no se ha activado.
  - *Objetivo:* Gestionar certificados SSL (Let's Encrypt) mediante el **DNS Challenge** (con la API de Cloudflare, DuckDNS, etc.) sin exponer directamente todos los servicios.

- [ ] **Cierre de puertos expuestos de forma innecesaria:**
  - Modificar los Compose para que dejen de mapear los puertos a la IP de la Pi (`0.0.0.0:XXXX->XXXX`). Solo el Reverse Proxy debería exponer puertos al host.
  - *Objetivo:* Si un contenedor intermedio es vulnerable, no se puede acceder a él directamente desde la LAN, obligando a pasar siempre por el proxy y mejorando drásticamente la seguridad del host.

---

## ☁️ 4. Servicios Locales de Utilidad para un Estudiante de Ingeniería
*Conceptos clave: Repositorios locales, CI/CD, Productividad.*

- [ ] **Gitea / Forgejo (Tu propio GitHub local):**
  - Desplegar un servidor Git ligero para tus proyectos de la universidad, scripts locales y dotfiles.
  - *Objetivo:* Gestionar código de forma privada en tu propio hardware y entender el ciclo de vida de los servidores de control de versiones.

- [ ] **Servidor de CI/CD (Woodpecker CI o Gitea Actions):**
  - Conectar un corredor (*runner*) de integración continua a tu Git local.
  - *Objetivo:* Que al hacer un `git push` de tus Docker Compose, el propio sistema pase un linter al código yaml, verifique la sintaxis y avise a Komodo para actualizar el despliegue automáticamente.