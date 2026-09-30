#!/usr/bin/env bash
# Generate a self-signed SAN certificate for local homelab testing

set -euo pipefail

DOMAIN="${1:-homelab.local}"
OUTPUT_DIR="${2:-certs}"

mkdir -p "${OUTPUT_DIR}"

echo "Generating private key and certificate for: *.${DOMAIN} and ${DOMAIN}..."

openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout "${OUTPUT_DIR}/tls.key" \
  -out "${OUTPUT_DIR}/tls.crt" \
  -subj "/CN=${DOMAIN}/O=Homelab" \
  -addext "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN}"

echo "Done."
echo "Key:  ${OUTPUT_DIR}/tls.key"
echo "Cert: ${OUTPUT_DIR}/tls.crt"
echo ""
echo "To create the Kubernetes TLS secret imperatively:"
echo "kubectl create secret tls app-tls-secret --cert=${OUTPUT_DIR}/tls.crt --key=${OUTPUT_DIR}/tls.key -n <namespace>"
