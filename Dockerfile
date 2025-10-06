FROM n8nio/n8n:latest

WORKDIR /data

# Copy environment variables
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# Copy the backup script
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Start using the script instead of n8n directly
CMD ["/backup.sh"]
