#!/bin/sh
set -eu

# How often to back up (hours)
INTERVAL_HOURS="${BACKUP_INTERVAL_HOURS:-24}"
BRANCH="${BACKUP_BRANCH:-main}"
DATA_DIR="${N8N_USER_FOLDER:-/home/node/.n8n}"

while true; do
  echo "Running backup at $(date)"

  # Prepare a clean temp dir; copy n8n data there
  rm -rf /tmp/n8n-backup && mkdir -p /tmp/n8n-backup
  cp -a "$DATA_DIR/." /tmp/n8n-backup/

  cd /tmp/n8n-backup

  # Init repo if needed, commit and push
  git init >/dev/null 2>&1 || true
  git checkout -B "$BRANCH"
  git add -A
  git commit -m "Automated backup $(date)" || true

  # Push using your Render env vars
  # GITHUB_REPO like: testforworkn8n/n8n-backups
  git push -f "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" "$BRANCH"

  echo "Backup done. Sleeping ${INTERVAL_HOURS}h…"
  sleep "$(( INTERVAL_HOURS * 3600 ))"
done
