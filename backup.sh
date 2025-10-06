#!/bin/bash
set -e

# --- CONFIG ---
REPO_URL="https://github.com/testforworkn8n/n8n-on-render.git"
BRANCH="main"
BACKUP_PATH="/data"
BACKUP_FILE="backup/data.tar.gz"

# --- SETUP ---
cd /tmp
git clone --depth=1 -b $BRANCH $REPO_URL repo
cd repo

# --- RESTORE ---
if [ -f "$BACKUP_FILE" ]; then
  echo "🔁 Restoring n8n data from $BACKUP_FILE..."
  mkdir -p $BACKUP_PATH
  tar -xzf "$BACKUP_FILE" -C /
else
  echo "⚠️ No backup found, starting fresh."
fi

# --- START n8n ---
n8n start &

# Wait 60 seconds to ensure n8n started properly
sleep 60

# --- BACKUP LOOP ---
while true; do
  echo "💾 Creating backup..."
  mkdir -p backup
  tar -czf "$BACKUP_FILE" -C / data
  git config user.email "n8n-bot@local"
  git config user.name "n8n Backup Bot"
  git add $BACKUP_FILE
  git commit -m "Auto backup $(date '+%Y-%m-%d %H:%M:%S')" || true
  git push origin $BRANCH
  echo "✅ Backup completed, sleeping for 1 hour..."
  sleep 3600
done
