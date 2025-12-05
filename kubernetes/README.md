# ICRN Kernel Manager - Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the ICRN Kernel Manager components.

## Overview

The deployment consists of three main components:

1. **PersistentVolume (PV) & PersistentVolumeClaim (PVC)**: NFS mount to the kernel repository
2. **Web Deployment**: FastAPI web interface with Nginx, Service, and Ingress
3. **CronJob**: Kernel indexer that runs every hour to generate/update index files

## Files

- `01-pv-pvc.yaml` - PersistentVolume and PersistentVolumeClaim for NFS mount
- `02-web-deployment.yaml` - Deployment, Service, and Ingress for web interface
- `03-cronjob-indexer.yaml` - CronJob and RBAC for kernel indexer

## Prerequisites

- Kubernetes 1.20+ cluster
- Access to `harbor-cc.internal.ncsa.edu` NFS server from cluster nodes
- Nginx Ingress Controller (for Ingress)
- Cert-Manager (optional, for HTTPS/TLS)
- kubectl CLI configured to access your cluster

## Configuration

Before deploying, update the following:

### 1. Namespace (All Files)
Replace `default` with your target namespace:
```bash
kubectl create namespace icrn
# Then update all YAML files: namespace: default → namespace: icrn
```

### 2. Domain Name (02-web-deployment.yaml)
Update the Ingress host:
```yaml
- host: icrn-kernels.example.com  # Change to your domain
```

### 3. Image Registry (All Files)
Update Docker image references if using a private registry:
```yaml
image: hdpriest/icrn-kernel-webserver:latest  # Update as needed
image: hdpriest/icrn-kernel-indexer:latest    # Update as needed
```

### 4. Kernel Path (03-cronjob-indexer.yaml)
Verify the kernel root path matches your NFS structure:
```yaml
- name: KERNEL_ROOT
  value: "/data/Kernels"  # Adjust if needed
```

### 5. Storage Size (01-pv-pvc.yaml)
Update if your kernel repository is larger than 500Gi:
```yaml
capacity:
  storage: 500Gi  # Change as needed
```

## Deployment

### 1. Apply PV and PVC
```bash
kubectl apply -f 01-pv-pvc.yaml
```

Verify:
```bash
kubectl get pv,pvc
```

### 2. Apply Web Deployment
```bash
kubectl apply -f 02-web-deployment.yaml
```

Verify:
```bash
kubectl get deployment,service,ingress -l app=icrn-web
kubectl get pods -l app=icrn-web
```

### 3. Apply CronJob
```bash
kubectl apply -f 03-cronjob-indexer.yaml
```

Verify:
```bash
kubectl get cronjob,serviceaccount
```

### Deploy All at Once
```bash
kubectl apply -f .
```

## Verification

### Check Pod Status
```bash
kubectl get pods -l app=icrn-web
kubectl logs -l app=icrn-web
```

### Check CronJob Status
```bash
kubectl get cronjob icrn-kernel-indexer
kubectl get jobs -l app=icrn-kernel-manager
kubectl logs -l component=kernel-indexer
```

### Check PVC Mount
```bash
kubectl exec -it <pod-name> -- ls /data/
kubectl exec -it <pod-name> -- cat /data/collated_manifests.json | head
```

### Access the Web Interface
```bash
# Port forward to test
kubectl port-forward svc/icrn-web-service 8080:80

# Then visit http://localhost:8080
```

Or if Ingress is configured:
```
https://icrn-kernels.example.com
```

## Troubleshooting

### PVC Not Binding
```bash
kubectl describe pvc icrn-kernels-pvc
kubectl describe pv icrn-kernels-pv
```

Check that:
- NFS server is accessible from cluster nodes
- NFS path permissions allow read access

### CronJob Not Running
```bash
kubectl get cronjob icrn-kernel-indexer
kubectl describe cronjob icrn-kernel-indexer
```

Check that:
- ServiceAccount exists: `kubectl get sa icrn-indexer`
- RBAC bindings exist: `kubectl get clusterrolebinding | grep icrn`

### Web Pod Crashing
```bash
kubectl logs <pod-name>
```

Check:
- NFS is mounted and readable
- JSON files exist: `/data/collated_manifests.json`, `/data/package_index.json`
- Resource limits aren't too restrictive

### Missing Index Files
The CronJob generates these files:
- `/data/collated_manifests.json`
- `/data/package_index.json`

If missing after first run, check:
- CronJob Job output: `kubectl logs <job-pod-name>`
- NFS mount permissions on source
- Kernel directory structure at `/harbor/illinois/iccp/sw/icrn/dev/Kernels`

## CronJob Schedule

The kernel indexer runs on this schedule:
```
0 * * * *  (every hour at minute 0)
```

To change the schedule, edit `spec.schedule` in `03-cronjob-indexer.yaml`:
```yaml
schedule: "0 */6 * * *"  # Every 6 hours
schedule: "0 0 * * *"    # Daily at midnight
```

See [crontab.guru](https://crontab.guru) for schedule syntax.

## Resource Requirements

### Web Deployment
- **Requests**: 256Mi memory, 250m CPU
- **Limits**: 512Mi memory, 500m CPU

### Kernel Indexer CronJob
- **Requests**: 512Mi memory, 500m CPU
- **Limits**: 1Gi memory, 1000m CPU

Adjust based on your kernel repository size and cluster capacity.

## Scaling

### Scale Web Deployment
```bash
kubectl scale deployment icrn-web --replicas=3
```

Or edit the deployment:
```bash
kubectl edit deployment icrn-web
# Change spec.replicas
```

## Cleanup

To remove all components:
```bash
kubectl delete -f 03-cronjob-indexer.yaml
kubectl delete -f 02-web-deployment.yaml
kubectl delete -f 01-pv-pvc.yaml
```

## SSL/TLS Configuration

If using cert-manager for automatic certificate generation:

1. Install cert-manager:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. Create a ClusterIssuer:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

3. The Ingress will automatically request and manage certificates.

## References

- [Kubernetes PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [NFS Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)
