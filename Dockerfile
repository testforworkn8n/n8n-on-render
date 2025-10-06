FROM n8nio/n8n:latest

WORKDIR /data

# Copy your backup script and set permissions in one go
COPY --chmod=755 backup.sh /backup.sh

# Install bash (Alpine doesn’t have it by default)
RUN apk add --no-cache bash

# Start n8n and run your backup script in the background
CMD ["bash", "-c", "/backup.sh & n8n start"]
