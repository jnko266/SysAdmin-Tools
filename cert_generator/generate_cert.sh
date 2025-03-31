#!/bin/bash

set -e

# Default values
KEY_LENGTH=2048
VALIDITY_DAYS=365
ROOT_CRT="root.crt"
ROOT_KEY="root.key"
DOMAIN=""
ALT_NAMES=()
CLEANUP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)
      DOMAIN="$2"
      shift 2
      ;;
    --alt)
      ALT_NAMES+=("$2")
      shift 2
      ;;
    --key-length)
      KEY_LENGTH="$2"
      shift 2
      ;;
    --validity)
      VALIDITY_DAYS="$2"
      shift 2
      ;;
    --root-crt)
      ROOT_CRT="$2"
      shift 2
      ;;
    --root-key)
      ROOT_KEY="$2"
      shift 2
      ;;
    --cleanup)
      CLEANUP=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$DOMAIN" ]]; then
  echo "Error: --domain is required"
  exit 1
fi

CERT_NAME="$DOMAIN"
KEY_FILE="${CERT_NAME}.key"
CSR_FILE="${CERT_NAME}.csr"
CRT_FILE="${CERT_NAME}.crt"
EXT_FILE="${CERT_NAME}_san.ext"
SERIAL_FILE="$(basename "$ROOT_CRT" .crt).srl"

# Generate private key
openssl genrsa -out "$KEY_FILE" "$KEY_LENGTH"

# Generate CSR
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -subj "/CN=$DOMAIN"

# Create SAN config
{
  echo "authorityKeyIdentifier=keyid,issuer"
  echo "basicConstraints=CA:FALSE"
  echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment"
  echo "subjectAltName = @alt_names"
  echo ""
  echo "[alt_names]"
  echo "DNS.1 = $DOMAIN"
  i=2
  for alt in "${ALT_NAMES[@]}"; do
    echo "DNS.$i = $alt"
    ((i++))
  done
} > "$EXT_FILE"

# Sign the certificate
openssl x509 -req \
  -in "$CSR_FILE" \
  -CA "$ROOT_CRT" -CAkey "$ROOT_KEY" -CAcreateserial \
  -out "$CRT_FILE" \
  -days "$VALIDITY_DAYS" -sha256 -extfile "$EXT_FILE"

# Cleanup
if $CLEANUP; then
  echo "🧹 Cleaning up intermediate files..."
  rm -f "$CSR_FILE" "$EXT_FILE" "$SERIAL_FILE"
fi

echo "✅ Certificate generated:"
echo " - Private key: $KEY_FILE"
echo " - Certificate: $CRT_FILE"
