#!/usr/bin/env bash
set -e

echo "[entrypoint] Starting crond..."
crond -l 2 -d 8

echo "[entrypoint] Starting n8n..."
exec n8n start
