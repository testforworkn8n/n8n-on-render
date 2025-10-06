# Use a Debian-based n8n image so apt-get exists
FROM n8nio/n8n:1.74.0-debian

# Switch to root to install additional tools
USER root

# Install bash and git
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /data

# Copy backup script and make it executable
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Switch back to n8n user
USER node

# Expose default port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
