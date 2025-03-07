FROM ollama/ollama:latest

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl dos2unix && rm -rf /var/lib/apt/lists/*

# Copy initialization script
COPY containers/ollama/init.sh /init.sh
# Convert line endings and ensure script is executable
RUN dos2unix /init.sh && \
    chmod +x /init.sh

# Set the entrypoint
ENTRYPOINT ["/init.sh"]