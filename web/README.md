# Nginx JSON API Kubernetes Deployment

This deployment provides a Kubernetes-based solution for serving JSON data via a RESTful API, with automatic hourly refresh capabilities.

## Architecture

- **FastAPI**: Python RESTful API that generates and serves JSON data
- **Nginx**: Reverse proxy that forwards requests to the FastAPI backend
- **Background Thread**: Automatically refreshes the JSON file every hour
- **Kubernetes**: Container orchestration for deployment and scaling

## Components

### Application Files
- `kernel_service.py`: FastAPI application with JSON generation and serving logic
- `requirements.txt`: Python dependencies
- `nginx.conf`: Nginx configuration for reverse proxy
- `start.sh`: Startup script that launches both nginx and the API
- `Dockerfile`: Container image definition

### Kubernetes Files
- `nginx-deployment.yml`: Kubernetes Deployment configuration
- `nginx-service.yml`: Kubernetes Service configuration (NodePort on port 30080)

## Features

1. **Automatic JSON Generation**: Generates initial JSON if file doesn't exist
2. **Hourly Refresh**: Automatically reloads JSON file every hour
3. **RESTful API**: Multiple endpoints for accessing JSON data
4. **Health Checks**: Built-in health and readiness probes
5. **Path-based Access**: Access nested JSON data via path parameters

## API Endpoints

- `GET /`: API information and status
- `GET /health`: Health check endpoint
- `GET /api/data`: Get all JSON data
- `GET /api/data/{path}`: Get specific section by path (e.g., `/api/data/data/items/0`)
- `POST /api/refresh`: Manually trigger JSON refresh

## Deployment Steps

### 1. Build Docker Image

```bash
cd nginx_kuber
docker build -t nginx-json-api:latest .
```

### 2. Load Image to Kubernetes Cluster

If using a local cluster (like minikube or kind):

```bash
# For minikube
minikube image load nginx-json-api:latest

# For kind
kind load docker-image nginx-json-api:latest
```

Or push to a container registry and update the image reference in `nginx-deployment.yml`.

### 3. Deploy to Kubernetes

```bash
kubectl apply -f nginx-deployment.yml
kubectl apply -f nginx-service.yml
```

### 4. Verify Deployment

```bash
# Check deployment status
kubectl get deployments nginx-json-api

# Check pods
kubectl get pods -l app=nginx-json-api

# Check service
kubectl get svc nginx-json-api

# View logs
kubectl logs -l app=nginx-json-api
```

### 5. Access the API

If using NodePort (default):
- Get node IP: `kubectl get nodes -o wide`
- Access API: `http://<NODE_IP>:30080`

Or port-forward:
```bash
kubectl port-forward svc/nginx-json-api 8080:80
# Then access at http://localhost:8080
```

## Customization

### Modify JSON Generation

Edit the `generate_json()` function in `kernel_service.py` to customize the JSON structure.

### Change Refresh Interval

Modify the sleep duration in the `refresh_json_periodically()` function (currently 3600 seconds = 1 hour).

### External JSON File Updates

The application watches for file changes. If you have an external process that updates `/app/data/reference.json`, the API will pick it up on the next hourly refresh, or you can trigger a manual refresh via `POST /api/refresh`.

### Persistent Storage

To persist JSON data across pod restarts, modify `nginx-deployment.yml` to use a PersistentVolumeClaim instead of `emptyDir`.

## Environment Variables

- `JSON_FILE_PATH`: Path to the JSON file (default: `/app/data/reference.json`)
- `API_PORT`: Port for FastAPI backend (default: `8000`)

## Troubleshooting

1. **Check pod logs**: `kubectl logs -l app=nginx-json-api`
2. **Check pod status**: `kubectl describe pod -l app=nginx-json-api`
3. **Test API directly**: `kubectl exec -it <pod-name> -- curl http://localhost:80/health`
4. **Verify JSON file**: `kubectl exec -it <pod-name> -- cat /app/data/reference.json`

