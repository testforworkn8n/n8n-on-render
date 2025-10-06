# Use the official n8n image (Alpine-based)
FROM n8nio/n8n:latest

# Switch to root to install packages
USER root

# Install required tools for backup (git, bash, curl)
RUN apk add --no-cache bash git curl

# Create a backup directory
RUN mkdir -p /data/backup

# Copy the backup script to the image
COPY backup.sh /data/backup.sh

# Give execute permissions
RUN chmod +x /data/backup.sh

# Switch back to the default n8n user
USER node

# Expose port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
