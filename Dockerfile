FROM n8nio/n8n:latest-debian

WORKDIR /data

# Copy backup script and set permissions
COPY --chmod=755 backup.sh /backup.sh

# You might need git (if you push to GitHub)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

CMD ["bash", "-c", "/backup.sh & n8n start"]
