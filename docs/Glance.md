Glance es el dashboard del homelab. Su stack versionado está en `Compose/Glance/`, pero la configuración operativa del dashboard vive fuera de este repositorio, en la Raspberry Pi.

## Ubicación y montaje

El archivo que se debe editar en el servidor es:

```text
/home/villacus/glance/glance.yml
```

`Compose/Glance/.env` define `CONFIG_PATH=/home/villacus/glance` y `Compose/Glance/docker-compose.yml` monta esa ruta como `/app/config` dentro del contenedor. El stack publica el puerto `8082` del host hacia el puerto `8080` del contenedor.

El Compose también monta en solo lectura el socket de Docker, `/etc/localtime` y `/mnt/nasdisk`. Esto permite que Glance consulte el estado de los contenedores y algunos datos del NAS sin conceder permisos de escritura sobre esos recursos. Las URLs de servicios usadas por widgets se mantienen en las variables del `.env` de Glance; no se deben copiar credenciales a la documentación.

## Cómo añadir un servicio

Antes de editar, inspecciona el archivo real en `pilla`:

```bash
ssh pilla
sed -n '1,240p' /home/villacus/glance/glance.yml
```

El archivo no está incluido en este checkout, por lo que no se deben inventar nombres de páginas, columnas, widgets, URLs ni bloques YAML. Conserva la estructura que ya exista: normalmente habrá páginas o secciones, columnas, widgets y enlaces. Para incorporar un servicio nuevo:

1. Identifica la página y la columna que agrupan servicios similares.
2. Reutiliza el tipo de widget, el orden, la indentación y el estilo de URL que ya use esa sección.
3. Usa la URL local o la URL de Tailscale que corresponda al servicio, según el patrón existente en el archivo.
4. Comprueba que el nombre y el puerto coinciden con [[Servicios]] y con el Compose del servicio.
5. Valida el YAML antes de reiniciar Glance.
6. Reinicia o redeploya el stack y comprueba el dashboard desde `https://glance.tailf45616.ts.net`.

Una forma de revisar sin entrar en una sesión interactiva es:

```bash
ssh pilla "grep -n -E 'pages:|columns:|widgets:|title:|url:' /home/villacus/glance/glance.yml"
```

El comando solo sirve para orientarse; la edición debe respetar el contexto completo del YAML y no hacerse mediante sustituciones ciegas.

## Actualización automática

Los cambios en `Compose/Glance/**` son detectados por `.github/workflows/deploy-arcane.yml`. Cuando están configurados `TAILSCALE_AUTHKEY` y `WEBHOOK_GLANCE` en GitHub Actions, el workflow entra en la Tailnet y llama al webhook de Arcane para redeployar Glance. El webhook no actualiza por sí mismo el contenido externo de `/home/villacus/glance/glance.yml`: ese archivo debe editarse en `pilla`, como se describe arriba.

Si Arcane y el webhook todavía no están configurados, el administrador debe hacer el primer despliegue manual y configurar después el secreto `WEBHOOK_GLANCE`. El flujo completo está en [[Despliegue]].

## Seguridad y mantenimiento

No guardes contraseñas, tokens ni URLs de webhook en este documento ni en Git. La configuración del dashboard está fuera de la vault precisamente porque pertenece al host; documenta aquí el procedimiento, no sus secretos ni un volcado completo del archivo. Para las rutas y montajes del stack consulta [[Convenciones]].
