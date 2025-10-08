#!/bin/bash
export N8N_ENCRYPTION_KEY=$(openssl rand -hex 24)
export N8N_PORT=10000
export WEBHOOK_URL="https://n8n-on-render-7n4x.onrender.com/"
n8n start
