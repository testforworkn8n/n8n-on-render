# Use last n8n Alpine image that includes /bin/sh and apk
FROM n8nio/n8n:1.52.1-alpine

# Set working directory
WORKDIR /data

# Copy backup script and make executable
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Run both backup loop and n8n
CMD sh -c "/backup.sh & n8n start"
