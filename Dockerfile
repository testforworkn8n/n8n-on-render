# Use Debian-based Node image (includes bash, git, and apt)
FROM node:18-bullseye

# Set working directory
WORKDIR /data

# Copy project files (including .env)
COPY . .

# Install n8n globally
RUN npm install -g n8n

# Make backup script executable
RUN chmod +x /backup.sh

# Expose n8n default port
EXPOSE 5678

# Start both n8n and backup loop
CMD bash -c "n8n start & ./backup.sh"
