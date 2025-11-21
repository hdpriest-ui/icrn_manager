# Kernel Indexer Docker Container - Design Document

## Overview

This document describes the design and approach for creating a Docker container that runs the kernel indexer script to index kernel repositories and generate JSON files for consumption by the web server.

## Architecture

### Components

1. **Kernel Indexer Container** (this design)
   - Runs the `kernel_indexer` bash script
   - Indexes kernels from the repository
   - Generates `collated_manifests.json` and `package_index.json`
   - Designed to run as a Kubernetes CronJob

2. **Web Server Container** (existing)
   - Reads the generated JSON files
   - Serves them via REST API
   - Runs continuously

### Data Flow

```
Kernel Repository (/sw/icrn/jupyter/icrn_ncsa_resources/Kernels)
    ↓ (read-write mount)
Kernel Indexer Container (CronJob)
    ↓
    ├─→ Index all kernels
    │   └─→ Writes package_manifest.json to each kernel directory
    │       (e.g., R/kernel_name/version/package_manifest.json)
    └─→ Collate results
        └─→ Writes to kernel repo root:
            ├─→ collated_manifests.json
            └─→ package_index.json
    ↓
Kernel Repository (updated with manifests and collated files)
    ↓ (read-only or read-write mounts)
    ├─→ Web Server Container
    ├─→ Other Service Containers
    └─→ Other Endpoints
    All read the same files from kernel repository
```

## Directory Structure

```
kernel-indexer/
├── Dockerfile                 # Container definition
├── entrypoint.sh             # Main entrypoint script
├── README.md                 # Usage instructions
├── DESIGN.md                 # This file
└── .dockerignore             # Files to exclude from build
```

## Container Design

### Base Image

- **Base**: `continuumio/miniconda3` or `condaforge/mambaforge`
  - Provides `conda` command required by kernel_indexer
  - Includes Python for any future enhancements
  - Lightweight compared to full Anaconda

### Dependencies

1. **System packages**:
   - `jq` - JSON processing (required by kernel_indexer)
   - `bash` - Shell interpreter
   - `findutils` - For `find` command
   - `coreutils` - Standard Unix utilities

2. **Conda**:
   - Already included in base image
   - Used by kernel_indexer to query kernel environments

### File Organization

1. **kernel_indexer script**:
   - Copy from repo root (`../kernel_indexer`)
   - Place at `/usr/local/bin/kernel_indexer`
   - Make executable

2. **Entrypoint script**:
   - Handles execution logic
   - Manages error handling and logging
   - Configurable via environment variables

### Volume Mounts

The container will need access to:

1. **Kernel Repository** (read-write):
   - Mount: `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels`
   - Purpose: 
     - Source of kernels to index (read)
     - Write `package_manifest.json` files into each kernel directory (write)
     - Write `collated_manifests.json` and `package_index.json` to repo root (write)
   - **Critical**: Must be read-write to allow writing manifests back to kernel directories

## Execution Flow

### Entrypoint Script Logic

1. **Validation**:
   - Check that `KERNEL_ROOT` directory exists (fail if missing - this is core infrastructure)
   - Check that `KERNEL_ROOT` is mounted and accessible
   - Verify `KERNEL_ROOT` is writable (needed for writing manifests)
   - Verify `kernel_indexer` script is executable
   - Check that `jq` and `conda` are available
   - **Critical**: Do NOT attempt to create `KERNEL_ROOT` if missing - this indicates a serious infrastructure problem

2. **Configuration**:
   - Read `KERNEL_ROOT` from environment variable (default: `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels`)
   - Read `OUTPUT_DIR` from environment variable (default: `$KERNEL_ROOT` - write to kernel repo root)
   - Read `LANGUAGE_FILTER` from environment variable (optional, for filtering by language)
   - Determine if using separate output directory or kernel repo root

3. **Execution**:
   - Run: `kernel_indexer index --kernel-root $KERNEL_ROOT [--language $LANGUAGE_FILTER]`
     - This writes `package_manifest.json` into each kernel directory
     - Each manifest is written atomically by kernel_indexer script
   - Run: `kernel_indexer collate --kernel-root $KERNEL_ROOT --output-dir $OUTPUT_DIR [--language $LANGUAGE_FILTER]`
     - This creates `collated_manifests.json` and `package_index.json` in output directory
   - **Atomic Writes for Collated Files**:
     - Write to temporary files first: `collated_manifests.json.tmp` and `package_index.json.tmp`
     - Validate JSON structure using `jq`
     - Atomically rename: `mv collated_manifests.json.tmp collated_manifests.json`
     - This ensures other services never read partially-written files

