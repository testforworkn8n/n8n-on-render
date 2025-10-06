FROM n8nio/n8n:latest

WORKDIR /data

# Copy the backup script and make it executable
COPY --chmod=755 backup.sh /backup.sh

# Start n8n and run backup script in the background using sh
CMD ["sh", "-c", "/backup.sh & n8n start"]
