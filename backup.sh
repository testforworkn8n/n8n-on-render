#!/bin/sh
echo "Starting backup loop..."

while true
do
  echo "Running backup..."
  mkdir -p /backup
  cp -r /data/* /backup/
  cd /backup || exit 1
  git init
  git config user.email "backup@render.com"
  git config user.name "Render Backup Bot"
  git add .
  git commit -m "Automated backup $(date)"
  git push -f https://${GITHUB_USER}:${BACKUP_GITHUB_TOKEN}@github.com/${BACKUP_REPO}.git ${BACKUP_BRANCH}
  echo "Sleeping 24h..."
  sleep 86400
done
