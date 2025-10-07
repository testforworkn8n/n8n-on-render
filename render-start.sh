#!/usr/bin/env bash
set -euo pipefail

echo "Starting n8n on Render..."
echo "Data directory: /opt/render/project/src/data"

# Make sure data directory exists
mkdir -p /opt/render/project/src/data

# Point n8n to that directory
export N8N_USER_FOLDER="/opt/render/project/src/data"

# Fix permission warnings
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Start n8n in foreground (Render keeps it alive)
exec n8n start
