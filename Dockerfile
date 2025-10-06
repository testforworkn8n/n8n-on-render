# Use a Debian-based n8n image to ensure /bin/sh and apt exist
FROM n8nio/n8n:1.74.0

# Switch to root to install tools
USER root

# Install bash + git
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash git && \
    rm -rf /var/lib/apt/lists/*

# Create /data directory for backups
WORKDIR /data

# Copy and make backup script executable
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Switch back to node user for n8n
USER node

# Expose port
EXPOSE 5678

# Run both backup script (in background) and n8n together
CMD ["bash", "-c", "/backup.sh & n8n start"]
