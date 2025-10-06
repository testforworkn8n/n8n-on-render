FROM n8nio/n8n:latest

USER root
WORKDIR /data

# Copy your backup script
COPY backup.sh /data/backup.sh

# Give execution rights
RUN chmod +x /data/backup.sh

# Switch back to node user for n8n
USER node

# Start n8n and the backup script together
CMD ["bash", "-c", "/data/backup.sh & n8n start"]
