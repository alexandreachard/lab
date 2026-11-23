# BookStack Multi-Container Stack

Demonstrates:

- Service dependencies
- Health checks
- Resource limits
- Multiple networks
- Persistent storage
- Redis caching
- MariaDB backend
- Logging configuration
- Security options

## Configuration

Copy the example environment file and adjust the values to your environment:

```bash
cp .env.example .env
```

Generate a BookStack application key:

```bash
openssl rand -base64 32
```

Review and update:

- APP_URL
- APP_KEY
- DB_PASSWORD
- DB_ROOT_PASSWORD
- REDIS_PASSWORD
- DATA_PATH

> Note
>
> Resource limits defined under `deploy.resources` are primarily intended for Docker Swarm.
> Depending on the Docker Compose version and runtime, they may not be enforced outside of Swarm deployments.