4. **Error Handling** (Fail-Fast Strategy):
   - Exit immediately with non-zero code on any error
   - Do NOT retry or re-attempt within the same job run
   - Let the cron schedule trigger the next attempt (likely hourly)
   - Log errors to stderr for Kubernetes logging
   - Exit codes indicate the type of failure for debugging

5. **Output**:
   - Log progress to stdout
   - Log summary statistics (kernels indexed, packages found, etc.)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KERNEL_ROOT` | `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels` | Path to kernel repository root (must be read-write) |
| `OUTPUT_DIR` | (same as `KERNEL_ROOT`) | Directory where collated JSON files will be written. Defaults to kernel repo root. |
| `LANGUAGE_FILTER` | (empty) | Optional: Filter by language (R, Python, etc.) |
| `LOG_LEVEL` | `INFO` | Logging verbosity (DEBUG, INFO, WARN, ERROR) |
| `ATOMIC_WRITES` | `true` | Use atomic writes for collated files (write to temp, then rename) |

## Kubernetes Integration

### CronJob Configuration

**Option 1: Write to Kernel Repository Root (Recommended)**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: kernel-indexer
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

### Volume Strategy

**Primary Strategy: Kernel Repository as Single Source of Truth**

Since the indexer writes `package_manifest.json` files back into kernel directories AND creates collated files, the kernel repository becomes the single source of truth:

1. **Kernel Repository Mount**:
   - **Indexer**: Mount as read-write (to write manifests and collated files)
   - **Web Server**: Mount as read-only (only needs to read files)
   - **Other Services**: Mount as read-only or read-write depending on needs
   - All services read from the same location, ensuring consistency

2. **File Locations**:
   - Individual manifests: `$KERNEL_ROOT/R/kernel_name/version/package_manifest.json`
   - Collated files: `$KERNEL_ROOT/collated_manifests.json` and `$KERNEL_ROOT/package_index.json`

3. **Data Synchronization**:
   - No explicit sync needed - all services mount the same kernel repository
   - Files are written atomically (write to temp, then rename) to prevent partial reads
   - Web server's hourly auto-reload will pick up new files automatically


## Error Handling and Logging

### Fail-Fast Strategy

The indexer implements a **fail-fast** approach:
- **No retries**: On any error, the job exits immediately with a non-zero code
- **No re-attempts**: The job does not retry within the same execution
- **Cron-driven recovery**: The next scheduled run (likely hourly) will attempt indexing again
- **Immediate failure**: Validation errors cause immediate exit before any indexing begins
- **Partial failure handling**: If indexing fails partway through, exit immediately (don't attempt collation)

This approach ensures:
- Problems are surfaced immediately rather than masked by retries
- Resource usage is predictable (no runaway retry loops)
- The cron schedule provides natural backoff and retry mechanism
- Logs clearly show what failed without retry noise

### Exit Codes

- `0`: Success - indexing and collation completed successfully
- `1`: General error - check logs for details
- `2`: Missing dependencies - jq or conda not found
- `3`: Kernel root not accessible or missing (infrastructure problem)
- `4`: Indexing failed - one or more kernels failed to index
- `5`: Collation failed - indexing succeeded but collation failed

### Logging Strategy

- **stdout**: Progress information, summary statistics
- **stderr**: Errors, warnings
- **Format**: Structured logging with timestamps
- **Kubernetes**: Logs captured automatically via container logs
- **On failure**: Clear error messages indicating what failed and why

## Performance Considerations

1. **Indexing Time**:
   - Depends on number of kernels
   - Each kernel requires conda environment activation
   - Consider parallelization for large repositories (future enhancement)

2. **Resource Requirements**:
   - Memory: 2-4 GB (for conda operations)
   - CPU: 1-2 cores (mostly I/O bound)
   - Disk: Minimal (only script and temp files)

3. **Caching**:
   - Kernel indexer already creates `package_manifest.json` in each kernel directory
   - Re-indexing only updates changed kernels (if implemented)
   - Current design: Full re-index on each run

## Security Considerations

1. **Kernel Repository Write Access**:
   - Indexer container needs read-write access to write `package_manifest.json` files
   - Other containers (web server, etc.) can use read-only mounts
   - Consider file ownership and permissions to prevent unauthorized writes

2. **Atomic Writes**:
   - Use atomic write pattern for collated files (write to `.tmp`, then `mv` to final name)
   - Prevents other services from reading partially-written files
   - Entrypoint script should implement this if kernel_indexer doesn't

3. **File Permissions**:
   - Ensure indexer can write to kernel directories
   - Ensure web server and other services can read the files
   - Consider using group permissions or specific user IDs

4. **Container Security**:
   - Run as non-root user if possible (may require permission adjustments)
   - Minimal base image reduces attack surface
   - Limit container capabilities if possible

## Testing Strategy

1. **Local Testing**:
   - Build Docker image locally
   - Test with sample kernel repository
   - Verify JSON output format

2. **Integration Testing**:
   - Test with actual kernel repository
   - Verify web server can read generated files
   - Test error scenarios (missing kernels, invalid paths)

3. **Kubernetes Testing**:
   - Deploy as CronJob in test cluster
   - Verify scheduling and execution
   - Check logs and output files



## Implementation Checklist

- [ ] Create Dockerfile
- [ ] Create entrypoint.sh script
- [ ] Add error handling and logging
- [ ] Test locally with sample data
- [ ] Create README.md with usage instructions
- [ ] Add .dockerignore file
- [ ] Test Kubernetes CronJob deployment
- [ ] Document volume mounting strategy
- [ ] Add example Kubernetes manifests

## Data Sharing and Synchronization

### Challenge
Multiple containers and endpoints need access to:
1. Individual `package_manifest.json` files (in each kernel directory)
2. Collated files (`collated_manifests.json` and `package_index.json`)

### Solution: Kernel Repository as Single Source

**Write Strategy**:
- Indexer writes all files to kernel repository
- Individual manifests: `$KERNEL_ROOT/{R,Python}/kernel_name/version/package_manifest.json`
  - Written directly by `kernel_indexer index` command
  - Each file is written atomically (kernel_indexer uses `jq` to write JSON)
- Collated files: `$KERNEL_ROOT/collated_manifests.json` and `$KERNEL_ROOT/package_index.json`
  - Written by `kernel_indexer collate` command
  - Entrypoint script wraps this with additional atomic write protection

**Read Strategy**:
- All services mount the same kernel repository
- Web server: Read-only mount (configurable path via env vars)
- Other services: Read-only or read-write mounts as needed
- No explicit synchronization needed - all read from same source
- Filesystem-level consistency ensures all services see the same data

**Atomic Write Implementation** (in entrypoint.sh):

```bash
# Function to write collated file atomically
atomic_write_collated() {
    local output_file=$1
    local temp_file="${output_file}.tmp"
    
    # kernel_indexer writes to temp file first
    # Then we validate and rename atomically
    if [ -f "$temp_file" ]; then
        # Validate JSON
        if jq '.' "$temp_file" >/dev/null 2>&1; then
            # Atomic rename (single filesystem operation)
            mv "$temp_file" "$output_file"
            return 0
        else
            echo "ERROR: Invalid JSON in $temp_file" >&2
            rm -f "$temp_file"
            return 1
        fi
    fi
    return 1
}

