FROM n8nio/n8n:latest

# Set working directory
WORKDIR /data

# Copy env vars to the image (optional)
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# Copy the backup script into the image
COPY backup.sh /data/backup.sh

# Expose port (Render auto-detects)
EXPOSE 5678

# Start a shell that sets permission + runs n8n
CMD ["sh", "-c", "chmod +x /data/backup.sh && ./backup.sh & n8n start"]
