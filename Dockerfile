# Use the latest stable n8n image (based on Debian 12 - Bookworm)
FROM n8nio/n8n:latest

# Switch to root to install additional packages
USER root

# Update sources to Bookworm (if still on Buster)
RUN sed -i 's/buster/bookworm/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|deb.debian.org/debian-security|g' /etc/apt/sources.list

# Update and install git + bash
RUN apt-get update && apt-get install -y git bash && rm -rf /var/lib/apt/lists/*

# Set working directory for n8n
WORKDIR /data

# Copy backup script and make executable
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Switch back to node user
USER node

# Expose the default n8n port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
