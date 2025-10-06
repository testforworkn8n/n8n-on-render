FROM n8nio/n8n:latest

# Set working directory
WORKDIR /data

# Copy environment variables (optional)
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# Expose the default n8n port
EXPOSE 5678

# Start n8n server
ENTRYPOINT ["tini", "--"]
CMD ["n8n", "start"]
