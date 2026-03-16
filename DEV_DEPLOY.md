# ICRN Kernel Manager — Dev Deployment Guide

Minimum steps to bring up or update the full stack in a development environment.

---

## Updating an Existing Deployment

Apply only the steps relevant to what changed. Steps are independent of each other unless noted.

### 1. Review Manifest Paths

Only needed if NFS topology or cluster hostnames have changed since the last deployment. See the [path reference table](#path-reference) below.

### 2. Apply Changed Kubernetes Manifests

Re-apply only the manifests that changed. `kubectl apply` is idempotent — unchanged resources are left alone.

```bash
# Web service image or configuration changed
kubectl apply -f kubernetes/02-web-deployment.yaml
kubectl -n kernels rollout status deployment/icrn-web

# Indexer image, schedule, or environment variables changed
kubectl apply -f kubernetes/03-cronjob-indexer.yaml
```

> **Note**: The PV/PVC (`01-pv-pvc.yaml`) and namespace (`00-namespace.yaml`) should not be re-applied unless storage configuration has explicitly changed. Re-applying a bound PVC can cause disruption.

### 3. Update CLI Scripts

Only needed if `icrn_manager` or `update_r_libs.sh` changed in this repo.

```bash
curl -fsSL https://raw.githubusercontent.com/ncsa/icrn_kernel_manager/main/icrn_manager \
  -o /sw/icrn/dev/bin/icrn_manager
curl -fsSL https://raw.githubusercontent.com/ncsa/icrn_kernel_manager/main/update_r_libs.sh \
  -o /sw/icrn/dev/bin/update_r_libs.sh
chmod +x /sw/icrn/dev/bin/icrn_manager
chmod +x /sw/icrn/dev/bin/update_r_libs.sh
```

### 4. Refresh the Kernel Catalog (Optional)

Only needed if the indexer image or logic changed and you want to verify the new output immediately rather than waiting for the next scheduled hourly run.

```bash
./kubernetes/kick-cronjob.sh
kubectl -n kernels logs -l component=kernel-indexer --follow
```

### 5. Verify

```bash
kubectl -n kernels port-forward svc/icrn-web-service 8080:80
curl http://localhost:8080/health
curl http://localhost:8080/api/languages
```

---

## Novel (First-Ever) Deployment

Steps must be followed **in order** — later steps depend on earlier ones completing successfully.

### Prerequisites

- `kubectl` configured against the target cluster (e.g. `cori-dev.ncsa.illinois.edu`)
- NFS share accessible from cluster nodes:
  - **Server**: `harbor-cc.internal.ncsa.edu`
  - **Export path**: `/harbor/illinois/iccp/sw/icrn/dev/kernels`
  - **Cluster-side mount**: `/sw/icrn/dev/kernels`
- Kernel directories already present on the NFS share (even an empty `R/` or `Python/` hierarchy is sufficient to bootstrap)

### 1. Review Manifest Paths

Review the [path reference table](#path-reference) below and update any values that differ from the dev defaults before applying any manifests.

### 2. Create the Namespace

All other resources depend on this namespace existing.

```bash
kubectl apply -f kubernetes/00-namespace.yaml
```

### 3. Create Storage

The PVC must reach `Bound` status before the web pod can start.

```bash
kubectl apply -f kubernetes/01-pv-pvc.yaml
kubectl -n kernels get pv,pvc   # wait for STATUS=Bound
```

### 4. Deploy Web Service and Indexer

With the namespace and PVC in place, apply the remaining manifests:

```bash
kubectl apply -f kubernetes/02-web-deployment.yaml
kubectl apply -f kubernetes/03-cronjob-indexer.yaml
```

Verify pods are running:

```bash
kubectl -n kernels get deployment,cronjob,serviceaccount
kubectl -n kernels rollout status deployment/icrn-web
```

### 5. Bootstrap the Kernel Catalog

The catalog JSON files do not yet exist on the NFS share. The web service will return empty results until the first indexer run completes. Kick it manually rather than waiting for the scheduled hour:

```bash
./kubernetes/kick-cronjob.sh
kubectl -n kernels logs -l component=kernel-indexer --follow
```

A successful run writes these files to `/sw/icrn/dev/kernels/`:

| File | Purpose |
|------|---------|
| `collated_manifests.json` | Kernel-centric index (read by web service) |
| `package_index.json` | Package-centric index (read by web service) |
| `icrn_kernel_catalog.json` | Flat catalog used by the CLI tool |

Individual `package_manifest.json` files are also written inside each kernel's versioned directory.

> The web service reloads catalog files from disk automatically every hour, or immediately via `POST /api/refresh`. No pod restart is needed.

### 6. Verify the Web Service

```bash
kubectl -n kernels port-forward svc/icrn-web-service 8080:80
curl http://localhost:8080/health
curl http://localhost:8080/api/languages
```

Or via Ingress once DNS resolves: `https://kernels.cori-dev.ncsa.illinois.edu`

### 7. Install the CLI Tool

```bash
curl -fsSL https://raw.githubusercontent.com/ncsa/icrn_kernel_manager/main/icrn_manager \
  -o /sw/icrn/dev/bin/icrn_manager
curl -fsSL https://raw.githubusercontent.com/ncsa/icrn_kernel_manager/main/update_r_libs.sh \
  -o /sw/icrn/dev/bin/update_r_libs.sh
chmod +x /sw/icrn/dev/bin/icrn_manager
chmod +x /sw/icrn/dev/bin/update_r_libs.sh
```

### 8. User Path Configuration (Per User, One-Time)

Each user accessing the dev environment for the first time must add the bin directory to their `PATH`. Add to `~/.bashrc` (or equivalent):

```bash
export PATH="/sw/icrn/dev/bin:$PATH"
source ~/.bashrc
```

Verify:

```bash
icrn_manager help
icrn_manager kernels available
```

#### R Users — `.Renviron` Setup

When a user activates an R kernel via `icrn_manager`, `update_r_libs.sh` configures `.Renviron` automatically. No manual editing is needed.

If a user needs to activate a kernel manually:

```bash
update_r_libs.sh ~/.Renviron \
  /sw/icrn/dev/kernels/R/<kernel_name>/<version> \
  ~/.icrn/icrn_kernels/<kernel_name>/overlay
```

---

## Path Reference

Values to review before applying manifests. Update if your dev environment differs from these defaults.

| File | Field | Dev Default | Change If… |
|------|-------|-------------|-----------|
| `kubernetes/01-pv-pvc.yaml` | `spec.nfs.server` | `harbor-cc.internal.ncsa.edu` | NFS server differs |
| `kubernetes/01-pv-pvc.yaml` | `spec.nfs.path` | `/harbor/illinois/iccp/sw/icrn/dev/kernels` | NFS export path differs |
| `kubernetes/02-web-deployment.yaml` | Ingress `host` | `kernels.cori-dev.ncsa.illinois.edu` | Deploying to a different hostname |
| `kubernetes/03-cronjob-indexer.yaml` | `KERNEL_ROOT` env var | `/app/data` | Container mount point changes |
| `kubernetes/03-cronjob-indexer.yaml` | `KERNEL_ROOT_HOST` env var | `/sw/icrn/dev/kernels` | NFS cluster-side mount path differs |
