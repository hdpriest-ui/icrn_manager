#!/bin/bash
set -e

echo "Starting FastAPI application with uvicorn..."

# Create data directory if it doesn't exist
mkdir -p /app/data

# Get number of workers from environment variable (default: 4)
WORKERS=${WORKERS:-4}

echo "Starting uvicorn with $WORKERS workers on port 8000..."
uvicorn kernel_service:app --host 0.0.0.0 --port 8000 --workers $WORKERS

