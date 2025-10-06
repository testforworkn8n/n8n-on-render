# Pin to a recent n8n; or keep :latest if you prefer
FROM n8nio/n8n:1.81.4

# Become root to install packages
USER root

# Alpine packages (no apt-get here)
RUN apk add --no-cache \
      bash git openssh-client ca-certificates \
  && update-ca-certificates

# Copy the backup script into PATH
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh && chown node:node /usr/local/bin/backup.sh

# n8n stores data here in the official image
ENV N8N_USER_FOLDER=/home/node/.n8n

# Optional: set a default git identity (can be overridden by env)
RUN git config --global user.name  "n8n render" \
 && git config --global user.email "render@example.local"

# Drop privileges back to the n8n user
USER node

# Start the backup loop in the background, then n8n
# (JSON form so it works in Docker everywhere)
CMD ["sh", "-c", "/usr/local/bin/backup.sh & exec n8n start"]
