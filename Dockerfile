# Debian variant (has /bin/sh and apt-get)
FROM n8nio/n8n:1.74.0-debian

# Install tools
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /data
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Run as node again
USER node
EXPOSE 5678

# Start backup loop + n8n
CMD ["bash", "-c", "/backup.sh & n8n start"]
