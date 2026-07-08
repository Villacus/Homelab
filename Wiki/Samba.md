# Samba

Servidor SMB/CIFS para compartir carpetas en red local y acceso remoto por Tailscale.

## Stack Docker
```yml
services:
  samba:
    image: dperson/samba
    container_name: samba
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    restart: unless-stopped
    stdin_open: true
    tty: true
    ports:
      - "137:137/udp"
      - "138:138/udp"
      - "139:139/tcp"
      - "445:445/tcp"
    volumes:
      - ${NAS_PATH}/privada:/mnt/privada
      - ${NAS_PATH}/compartida:/mnt/compartida
    command:
      - "-u"
      - "${SAMBA_USER1};${SAMBA_PASS1};${SAMBA_UID};users"
      - "-u"
      - "${SAMBA_USER2};${SAMBA_PASS2}"
      - "-s"
      - "Privada;/mnt/privada;yes;no;no;${SAMBA_USER1}"
      - "-s"
      - "Compartida;/mnt/compartida;yes;no;no;${SAMBA_USER2}"
      - "-p"
      - "-n"
    environment:
      - TZ=${TZ}
      - WORKGROUP=${WORKGROUP}
```

## Explicacion de la configuracion

### Servicio principal: samba
- **Imagen**: `dperson/samba`
- **Contenedor**: `samba`
- **Recursos**: 0.5 CPU y 128 MB de RAM
- **URLs de acceso (SMB)**:
  - Local: `192.168.0.9:445`
  - Tailscale: `samba.tailf45616.ts.net:445`

### Puertos SMB/CIFS
- `137/udp`: NetBIOS Name Service
- `138/udp`: NetBIOS Datagram Service
- `139/tcp`: NetBIOS Session Service
- `445/tcp`: SMB directo (puerto principal actual)

### Volumenes compartidos
- `${NAS_PATH}/privada:/mnt/privada`
- `${NAS_PATH}/compartida:/mnt/compartida`

### Usuarios definidos
- `${SAMBA_USER1}` (UID `${SAMBA_UID}`, grupo `users`)
- `${SAMBA_USER2}`

### Shares definidos
- `Privada -> /mnt/privada` (acceso para `${SAMBA_USER1}`)
- `Compartida -> /mnt/compartida` (acceso para `${SAMBA_USER2}`)

### Flags usadas en command
- `-u`: crea usuarios SMB
- `-s`: crea recursos compartidos (shares)
- `-p`: habilita soporte para permisos
- `-n`: desactiva NetBIOS (modo moderno centrado en SMB)

### Variables de entorno
- `TZ`: zona horaria del contenedor
- `WORKGROUP`: grupo de trabajo SMB en red local
- `NAS_PATH`: ruta base del NAS montado
- `SAMBA_USER1`, `SAMBA_PASS1`: primer usuario SMB y su contraseña
- `SAMBA_USER2`, `SAMBA_PASS2`: segundo usuario SMB y su contraseña
- `SAMBA_UID`: UID del primer usuario SMB

### Estrategia de reinicio
- **restart: unless-stopped**: reinicio automatico tras fallo o reinicio de Docker, salvo parada manual
