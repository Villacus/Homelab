# Estructura del Proyecto

Este documento define la organización jerárquica del repositorio `Homelab`, diseñada para facilitar la escalabilidad y la gestión de servicios mediante la metodología *Infrastructure as Code* (IaC).

```
Homelab/
├── docs/                # Documentación técnica adicional
├── Compose/             # Definiciones de contenedores
│   ├── <StackName>/     # Stack autocontenido
│   │   ├── docker-compose.yml
│   │   └── .env
│   └── ...
└── ...
```

## Concepto de Stack

Cada servicio o grupo de servicios relacionados se organiza como un "stack" autocontenido dentro del directorio `Compose/`. Esta estructura garantiza que toda la configuración necesaria (`docker-compose.yml` y variables de entorno `.env`) resida en un mismo lugar, simplificando tanto el mantenimiento como el proceso de [[Despliegue]]. Como excepción explícita, Navidrome, Musikat y Nginx Proxy Manager dependen de la red Docker externa `music-network`, que debe existir antes de desplegar cualquiera de esos stacks.

Para más detalles sobre cómo estandarizar la configuración de estos stacks, consulta [[Convenciones]].

