# Runbook: Upgrading NetBox via Docker Compose

This document tracks my operational checklist for backing up, rebuilding, and upgrading my NetBox instance along with its custom plugin ecosystem.

## Upgrade Lifecycle

### 1. Database Preservation
Before I touch the application lifecycle, I capture a compressed logical backup of the PostgreSQL state to prevent data loss:
```bash
docker compose exec -T postgres sh -c 'pg_dump -cU $POSTGRES_USER $POSTGRES_DB' | gzip > db_dump.sql.gz
```
### 2. Environment Teardown
Next, I stop the running containers to ensure no state changes occur while I modify the configuration files:
```bash
docker compose down
```
### 3. Dependency Alignment
I update my target versions across the configuration layers:
- I update the base image version tag in Dockerfile-plugins (e.g., migrating FROM v4.5.8-4.0.2 to the newer target release).
- I append or lock down the new plugin versions inside plugin_requirements.txt.
- I modify localized system parameters inside the configuration/ directories if the new release requires it.

### 4. Build and Orchestration Execution
I force a clean build of my custom image to bake in the updated plugins, pull external layer updates, and spin up the new stack in detached mode:
```bash
# I rebuild the custom layers from scratch
docker compose build --no-cache

# I refresh standard upstream images (Redis, Postgres, etc.)
docker compose pull

# I initialize the new stack containers
docker compose up -d
```
#### 5. Verification and Log Streaming
Finally, I monitor the post-deployment migrations and plugin initialization to confirm everything starts up successfully:
```bash
docker compose logs -f netbox
```
