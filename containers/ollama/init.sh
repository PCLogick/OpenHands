#!/bin/bash
set -e

echo "Starting Ollama service..."
# Start Ollama in the background
ollama serve &

# Wait for Ollama to be ready
echo "Waiting for Ollama API to become available..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 1
done
echo "Ollama API is now available"

# Use environment variable with fallback
MODEL="${OLLAMA_MODEL:-qwen2.5-coder:7b}"
echo "Using model: $MODEL"

# Check if model exists in Ollama
echo "Checking for model availability..."
if ! ollama list | grep -q "$MODEL"; then
    echo "Model $MODEL not found locally, attempting to pull..."
    ollama pull $MODEL
    if [ $? -ne 0 ]; then
        echo "Failed to pull model $MODEL"
        echo "Available models:"
        ollama list
        exit 1
    fi
fi

# Verify model was pulled successfully
echo "Verifying model..."
if ! ollama list | grep -q "$MODEL"; then
    echo "Model verification failed. Available models:"
    ollama list
    exit 1
fi

# Test model with a simple query
echo "Testing model with a simple query..."
RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"Say 'Model loaded successfully'\",
    \"stream\": false
}")
echo "Model test response: $RESPONSE"

if [ $? -ne 0 ]; then
    echo "Failed to test model. Response: $RESPONSE"
    exit 1
fi

echo "$MODEL is ready for use!"

# Keep the container running
tail -f /dev/null 