# Homepage

Panel de inicio para ver el estado del sistema y de los contenedores, con accesos rapidos a los servicios del homelab.

## Stack Docker
```yml
services:
	homepage:
		image: ghcr.io/gethomepage/homepage:latest
		container_name: homepage
		deploy:
			resources:
				limits:
					cpus: '0.5'
					memory: 128M
		env_file:
			- .env
		environment:
			- HOMEPAGE_ALLOWED_HOSTS=${HOMEPAGE_ALLOWED_HOSTS}
		volumes:
			- ${HOMEPAGE_DATA_PATH}:/app/config
			- ${DOCKER_SOCKET}:/var/run/docker.sock:ro
			- ${NAS_PATH}:/mnt/nasdisk:ro
		ports:
			- ${APP_PORT}:3000
		restart: unless-stopped
```

## Explicacion de la configuracion

### Servicio principal: homepage
- **Imagen**: `ghcr.io/gethomepage/homepage:latest`
- **Contenedor**: `homepage`
- **Puerto**: `${APP_PORT}:3000`
- **URLs de acceso**:
	- Local: `192.168.0.9:3000`
	- Tailscale: `homepage.tailf45616.ts.net`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **Proposito**: dashboard central para consultar servicios, contenedores y estado general del homelab

### Variables de entorno
- `env_file: .env`: carga la configuracion externa del stack
- `HOMEPAGE_ALLOWED_HOSTS`: define los hosts permitidos para acceder a la interfaz

### Volumenes
- `${HOMEPAGE_DATA_PATH}:/app/config`: persistencia de la configuracion de Homepage
- `${DOCKER_SOCKET}:/var/run/docker.sock:ro`: acceso de solo lectura al Docker del host para leer contenedores y su estado
- `${NAS_PATH}:/mnt/nasdisk:ro`: acceso de solo lectura al almacenamiento NAS para widgets o referencias locales

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico si el contenedor falla o cuando Docker se reinicia, salvo que se haya detenido manualmente
