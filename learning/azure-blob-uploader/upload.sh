#!/bin/sh
# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting PDF synchronization to Azure Blob Storage..."

# Run the upload using the provided SAS Token
az storage blob upload-batch \
  --source ./pdfs \
  --destination "$BLOB_CONTAINER_URL" \
  --sas-token "$SAS_TOKEN" \
  --pattern "*.pdf"

echo "Upload completed successfully."