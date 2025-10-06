# Use the full Alpine variant — includes /bin/sh and apk
FROM n8nio/n8n:1.72.1-alpine

# Set working directory
WORKDIR /data

# Copy backup script and give execute permissions
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Run n8n and the backup script in parallel
CMD sh -c "/backup.sh & n8n start"
