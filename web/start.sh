#!/bin/bash
set -e

echo "Starting nginx and API server..."

# Create data directory if it doesn't exist
mkdir -p /app/data

# Start nginx in the background
echo "Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Wait a moment for nginx to start
sleep 2

# Start the FastAPI application
echo "Starting FastAPI application..."
python /app/kernel_service.py &
API_PID=$!

# Function to handle shutdown
cleanup() {
    echo "Shutting down..."
    kill $NGINX_PID 2>/dev/null || true
    kill $API_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Wait for both processes
wait $NGINX_PID $API_PID

