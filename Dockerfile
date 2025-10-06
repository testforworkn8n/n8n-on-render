# Use the official n8n image (already Debian-based)
FROM n8nio/n8n:latest

# Switch to root so we can install additional tools
USER root

# Update and install bash + git
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /data

# Copy backup script and make it executable
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Switch back to non-root user
USER node

# Expose n8n’s default port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
