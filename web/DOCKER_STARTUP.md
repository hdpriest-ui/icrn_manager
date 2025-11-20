# Docker Startup Guide for ICRN Kernel Manager Web

This guide walks you through building and running the ICRN Kernel Manager web interface in Docker.

## Prerequisites

- Docker installed and running
- You are at the root of the git repository (`/u/hdpriest/Code/icrn_manager/`)
- The required data files are available (either in `web/examples/` or generated via `kernel_indexer`)

## Step 1: Build the Docker Image

From the root of the repository:

```bash
cd web
docker build -t icrn-web .
```

Or from the root directory:

```bash
docker build -t icrn-web -f web/Dockerfile web/
```

**Expected output:**
```
[+] Building ... 
 => => transferring context ...
 => => writing image sha256:...
Successfully tagged icrn-web:latest
```

## Step 2: Run the Container

### Basic Run (Port 8080)

```bash
docker run -d -p 8080:80 --name icrn-web icrn-web
```

### Run with Data Files Mounted (Recommended for Production)

If you have the data files on your host system:

```bash
docker run -d -p 8080:80 --name icrn-web \
  -v /path/to/collated_manifests.json:/app/data/collated_manifests.json \
  -v /path/to/package_index.json:/app/data/package_index.json \
  icrn-web
```

### Run with Example Data Files

If using the example files from the repository:

```bash
docker run -d -p 8080:80 --name icrn-web \
  -v $(pwd)/web/examples/collated_manifests.json:/app/data/collated_manifests.json \
  -v $(pwd)/web/examples/package_index.json:/app/data/package_index.json \
  icrn-web
```

**Note:** The container will start but the API will return errors until data files are available.

## Step 3: Copy Data Files (If Not Mounted)

If you didn't mount the files, copy them into the running container:

```bash
# From the root of the repository
docker cp web/examples/collated_manifests.json icrn-web:/app/data/collated_manifests.json
docker cp web/examples/package_index.json icrn-web:/app/data/package_index.json
```

Or use the provided script:

```bash
./copy-data-to-container.sh
```

## Step 4: Verify Container is Running

```bash
docker ps
```

You should see something like:
```
CONTAINER ID   IMAGE      COMMAND        STATUS         PORTS
abc123def456   icrn-web   "/app/start.sh"   Up 2 minutes   0.0.0.0:8080->80/tcp
```

## Step 5: Check Logs

```bash
# View all logs
docker logs icrn-web

# Follow logs in real-time
docker logs -f icrn-web
```

**Expected log output:**
```
Starting nginx and API server...
Starting nginx...
Starting FastAPI application...
Starting ICRN Kernel Manager API server...
Collated manifests file loaded successfully
  Total kernels: 5
Package index file loaded successfully
  Total packages: 1037
All required data files loaded successfully
Background reload thread started (reads files from disk every hour, no indexing)
```

## Step 6: Access the Website

Open your browser and navigate to:

```
http://localhost:8080
```

You should see the ICRN Kernel Manager interface with:
- Language selector (defaulting to "R")
- Kernel list
- Package table (when a kernel is selected)

## Step 7: Test the API

### Health Check
```bash
curl http://localhost:8080/health
```

### Get Languages
```bash
curl http://localhost:8080/api/languages
```

### Manual Reload (if you updated data files)
```bash
curl -X POST http://localhost:8080/api/refresh
```

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker logs icrn-web
```

**Common issues:**
- Port 8080 already in use: Change the port mapping (e.g., `-p 8081:80`)
- Missing data files: The container will start but API will return 503 errors

### Website Loads But No Data

**Symptoms:** Website loads but shows "Error loading languages" or empty lists.

**Solutions:**
1. Verify data files exist in container:
   ```bash
   docker exec icrn-web ls -la /app/data/
   ```

2. Check if files are valid JSON:
   ```bash
   docker exec icrn-web python -m json.tool /app/data/collated_manifests.json > /dev/null
   docker exec icrn-web python -m json.tool /app/data/package_index.json > /dev/null
   ```

3. Copy files again:
   ```bash
   ./copy-data-to-container.sh
   ```

4. Trigger manual reload:
   ```bash
   curl -X POST http://localhost:8080/api/refresh
   ```

### API Returns 503 Errors

This means the data files are missing or invalid. Check:
```bash
# Check if files exist
docker exec icrn-web ls -la /app/data/

# Check API health
curl http://localhost:8080/health
```

### Container Keeps Restarting

Check logs for errors:
```bash
docker logs icrn-web
```

Common causes:
- Invalid JSON in data files
- Missing required files
- Port conflicts

## Useful Commands

### Stop the Container
```bash
docker stop icrn-web
```

### Start a Stopped Container
```bash
docker start icrn-web
```

### Remove the Container
```bash
docker stop icrn-web
docker rm icrn-web
```

### Execute Commands in Container
```bash
# Open a shell
docker exec -it icrn-web /bin/bash

# Check file contents
docker exec icrn-web cat /app/data/collated_manifests.json | head -20
```

### View Container Resource Usage
```bash
docker stats icrn-web
```

## Environment Variables

You can customize paths using environment variables:

```bash
docker run -d -p 8080:80 --name icrn-web \
  -e COLLATED_MANIFESTS_PATH=/app/data/collated_manifests.json \
  -e PACKAGE_INDEX_PATH=/app/data/package_index.json \
  -v $(pwd)/web/examples/collated_manifests.json:/app/data/collated_manifests.json \
  -v $(pwd)/web/examples/package_index.json:/app/data/package_index.json \
  icrn-web
```

## Production Considerations

1. **Use Volume Mounts**: Mount data files as volumes for easy updates
2. **Set Resource Limits**: Use `--memory` and `--cpus` flags
3. **Use Docker Compose**: For easier management
4. **Set Up Logging**: Configure log rotation
5. **Use HTTPS**: Set up reverse proxy with SSL/TLS

## Quick Start Summary

```bash
# 1. Build
docker build -t icrn-web -f web/Dockerfile web/

# 2. Run
docker run -d -p 8080:80 --name icrn-web \
  -v $(pwd)/web/examples/collated_manifests.json:/app/data/collated_manifests.json \
  -v $(pwd)/web/examples/package_index.json:/app/data/package_index.json \
  icrn-web

# 3. Verify
curl http://localhost:8080/health

# 4. Access
# Open http://localhost:8080 in your browser
```

## Next Steps

- Update data files by regenerating with `kernel_indexer`
- Customize the frontend in `web/static/index.html`
- Configure nginx settings in `web/nginx.conf`
- Set up automated data file updates

