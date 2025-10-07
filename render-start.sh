# Upload file to GitHub via Contents API
put_new_file() {
  local path="$1"    # e.g. backup/2025-10-07T12-00-00Z.tar.gz
  local msg="$2"     # commit message
  local b64file="$3" # base64 string of the file

  log "→ Uploading ${path} to GitHub..."
  resp=$(curl -s -o /tmp/curl_resp.json -w "%{http_code}" \
    -X PUT "${GH_API}/contents/${path}" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"${msg}\",\"content\":\"${b64file}\",\"branch\":\"${BACKUP_BRANCH}\"}")

  if [ "$resp" -ge 200 ] && [ "$resp" -lt 300 ]; then
    log "✅ Backup uploaded successfully (${path})"
  else
    log "❌ GitHub upload failed (HTTP $resp)"
    log "$(cat /tmp/curl_resp.json)"
  fi
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
