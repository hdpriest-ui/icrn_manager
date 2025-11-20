#!/bin/bash
# Copy example data files to running Docker container
# Run from root of git repository

# Find container
CONTAINER_ID=$(docker ps -q --filter "ancestor=icrn-web" | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No running container found. Is the container running?"
    exit 1
fi

echo "Found container: $CONTAINER_ID"
echo "Copying files..."

# Copy files
docker cp web/examples/collated_manifests.json ${CONTAINER_ID}:/app/data/collated_manifests.json
docker cp web/examples/package_index.json ${CONTAINER_ID}:/app/data/package_index.json

echo "Files copied successfully!"
echo "Triggering reload..."
curl -X POST http://localhost:8080/api/refresh

echo "Done! The website should now have data available."