# After collate command:
atomic_write_collated "$OUTPUT_DIR/collated_manifests.json"
atomic_write_collated "$OUTPUT_DIR/package_index.json"
```

**Alternative: Direct Atomic Write**:
- Modify entrypoint to redirect kernel_indexer output to temp files
- Validate and rename atomically
- Ensures no partial reads by other services

**Web Server Configuration**:
- Update web server to read from kernel repository mount
- Option 1: Mount kernel repo to `/app/data` and use default paths
- Option 2: Use environment variables:
  - `COLLATED_MANIFESTS_PATH=/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/collated_manifests.json`
  - `PACKAGE_INDEX_PATH=/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/package_index.json`

**Concurrency Considerations**:
- If multiple indexers could run simultaneously, add lock file mechanism
- Use `flock` or similar to ensure only one indexer runs at a time
- Lock file: `$KERNEL_ROOT/.indexing.lock`

## Questions to Resolve

1. **Output Location**:
   - Should output be written to kernel repo root or separate location?
   - **Resolution**: Default to kernel repo root (simpler, single source of truth). Allow override via `OUTPUT_DIR` if needed.

2. **Language Filtering**:
   - Should the cron job index all languages or be configurable?
   - **Resolution**: Make it configurable via `LANGUAGE_FILTER` env var, default to all languages

3. **Indexing Strategy**:
   - Full re-index every time or incremental?
   - **Resolution**: Start with full re-index (simpler), enhance later if needed

4. **Failure Handling**:
   - What happens if indexing fails partially?
   - **Resolution**: Fail fast - exit immediately on any error with non-zero code. No retries within the same job run. The cron schedule (likely hourly) will trigger the next attempt. Partial writes to individual manifests are acceptable (they'll be overwritten on next successful run). Kubernetes `restartPolicy: Never` ensures no automatic retries.

5. **Web Server Refresh**:
   - How does web server know to reload files?
   - **Resolution**: Web server already has hourly auto-reload, plus manual refresh endpoint. Files are written atomically so reloads are safe.

6. **File Locking**:
   - Do we need file locking during writes?
   - **Resolution**: Atomic writes (temp + rename) should be sufficient. If multiple indexers run concurrently, consider adding lock file mechanism.

