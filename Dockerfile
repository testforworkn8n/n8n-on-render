FROM n8nio/n8n:latest

# Show which Linux distribution the image is based on
RUN echo "===== OS release info =====" && cat /etc/os-release || true
RUN echo "===== Installed package manager check =====" \
 && (command -v apt-get && echo "apt-get found (Debian/Ubuntu based)") \
 || (command -v apk && echo "apk found (Alpine based)") \
 || (echo "No apt-get or apk found — custom image")

# Default startup (so Render still runs n8n)
CMD ["n8n", "start"]
