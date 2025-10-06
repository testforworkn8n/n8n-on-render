FROM n8nio/n8n:latest

# Set working directory
WORKDIR /data

# Copy env vars to the image (optional, safe to skip if set via Render dashboard)
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# Expose port 5678 (Render maps this automatically)
EXPOSE 5678

# Default command to start n8n
CMD ["n8n", "start"]
