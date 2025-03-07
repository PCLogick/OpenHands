#!/bin/bash
set -e

# Start Ollama in the background
ollama serve &

# Wait for Ollama to be ready
until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 1
done

MODEL="deepseek-coder:6.7b"

# Pull the model if it's not already present
if ! ollama list | grep -q "$MODEL"; then
    echo "Pulling $MODEL model..."
    ollama pull $MODEL
fi

# Preload the model by making a test query
echo "Preloading $MODEL into memory..."
curl -s http://localhost:11434/api/generate -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"Say 'Model loaded successfully'\",
    \"stream\": false
}" > /dev/null

echo "$MODEL is ready for use!"

# Keep the container running
tail -f /dev/null 