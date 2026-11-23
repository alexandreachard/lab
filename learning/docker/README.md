# Docker Compose sandboxes

Small Compose files I wrote while learning, one feature each:

- `healthchecks/`, `depends-on/`: start a service only when its dependency is healthy (`condition: service_healthy`)
- `networking/`: several networks, which container sees which
- `persistence/`: named volumes vs bind mounts
- `resource-limits/`: CPU and memory limits
- `reverse-proxy-nginx/`: nginx in front of other containers, settings from a `.env`
- `multi-container-stack/bookstack/`: everything together (BookStack, MariaDB, Redis)
