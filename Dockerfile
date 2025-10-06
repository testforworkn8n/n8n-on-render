FROM n8nio/n8n:1.74.0-alpine

USER root
RUN apk add --no-cache bash git

WORKDIR /data
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

USER node
EXPOSE 5678
CMD ["bash", "-c", "/backup.sh & n8n start"]
