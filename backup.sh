#!/usr/bin/env bash
set -euo pipefail

N8N_USER_FOLDER="${N8N_USER_FOLDER:-/opt/.n8n}"
BUCKET="${AWS_S3_BUCKET:?AWS_S3_BUCKET env required}"
PREFIX="${AWS_S3_PREFIX:-default}"

timestamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"

backup_file="${N8N_USER_FOLDER}/n8n-backup-${timestamp}.tar.gz"

echo "[backup] Starting backup at ${timestamp}"
echo "[backup] Creating archive from ${N8N_USER_FOLDER}..."

tar -czf "${backup_file}" -C "${N8N_USER_FOLDER}" .

s3_key="${PREFIX}/n8n-${timestamp}.tar.gz"
echo "[backup] Uploading ${backup_file} to s3://${BUCKET}/${s3_key} ..."

aws s3 cp "${backup_file}" "s3://${BUCKET}/${s3_key}"

rm -f "${backup_file}"

echo "[backup] Backup completed at $(date -u)."
