# NetBox

NetBox IPAM managed with Terraform (RIRs, RFC 1918 aggregates, prefixes), and how I upgrade a NetBox running with netbox-docker and plugins.

## Why

I use NetBox as my source of truth for IP addresses and VMs. I run a dev and a prod instance, I upgrade them, and I wrote scripts around them (not in this repo): a PowerShell sync of the Hyper-V VMs into NetBox, and a prod to dev copy on a systemd timer.

## What I learned

- NetBox 4.5 added v2 API tokens (`nbt_` prefix, `Authorization: Bearer` instead of `Token`). v1 tokens are deprecated in 4.6 and removed in 5.0: I had to rework my sync script for it.
- The Terraform provider version has to match the NetBox version (compatibility table in the provider README). `~> 5.0.0` only covered NetBox 4.3 to 4.4.
- The provider reads `NETBOX_SERVER_URL` and `NETBOX_API_TOKEN`, so the token doesn't need to be in a tfvars file.
- With netbox-docker, plugins go in a custom image: `Dockerfile-plugins`, `plugin_requirements.txt` and `configuration/plugins.py`.
- Database migrations run by themselves when the new container starts.

## Run it

```sh
export NETBOX_SERVER_URL="https://netbox.example.com"
export NETBOX_API_TOKEN="..."
terraform init
terraform plan
```

## Upgrade NetBox (netbox-docker)

Back up the database first:

```sh
docker compose exec -T postgres sh -c 'pg_dump -cU $POSTGRES_USER $POSTGRES_DB' | gzip > db_dump.sql.gz
docker compose down
```

Update the image tag in `upgrade/Dockerfile-plugins` (`FROM netboxcommunity/netbox:<new tag>`) and the plugin versions in `plugin_requirements.txt`, then:

```sh
docker compose build --no-cache
docker compose pull
docker compose up -d
docker compose logs -f netbox    # watch the migrations and plugin loading
```

I do it on the dev instance first, then prod.
