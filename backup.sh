#!/bin/sh

echo "Starting backup loop..."

while true
do
    echo "Running backup..."
    # Sync /data to GitHub repo folder
    cp -r /data /backup

    cd /backup || exit
    git add .
    git commit -m "Automated n8n backup $(date)"
    git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git main

    echo "Backup complete. Sleeping 24h..."
    sleep 86400
done
