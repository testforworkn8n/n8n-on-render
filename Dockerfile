# Use the official Alpine-based image
FROM n8nio/n8n:latest

# Switch to root to install packages
USER root

# Install bash, git, and make sure shell works (Alpine uses apk)
RUN apk add --no-cache bash git

# Set working directory
WORKDIR /data

# Copy your backup script and set execute permissions
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Switch back to non-root user
USER node

# Expose n8n default port
EXPOSE 5678

# Start both n8n and the backup script in parallel
CMD ["bash", "-c", "/backup.sh & n8n start"]
