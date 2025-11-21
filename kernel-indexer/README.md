# Kernel Indexer Docker Container

This Docker container runs the kernel indexer script to index kernel repositories and generate JSON files for consumption by the web server and other services.

## Overview

The kernel indexer container:
- Indexes all kernels in the repository (creates `package_manifest.json` in each kernel directory)
- Collates results into two JSON files: `collated_manifests.json` and `package_index.json`
- Designed to run as a Kubernetes CronJob
- Implements fail-fast error handling (no retries within the same run)

## Building the Image

From the repository root:

```bash
docker build -t icrn-kernel-indexer:latest -f kernel-indexer/Dockerfile .
```

Or from the `kernel-indexer` directory:

```bash
docker build -t icrn-kernel-indexer:latest .
```

## Running Locally

### Basic Usage

```bash
docker run --rm \
  -v /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
  icrn-kernel-indexer:latest
```

### With Custom Configuration

```bash
docker run --rm \
  -v /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
  -e KERNEL_ROOT=/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
  -e LANGUAGE_FILTER=Python \
  -e LOG_LEVEL=DEBUG \
  icrn-kernel-indexer:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KERNEL_ROOT` | `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels` | Path to kernel repository root (must be read-write) |
| `OUTPUT_DIR` | (same as `KERNEL_ROOT`) | Directory where collated JSON files will be written |
| `LANGUAGE_FILTER` | (empty) | Optional: Filter by language (R, Python, etc.). If omitted, processes all languages |
| `LOG_LEVEL` | `INFO` | Logging verbosity: `DEBUG`, `INFO`, `WARN`, or `ERROR` |
| `ATOMIC_WRITES` | `true` | Use atomic writes for collated files (write to temp, then rename) |

## Kubernetes Deployment

### CronJob Example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: kernel-indexer
spec:
  schedule: "0 * * * *"  # Run hourly
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: kernel-indexer
            image: icrn-kernel-indexer:latest
            env:
            - name: KERNEL_ROOT
              value: "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels"
            # OUTPUT_DIR defaults to KERNEL_ROOT, so collated files go to repo root
            volumeMounts:
            - name: kernel-repo
              mountPath: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels
              # readOnly: false (default) - needed to write manifests
          volumes:
          - name: kernel-repo
            hostPath:
              path: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels
              type: Directory
              # Note: Directory type requires the path to exist - will fail if missing
              # This is intentional as this is core infrastructure that must be present
          restartPolicy: Never
          # Never retry on failure - fail fast and let cron schedule handle next attempt
```

### With Language Filter

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: kernel-indexer-python
spec:
  schedule: "0 2 * * *"  # Run daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: kernel-indexer
            image: icrn-kernel-indexer:latest
            env:
            - name: KERNEL_ROOT
              value: "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels"
            - name: LANGUAGE_FILTER
              value: "Python"
            volumeMounts:
            - name: kernel-repo
              mountPath: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels
          volumes:
          - name: kernel-repo
            hostPath:
              path: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels
              type: Directory
          restartPolicy: Never
```

## Output Files

The indexer creates the following files:

1. **Individual Manifests**: `$KERNEL_ROOT/{R,Python}/kernel_name/version/package_manifest.json`
   - One file per kernel version
   - Contains package list for that specific kernel

2. **Collated Files** (in `OUTPUT_DIR`, default: `KERNEL_ROOT`):
   - `collated_manifests.json` - Kernel-centric index (list of all kernels)
   - `package_index.json` - Package-centric index (which kernels contain each package)

## Error Handling

The container implements a **fail-fast** strategy:
- Exits immediately on any error (no retries)
- Exit codes indicate the type of failure:
  - `0`: Success
  - `1`: General error
  - `2`: Missing dependencies (jq, conda, or kernel_indexer)
  - `3`: Kernel root validation failed
  - `4`: Indexing phase failed
  - `5`: Collation phase failed
- The cron schedule handles retries (next scheduled run)

## Logging

Logs are written to stdout and stderr:
- **stdout**: Progress information, summary statistics
- **stderr**: Errors and warnings
- Format: `[TIMESTAMP] [LEVEL] MESSAGE`

Set `LOG_LEVEL=DEBUG` for verbose output during troubleshooting.

## Troubleshooting

### Container Fails to Start

**Check kernel repository mount:**
```bash
kubectl describe pod <pod-name>
# Look for volume mount errors
```

**Verify directory exists on host:**
```bash
ls -ld /sw/icrn/jupyter/icrn_ncsa_resources/Kernels
```

### Indexing Fails

**Check logs:**
```bash
kubectl logs <pod-name>
```

**Common issues:**
- Kernel repository not writable: Check permissions
- Missing conda environments: Verify kernel directories contain valid conda environments
- Network issues: If kernels are on network storage, check connectivity

### Collation Fails

**Check if indexing completed:**
```bash
# Look for package_manifest.json files in kernel directories
find /sw/icrn/jupyter/icrn_ncsa_resources/Kernels -name package_manifest.json | head -5
```

**Validate JSON files:**
```bash
jq '.' /sw/icrn/jupyter/icrn_ncsa_resources/Kernels/collated_manifests.json
jq '.' /sw/icrn/jupyter/icrn_ncsa_resources/Kernels/package_index.json
```

## Integration with Web Server

The web server container should mount the same kernel repository (read-only) and configure paths:

```yaml
env:
- name: COLLATED_MANIFESTS_PATH
  value: "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/collated_manifests.json"
- name: PACKAGE_INDEX_PATH
  value: "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/package_index.json"
```

Or mount the kernel repo to `/app/data` and use default paths.

## See Also

- [DESIGN.md](DESIGN.md) - Detailed design document
- [../kernel_indexer](../kernel_indexer) - The kernel indexer script itself
- [../web/](../web/) - Web server that consumes the generated files

