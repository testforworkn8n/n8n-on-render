# Use official Debian-based n8n image
FROM n8nio/n8n:1.74.0

# Switch to root for installing dependencies
USER root

# Update and install tools (bash, git, curl)
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash git curl && \
    rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /data

# Copy optional backup script (if exists)
COPY backup.sh /data/backup.sh
RUN chmod +x /data/backup.sh || true

# Expose n8n default port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
