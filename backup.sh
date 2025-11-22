#!/bin/sh
set -eu

# Check that AWS CLI is installed
if ! command -v aws >/dev/null 2>&1; then
  echo "[backup] Error: AWS CLI is not installed or not in PATH" >&2
  exit 1
fi

# Resolve and validate n8n user folder
N8N_USER_FOLDER="${N8N_USER_FOLDER:-/opt/.n8n}"

if [ ! -d "$N8N_USER_FOLDER" ]; then
  echo "[backup] Error: N8N_USER_FOLDER '$N8N_USER_FOLDER' does not exist or is not a directory" >&2
  exit 1
fi

# Required S3 configuration
: "${AWS_S3_BUCKET:?AWS_S3_BUCKET env required}"
BUCKET="$AWS_S3_BUCKET"
PREFIX="${AWS_S3_PREFIX:-default}"

timestamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"

# Store backup outside the folder being archived so it does not include itself
backup_file="/tmp/n8n-backup-${timestamp}.tar.gz"

cleanup() {
  if [ -f "$backup_file" ]; then
    rm -f "$backup_file" || true
  fi
}
trap cleanup EXIT

echo "[backup] Starting backup at $timestamp"
echo "[backup] Creating archive from '$N8N_USER_FOLDER'..."

tar -czf "$backup_file" -C "$N8N_USER_FOLDER" .

s3_key="${PREFIX}/n8n-${timestamp}.tar.gz"
echo "[backup] Uploading '$backup_file' to s3://$BUCKET/$s3_key ..."

if aws s3 cp "$backup_file" "s3://$BUCKET/$s3_key"; then
  echo "[backup] Upload successful"
else
  echo "[backup] Upload failed" >&2
  exit 1
fi

echo "[backup] Backup completed at $(date -u)."
