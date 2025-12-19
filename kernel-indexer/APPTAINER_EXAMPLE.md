# Apptainer Usage Examples for Kernel Indexer

Pull down apptainer to CC:
```sh
apptainer pull icrn-kernel-indexer.sif docker://hdpriest0uiuc/icrn-kernel-indexer:latest
```

## Basic Usage

Run the indexer with default configuration (indexes all languages):

```bash
apptainer run --bind /sw/icrn/dev/kernels:/sw/icrn/dev/kernels \
    icrn-kernel-indexer.sif
```

## With Environment Variables

### Index Only Python Kernels

```bash
apptainer run \
    --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
    --env LANGUAGE_FILTER=Python \
    icrn-kernel-indexer.sif
```

### Index Only R Kernels

```bash
apptainer run \
    --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
    --env LANGUAGE_FILTER=R \
    icrn-kernel-indexer.sif
```

### With Debug Logging

```bash
apptainer run \
    --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
    --env LOG_LEVEL=DEBUG \
    icrn-kernel-indexer.sif
```

### Custom Output Directory

If you need to write collated files to a different location:

```bash
apptainer run \
    --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
    --bind /path/to/output:/app/data \
    --env OUTPUT_DIR=/app/data \
    icrn-kernel-indexer.sif
```

## Complete Example with All Options

```bash
apptainer run \
    --bind /sw/icrn/dev/kernels:/sw/icrn/dev/kernels \
    --env KERNEL_ROOT=/sw/icrn/dev/kernels \
    --env LANGUAGE_FILTER=Python \
    --env LOG_LEVEL=INFO \
    --env ATOMIC_WRITES=true \
    icrn-kernel-indexer.sif
```

## Notes

- The kernel repository must be bind-mounted with read-write access (default)
- The bind mount path inside the container matches the host path
- Environment variables can be set using `--env` or `-e`
- The SIF file should be in the current directory or provide the full path

