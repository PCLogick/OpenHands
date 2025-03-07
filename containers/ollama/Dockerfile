FROM ollama/ollama:latest

# Install curl for healthcheck and other utilities
RUN apt-get update && \
    apt-get install -y \
    curl \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the init script and convert line endings in one step
COPY containers/ollama/init.sh ./init.sh
RUN sed -i 's/\r$//' ./init.sh && \
    cat ./init.sh | tr -d '\r' > /init.sh && \
    chmod +x /init.sh && \
    echo "Content of init.sh:" && \
    cat /init.sh && \
    echo "File permissions:" && \
    ls -la /init.sh

# Set the shell to bash explicitly
SHELL ["/bin/bash", "-c"]

# Set the entrypoint with explicit shell
ENTRYPOINT ["/bin/bash", "/init.sh"]