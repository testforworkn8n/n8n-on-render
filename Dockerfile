# Use the maintained Debian variant of n8n
FROM n8nio/n8n:latest-debian

WORKDIR /data

# Update apt sources to use Bookworm (buster is deprecated)
RUN sed -i 's|deb.debian.org/debian buster|deb.debian.org/debian bookworm|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security buster/updates|security.debian.org/debian-security bookworm-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Copy your backup script and make it executable
COPY --chmod=755 backup.sh /backup.sh

# Start backup script in background and then launch n8n
CMD ["bash", "-c", "/backup.sh & n8n start"]
