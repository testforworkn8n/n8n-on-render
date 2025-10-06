FROM n8nio/n8n:latest

# Set working directory
WORKDIR /data

# Copy env vars to image (optional)
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# Copy the backup script
COPY backup.sh /data/backup.sh

# Ensure /bin/bash exists, then run both backup and n8n
# Use "bash -c" since sh may not be available in the Render build env
CMD ["/bin/bash", "-c", "chmod +x /data/backup.sh && /data/backup.sh & n8n start"]
