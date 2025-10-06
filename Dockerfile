# Base official NodeJS (includes bash & git)
FROM node:18-bullseye

# Install n8n globally
RUN npm install -g n8n

# Set working directory
WORKDIR /data

# Copy backup script
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Start both n8n and the backup loop
CMD ["bash", "-c", "n8n start & /backup.sh"]
