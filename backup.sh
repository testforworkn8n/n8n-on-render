#!/bin/sh
echo "Starting backup loop..."

while true
do
    echo "Running backup..."
    cp -r /data /backup
    cd /backup || exit 1
    git add .
    git commit -m "Automated backup $(date)"
    git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git main
    echo "Sleeping 24h..."
    sleep 86400
done
