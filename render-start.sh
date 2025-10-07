#!/usr/bin/env bash
set -euo pipefail

# -------- config (no Render disk used) --------
PROJECT_DIR="/opt/render/project/src"
DATA_DIR="$PROJECT_DIR/data"
BACKUP_DIR_NAME="backup"                  # folder in the backup repo
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-86400}"  # default 24h

# Required env from Render dashboard:
#   BACKUP_GITHUB_TOKEN (fine-grained PAT)
#   BACKUP_REPO        (e.g. testforworkn8n/n8n-backups)
#   BACKUP_BRANCH      (e.g. main)

GH_API="https://api.github.com/repos/${BACKUP_REPO}"
AUTH_HEADER="Authorization: token ${BACKUP_GITHUB_TOKEN}"
mkdir -p "$DATA_DIR"

log() { echo "[$(date -u +%FT%TZ)] $*"; }

# -------- helpers --------
# PUT file via GitHub Contents API (creates new path each time -> no SHA needed)
put_new_file() {
  local path="$1"    # e.g. backup/2025-10-07T12-00-00Z.tar.gz
  local msg="$2"     # commit message
  local b64file="$3" # base64 string of the file

  curl -sS -X PUT \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"${msg}\",\"content\":\"${b64file}\",\"branch\":\"${BACKUP_BRANCH}\"}" \
    "${GH_API}/contents/${path}" >/dev/null
}

# Upload or update small text file (pointer to latest)
upsert_text_file() {
  local path="$1"     # e.g. backup/LATEST
  local msg="$2"
  local content="$3"  # plain text

  log "→ Updating pointer file ${path}..."
  sha=$(curl -s -H "$AUTH_HEADER" "${GH_API}/contents/${path}?ref=${BACKUP_BRANCH}" | jq -r '.sha // empty')
  b64=$(printf "%s" "$content" | base64 -w 0)

  json="{\"message\":\"${msg}\",\"content\":\"${b64}\",\"branch\":\"${BACKUP_BRANCH}\""
  [ -n "$sha" ] && json+=",\"sha\":\"${sha}\""
  json+="}"

  resp=$(curl -s -o /tmp/curl_resp.json -w "%{http_code}" \
    -X PUT "${GH_API}/contents/${path}" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json")

  if [ "$resp" -ge 200 ] && [ "$resp" -lt 300 ]; then
    log "✅ Pointer updated (${path})"
  else
    log "❌ Pointer update failed (HTTP $resp)"
    log "$(cat /tmp/curl_resp.json)"
  fi
}

# Download latest tarball pointed by backup/LATEST (if present)
restore_from_backup() {
  log "Restoring data (if a backup exists)..."
  # get the file name from LATEST
  latest_json=$(curl -sS -H "$AUTH_HEADER" "${GH_API}/contents/${BACKUP_DIR_NAME}/LATEST?ref=${BACKUP_BRANCH}" || true)
  latest_name=$(echo "$latest_json" | sed -n 's/.*"content":[[:space:]]*"([^"]*)".*/\1/p' | base64 -d 2>/dev/null || true)

  if [ -z "${latest_name:-}" ]; then
    log "No LATEST pointer found; skipping restore."
    return 0
  fi

  # fetch download URL for that tarball
  meta=$(curl -sS -H "$AUTH_HEADER" "${GH_API}/contents/${BACKUP_DIR_NAME}/${latest_name}?ref=${BACKUP_BRANCH}" || true)
  dl_url=$(echo "$meta" | sed -n 's/.*"download_url":[[:space:]]*"([^"]*)".*/\1/p' || true)

  if [ -z "${dl_url:-}" ]; then
    log "LATEST points to '${latest_name}' but file not found; skipping restore."
    return 0
  fi

  tmp_tgz="$(mktemp /tmp/n8n-restore.XXXXXX).tgz"
  curl -sSL -o "$tmp_tgz" "$dl_url"
  mkdir -p "$DATA_DIR"
  rm -rf "$DATA_DIR"/*
  tar -xzf "$tmp_tgz" -C "$DATA_DIR"
  rm -f "$tmp_tgz"
  log "Restore completed."
}

backup_loop() {
  while true; do
    ts=$(date -u +%Y-%m-%dT%H-%M-%SZ)
    tmp_tgz="$(mktemp /tmp/n8n-backup.XXXXXX).tgz"
    # pack up everything inside DATA_DIR
    (cd "$DATA_DIR" && tar -czf "$tmp_tgz" .)
    b64=$(base64 -w 0 "$tmp_tgz")
    rm -f "$tmp_tgz"

    file_name="${ts}.tar.gz"
    commit_msg="n8n backup ${ts}"
    path="${BACKUP_DIR_NAME}/${file_name}"

    log "Uploading backup ${file_name}..."
    put_new_file "$path" "$commit_msg" "$b64"
    upsert_text_file "${BACKUP_DIR_NAME}/LATEST" "update LATEST -> ${file_name}" "${file_name}"
    log "Backup complete; sleeping ${BACKUP_INTERVAL_SECONDS}s."
    sleep "$BACKUP_INTERVAL_SECONDS"
  done
}

# -------- RUN --------
restore_from_backup

# Point n8n to our in-repo data dir (no Render disk)
export N8N_USER_FOLDER="$DATA_DIR"

# Start the backup loop in background
backup_loop &

# Finally start n8n (foreground)
exec n8n start
