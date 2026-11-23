# Azure Blob uploader

A small container with the Azure CLI that uploads the files of a local folder to a Blob Storage container, with a SAS token.

## Why

I needed to push test PDFs into a storage account from different machines without installing the Azure CLI everywhere.

## Run it

Put the PDFs in `./pdfs` (they are copied into the image at build time), then:

```sh
docker build -t blob-uploader .
docker run --rm \
  -e BLOB_CONTAINER_URL="https://<account>.blob.core.windows.net/<container>" \
  -e SAS_TOKEN="<sas token>" \
  blob-uploader
```

## What I'd change

- Mount the folder (`-v ./pdfs:/app/pdfs`) instead of copying it into the image: no rebuild for each batch.
- A SAS token is a secret passed around in a command line. For anything else than a quick test, I'd use a managed identity (or `azcopy login`) and the Storage Blob Data Contributor role.
