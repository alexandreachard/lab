# Recipe: Automated PDF Ingestion via Docker & SAS Token

This recipe containerizes the process of batch-uploading files to an isolated Azure Storage Account container using a short-lived Shared Access Signature (SAS) token.

## Why this pattern?
I packed the Azure CLI into a minimal Alpine container, so i can run data ingestion pipelines from any environment (GitHub Actions, local machines, or on-prem servers) without manually installing cloud dependencies on the host system.

## Execution

1. I drop my target files into a local `./pdfs` folder.
2. I build the lightweight automation container:
```bash
docker build -t blob-uploader .
```

And then I run the container by passing my destination url and my secure SAS token as environment variables:
```bash
docker run --rm \
  -e BLOB_CONTAINER_URL="[https://ragdevstocore.blob.core.windows.net/data-bucket](https://ragdevstocore.blob.core.windows.net/data-bucket)" \
  -e SAS_TOKEN="sp=r&st=2026-06-26T...your-sas-token-string..." \
  blob-uploader
```
## Production Note
This setup is meant for my own local verification and quick testing. In a production environment, I would swap out the SAS token mechanism for Azure Managed Identities to avoid passing around temporary credential strings.