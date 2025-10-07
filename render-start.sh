#!/usr/bin/env bash
set -euo pipefail

# -------- config (no Render disk used) --------
PROJECT_DIR="/opt/render/project/src"
DATA_DIR="$PROJECT_DIR/data"
BACKUP_DIR_NAME="backup"
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-86400}"

GH_API="https://ghapi.hackclub.dev/repos/${BACKUP_REPO}"
AUTH_HEADER="Authorization: Bearer ${BACKUP_GITHUB_TOKEN}"

mkdir -p "$DATA_DIR"

# ---------- DEBUG: ENVIRONMENT CHECK ----------
echo "----------------------------------------"
echo "[DEBUG] Starting render-start.sh diagnostic mode"
echo "[DEBUG] BACKUP_REPO=${BACKUP_REPO:-<empty>}"
echo "[DEBUG] BACKUP_BRANCH=${BACKUP_BRANCH:-<empty>}"
echo "[DEBUG] GH_API=${GH_API}"
if [ -z "${BACKUP_GITHUB_TOKEN:-}" ]; then
  echo "[ERROR] BACKUP_GITHUB_TOKEN is empty — Render env var not loaded!"
else
  echo "[DEBUG] BACKUP_GITHUB_TOKEN prefix: ${BACKUP_GITHUB_TOKEN:0:10}****** (len=${#BACKUP_GITHUB_TOKEN})"
fi
echo "----------------------------------------"

# ---------- ADDITIONAL DEEP DIAGNOSTICS ----------
echo "[DEBUG] (1) Checking token raw bytes and hidden characters..."
printf "[DEBUG] Token raw length: %d bytes\n" "$(printf %s "$BACKUP_GITHUB_TOKEN" | wc -c)"
printf "[DEBUG] Token last 10 chars (escaped): %q\n" "${BACKUP_GITHUB_TOKEN: -10}"

echo "----------------------------------------"
echo "[DEBUG] (2) Testing public GitHub connectivity (no auth)..."
curl -s https://api.github.com/meta | grep -A1 hooks || echo "[WARN] Public GitHub meta check failed!"

echo "----------------------------------------"
echo "[DEBUG] (3) Verbose GitHub API call test..."
curl -v -H "$AUTH_HEADER" -H "Accept: application/vnd.github+json" "$GH_API" 2>&1 | tee /tmp/debug_curl.log
echo "----------------------------------------"

# ---------- DEBUG: TEST AUTH REQUEST ----------
echo "[DEBUG] Testing GitHub authentication..."
auth_test_resp=$(curl -s -o /tmp/auth_test.json -w "%{http_code}" \
  -H "$AUTH_HEADER" -H "Accept: application/vnd.github+json" \
  "$GH_API")

if [ "$auth_test_resp" != "200" ]; then
  echo "[ERROR] GitHub auth test failed (HTTP $auth_test_resp)"
  cat /tmp/auth_test.json
  echo "----------------------------------------"
else
  echo "[DEBUG] ✅ GitHub auth test successful."
fi

# ---------- LOG FUNCTION ----------
log() { echo "[$(date -u +%FT%TZ)] $*"; }

# ---------- HELPERS ----------
put_new_file() {
  local path="$1"
  local msg="$2"
  local b64file="$3"

  log "→ Uploading ${path} to GitHub..."
  echo "[DEBUG] PUT URL: ${GH_API}/contents/${path}"
  echo "[DEBUG] Using branch: ${BACKUP_BRANCH}"
  echo "[DEBUG] Header: $AUTH_HEADER"

  resp=$(curl -s -o /tmp/put_resp.json -w "%{http_code}" \
    -X PUT "${GH_API}/contents/${path}" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"${msg}\",\"content\":\"${b64file}\",\"branch\":\"${BACKUP_BRANCH}\"}")

  echo "[DEBUG] PUT response code: $resp"
  cat /tmp/put_resp.json || true

  if [ "$resp" -ge 200 ] && [ "$resp" -lt 300 ]; then
    log "✅ Upload successful"
  else
    log "❌ Upload failed (HTTP $resp)"
  fi
}

upsert_text_file() {
  local path="$1"
  local msg="$2"
  local content="$3"

  log "→ Updating pointer file ${path}..."
  b64=$(printf "%s" "$content" | base64 -w 0)

  sha=$(curl -s -H "$AUTH_HEADER" "${GH_API}/contents/${path}?ref=${BACKUP_BRANCH}" | jq -r '.sha // empty')
  echo "[DEBUG] Existing SHA for ${path}: ${sha:-<none>}"

  json="{\"message\":\"${msg}\",\"content\":\"${b64}\",\"branch\":\"${BACKUP_BRANCH}\""
  [ -n "$sha" ] && json+=",\"sha\":\"${sha}\""
  json+="}"

  echo "[DEBUG] JSON payload: $json"

  resp=$(curl -s -o /tmp/pointer_resp.json -w "%{http_code}" \
    -X PUT "${GH_API}/contents/${path}" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "$json")

  echo "[DEBUG] Pointer update HTTP code: $resp"
  cat /tmp/pointer_resp.json || true

  if [ "$resp" -ge 200 ] && [ "$resp" -lt 300 ]; then
    log "✅ Pointer updated"
  else
    log "❌ Pointer update failed (HTTP $resp)"
  fi
}

# ---------- RESTORE ----------
restore_from_backup() {
  log "Restoring data (if a backup exists)..."
  latest_json=$(curl -sS -H "$AUTH_HEADER" "${GH_API}/contents/${BACKUP_DIR_NAME}/LATEST?ref=${BACKUP_BRANCH}" || true)
  latest_name=$(echo "$latest_json" | sed -n 's/.*"content":[[:space:]]*"([^"]*)".*/\1/p' | base64 -d 2>/dev/null || true)

  if [ -z "${latest_name:-}" ]; then
    log "No LATEST pointer found; skipping restore."
    return 0
  fi
}

# ---------- BACKUP LOOP ----------
backup_loop() {
  while true; do
    ts=$(date -u +%Y-%m-%dT%H-%M-%SZ)
    tmp_tgz="$(mktemp /tmp/n8n-backup.XXXXXX).tgz"
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

# ---------- RUN ----------
restore_from_backup
export N8N_USER_FOLDER="$DATA_DIR"
backup_loop &
exec n8n start
