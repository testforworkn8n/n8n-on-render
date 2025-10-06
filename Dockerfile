FROM n8nio/n8n:latest

USER root
WORKDIR /data

# Copy the backup script
COPY backup.sh /data/backup.sh

# Make sure the script is executable
RUN chmod 755 /data/backup.sh

# Switch back to n8n user (very important)
USER node

# Start n8n and background backup task
CMD bash -c "/data/backup.sh & n8n start"
