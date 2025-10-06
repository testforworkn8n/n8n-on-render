# Use the official n8n image
FROM n8nio/n8n:latest

# Set working directory
WORKDIR /data

# Copy your backup script into the container
COPY backup.sh /backup.sh

# Give execute permission (Alpine requires busybox sh syntax)
RUN chmod +x /backup.sh

# Install bash (Alpine doesn’t include it by default)
RUN apk add --no-cache bash

# Optional: run your backup script on startup before n8n
# Replace this line if you want automatic backup logic
CMD ["bash", "-c", "/backup.sh & n8n start"]
